import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';

/// Provider para acceder al servicio de traducción basado en IA.
final translationServiceProvider = Provider((ref) => TranslationService());

class TranslationService {
  /// Traduce el texto proporcionado al idioma destino usando Gemini,
  /// adaptando el tono según el arquetipo del usuario si se proporciona.
  Future<String> translate(String text,
      {required String targetLanguage, String? archetype}) async {
    final apiKey = _getApiKey();
    if (apiKey == null) return text;

    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
      final prompt = archetype != null
          ? 'Traduce el siguiente texto al idioma "$targetLanguage", adaptando el tono al arquetipo "$archetype" (ej: más poético, técnico o aventurero). Responde ÚNICAMENTE con la traducción:\n\n$text'
          : 'Traduce el siguiente texto al idioma "$targetLanguage". Responde ÚNICAMENTE con la traducción:\n\n$text';

      final response = await model.generateContent([Content.text(prompt)]);
      return response.text?.trim() ?? text;
    } catch (e) {
      AppLogger.e('Error en TranslationService.translate: $e');
      return text;
    }
  }

  /// Detecta el idioma del texto (ej: 'es', 'en', 'fr').
  Future<String> detectLanguage(String text) async {
    final apiKey = _getApiKey();
    if (apiKey == null) return 'unknown';

    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
      final prompt = 'Detecta el idioma del siguiente texto. Responde ÚNICAMENTE con el código ISO de dos letras (ej: es, en, fr):\n\n$text';

      final response = await model.generateContent([Content.text(prompt)]);
      return response.text?.trim().toLowerCase() ?? 'unknown';
    } catch (e) {
      AppLogger.e('Error en TranslationService.detectLanguage: $e');
      return 'unknown';
    }
  }

  String? _getApiKey() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? dotenv.env['GOOGLE_AI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      AppLogger.w('TranslationService: API Key no configurada.');
      return null;
    }
    return apiKey;
  }
}
