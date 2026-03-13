import { onCall, onRequest, HttpsError } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import { initializeApp } from "firebase-admin/app";
import { DecodedIdToken, getAuth } from "firebase-admin/auth";
import { getFirestore, FieldValue, Timestamp } from "firebase-admin/firestore";
import type { CollectionReference, Query } from "firebase-admin/firestore";
import { GoogleGenerativeAI } from "@google/generative-ai";
import Stripe from "stripe";
import * as crypto from "crypto";
import { Request } from "express";

initializeApp();
const db = getFirestore();

const RATE_LIMIT_WINDOW_MS = 60_000;
const RATE_LIMIT_MAX_REQUESTS = 12;
const MAX_TEXT_LENGTH = 2_000;
const DEFAULT_MODEL = "gemini-1.5-flash";
const MAX_REVIEW_COMMENT_LENGTH = 1_000;
const DEFAULT_CURRENCY = "usd";
const MAX_CHECKOUT_ITEMS = 20;
const TAX_RATE_BPS = 1_000; // 10.00%
const DEFAULT_CHECKOUT_SUCCESS_URL = "https://feeltrip.app/checkout/success";
const DEFAULT_CHECKOUT_CANCEL_URL = "https://feeltrip.app/checkout/cancel";

function base64UrlToBuffer(input: string): Buffer {
  const normalized = input.replace(/-/g, "+").replace(/_/g, "/");
  const padded = normalized.padEnd(
    normalized.length + ((4 - (normalized.length % 4)) % 4),
    "=",
  );
  return Buffer.from(padded, "base64");
}

function parseFacebookSignedRequest(
  signedRequest: string,
  appSecret: string,
): Record<string, unknown> | null {
  const parts = signedRequest.split(".");
  if (parts.length !== 2) return null;

  const [encodedSig, encodedPayload] = parts;
  const sig = base64UrlToBuffer(encodedSig);

  const expectedSig = crypto
    .createHmac("sha256", appSecret)
    .update(encodedPayload)
    .digest();

  if (
    sig.length !== expectedSig.length ||
    !crypto.timingSafeEqual(sig, expectedSig)
  ) {
    return null;
  }

  const payloadBuffer = base64UrlToBuffer(encodedPayload);
  try {
    const payload = JSON.parse(payloadBuffer.toString("utf8"));
    return payload as Record<string, unknown>;
  } catch {
    return null;
  }
}

async function deleteCollectionInBatches(
  collectionRef: CollectionReference,
  batchSize = 400,
): Promise<void> {
  while (true) {
    const snap = await collectionRef.limit(batchSize).get();
    if (snap.empty) return;

    const batch = db.batch();
    for (const doc of snap.docs) {
      batch.delete(doc.ref);
    }
    await batch.commit();
  }
}

async function deleteQueryInBatches(
  query: Query,
  batchSize = 400,
): Promise<void> {
  while (true) {
    const snap = await query.limit(batchSize).get();
    if (snap.empty) return;

    const batch = db.batch();
    for (const doc of snap.docs) {
      batch.delete(doc.ref);
    }
    await batch.commit();
  }
}

async function deleteUserDataByUid(uid: string): Promise<void> {
  const userRef = db.collection("users").doc(uid);

  const knownSubcollections = [
    "private",
    "cartItems",
    "diaryEntries",
    "achievements",
    "trips",
    "impactMetrics",
    "quizResults",
    "stories",
  ];

  for (const sub of knownSubcollections) {
    await deleteCollectionInBatches(userRef.collection(sub));
  }

  // Delete public stories created by this user (and their comments)
  const publicStories = await db
    .collection("stories")
    .where("userId", "==", uid)
    .get();

  for (const storyDoc of publicStories.docs) {
    await deleteCollectionInBatches(storyDoc.ref.collection("comments"));
    await storyDoc.ref.delete();
  }

  // Delete comments authored by this user across all stories
  await deleteQueryInBatches(db.collectionGroup("comments").where("userId", "==", uid));

  // Finally remove the user document and auth user
  await userRef.delete().catch(() => undefined);
  await getAuth().deleteUser(uid).catch(() => undefined);
}

