import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<String?> generateChronicle({
    required String diaryEntry,
    required bool isPremium,
    String? username,
  }) async {
    if (_apiKey.isEmpty) {
      AppLogger.e('EmotionalEngineService: GEMINI_API_KEY no configurada.');
      return null;
    }

    final String name = username ?? 'Explorador';

    final String systemPrompt = isPremium
        ? 'Eres un novelista de viajes poético y reflexivo. Basándote en las notas del diario de $name, escribe una crónica literaria en primera persona que sea inspiradora y profunda. Usa metáforas, resalta el crecimiento emocional y dale un aire de sabiduría. Divide en tres partes: El Inicio, El Desafío y La Transformación.'
        : 'Eres un asistente de viajes eficiente. Resume las notas del diario de $name en una bitácora concisa, resaltando los hitos principales y el sentimiento detectado.';

    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
      systemInstruction: Content('system', [TextPart(systemPrompt)]),
    );

    try {
      final response = await model.generateContent([Content.text(diaryEntry)]);
      return response.text;
    } catch (e) {
      AppLogger.e('Error en generación de crónica: $e');
    }
    return null;
  }

  /// F4.1 — IA Predictiva de Emociones
  /// Analiza las últimas entradas del diario para detectar patrones
  /// emocionales y recomendar un tipo de expedición.
  Future<EmotionalPrediction?> predictEmotionalNeed(List<String> recentEntries) async {
    if (_apiKey.isEmpty || recentEntries.isEmpty) return null;

    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
      systemInstruction: Content('system', [
        TextPart(
          'Eres el Motor Predictivo de FeelTrip. Analiza las últimas entradas del '
          'diario de un viajero para detectar su PATRÓN EMOCIONAL ACTUAL. '
          'Devuelve un JSON con: '
          '"mood_pattern" (string como "estrés acumulado", "nostalgia", "entusiasmo", "agotamiento", "curiosidad"), '
          '"intensity" (número de 0.0 a 1.0), '
          '"recommended_archetype" (string: "EXPLORADOR", "ERMITAÑO", "CONECTOR", "ALQUIMISTA", "ACADÉMICO"), '
          '"suggested_destination" (string con nombre de lugar), '
          '"reasoning" (string con explicación breve y empática de por qué se recomienda ese destino).',
        ),
      ]),
    );

    try {
      final combinedText = recentEntries.asMap().entries
          .map((e) => 'Entrada ${e.key + 1}: ${e.value}')
          .join('\n\n');
      final response = await model.generateContent([Content.text(combinedText)]);
      if (response.text != null) {
        return EmotionalPrediction.fromJson(response.text!);
      }
    } catch (e) {
      AppLogger.e('Error en predicción emocional: $e');
    }
    return null;
  }
}

/// Modelo de datos para la predicción emocional.
class EmotionalPrediction {
  final String moodPattern;
  final double intensity;
  final String recommendedArchetype;
  final String suggestedDestination;
  final String reasoning;
  final Map<String, dynamic>? flightInfo;
  final String? weatherInfo;
  final List<String>? activityInfo;
  final Map<String, dynamic>? paymentInfo;

  EmotionalPrediction({
    required this.moodPattern,
    required this.intensity,
    required this.recommendedArchetype,
    required this.suggestedDestination,
    required this.reasoning,
    this.flightInfo,
    this.weatherInfo,
    this.activityInfo,
    this.paymentInfo,
  });

  factory EmotionalPrediction.fromJson(String source) {
    final cleaned = source.replaceAll('```json', '').replaceAll('```', '').trim();
    final data = jsonDecode(cleaned) as Map<String, dynamic>;
    return EmotionalPrediction(
      moodPattern: (data['mood_pattern'] as String?) ?? 'indefinido',
      intensity: ((data['intensity'] as num?) ?? 0.5).toDouble(),
      recommendedArchetype: (data['recommended_archetype'] as String?) ?? 'EXPLORADOR',
      suggestedDestination: (data['suggested_destination'] as String?) ?? 'Tu próximo destino',
      reasoning: (data['reasoning'] as String?) ?? '',
      flightInfo: data['flightInfo'] as Map<String, dynamic>?,
      weatherInfo: data['weatherInfo'] as String?,
      activityInfo: (data['activityInfo'] as List?)?.map((e) => e.toString()).toList(),
      paymentInfo: data['paymentInfo'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'mood_pattern': moodPattern,
      'intensity': intensity,
      'recommended_archetype': recommendedArchetype, // KPI principal para agencias
      'suggested_destination': suggestedDestination,
      'reasoning': reasoning,
      'flightInfo': flightInfo,
      'weatherInfo': weatherInfo,
      'activityInfo': activityInfo,
      'paymentInfo': paymentInfo,
      'createdAt': FieldValue.serverTimestamp(), // Usar serverTimestamp para orden real en Dashboard
      'isConversionReady': paymentInfo != null || (flightInfo != null && flightInfo!['result'].toString().contains('http')),
    };
  }

  /// Alias de conveniencia para uso fuera de Firestore (ej: scout_agent_screen).
  Map<String, dynamic> toJson() {
    return {
      'mood_pattern': moodPattern,
      'intensity': intensity,
      'recommended_archetype': recommendedArchetype,
      'suggested_destination': suggestedDestination,
      'reasoning': reasoning,
      'flightInfo': flightInfo,
      'weatherInfo': weatherInfo,
      'activityInfo': activityInfo,
      'paymentInfo': paymentInfo,
    };
  }
}