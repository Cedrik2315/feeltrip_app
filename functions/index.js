const functions = require("firebase-functions");
const { onCall, onRequest, HttpsError } = require("firebase-functions/v2/https");
const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp();

function getMercadoPagoAccessToken() {
  const token = functions.config().mercadopago?.token;
  if (!token) {
    throw new HttpsError(
      "failed-precondition",
      "Mercado Pago no está configurado en Functions config",
    );
  }
  return token;
}

exports.toggleStoryLike = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Usuario no autenticado");
  }

  const storyId = request.data?.storyId;
  if (!storyId || typeof storyId !== "string") {
    throw new HttpsError("invalid-argument", "storyId es requerido");
  }

  const userId = request.auth.uid;
  const storyRef = admin.firestore().collection("stories").doc(storyId);

  return admin.firestore().runTransaction(async (transaction) => {
    const snapshot = await transaction.get(storyRef);
    if (!snapshot.exists) {
      throw new HttpsError("not-found", "Historia no encontrada");
    }

    const story = snapshot.data() || {};
    const likedBy = Array.isArray(story.likedBy) ? [...story.likedBy] : [];
    const alreadyLiked = likedBy.includes(userId);
    const updatedLikedBy = alreadyLiked
      ? likedBy.filter((id) => id !== userId)
      : [...likedBy, userId];

    transaction.update(storyRef, {
      likedBy: updatedLikedBy,
      likes: updatedLikedBy.length,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
      liked: !alreadyLiked,
      likes: updatedLikedBy.length,
    };
  });
});

exports.createMercadoPagoPreference = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Usuario no autenticado");
  }

  const bookingId = request.data?.bookingId;
  const experienceId = request.data?.experienceId || request.data?.destinationId || null;
  const amount = Number(request.data?.amount);
  const title = typeof request.data?.title === "string" && request.data.title.trim().length > 0
    ? request.data.title.trim()
    : "FeelTrip Booking";
  const purpose = typeof request.data?.purpose === "string" && request.data.purpose.trim().length > 0
    ? request.data.purpose.trim()
    : "booking";
  const currency = typeof request.data?.currency === "string" && request.data.currency.trim().length > 0
    ? request.data.currency.trim().toUpperCase()
    : "ARS";

  if (!bookingId || typeof bookingId !== "string") {
    throw new HttpsError("invalid-argument", "bookingId es requerido");
  }

  if (!Number.isFinite(amount) || amount <= 0) {
    throw new HttpsError("invalid-argument", "amount debe ser mayor a 0");
  }

  const bookingRef = admin.firestore().collection("bookings").doc(bookingId);
  const bookingDoc = await bookingRef.get();
  if (!bookingDoc.exists) {
    throw new HttpsError("not-found", "Booking no encontrado");
  }

  const booking = bookingDoc.data() || {};
  if (booking.userId !== request.auth.uid) {
    throw new HttpsError("permission-denied", "El booking no pertenece al usuario autenticado");
  }

  if (booking.status !== "pending") {
    throw new HttpsError("failed-precondition", "El booking ya no está disponible para pago");
  }

  const expectedAmount = Number(booking.amount);
  if (!Number.isFinite(expectedAmount) || expectedAmount <= 0) {
    throw new HttpsError("failed-precondition", "El booking tiene un monto inválido");
  }

  if (Math.abs(expectedAmount - amount) > 0.01) {
    throw new HttpsError("failed-precondition", "El monto solicitado no coincide con la reserva");
  }

  const token = getMercadoPagoAccessToken();
  const appBaseUrl = functions.config().app?.base_url || "https://feeltrip.app";
  const webhookUrl = functions.config().app?.webhook_url || null;

  const preferencePayload = {
    items: [
      {
        title,
        quantity: 1,
        currency_id: currency,
        unit_price: Number(amount.toFixed(2)),
      },
    ],
    external_reference: bookingId,
    metadata: {
      bookingId,
      userId: request.auth.uid,
      experienceId,
      purpose,
    },
    back_urls: {
      success: `${appBaseUrl}/payments/success?bookingId=${bookingId}`,
      failure: `${appBaseUrl}/payments/failure?bookingId=${bookingId}`,
      pending: `${appBaseUrl}/payments/pending?bookingId=${bookingId}`,
    },
    auto_return: "approved",
  };

  if (webhookUrl) {
    preferencePayload.notification_url = webhookUrl;
  }

  try {
    const response = await axios.post(
      "https://api.mercadopago.com/checkout/preferences",
      preferencePayload,
      {
        headers: {
          Authorization: `Bearer ${token}`,
          "Content-Type": "application/json",
        },
      },
    );

    const preference = response.data || {};

    await bookingRef.update({
      paymentProvider: "mercadopago",
      preferenceId: preference.id || null,
      paymentStatus: "pending",
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
      preferenceId: preference.id || "",
      initPoint: preference.init_point || "",
      externalReference: bookingId,
      provider: "mercadopago",
      status: "pending",
      bookingId,
    };
  } catch (error) {
    const details = error.response?.data || error.message || "unknown_error";
    console.error("Error creating Mercado Pago preference:", details);
    throw new HttpsError(
      "internal",
      "No se pudo generar la preferencia de pago",
      details,
    );
  }
});