type CheckoutItemInput = {
  tripId: string;
  quantity: number;
};

type ResolvedCheckoutItem = {
  tripId: string;
  title: string;
  quantity: number;
  unitAmountCents: number;
  subtotalCents: number;
};

function getModelName(): string {
  return process.env.GEMINI_MODEL?.trim() || DEFAULT_MODEL;
}

async function enforceRateLimit(userKey: string): Promise<void> {
  const bucket = Math.floor(Date.now() / RATE_LIMIT_WINDOW_MS);
  const docRef = db
    .collection("_rateLimits")
    .doc(`analyzeDiaryEntry_${userKey}_${bucket}`);

  await db.runTransaction(async (tx) => {
    const snap = await tx.get(docRef);
    const currentCount = Number(snap.data()?.count ?? 0);

    if (currentCount >= RATE_LIMIT_MAX_REQUESTS) {
      throw new HttpsError(
        "resource-exhausted",
        "Límite de solicitudes alcanzado. Intenta nuevamente en un minuto.",
      );
    }

    tx.set(
      docRef,
      {
        count: currentCount + 1,
        updatedAt: FieldValue.serverTimestamp(),
        expireAt: Timestamp.fromMillis((bucket + 2) * RATE_LIMIT_WINDOW_MS),
      },
      { merge: true },
    );
  });
}

export const analyzeDiaryEntry = onCall(
  {
    region: "us-east1",
    secrets: ["GEMINI_API_KEY"],
  },
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError(
        "unauthenticated",
        "Debes iniciar sesión para analizar el diario.",
      );
    }

    const text = request.data?.text;
    if (typeof text !== "string") {
      throw new HttpsError("invalid-argument", "El campo 'text' debe ser string.");
    }

    const normalizedText = text.trim();
    if (!normalizedText) {
      throw new HttpsError("invalid-argument", "Falta el texto a analizar.");
    }

    if (normalizedText.length > MAX_TEXT_LENGTH) {
      throw new HttpsError(
        "invalid-argument",
        `El texto excede el máximo de ${MAX_TEXT_LENGTH} caracteres.`,
      );
    }

    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey) {
      logger.error("GEMINI_API_KEY no está definido en el entorno.");
      throw new HttpsError("internal", "Servicio de IA no configurado.");
    }

    await enforceRateLimit(request.auth.uid);

    const genAI = new GoogleGenerativeAI(apiKey);
    const model = genAI.getGenerativeModel({ model: getModelName() });

    const prompt = `Analiza el siguiente diario emocional: "${normalizedText}".
    Responde ÚNICAMENTE en formato JSON con esta estructura:
    {
      "emociones": ["emocion1", "emocion2"],
      "destino_sugerido": "Nombre de ciudad o lugar",
      "explicacion": "Una frase corta de por qué este lugar ayudará a su estado emocional"
    }`;

    try {
      const result = await model.generateContent(prompt);
      const response = await result.response;

      let jsonText = response.text();
      const jsonMatch = jsonText.match(/\{[\s\S]*\}/);
      jsonText = jsonMatch ? jsonMatch[0] : jsonText;

      return JSON.parse(jsonText);
    } catch (error) {
      if (error instanceof HttpsError) {
        throw error;
      }
      logger.error("Error inesperado en analyzeDiaryEntry", {
        uid: request.auth.uid,
        error,
      });
      throw new HttpsError("internal", "Error inesperado al analizar el texto.");
    }
  },
);

function extractBearerToken(authHeader: string | undefined): string | null {
  if (!authHeader) return null;
  const match = authHeader.match(/^Bearer\s+(.+)$/i);
  return match ? match[1].trim() : null;
}

function getStripeClient(): Stripe {
  const secret = process.env.STRIPE_SECRET_KEY?.trim();
  if (!secret) {
    throw new Error("missing-stripe-secret-key");
  }
  return new Stripe(secret, {
    apiVersion: "2023-10-16" as Stripe.LatestApiVersion,
  });
}

