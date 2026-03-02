import 'dart:convert';
import 'dart:developer' as developer;

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Servicio de IA para análisis emocional y recomendaciones de viajes
/// Utiliza Google Generative AI y Firebase Cloud Functions
class AIService {
  AIService({
    FirebaseFunctions? functions,
    http.Client? httpClient,
  })  : _functions = functions ?? FirebaseFunctions.instance,
        _httpClient = httpClient ?? http.Client();

  final FirebaseFunctions _functions;
  final http.Client _httpClient;

  static const String _baseUrl = 'https://generativelanguage.googleapis.com';
  static const String _modelName = 'gemini-pro';

  /// Analiza el texto de una entrada de diario y devuelve las emociones detectadas
  Future<List<String>> analyzeDiaryEntry(String text) async {
    try {
      final callable = _functions.httpsCallable('analyzeDiaryEntry');
      final results = await callable.call({'text': text});

      if (results.data['suggestions'] != null) {
        String sugerencias = results.data['suggestions'];
        return sugerencias.split(',').map((e) => e.trim()).toList();
      }
      return [];
    } catch (e, st) {
      developer.log(
        'Error en analyzeDiaryEntry',
        name: 'AIService',
        error: e,
        stackTrace: st,
      );
      return [];
    }
  }

  /// Genera recomendaciones de viajes basadas en preferencias emocionales
  Future<TravelRecommendation?> getTravelRecommendations({
    required List<String> emotions,
    required String experienceType,
    int maxResults = 5,
  }) async {
    try {
      final prompt = _buildRecommendationPrompt(emotions, experienceType);
      final response = await _callGenerativeAI(prompt);

      if (response != null) {
        return _parseTravelRecommendations(response, maxResults);
      }
      return null;
    } catch (e, st) {
      developer.log(
        'Error en getTravelRecommendations',
        name: 'AIService',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// Genera una descripción transformadora para un viaje
  Future<String?> generateTransformationMessage({
    required String destination,
    required String experienceType,
    required List<String> desiredEmotions,
  }) async {
    try {
      final prompt = '''
Genera un mensaje inspirador para un viaje transformador a $destination 
de tipo $experienceType que busca generar las siguientes emociones: ${desiredEmotions.join(', ')}.
El mensaje debe ser emotivo, inspirador y en español. Máximo 200 caracteres.
''';

      return await _callGenerativeAI(prompt);
    } catch (e, st) {
      developer.log(
        'Error en generateTransformationMessage',
        name: 'AIService',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// Analiza el perfil del usuario y devuelve su arquetipo de viajero
  Future<TravelerArchetype?> analyzeTravelerProfile({
    required List<String> quizAnswers,
    required List<String> diaryEmotions,
  }) async {
    try {
      final prompt = '''
Basado en las siguientes respuestas de quiz: ${quizAnswers.join(', ')}
y las emociones de su diario: ${diaryEmotions.join(', ')}
Determina el arquetipo de viajero de esta persona.
Devuelve solo el nombre del arquetipo y una breve descripción.
Arquetipos posibles: Aventurero, Cultural, Espiritual, Relajado, Explorador, Conector.
''';

      final result = await _callGenerativeAI(prompt);
      if (result != null) {
        return _parseTravelArchetype(result);
      }
      return null;
    } catch (e, st) {
      developer.log(
        'Error en analyzeTravelerProfile',
        name: 'AIService',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// Genera actividades personalizadas basadas en el destino y preferencias
  Future<List<String>?> generatePersonalizedActivities({
    required String destination,
    required String travelerType,
    required int days,
  }) async {
    try {
      final prompt = '''
Genera una lista de $days actividades diarias para un viaje a $destination
para un viajero tipo $travelerType.
Devuelve solo los nombres de las actividades, uno por línea.
''';

      final result = await _callGenerativeAI(prompt);
      if (result != null) {
        return result.split('\n').where((s) => s.trim().isNotEmpty).toList();
      }
      return null;
    } catch (e, st) {
      developer.log(
        'Error en generatePersonalizedActivities',
        name: 'AIService',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  ///Llama a Google Generative AI
  Future<String?> _callGenerativeAI(String prompt) async {
    try {
      // Obtener API key desde Firebase config o variables de entorno
      final apiKey = await _getApiKey();
      if (apiKey == null) {
        developer.log('API Key no disponible', name: 'AIService');
        return null;
      }

      final uri = Uri.parse(
          '$_baseUrl/v1/models/$_modelName:generateContent?key=$apiKey');

      final response = await _httpClient
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': prompt}
                  ]
                }
              ],
              'generationConfig': {
                'temperature': 0.7,
                'maxOutputTokens': 1000,
              }
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'] as Map?;
          if (content != null) {
            final parts = content['parts'] as List?;
            if (parts != null && parts.isNotEmpty) {
              return parts[0]['text'] as String?;
            }
          }
        }
      }
      return null;
    } catch (e) {
      developer.log('Error calling Generative AI: $e', name: 'AIService');
      return null;
    }
  }

  Future<String?> _getApiKey() async {
    // Obtener API key desde variables de entorno (.env)
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
      if (apiKey.isEmpty) {
        developer.log(
          'ADVERTENCIA: GEMINI_API_KEY no configurada en .env',
          name: 'AIService',
        );
        return null;
      }
      return apiKey;
    } catch (e) {
      developer.log('Error obteniendo API key: $e', name: 'AIService');
      return null;
    }
  }

  String _buildRecommendationPrompt(
      List<String> emotions, String experienceType) {
    return '''
Basado en las siguientes emociones: ${emotions.join(', ')}
y el tipo de experiencia: $experienceType
Recomienda destinos de viaje transformadores.
Para cada destino, incluye: nombre, país, y por qué es transformador.
''';
  }

  TravelRecommendation? _parseTravelRecommendations(
      String response, int maxResults) {
    // Parseo básico - en producción sería más robusto
    final lines = response
        .split('\n')
        .where((s) => s.trim().isNotEmpty)
        .take(maxResults)
        .toList();
    if (lines.isEmpty) return null;

    return TravelRecommendation(
      destinations: lines.map((l) => l.trim()).toList(),
      generatedAt: DateTime.now(),
    );
  }

  TravelerArchetype? _parseTravelArchetype(String response) {
    final lines =
        response.split('\n').where((s) => s.trim().isNotEmpty).toList();
    if (lines.isEmpty) return null;

    final name = lines.first.trim();
    final description = lines.length > 1 ? lines[1].trim() : '';

    return TravelerArchetype(
      name: name,
      description: description,
    );
  }

  void dispose() {
    _httpClient.close();
  }
}

/// Modelo para recomendaciones de viaje
class TravelRecommendation {
  final List<String> destinations;
  final DateTime generatedAt;

  TravelRecommendation({
    required this.destinations,
    required this.generatedAt,
  });
}

/// Modelo para arquetipos de viajero
class TravelerArchetype {
  final String name;
  final String description;

  TravelerArchetype({
    required this.name,
    required this.description,
  });
}
