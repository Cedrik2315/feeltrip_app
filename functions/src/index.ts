import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import { initializeApp } from "firebase-admin/app";
import { getFirestore, FieldValue, Timestamp } from "firebase-admin/firestore";

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

    const model = getModelName();
    const apiVersion = process.env.GEMINI_API_VERSION?.trim() || "v1";
    const url =
      `https://generativelanguage.googleapis.com/${apiVersion}/models/` +
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
                  text:
                    `Extrae las 3 emociones principales de: \"${normalizedText}\". ` +
                    "Responde solo las emociones separadas por comas.",
                },
              ],
            },
          ],
        }),
      });

      const data = (await response.json()) as {
        error?: { message?: string };
        candidates?: Array<{
          content?: { parts?: Array<{ text?: string }> };
        }>;
      };

      if (!response.ok) {
        logger.error("Error en Gemini API", {
          status: response.status,
          message: data.error?.message,
          uid: request.auth.uid,
        });
        throw new HttpsError("internal", "No se pudo procesar el análisis.");
      }

      const resultText = data.candidates?.[0]?.content?.parts?.[0]?.text?.trim();
      return { suggestions: resultText || "Sin resultados" };
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