function isValidHttpUrl(url: string): boolean {
  try {
    const parsed = new URL(url);
    return parsed.protocol === "https:" || parsed.protocol === "http:";
  } catch {
    return false;
  }
}

function normalizeCurrency(value: unknown): string {
  const raw = String(value ?? DEFAULT_CURRENCY).trim().toLowerCase();
  const normalized = raw || DEFAULT_CURRENCY;
  if (!/^[a-z]{3}$/.test(normalized)) {
    throw new Error("invalid-currency");
  }
  return normalized;
}

function normalizeCheckoutItems(rawItems: unknown): CheckoutItemInput[] {
  if (!Array.isArray(rawItems) || rawItems.length === 0) {
    throw new Error("missing-items");
  }
  if (rawItems.length > MAX_CHECKOUT_ITEMS) {
    throw new Error("too-many-items");
  }

  return rawItems.map((item) => {
    const tripId = String((item as { tripId?: unknown })?.tripId ?? "").trim();
    const quantity = Number((item as { quantity?: unknown })?.quantity);
    if (!tripId) {
      throw new Error("invalid-trip-id");
    }
    if (!Number.isInteger(quantity) || quantity < 1 || quantity > 99) {
      throw new Error("invalid-quantity");
    }
    return { tripId, quantity };
  });
}

async function resolveCheckoutItem(item: CheckoutItemInput): Promise<ResolvedCheckoutItem> {
  const tripSnap = await db.collection("trips").doc(item.tripId).get();
  if (!tripSnap.exists) {
    throw new Error("trip-not-found");
  }

  const tripData = tripSnap.data() ?? {};
  const title = String(tripData.title ?? tripData.name ?? "Experiencia FeelTrip").trim();
  const price = Number(tripData.price);
  if (!Number.isFinite(price) || price <= 0) {
    throw new Error("invalid-trip-price");
  }

  const unitAmountCents = Math.round(price * 100);
  const subtotalCents = unitAmountCents * item.quantity;

  return {
    tripId: item.tripId,
    title: title || "Experiencia FeelTrip",
    quantity: item.quantity,
    unitAmountCents,
    subtotalCents,
  };
}

async function verifyHttpAuth(req: Request): Promise<DecodedIdToken> {
  const token = extractBearerToken(req.header("authorization"));
  if (!token) {
    throw new Error("missing-bearer-token");
  }
  return getAuth().verifyIdToken(token);
}

/**
 * Endpoint seguro para reviews.
 * Espera:
 * - POST /trips/{id}/reviews (vía rewrite/proxy)
 *   o body con { tripId, rating, comment }.
 * Seguridad:
 * - Ignora userId/userName del body.
 * - Usa userId del JWT verificado.
 */
export const createTripReview = onRequest(
  { region: "us-east1" },
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).json({ error: "method-not-allowed" });
      return;
    }

    const token = extractBearerToken(req.header("authorization"));
    if (!token) {
      res.status(401).json({ error: "missing-bearer-token" });
      return;
    }

    let decodedToken;
    try {
      decodedToken = await getAuth().verifyIdToken(token);
    } catch (error) {
      logger.warn("JWT inválido en createTripReview", { error });
      res.status(401).json({ error: "invalid-token" });
      return;
    }

    const pathTripMatch = req.path.match(/^\/?trips\/([^/]+)\/reviews\/?$/);
    const tripIdFromPath = pathTripMatch?.[1];
    const tripIdRaw = tripIdFromPath || req.body?.tripId;

    if (typeof tripIdRaw !== "string" || !tripIdRaw.trim()) {
      res.status(400).json({ error: "invalid-trip-id" });
      return;
    }
    const tripId = tripIdRaw.trim();

    const rating = Number(req.body?.rating);
    if (!Number.isFinite(rating) || rating < 1 || rating > 5) {
      res.status(400).json({ error: "invalid-rating" });
      return;
    }

    const comment = String(req.body?.comment ?? "").trim();
    if (!comment) {
      res.status(400).json({ error: "missing-comment" });
      return;
    }
    if (comment.length > MAX_REVIEW_COMMENT_LENGTH) {
      res.status(400).json({ error: "comment-too-long" });
      return;
    }

    const authUserId = decodedToken.uid;
    const authUserName = (decodedToken.name || "").trim() || "Usuario";

    try {
      const reviewRef = db.collection("trips").doc(tripId).collection("reviews").doc();

      await reviewRef.set({
        id: reviewRef.id,
        tripId,
        userId: authUserId,
        userName: authUserName,
        rating,
        comment,
        createdAt: FieldValue.serverTimestamp(),
      });

      logger.info("Review creada", { tripId, reviewId: reviewRef.id, authUserId });

      res.status(201).json({
        ok: true,
        reviewId: reviewRef.id,
        tripId,
        userId: authUserId,
      });
    } catch (error) {
      logger.error("Error creando review", { tripId, authUserId, error });
      res.status(500).json({ error: "internal-error" });
    }
  },
);

