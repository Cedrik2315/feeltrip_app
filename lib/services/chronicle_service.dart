import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:feeltrip_app/models/expedition_data.dart';
import 'package:feeltrip_app/models/chronicle_model.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';

/// ChronicleService - Generates AI-powered chronicles from expedition data.
/// Uses Gemini for narrative generation (contemplative, feeltrip-style).
class ChronicleService {
  late final GenerativeModel _model;

  ChronicleService({required String apiKey}) : _model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: apiKey,
    generationConfig: GenerationConfig(
      temperature: 0.8,
      topP: 0.95,
      maxOutputTokens: 2048,
    ),
  );

  /// Generates a ChronicleModel from expedition data.
  /// Formats poetic, contemplative narrative based on FeelTrip tone.
  Future<ChronicleModel> generateChronicle({
    required ExpeditionData data,
    required String userId,
    required int expeditionNumber,
  }) async {
    try {
      final prompt = _buildPrompt(data, userId, expeditionNumber);
      final content = [Content.text(prompt)];
      
      final response = await _model.generateContent(content);
      final text = response.text ?? 'No se pudo generar la crónica.';

      AppLogger.i('ChronicleService: Generated chronicle #$expeditionNumber for $userId');

      final expData = data;
      return ChronicleModel(
        id: _generateId(userId, expeditionNumber),
        userId: userId,
        title: 'Crónica ${expeditionNumber.toString().padLeft(3, "0")}: ${expData.placeName}',
        paragraphs: text.split('\n\n').where((p) => p.trim().isNotEmpty).map((p) => p.trim()).toList(),
        expeditionData: expData,
        generatedAt: DateTime.now(),
        expeditionNumber: expeditionNumber,
      );
    } catch (e) {
      AppLogger.e('ChronicleService error: $e');
      rethrow;
    }
  }

  String _buildPrompt(ExpeditionData data, String userId, int expeditionNumber) {
    return '''
Genera una crónica contemplativa y poética estilo FeelTrip para la expedición #$expeditionNumber del explorador $userId.

Detalles de la expedición:
- Lugar: ${data.placeName}, ${data.region}
- Hora de llegada: ${data.arrivalTime}
- Temperatura: ${data.temperature}
- Detalle único: ${data.uniqueDetail}
- Distancia: ${data.distanceKm.toStringAsFixed(1)} km
- Duración: ${data.durationMinutes} min
- Elevación: ${data.elevationGainM.toStringAsFixed(0)} m
- Tono: ${data.tone.name}

Escribe en español, primera persona, tono ${data.tone.name}. Enfócate en sensaciones, emociones, conexión con la naturaleza. Máximo 800 palabras. Incluye reflexión final.
''';
  }

  String _generateId(String userId, int expeditionNumber) => 
      'chronicle_${userId}_${expeditionNumber}_${DateTime.now().millisecondsSinceEpoch}';
}
