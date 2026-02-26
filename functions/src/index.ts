import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import { initializeApp } from "firebase-admin/app";
import { getFirestore, FieldValue, Timestamp } from "firebase-admin/firestore";
import { GoogleGenerativeAI } from "@google/generative-ai";

initializeApp();
const db = getFirestore();

const RATE_LIMIT_WINDOW_MS = 60_000;
const RATE_LIMIT_MAX_REQUESTS = 12;
const MAX_TEXT_LENGTH = 2_000;
const DEFAULT_MODEL = "gemini-1.5-flash";

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
      
      // Limpiamos la respuesta para asegurar que sea JSON válido
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