/**
 * Checkout productivo:
 * - Calcula montos server-side usando precio oficial de "trips/{tripId}".
 * - Crea orden en Firestore con estado pending.
 * - Crea Stripe Checkout Session y devuelve URL de pago.
 */
export const createCheckoutSession = onRequest(
  {
    region: "us-east1",
    secrets: ["STRIPE_SECRET_KEY"],
  },
  async (req, res) => {
    res.set("Access-Control-Allow-Origin", "*");
    res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");
    if (req.method === "OPTIONS") {
      res.status(204).send("");
      return;
    }
    if (req.method !== "POST") {
      res.status(405).json({ error: "method-not-allowed" });
      return;
    }

    let decodedToken: DecodedIdToken;
    try {
      decodedToken = await verifyHttpAuth(req);
    } catch (error) {
      logger.warn("Auth invalida en createCheckoutSession", { error });
      res.status(401).json({ error: "invalid-token" });
      return;
    }

    let currency: string;
    let normalizedItems: CheckoutItemInput[];
    try {
      currency = normalizeCurrency(req.body?.currency);
      normalizedItems = normalizeCheckoutItems(req.body?.items);
    } catch (error) {
      res.status(400).json({ error: (error as Error).message });
      return;
    }

    const successUrlRaw = String(
      req.body?.successUrl ?? process.env.CHECKOUT_SUCCESS_URL ?? DEFAULT_CHECKOUT_SUCCESS_URL,
    ).trim();
    const cancelUrlRaw = String(
      req.body?.cancelUrl ?? process.env.CHECKOUT_CANCEL_URL ?? DEFAULT_CHECKOUT_CANCEL_URL,
    ).trim();

    if (!isValidHttpUrl(successUrlRaw) || !isValidHttpUrl(cancelUrlRaw)) {
      res.status(400).json({ error: "invalid-success-or-cancel-url" });
      return;
    }

    try {
      const resolvedItems = await Promise.all(normalizedItems.map((item) => resolveCheckoutItem(item)));
      const subtotalCents = resolvedItems.reduce((acc, item) => acc + item.subtotalCents, 0);
      const taxCents = Math.round((subtotalCents * TAX_RATE_BPS) / 10_000);
      const totalCents = subtotalCents + taxCents;

      if (totalCents <= 0) {
        res.status(400).json({ error: "invalid-total-amount" });
        return;
      }

      const orderRef = db.collection("orders").doc();
      await orderRef.set({
        id: orderRef.id,
        userId: decodedToken.uid,
        status: "pending",
        paymentProvider: "stripe",
        currency,
        items: resolvedItems,
        subtotalCents,
        taxCents,
        totalCents,
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });

      const stripe = getStripeClient();
      const stripeLineItems: Stripe.Checkout.SessionCreateParams.LineItem[] = resolvedItems.map((item) => ({
        quantity: item.quantity,
        price_data: {
          currency,
          unit_amount: item.unitAmountCents,
          product_data: {
            name: item.title,
            metadata: { tripId: item.tripId },
          },
        },
      }));

      if (taxCents > 0) {
        stripeLineItems.push({
          quantity: 1,
          price_data: {
            currency,
            unit_amount: taxCents,
            product_data: {
              name: "Impuestos FeelTrip",
            },
          },
        });
      }

      const session = await stripe.checkout.sessions.create({
        mode: "payment",
        line_items: stripeLineItems,
        success_url: `${successUrlRaw}?orderId=${orderRef.id}&session_id={CHECKOUT_SESSION_ID}`,
        cancel_url: `${cancelUrlRaw}?orderId=${orderRef.id}`,
        client_reference_id: orderRef.id,
        metadata: {
          orderId: orderRef.id,
          userId: decodedToken.uid,
        },
      });

      await orderRef.set(
        {
          stripeSessionId: session.id,
          stripePaymentIntentId: session.payment_intent ?? null,
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );

      logger.info("Checkout session creada", {
        orderId: orderRef.id,
        userId: decodedToken.uid,
        stripeSessionId: session.id,
      });

      res.status(201).json({
        ok: true,
        orderId: orderRef.id,
        checkoutUrl: session.url,
        amountCents: totalCents,
        currency,
      });
    } catch (error) {
      logger.error("Error creando checkout session", { error, uid: decodedToken.uid });
      res.status(500).json({ error: "internal-error" });
    }
  },
);

/**
 * Webhook Stripe:
 * - Verifica firma del evento.
 * - Marca orden pagada/fallida/cancelada en Firestore.
 */
export const stripeWebhook = onRequest(
  {
    region: "us-east1",
    secrets: ["STRIPE_SECRET_KEY", "STRIPE_WEBHOOK_SECRET"],
  },
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).send("method-not-allowed");
      return;
    }

    const signature = req.header("stripe-signature");
    if (!signature) {
      res.status(400).send("missing-stripe-signature");
      return;
    }

    const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET?.trim();
    if (!webhookSecret) {
      logger.error("Falta STRIPE_WEBHOOK_SECRET");
      res.status(500).send("missing-webhook-secret");
      return;
    }

    let event: Stripe.Event;
    try {
      const stripe = getStripeClient();
      event = stripe.webhooks.constructEvent(req.rawBody, signature, webhookSecret);
    } catch (error) {
      logger.warn("Firma webhook invalida", { error });
      res.status(400).send("invalid-signature");
      return;
    }

    try {
      const eventType = event.type;
      if (eventType === "checkout.session.completed") {
        const session = event.data.object as Stripe.Checkout.Session;
        const orderId = session.metadata?.orderId ?? session.client_reference_id;
        if (orderId) {
          await db.collection("orders").doc(orderId).set(
            {
              status: "paid",
              paidAt: FieldValue.serverTimestamp(),
              stripeSessionId: session.id,
              stripePaymentIntentId: session.payment_intent ?? null,
              lastStripeEventId: event.id,
              updatedAt: FieldValue.serverTimestamp(),
            },
            { merge: true },
          );
          logger.info("Orden marcada como pagada", { orderId, eventId: event.id });
        }
      } else if (eventType === "checkout.session.expired") {
        const session = event.data.object as Stripe.Checkout.Session;
        const orderId = session.metadata?.orderId ?? session.client_reference_id;
        if (orderId) {
          await db.collection("orders").doc(orderId).set(
            {
              status: "expired",
              stripeSessionId: session.id,
              lastStripeEventId: event.id,
              updatedAt: FieldValue.serverTimestamp(),
            },
            { merge: true },
          );
        }
      } else if (eventType === "checkout.session.async_payment_failed") {
        const session = event.data.object as Stripe.Checkout.Session;
        const orderId = session.metadata?.orderId ?? session.client_reference_id;
        if (orderId) {
          await db.collection("orders").doc(orderId).set(
            {
              status: "payment_failed",
              stripeSessionId: session.id,
              lastStripeEventId: event.id,
              updatedAt: FieldValue.serverTimestamp(),
            },
            { merge: true },
          );
        }
      }

      res.status(200).json({ received: true });
    } catch (error) {
      logger.error("Error procesando webhook Stripe", { error, eventId: event.id });
      res.status(500).send("internal-error");
    }
  },
);

