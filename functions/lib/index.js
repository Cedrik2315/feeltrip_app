"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.analyzeDiaryEntry = void 0;
const https_1 = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const app_1 = require("firebase-admin/app");
const firestore_1 = require("firebase-admin/firestore");
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
    var _a, _b, _c, _d, _e, _f, _g, _h, _j, _k;
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
    const model = getModelName();
    const apiVersion = ((_c = process.env.GEMINI_API_VERSION) === null || _c === void 0 ? void 0 : _c.trim()) || "v1";
    const url = `https://generativelanguage.googleapis.com/${apiVersion}/models/` +
        `${model}:generateContent?key=${apiKey}`;
    try {
        const response = await fetch(url, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                contents: [
                    {
                        parts: [
                            {
                                text: `Extrae las 3 emociones principales de: \"${normalizedText}\". ` +
                                    "Responde solo las emociones separadas por comas.",
                            },
                        ],
                    },
                ],
            }),
        });
        const data = (await response.json());
        if (!response.ok) {
            logger.error("Error en Gemini API", {
                status: response.status,
                message: (_d = data.error) === null || _d === void 0 ? void 0 : _d.message,
                uid: request.auth.uid,
            });
            throw new https_1.HttpsError("internal", "No se pudo procesar el análisis.");
        }
        const resultText = (_k = (_j = (_h = (_g = (_f = (_e = data.candidates) === null || _e === void 0 ? void 0 : _e[0]) === null || _f === void 0 ? void 0 : _f.content) === null || _g === void 0 ? void 0 : _g.parts) === null || _h === void 0 ? void 0 : _h[0]) === null || _j === void 0 ? void 0 : _j.text) === null || _k === void 0 ? void 0 : _k.trim();
        return { suggestions: resultText || "Sin resultados" };
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
//# sourceMappingURL=index.js.map