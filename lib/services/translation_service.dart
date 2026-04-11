import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';

/// Provider para acceder al servicio de traducción basado en IA.
final translationServiceProvider = Provider((ref) => TranslationService());

class TranslationService {
  /// Traduce el texto proporcionado al idioma destino usando Gemini.
  Future<String> translate(String text,
      {required String targetLanguage}) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      AppLogger.w('TranslationService: API Key no configurada.');
      return text;
    }

    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
      final prompt =
          'Traduce el siguiente texto al idioma "$targetLanguage". Responde ÚNICAMENTE con la traducción, sin explicaciones ni comillas adicionales:\n\n$text';

      final response = await model.generateContent([Content.text(prompt)]);
      final translatedText = response.text?.trim() ?? text;
      return translatedText;
    } catch (e) {
      AppLogger.e('Error en TranslationService: $e');
      return text;
    }
  }
}