/**
 * Consulta de estado de orden para cliente autenticado.
 */
export const getCheckoutOrderStatus = onRequest(
  { region: "us-east1" },
  async (req, res) => {
    res.set("Access-Control-Allow-Origin", "*");
    res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");
    if (req.method === "OPTIONS") {
      res.status(204).send("");
      return;
    }
    if (req.method !== "GET") {
      res.status(405).json({ error: "method-not-allowed" });
      return;
    }

    let decodedToken: DecodedIdToken;
    try {
      decodedToken = await verifyHttpAuth(req);
    } catch (error) {
      logger.warn("Auth invalida en getCheckoutOrderStatus", { error });
      res.status(401).json({ error: "invalid-token" });
      return;
    }

    const orderId = String(req.query.orderId ?? req.query.id ?? "").trim();
    if (!orderId) {
      res.status(400).json({ error: "missing-order-id" });
      return;
    }

    try {
      const orderSnap = await db.collection("orders").doc(orderId).get();
      if (!orderSnap.exists) {
        res.status(404).json({ error: "order-not-found" });
        return;
      }
      const orderData = orderSnap.data() ?? {};
      if (orderData.userId !== decodedToken.uid) {
        res.status(403).json({ error: "forbidden" });
        return;
      }

      res.status(200).json({
        ok: true,
        orderId,
        status: orderData.status ?? "unknown",
        totalCents: orderData.totalCents ?? null,
        currency: orderData.currency ?? null,
      });
    } catch (error) {
      logger.error("Error consultando estado de orden", { error, orderId, uid: decodedToken.uid });
      res.status(500).json({ error: "internal-error" });
    }
  },
);

