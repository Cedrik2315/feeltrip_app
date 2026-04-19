const functions = require("firebase-functions");
const { onCall, onRequest, HttpsError } = require("firebase-functions/v2/https");
const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
const axios = require("axios");
const { MercadoPagoConfig, Preference } = require("mercadopago");

admin.initializeApp();

// Configuracion de Mercado Pago SDK v2
const mpClient = new MercadoPagoConfig({ 
  accessToken: process.env.MP_ACCESS_TOKEN || functions.config().mercadopago?.token || "" 
});

function getMercadoPagoAccessToken() {
  const token = process.env.MP_ACCESS_TOKEN || functions.config().mercadopago?.token;
  if (!token) {
    throw new HttpsError(
      "failed-precondition",
      "Mercado Pago no esta configurado en Cloud Functions (MP_ACCESS_TOKEN)",
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
    throw new HttpsError("failed-precondition", "El booking ya no esta disponible para pago");
  }

  const expectedAmount = Number(booking.amount);
  if (!Number.isFinite(expectedAmount) || expectedAmount <= 0) {
    throw new HttpsError("failed-precondition", "El booking tiene un monto invalido");
  }

  if (Math.abs(expectedAmount - amount) > 0.01) {
    throw new HttpsError("failed-precondition", "El monto solicitado no coincide con la reserva");
  }

  const token = getMercadoPagoAccessToken();
  const appBaseUrl = functions.config().app?.base_url || "https://feeltrip.app";
  const webhookUrl = functions.config().app?.webhook_url || "https://us-central1-feeltrip-app.cloudfunctions.net/mercadoPagoWebhook";

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
      success: `feeltrip://payments/success?bookingId=${bookingId}`,
      failure: `feeltrip://payments/failure?bookingId=${bookingId}`,
      pending: `feeltrip://payments/pending?bookingId=${bookingId}`,
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
            console.error(`Alerta de Fraude: Booking ${bookingId} pago ${payment.transaction_amount} pero esperaba ${expectedAmount}`);
            return res.status(400).send("Amount mismatch");
          }

          await bookingRef.update({
            paymentId,
            status: "paid",
            paymentStatus: "approved",
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });

          // REGALO ESTRATEGICO: Otorgar 30 dias de trial Premium tras el primer pago
          const userRef = admin.firestore().collection("users").doc(userId);
          const trialEndDate = new Date();
          trialEndDate.setDate(trialEndDate.getDate() + 30);
          
          await userRef.update({
            premiumTrialActive: true,
            premiumTrialExpiresAt: admin.firestore.Timestamp.fromDate(trialEndDate),
            role: "explorer_premium_trial",
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });

          const userDoc = await admin.firestore().collection("users").doc(userId).get();
          const fcmToken = userDoc.data()?.fcmToken;

          if (fcmToken) {
            await admin.messaging().send({
              token: fcmToken,
              notification: {
                title: "Pago confirmado",
                body: "Tu reserva en FeelTrip ha sido confirmada con exito.",
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

/**
 * Crea una preferencia de pago basica
 * Llamada desde Flutter: PaymentRepository.createPreference
 */
exports.createMpPreference = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Debes estar logueado para realizar un pago.");
  }
  const data = request.data;
  try {
    const preference = new Preference(mpClient);
    const body = {
      items: [
        {
          id: data.id || "manual_payment",
          title: data.title || "Servicio FeelTrip",
          unit_price: Number(data.unitPrice),
          quantity: Number(data.quantity || 1),
          currency_id: data.currencyId || "CLP",
        }
      ],
      external_reference: request.auth.uid, 
      back_urls: {
        success: "feeltrip://payment/success",
        failure: "feeltrip://payment/error",
        pending: "feeltrip://payment/pending",
      },
      auto_return: "approved",
      notification_url: "https://us-central1-feeltrip-app.cloudfunctions.net/mercadoPagoWebhook",
    };
    const response = await preference.create({ body });
    return { 
      id: response.id,
      initPoint: response.init_point
    };
  } catch (error) {
    console.error("Error MP Preference:", error);
    throw new HttpsError("internal", "Error al generar la pasarela de Mercado Pago.");
  }
});

/**
 * Cronjob que se ejecuta cada hora para despachar notificaciones programadas
 * (ej: recordatorios de trial, engagement diferido).
 */
exports.dispatchScheduledNotifications = onSchedule("every 1 hours", async (event) => {
  const now = admin.firestore.Timestamp.now();
  const usersSnap = await admin.firestore().collection("users").get();

  let notificationsSent = 0;

  for (const userDoc of usersSnap.docs) {
    const userId = userDoc.id;
    const fcmToken = userDoc.data()?.fcmToken;
    if (!fcmToken) continue;

    const notifsRef = admin.firestore().collection("users").doc(userId).collection("notifications");
    const pendingSnap = await notifsRef
      .where("sent", "==", false)
      .where("scheduledFor", "<=", now)
      .get();

    for (const doc of pendingSnap.docs) {
      const data = doc.data();
      
      try {
        await admin.messaging().send({
          token: fcmToken,
          notification: {
            title: data.title || "FeelTrip",
            body: data.body || "",
          },
          data: {
            type: data.type || "scheduled",
            ...data.data, // Payload extendido si existe
          },
        });
        
        await doc.ref.update({ 
          sent: true, 
          sentAt: admin.firestore.FieldValue.serverTimestamp() 
        });
        notificationsSent++;
        console.log(`Notificacion programada enviada: ${doc.id} a ${userId}`);
      } catch (err) {
        console.error(`Error enviando notificacion programada a ${userId}:`, err.message);
      }
    }
  }
  console.log(`Dispatch de notificaciones programadas completado. Enviadas: ${notificationsSent}`);
});
