"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.registerAffiliateConversion = exports.getCheckoutOrderStatus = exports.stripeWebhook = exports.createCheckoutSession = exports.createTripReview = exports.analyzeDiaryEntry = void 0;
const https_1 = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const app_1 = require("firebase-admin/app");
const auth_1 = require("firebase-admin/auth");
const firestore_1 = require("firebase-admin/firestore");
const generative_ai_1 = require("@google/generative-ai");
const stripe_1 = require("stripe");
(0, app_1.initializeApp)();
const db = (0, firestore_1.getFirestore)();
const RATE_LIMIT_WINDOW_MS = 60000;
const RATE_LIMIT_MAX_REQUESTS = 12;
const MAX_TEXT_LENGTH = 2000;
const DEFAULT_MODEL = "gemini-1.5-flash";
const MAX_REVIEW_COMMENT_LENGTH = 1000;
const DEFAULT_CURRENCY = "usd";
const MAX_CHECKOUT_ITEMS = 20;
const TAX_RATE_BPS = 1000; // 10.00%
const DEFAULT_CHECKOUT_SUCCESS_URL = "https://feeltrip.app/checkout/success";
const DEFAULT_CHECKOUT_CANCEL_URL = "https://feeltrip.app/checkout/cancel";
function getModelName() {
    var _a;
    return ((_a = process.env.GEMINI_MODEL) === null || _a === void 0 ? void 0 : _a.trim()) || DEFAULT_MODEL;
}
async function enforceRateLimit(userKey) {
    const bucket = Math.floor(Date.now() / RATE_LIMIT_WINDOW_MS);
    const docRef = db
        .collection("_rateLimits")
        .doc(`analyzeDiaryEntry_${userKey}_${bucket}`);
    await db.runTransaction(async (tx) => {
        var _a, _b;
        const snap = await tx.get(docRef);
        const currentCount = Number((_b = (_a = snap.data()) === null || _a === void 0 ? void 0 : _a.count) !== null && _b !== void 0 ? _b : 0);
        if (currentCount >= RATE_LIMIT_MAX_REQUESTS) {
            throw new https_1.HttpsError("resource-exhausted", "Límite de solicitudes alcanzado. Intenta nuevamente en un minuto.");
        }
        tx.set(docRef, {
            count: currentCount + 1,
            updatedAt: firestore_1.FieldValue.serverTimestamp(),
            expireAt: firestore_1.Timestamp.fromMillis((bucket + 2) * RATE_LIMIT_WINDOW_MS),
        }, { merge: true });
    });
}
exports.analyzeDiaryEntry = (0, https_1.onCall)({
    region: "us-east1",
    secrets: ["GEMINI_API_KEY"],
}, async (request) => {
    var _a, _b;
    if (!((_a = request.auth) === null || _a === void 0 ? void 0 : _a.uid)) {
        throw new https_1.HttpsError("unauthenticated", "Debes iniciar sesión para analizar el diario.");
    }
    const text = (_b = request.data) === null || _b === void 0 ? void 0 : _b.text;
    if (typeof text !== "string") {
        throw new https_1.HttpsError("invalid-argument", "El campo 'text' debe ser string.");
    }
    const normalizedText = text.trim();
    if (!normalizedText) {
        throw new https_1.HttpsError("invalid-argument", "Falta el texto a analizar.");
    }
    if (normalizedText.length > MAX_TEXT_LENGTH) {
        throw new https_1.HttpsError("invalid-argument", `El texto excede el máximo de ${MAX_TEXT_LENGTH} caracteres.`);
    }
    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey) {
        logger.error("GEMINI_API_KEY no está definido en el entorno.");
        throw new https_1.HttpsError("internal", "Servicio de IA no configurado.");
    }
    await enforceRateLimit(request.auth.uid);
    const genAI = new generative_ai_1.GoogleGenerativeAI(apiKey);
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
    }
    catch (error) {
        if (error instanceof https_1.HttpsError) {
            throw error;
        }
        logger.error("Error inesperado en analyzeDiaryEntry", {
            uid: request.auth.uid,
            error,
        });
        throw new https_1.HttpsError("internal", "Error inesperado al analizar el texto.");
    }
});
function extractBearerToken(authHeader) {
    if (!authHeader)
        return null;
    const match = authHeader.match(/^Bearer\s+(.+)$/i);
    return match ? match[1].trim() : null;
}
function getStripeClient() {
    var _a;
    const secret = (_a = process.env.STRIPE_SECRET_KEY) === null || _a === void 0 ? void 0 : _a.trim();
    if (!secret) {
        throw new Error("missing-stripe-secret-key");
    }
    return new stripe_1.default(secret, {
        apiVersion: "2023-10-16",
    });
}
function isValidHttpUrl(url) {
    try {
        const parsed = new URL(url);
        return parsed.protocol === "https:" || parsed.protocol === "http:";
    }
    catch (_a) {
        return false;
    }
}
function normalizeCurrency(value) {
    const raw = String(value !== null && value !== void 0 ? value : DEFAULT_CURRENCY).trim().toLowerCase();
    const normalized = raw || DEFAULT_CURRENCY;
    if (!/^[a-z]{3}$/.test(normalized)) {
        throw new Error("invalid-currency");
    }
    return normalized;
}
function normalizeCheckoutItems(rawItems) {
    if (!Array.isArray(rawItems) || rawItems.length === 0) {
        throw new Error("missing-items");
    }
    if (rawItems.length > MAX_CHECKOUT_ITEMS) {
        throw new Error("too-many-items");
    }
    return rawItems.map((item) => {
        var _a;
        const tripId = String((_a = item === null || item === void 0 ? void 0 : item.tripId) !== null && _a !== void 0 ? _a : "").trim();
        const quantity = Number(item === null || item === void 0 ? void 0 : item.quantity);
        if (!tripId) {
            throw new Error("invalid-trip-id");
        }
        if (!Number.isInteger(quantity) || quantity < 1 || quantity > 99) {
            throw new Error("invalid-quantity");
        }
        return { tripId, quantity };
    });
}
async function resolveCheckoutItem(item) {
    var _a, _b, _c;
    const tripSnap = await db.collection("trips").doc(item.tripId).get();
    if (!tripSnap.exists) {
        throw new Error("trip-not-found");
    }
    const tripData = (_a = tripSnap.data()) !== null && _a !== void 0 ? _a : {};
    const title = String((_c = (_b = tripData.title) !== null && _b !== void 0 ? _b : tripData.name) !== null && _c !== void 0 ? _c : "Experiencia FeelTrip").trim();
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
async function verifyHttpAuth(req) {
    const token = extractBearerToken(req.header("authorization"));
    if (!token) {
        throw new Error("missing-bearer-token");
    }
    return (0, auth_1.getAuth)().verifyIdToken(token);
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
exports.createTripReview = (0, https_1.onRequest)({ region: "us-east1" }, async (req, res) => {
    var _a, _b, _c, _d;
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
        decodedToken = await (0, auth_1.getAuth)().verifyIdToken(token);
    }
    catch (error) {
        logger.warn("JWT inválido en createTripReview", { error });
        res.status(401).json({ error: "invalid-token" });
        return;
    }
    const pathTripMatch = req.path.match(/^\/?trips\/([^/]+)\/reviews\/?$/);
    const tripIdFromPath = pathTripMatch === null || pathTripMatch === void 0 ? void 0 : pathTripMatch[1];
    const tripIdRaw = tripIdFromPath || ((_a = req.body) === null || _a === void 0 ? void 0 : _a.tripId);
    if (typeof tripIdRaw !== "string" || !tripIdRaw.trim()) {
        res.status(400).json({ error: "invalid-trip-id" });
        return;
    }
    const tripId = tripIdRaw.trim();
    const rating = Number((_b = req.body) === null || _b === void 0 ? void 0 : _b.rating);
    if (!Number.isFinite(rating) || rating < 1 || rating > 5) {
        res.status(400).json({ error: "invalid-rating" });
        return;
    }
    const comment = String((_d = (_c = req.body) === null || _c === void 0 ? void 0 : _c.comment) !== null && _d !== void 0 ? _d : "").trim();
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
            createdAt: firestore_1.FieldValue.serverTimestamp(),
        });
        logger.info("Review creada", { tripId, reviewId: reviewRef.id, authUserId });
        res.status(201).json({
            ok: true,
            reviewId: reviewRef.id,
            tripId,
            userId: authUserId,
        });
    }
    catch (error) {
        logger.error("Error creando review", { tripId, authUserId, error });
        res.status(500).json({ error: "internal-error" });
    }
});
/**
 * Checkout productivo:
 * - Calcula montos server-side usando precio oficial de "trips/{tripId}".
 * - Crea orden en Firestore con estado pending.
 * - Crea Stripe Checkout Session y devuelve URL de pago.
 */
