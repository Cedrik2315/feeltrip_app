import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';

/// Servicio encargado de traducir textos utilizando la IA de Gemini,
/// adaptando el tono al arquetipo del usuario.
class TranslatorService {
  final GenerativeModel _model;
  final _languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);

  TranslatorService({required String apiKey})
      : _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

  /// Detecta el idioma del texto localmente utilizando ML Kit (sin costo de tokens).
  Future<String> detectLanguage(String text) async {
    try {
      if (text.trim().isEmpty) return 'und';
      final languageCode = await _languageIdentifier.identifyLanguage(text);
      return languageCode;
    } catch (e) {
      AppLogger.e('Error detectando idioma: $e');
      return 'und';
    }
  }

  /// Libera los recursos del identificador de idiomas.
  void dispose() {
    _languageIdentifier.close();
  }

  /// Traduce [text] al idioma [targetLanguage] (por defecto Español)
  /// ajustando el estilo narrativo según el [archetype].
  Future<String> translate(
    String text, {
    required String archetype,
    String targetLanguage = 'Spanish',
  }) async {
    try {
      final prompt = '''
        Actúa como el Módulo de Traducción Universal de FeelTrip.
        Tu misión es traducir evidencias encontradas en campo.
        
        Arquetipo del explorador: $archetype.
        Idioma de salida: $targetLanguage.

        INSTRUCCIONES:
        - Traduce el texto con precisión pero usa el vocabulario y tono del arquetipo.
        - Si es 'ALQUIMISTA', usa un tono místico. 
        - Si es 'ACADÉMICO', usa un tono técnico e histórico.
        - Si es 'EXPLORADOR', usa un tono épico y de bitácora de campo.

        Texto a procesar: "$text"
      ''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'ERROR_DECODING: No se pudo recuperar la señal de traducción.';
    } catch (e) {
      AppLogger.e('Error en TranslatorService: $e');
      return 'LINK_FAILURE: Error de conexión con el núcleo de traducción.';
    }
  }
}