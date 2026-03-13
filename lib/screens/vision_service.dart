import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class VisionService {
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  /// Generates a poetic message from an image using the Gemini vision model.
  Future<String?> getPoeticMessageFromImage(File image) async {
    if (_apiKey.isEmpty) {
      debugPrint('CRITICAL: GEMINI_API_KEY is not set in the .env file');
      return 'Error: La clave de API para el servicio de visión no está configurada.';
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-pro-vision',
        apiKey: _apiKey,
      );

      final prompt = TextPart(
          "Eres un poeta viajero. Describe esta imagen con un mensaje breve, inspirador y poético sobre el asombro de viajar y descubrir el mundo. Evita descripciones literales. Enfócate en la emoción y la sensación del momento.");

      final imageBytes = await image.readAsBytes();
      final imagePart = DataPart('image/jpeg', imageBytes);

      final response = await model.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      return response.text;
    } catch (e) {
      debugPrint('Error calling Gemini Vision API: $e');
      return 'No se pudo generar un mensaje en este momento. Intenta de nuevo.';
    }
  }
}