exports.createCheckoutSession = (0, https_1.onRequest)({
    region: "us-east1",
    secrets: ["STRIPE_SECRET_KEY"],
}, async (req, res) => {
    var _a, _b, _c, _d, _e, _f, _g, _h, _j;
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
    let decodedToken;
    try {
        decodedToken = await verifyHttpAuth(req);
    }
    catch (error) {
        logger.warn("Auth invalida en createCheckoutSession", { error });
        res.status(401).json({ error: "invalid-token" });
        return;
    }
    let currency;
    let normalizedItems;
    try {
        currency = normalizeCurrency((_a = req.body) === null || _a === void 0 ? void 0 : _a.currency);
        normalizedItems = normalizeCheckoutItems((_b = req.body) === null || _b === void 0 ? void 0 : _b.items);
    }
    catch (error) {
        res.status(400).json({ error: error.message });
        return;
    }
    const successUrlRaw = String((_e = (_d = (_c = req.body) === null || _c === void 0 ? void 0 : _c.successUrl) !== null && _d !== void 0 ? _d : process.env.CHECKOUT_SUCCESS_URL) !== null && _e !== void 0 ? _e : DEFAULT_CHECKOUT_SUCCESS_URL).trim();
    const cancelUrlRaw = String((_h = (_g = (_f = req.body) === null || _f === void 0 ? void 0 : _f.cancelUrl) !== null && _g !== void 0 ? _g : process.env.CHECKOUT_CANCEL_URL) !== null && _h !== void 0 ? _h : DEFAULT_CHECKOUT_CANCEL_URL).trim();
    if (!isValidHttpUrl(successUrlRaw) || !isValidHttpUrl(cancelUrlRaw)) {
        res.status(400).json({ error: "invalid-success-or-cancel-url" });
        return;
    }
    try {
        const resolvedItems = await Promise.all(normalizedItems.map((item) => resolveCheckoutItem(item)));
        const subtotalCents = resolvedItems.reduce((acc, item) => acc + item.subtotalCents, 0);
        const taxCents = Math.round((subtotalCents * TAX_RATE_BPS) / 10000);
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
            createdAt: firestore_1.FieldValue.serverTimestamp(),
            updatedAt: firestore_1.FieldValue.serverTimestamp(),
        });
        const stripe = getStripeClient();
        const stripeLineItems = resolvedItems.map((item) => ({
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
        await orderRef.set({
            stripeSessionId: session.id,
            stripePaymentIntentId: (_j = session.payment_intent) !== null && _j !== void 0 ? _j : null,
            updatedAt: firestore_1.FieldValue.serverTimestamp(),
        }, { merge: true });
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
    }
    catch (error) {
        logger.error("Error creando checkout session", { error, uid: decodedToken.uid });
        res.status(500).json({ error: "internal-error" });
    }
});
/**
 * Webhook Stripe:
 * - Verifica firma del evento.
 * - Marca orden pagada/fallida/cancelada en Firestore.
 */
exports.stripeWebhook = (0, https_1.onRequest)({
    region: "us-east1",
    secrets: ["STRIPE_SECRET_KEY", "STRIPE_WEBHOOK_SECRET"],
}, async (req, res) => {
    var _a, _b, _c, _d, _e, _f, _g, _h;
    if (req.method !== "POST") {
        res.status(405).send("method-not-allowed");
        return;
    }
    const signature = req.header("stripe-signature");
    if (!signature) {
        res.status(400).send("missing-stripe-signature");
        return;
    }
    const webhookSecret = (_a = process.env.STRIPE_WEBHOOK_SECRET) === null || _a === void 0 ? void 0 : _a.trim();
    if (!webhookSecret) {
        logger.error("Falta STRIPE_WEBHOOK_SECRET");
        res.status(500).send("missing-webhook-secret");
        return;
    }
    let event;
    try {
        const stripe = getStripeClient();
        event = stripe.webhooks.constructEvent(req.rawBody, signature, webhookSecret);
    }
    catch (error) {
        logger.warn("Firma webhook invalida", { error });
        res.status(400).send("invalid-signature");
        return;
    }
    try {
        const eventType = event.type;
        if (eventType === "checkout.session.completed") {
            const session = event.data.object;
            const orderId = (_c = (_b = session.metadata) === null || _b === void 0 ? void 0 : _b.orderId) !== null && _c !== void 0 ? _c : session.client_reference_id;
            if (orderId) {
                await db.collection("orders").doc(orderId).set({
                    status: "paid",
                    paidAt: firestore_1.FieldValue.serverTimestamp(),
                    stripeSessionId: session.id,
                    stripePaymentIntentId: (_d = session.payment_intent) !== null && _d !== void 0 ? _d : null,
                    lastStripeEventId: event.id,
                    updatedAt: firestore_1.FieldValue.serverTimestamp(),
                }, { merge: true });
                logger.info("Orden marcada como pagada", { orderId, eventId: event.id });
            }
        }
        else if (eventType === "checkout.session.expired") {
            const session = event.data.object;
            const orderId = (_f = (_e = session.metadata) === null || _e === void 0 ? void 0 : _e.orderId) !== null && _f !== void 0 ? _f : session.client_reference_id;
            if (orderId) {
                await db.collection("orders").doc(orderId).set({
                    status: "expired",
                    stripeSessionId: session.id,
                    lastStripeEventId: event.id,
                    updatedAt: firestore_1.FieldValue.serverTimestamp(),
                }, { merge: true });
            }
        }
        else if (eventType === "checkout.session.async_payment_failed") {
            const session = event.data.object;
            const orderId = (_h = (_g = session.metadata) === null || _g === void 0 ? void 0 : _g.orderId) !== null && _h !== void 0 ? _h : session.client_reference_id;
            if (orderId) {
                await db.collection("orders").doc(orderId).set({
                    status: "payment_failed",
                    stripeSessionId: session.id,
                    lastStripeEventId: event.id,
                    updatedAt: firestore_1.FieldValue.serverTimestamp(),
                }, { merge: true });
            }
        }
        res.status(200).json({ received: true });
    }
    catch (error) {
        logger.error("Error procesando webhook Stripe", { error, eventId: event.id });
        res.status(500).send("internal-error");
    }
});
/**
 * Consulta de estado de orden para cliente autenticado.
 */
exports.getCheckoutOrderStatus = (0, https_1.onRequest)({ region: "us-east1" }, async (req, res) => {
    var _a, _b, _c, _d, _e, _f;
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
    let decodedToken;
    try {
        decodedToken = await verifyHttpAuth(req);
    }
    catch (error) {
        logger.warn("Auth invalida en getCheckoutOrderStatus", { error });
        res.status(401).json({ error: "invalid-token" });
        return;
    }
    const orderId = String((_b = (_a = req.query.orderId) !== null && _a !== void 0 ? _a : req.query.id) !== null && _b !== void 0 ? _b : "").trim();
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
        const orderData = (_c = orderSnap.data()) !== null && _c !== void 0 ? _c : {};
        if (orderData.userId !== decodedToken.uid) {
            res.status(403).json({ error: "forbidden" });
            return;
        }
        res.status(200).json({
            ok: true,
            orderId,
            status: (_d = orderData.status) !== null && _d !== void 0 ? _d : "unknown",
            totalCents: (_e = orderData.totalCents) !== null && _e !== void 0 ? _e : null,
            currency: (_f = orderData.currency) !== null && _f !== void 0 ? _f : null,
        });
    }
    catch (error) {
        logger.error("Error consultando estado de orden", { error, orderId, uid: decodedToken.uid });
        res.status(500).json({ error: "internal-error" });
    }
});
/**
 * Postback de conversión de afiliados:
 * - Busca el booking intent por clickId.
 * - Marca conversión atribuida cuando encuentra coincidencia.
 * Seguridad:
 * - Requiere header x-affiliate-token con valor de AFFILIATE_POSTBACK_TOKEN.
 */
