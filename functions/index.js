﻿const functions = require("firebase-functions");
const admin = require("firebase-admin");
const mercadopago = require("mercadopago");
const axios = require("axios");

admin.initializeApp();

// Configura tu Access Token de Mercado Pago en Firebase:
// firebase functions:config:set mercadopago.token="TU_ACCESS_TOKEN"
mercadopago.configure({
  access_token: functions.config().mercadopago.token,
});

/**
 * Crea una preferencia de pago en Mercado Pago.
 * Invocada desde el cliente via Firebase Functions Callable.
 */
exports.createMercadoPagoPreference = functions.https.onCall(async (data, context) => {
  // Verificación de autenticación
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Usuario no autenticado");
  }

  const { bookingId, amount, experienceId } = data;

  const preference = {
    items: [
      {
        id: experienceId,
        title: "Reserva de Experiencia FeelTrip",
        unit_price: amount,
        quantity: 1,
        currency_id: "ARS", // O la moneda que corresponda
      },
    ],
    external_reference: bookingId,
    notification_url: `https://${process.env.GCLOUD_PROJECT}.cloudfunctions.net/mercadopagoWebhook`, // Ya estaba dinámico, pero lo reitero para claridad
  };

  try {
    const response = await mercadopago.preferences.create(preference);
    return response.body; // Retorna id e init_point
  } catch (error) {
    console.error("Error creando preferencia MP:", error);
    throw new functions.https.HttpsError("internal", "No se pudo crear la preferencia");
  }
});

/**
 * Webhook que recibe la confirmación de pago de Mercado Pago.
 * Valida la transacción, actualiza Firestore y notifica al usuario.
 */
exports.mercadopagoWebhook = functions.https.onRequest(async (req, res) => {
  const { action, data, type } = req.body;

  if (type === "payment" && (action === "payment.created" || action === "payment.updated")) {
    const paymentId = data.id;
    const accessToken = functions.config().mercadopago.token;

    try {
      const mpResponse = await axios.get(
        `https://api.mercadopago.com/v1/payments/${paymentId}`,
        { headers: { Authorization: `Bearer ${accessToken}` } }
      );

      const payment = mpResponse.data;
      const bookingId = payment.external_reference;
      const status = payment.status;

      if (bookingId && status === "approved") {
        const bookingRef = admin.firestore().collection("bookings").doc(bookingId);
        const bookingDoc = await bookingRef.get();

        if (bookingDoc.exists && status === "approved") {
          const bookingData = bookingDoc.data();
          const userId = bookingData.userId;
          const expectedAmount = bookingData.amount;

          // VALIDACIÓN DE SEGURIDAD: Verificar que el monto pagado coincida con el esperado
          if (payment.transaction_amount < expectedAmount) {
            console.error(`Alerta de Fraude: Booking ${bookingId} pagó ${payment.transaction_amount} pero esperaba ${expectedAmount}`);
            return res.status(400).send("Amount mismatch");
          }

          // 1. Actualización atómica del booking
          await bookingRef.update({
            paymentId: paymentId,
            status: "paid",
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });

          // 2. Enviar notificación push al usuario
          const userDoc = await admin.firestore().collection("users").doc(userId).get();
          const fcmToken = userDoc.data()?.fcmToken;

          if (fcmToken) {
            await admin.messaging().send({
              token: fcmToken,
              notification: {
                title: "¡Pago Confirmado! ✈️",
                body: "Tu reserva en FeelTrip ha sido confirmada con éxito.",
              },
              data: { bookingId: bookingId, type: "booking_success" },
            });
          }
        } else {
          console.warn(`Webhook: Booking ${bookingId} no encontrado o ya procesado.`);
        }
      }
    } catch (error) {
      console.error("Error en webhook:", error.message);
      // Respondemos 500 para que Mercado Pago reintente el envío del webhook
      return res.status(500).send("Internal Server Error");
    }
  }
  // Respondemos 200 para confirmar recepción en casos que no requieren acción
  res.status(200).send("OK");
});

/**
 * BI Pipeline: Exporta eventos de negocio a una colección dedicada para analítica.
 * Se dispara automáticamente cuando un booking cambia a estado 'paid'.
 */
exports.exportBookingToBI = functions.firestore
  .document("bookings/{bookingId}")
  .onUpdate(async (change, context) => {
    const newValue = change.after.data();
    const previousValue = change.before.data();

    // Solo exportamos si el estado cambió a 'paid'
    if (newValue.status === "paid" && previousValue.status !== "paid") {
      console.log(`BI Pipeline: Exportando booking ${context.params.bookingId} a BI collection`);
      
      return admin.firestore().collection("bi_analytics_events").add({
        eventType: "conversion_success",
        amount: newValue.amount,
        experienceId: newValue.experienceId,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        userId: newValue.userId,
        bookingId: context.params.bookingId
      });
    }
    return null;
  });