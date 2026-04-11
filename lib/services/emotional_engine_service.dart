import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';

/// Modelo de datos para el resultado del análisis emocional de un diario.
class EmotionalAnalysis {
  final double sentimentScore;
  final List<String> dominantEmotions;
  final List<String> travelTags;

  EmotionalAnalysis({
    required this.sentimentScore,
    required this.dominantEmotions,
    required this.travelTags,
  });

  factory EmotionalAnalysis.fromJson(String source) {
    // Intentamos limpiar la respuesta en caso de que la IA incluya bloques de código markdown
    final cleanedSource = source.replaceAll('```json', '').replaceAll('```', '').trim();
    final data = jsonDecode(cleanedSource) as Map<String, dynamic>;
    
    return EmotionalAnalysis(
      sentimentScore: (data['sentiment_score'] as num).toDouble(),
      dominantEmotions: List<String>.from(data['dominant_emotions'] as List),
      travelTags: List<String>.from(data['travel_tags'] as List),
    );
  }
}

/// Servicio encargado de procesar el texto de los diarios para extraer
/// métricas emocionales y etiquetas de interés usando Gemini.
class EmotionalEngineService {
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  Future<EmotionalAnalysis?> analyzeDiaryEntry(String entryText) async {
    if (_apiKey.isEmpty) {
      AppLogger.e('EmotionalEngineService: GEMINI_API_KEY no configurada.');
      return null;
    }

    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
      systemInstruction: Content('system', [
        TextPart(
          'Actúas como el Motor Emocional de FeelTrip. Analiza diarios de viaje. '
          "Devuelve un JSON con: 'sentiment_score' (número de -1.0 a 1.0), "
          "'dominant_emotions' (lista de strings) y 'travel_tags' (temas como: "
          'historia, gastronomía, naturaleza, aventura, arquitectura).',
        ),
      ]),
    );

    try {
      final response = await model.generateContent([Content.text(entryText)]);
      if (response.text != null) {
        return EmotionalAnalysis.fromJson(response.text!);
      }
    } catch (e) {
      AppLogger.e('Error en Motor Emocional (Gemini): $e');
    }
    return null;
  }
}