exports.registerAffiliateConversion = (0, https_1.onRequest)({
    region: "us-east1",
    secrets: ["AFFILIATE_POSTBACK_TOKEN"],
}, async (req, res) => {
    var _a, _b, _c, _d, _e, _f, _g, _h, _j, _k, _l, _m, _o, _p, _q, _r;
    if (req.method !== "POST") {
        res.status(405).json({ error: "method-not-allowed" });
        return;
    }
    const expectedToken = (_a = process.env.AFFILIATE_POSTBACK_TOKEN) === null || _a === void 0 ? void 0 : _a.trim();
    const providedToken = String((_b = req.header("x-affiliate-token")) !== null && _b !== void 0 ? _b : "").trim();
    if (!expectedToken || providedToken !== expectedToken) {
        res.status(401).json({ error: "invalid-postback-token" });
        return;
    }
    const clickId = String((_d = (_c = req.body) === null || _c === void 0 ? void 0 : _c.clickId) !== null && _d !== void 0 ? _d : "").trim();
    if (!clickId) {
        res.status(400).json({ error: "missing-click-id" });
        return;
    }
    const providerId = String((_f = (_e = req.body) === null || _e === void 0 ? void 0 : _e.providerId) !== null && _f !== void 0 ? _f : "").trim().toLowerCase();
    const externalBookingId = String((_h = (_g = req.body) === null || _g === void 0 ? void 0 : _g.externalBookingId) !== null && _h !== void 0 ? _h : "").trim();
    const currency = String((_k = (_j = req.body) === null || _j === void 0 ? void 0 : _j.currency) !== null && _k !== void 0 ? _k : "usd").trim().toLowerCase();
    const amount = Number((_m = (_l = req.body) === null || _l === void 0 ? void 0 : _l.amount) !== null && _m !== void 0 ? _m : 0);
    const commission = Number((_p = (_o = req.body) === null || _o === void 0 ? void 0 : _o.commission) !== null && _p !== void 0 ? _p : 0);
    const rawStatus = String((_r = (_q = req.body) === null || _q === void 0 ? void 0 : _q.status) !== null && _r !== void 0 ? _r : "converted").trim().toLowerCase();
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
                createdAt: firestore_1.FieldValue.serverTimestamp(),
                updatedAt: firestore_1.FieldValue.serverTimestamp(),
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
                convertedAt: firestore_1.FieldValue.serverTimestamp(),
            },
            status: conversionStatus === "cancelled" ? "conversion_cancelled" : "converted_attributed",
            updatedAt: firestore_1.FieldValue.serverTimestamp(),
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
    }
    catch (error) {
        logger.error("Error registrando conversion afiliado", { clickId, error });
        res.status(500).json({ error: "internal-error" });
    }
});
//# sourceMappingURL=index.js.map