const mercadoPagoWebhookHandler = onRequest(async (req, res) => {
  const { action, data, type } = req.body;

  if (type === "payment" && (action === "payment.created" || action === "payment.updated")) {
    const paymentId = data.id;
    const accessToken = getMercadoPagoAccessToken();

    try {
      const mpResponse = await axios.get(
        `https://api.mercadopago.com/v1/payments/${paymentId}`,
        { headers: { Authorization: `Bearer ${accessToken}` } },
      );

      const payment = mpResponse.data;
      const bookingId = payment.external_reference;
      const status = payment.status;

      if (bookingId && status === "approved") {
        const bookingRef = admin.firestore().collection("bookings").doc(bookingId);
        const bookingDoc = await bookingRef.get();

        if (bookingDoc.exists) {
          const bookingData = bookingDoc.data() || {};
          const userId = bookingData.userId;
          const expectedAmount = bookingData.amount;

          if (payment.transaction_amount < expectedAmount) {
            console.error(`Alerta de Fraude: Booking ${bookingId} pagó ${payment.transaction_amount} pero esperaba ${expectedAmount}`);
            return res.status(400).send("Amount mismatch");
          }

          await bookingRef.update({
            paymentId,
            status: "paid",
            paymentStatus: "approved",
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });

          const userDoc = await admin.firestore().collection("users").doc(userId).get();
          const fcmToken = userDoc.data()?.fcmToken;

          if (fcmToken) {
            await admin.messaging().send({
              token: fcmToken,
              notification: {
                title: "Pago confirmado",
                body: "Tu reserva en FeelTrip ha sido confirmada con éxito.",
              },
              data: { bookingId, type: "booking_success" },
            });
          }
        } else {
          console.warn(`Webhook: Booking ${bookingId} no encontrado o ya procesado.`);
        }
      }
    } catch (error) {
      console.error("Error en webhook:", error.message);
      return res.status(500).send("Internal Server Error");
    }
  }
  return res.status(200).send("OK");
});

exports.mercadopagoWebhook = mercadoPagoWebhookHandler;
exports.mercadoPagoWebhook = mercadoPagoWebhookHandler;

exports.revenueCatWebhook = onRequest(async (req, res) => {
  console.log("RevenueCat webhook recibido", {
    method: req.method,
    headers: req.headers,
  });
  return res.status(200).send("OK");
});

exports.exportBookingToBI = onDocumentUpdated("bookings/{bookingId}", async (event) => {
  const newValue = event.data?.after?.data();
  const previousValue = event.data?.before?.data();

  if (!newValue || !previousValue) {
    return null;
  }

  if (newValue.status === "paid" && previousValue.status !== "paid") {
    console.log(`BI Pipeline: Exportando booking ${event.params.bookingId} a BI collection`);

    return admin.firestore().collection("bi_analytics_events").add({
      eventType: "conversion_success",
      amount: newValue.amount,
      experienceId: newValue.experienceId,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      userId: newValue.userId,
      bookingId: event.params.bookingId,
    });
  }
  return null;
});
