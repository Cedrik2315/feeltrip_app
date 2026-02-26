"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.analyzeDiaryEntry = void 0;
const https_1 = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const app_1 = require("firebase-admin/app");
const firestore_1 = require("firebase-admin/firestore");
const generative_ai_1 = require("@google/generative-ai");
(0, app_1.initializeApp)();
const db = (0, firestore_1.getFirestore)();
const RATE_LIMIT_WINDOW_MS = 60000;
const RATE_LIMIT_MAX_REQUESTS = 12;
const MAX_TEXT_LENGTH = 2000;
const DEFAULT_MODEL = "gemini-1.5-flash";
function getModelName() {
    var _a;
    return ((_a = process.env.GEMINI_MODEL) === null || _a === void 0 ? void 0 : _a.trim()) || DEFAULT_MODEL;
}
async function enforceRateLimit(userKey) {
    const bucket = Math.floor(Date.now() / RATE_LIMIT_WINDOW_MS);
    const docRef = db
        .collection("_rateLimits")
        .doc("analyzeDiaryEntry_" + userKey + "_" + bucket);
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
    var _a, _b, _c, _d;
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
        throw new https_1.HttpsError("invalid-argument", "El texto excede el máximo de " + MAX_TEXT_LENGTH + " caracteres.");
    }
    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey) {
        logger.error("GEMINI_API_KEY no está definido en el entorno.");
        throw new https_1.HttpsError("internal", "Servicio de IA no configurado.");
    }
    await enforceRateLimit(request.auth.uid);
    const genAI = new generative_ai_1.GoogleGenerativeAI(apiKey);
    const model = genAI.getGenerativeModel({ model: getModelName() });
    const prompt = "Analiza el siguiente diario emocional: \"" + normalizedText + "\". \n    Responde ÚNICAMENTE en formato JSON con esta estructura:\n    {\n      \"emociones\": [\"emocion1\", \"emocion2\"],\n      \"destino_sugerido\": \"Nombre de ciudad o lugar\",\n      \"explicacion\": \"Una frase corta de por qué este lugar ayudará a su estado emocional\"\n    }";
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
            error: error,
        });
        throw new https_1.HttpsError("internal", "Error inesperado al analizar el texto.");
    }
});
//# sourceMappingURL=index.js.map