/**
 * Postback de conversión de afiliados:
 * - Busca el booking intent por clickId.
 * - Marca conversión atribuida cuando encuentra coincidencia.
 * Seguridad:
 * - Requiere header x-affiliate-token con valor de AFFILIATE_POSTBACK_TOKEN.
 */
export const registerAffiliateConversion = onRequest(
  {
    region: "us-east1",
    secrets: ["AFFILIATE_POSTBACK_TOKEN"],
  },
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).json({ error: "method-not-allowed" });
      return;
    }

    const expectedToken = process.env.AFFILIATE_POSTBACK_TOKEN?.trim();
    const providedToken = String(req.header("x-affiliate-token") ?? "").trim();
    if (!expectedToken || providedToken !== expectedToken) {
      res.status(401).json({ error: "invalid-postback-token" });
      return;
    }

    const clickId = String(req.body?.clickId ?? "").trim();
    if (!clickId) {
      res.status(400).json({ error: "missing-click-id" });
      return;
    }

    const providerId = String(req.body?.providerId ?? "").trim().toLowerCase();
    const externalBookingId = String(req.body?.externalBookingId ?? "").trim();
    const currency = String(req.body?.currency ?? "usd").trim().toLowerCase();
    const amount = Number(req.body?.amount ?? 0);
    const commission = Number(req.body?.commission ?? 0);
    const rawStatus = String(req.body?.status ?? "converted").trim().toLowerCase();
    const conversionStatus = rawStatus || "converted";

    try {
      const intentsSnap = await db
        .collectionGroup("bookingIntents")
        .where("clickId", "==", clickId)
        .limit(1)
        .get();

      if (intentsSnap.empty) {
        await db.collection("affiliateConversionsUnmatched").doc(clickId).set({
          clickId,
          providerId,
          externalBookingId,
          amount: Number.isFinite(amount) ? amount : null,
          commission: Number.isFinite(commission) ? commission : null,
          currency,
          status: conversionStatus,
          createdAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        }, { merge: true });

        res.status(202).json({
          ok: true,
          attributed: false,
          reason: "click-id-not-found",
        });
        return;
      }

      const intentRef = intentsSnap.docs[0].ref;
      await intentRef.set({
        conversion: {
          attributed: true,
          providerId,
          externalBookingId,
          amount: Number.isFinite(amount) ? amount : null,
          commission: Number.isFinite(commission) ? commission : null,
          currency,
          status: conversionStatus,
          convertedAt: FieldValue.serverTimestamp(),
        },
        status: conversionStatus === "cancelled" ? "conversion_cancelled" : "converted_attributed",
        updatedAt: FieldValue.serverTimestamp(),
      }, { merge: true });

      logger.info("Conversion afiliado atribuida", {
        clickId,
        providerId,
        externalBookingId,
        docPath: intentRef.path,
      });

      res.status(200).json({
        ok: true,
        attributed: true,
        clickId,
      });
    } catch (error) {
      logger.error("Error registrando conversion afiliado", { clickId, error });
      res.status(500).json({ error: "internal-error" });
    }
  },
);

export const facebookDataDeletionCallback = onRequest(
  {
    region: "us-east1",
    secrets: ["FACEBOOK_APP_SECRET"],
  },
  async (req, res) => {
    const secret = process.env.FACEBOOK_APP_SECRET?.trim();
    if (!secret) {
      res.status(500).json({ error: "FACEBOOK_APP_SECRET_not_configured" });
      return;
    }

    const body = req.body as unknown;
    let signedRequest: string | undefined;

    if (typeof (body as any)?.signed_request === "string") {
      signedRequest = (body as any).signed_request as string;
    } else if (typeof req.rawBody === "string") {
      const params = new URLSearchParams(req.rawBody);
      signedRequest = params.get("signed_request") ?? undefined;
    } else if (req.rawBody instanceof Buffer) {
      const raw = req.rawBody.toString("utf8");
      const params = new URLSearchParams(raw);
      signedRequest = params.get("signed_request") ?? undefined;
    }

    if (!signedRequest) {
      res.status(400).json({ error: "missing_signed_request" });
      return;
    }

    const payload = parseFacebookSignedRequest(signedRequest, secret);
    const facebookUserId = (payload?.user_id as string | undefined)?.trim();

    if (!facebookUserId) {
      res.status(400).json({ error: "invalid_signed_request" });
      return;
    }

    const confirmationCode = crypto.randomBytes(16).toString("hex");
    const projectId = process.env.GCLOUD_PROJECT || "unknown-project";
    const statusUrl = `https://us-east1-${projectId}.cloudfunctions.net/facebookDataDeletionStatus?code=${confirmationCode}`;

    await db
      .collection("_facebookDataDeletion")
      .doc(confirmationCode)
      .set({
        facebookUserId,
        status: "received",
        requestedAt: FieldValue.serverTimestamp(),
      });

    try {
      const userSnap = await db
        .collection("users")
        .where("facebookUserId", "==", facebookUserId)
        .limit(1)
        .get();

      if (userSnap.empty) {
        await db
          .collection("_facebookDataDeletion")
          .doc(confirmationCode)
          .set(
            {
              status: "pending_manual",
              completedAt: FieldValue.serverTimestamp(),
            },
            { merge: true },
          );
        res.json({ url: statusUrl, confirmation_code: confirmationCode });
        return;
      }

      const uid = userSnap.docs[0].id;
      await deleteUserDataByUid(uid);

      await db
        .collection("_facebookDataDeletion")
        .doc(confirmationCode)
        .set(
          {
            status: "complete",
            uid,
            completedAt: FieldValue.serverTimestamp(),
          },
          { merge: true },
        );
    } catch (e) {
      logger.error("Facebook data deletion failed", e);
      await db
        .collection("_facebookDataDeletion")
        .doc(confirmationCode)
        .set(
          {
            status: "error",
            error: String(e),
            completedAt: FieldValue.serverTimestamp(),
          },
          { merge: true },
        );
    }

    res.json({ url: statusUrl, confirmation_code: confirmationCode });
  },
);

export const facebookDataDeletionStatus = onRequest(
  {
    region: "us-east1",
  },
  async (req, res) => {
    const code = (req.query.code as string | undefined)?.trim();
    if (!code) {
      res.status(400).json({ error: "missing_code" });
      return;
    }

    const snap = await db.collection("_facebookDataDeletion").doc(code).get();
    if (!snap.exists) {
      res.status(404).json({ error: "not_found" });
      return;
    }

    res.json({
      confirmation_code: code,
      ...snap.data(),
    });
  },
);
