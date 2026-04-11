// lib/services/chronicle_service.dart
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hive/hive.dart';
import '../models/chronicle_model.dart';
import '../models/expedition_data.dart';
import '../core/logger/app_logger.dart';

class ChronicleService {
  final String apiKey;
  late final GenerativeModel _model;

  ChronicleService({required this.apiKey}) {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
  }

  /// Genera una nueva crónica basada en los datos de la expedición utilizando IA.
  Future<ChronicleModel> generateChronicle({
    required ExpeditionData data,
    required String userId,
    required int expeditionNumber,
  }) async {
    if (apiKey.isEmpty) {
      AppLogger.e('ChronicleService: API Key no configurada para crónicas.');
      throw Exception('Servicio de IA no disponible.');
    }

    final prompt = """
    Actúa como un cronista de viajes literario y mentor existencialista de FeelTrip.
    Redacta una crónica de transformación personal para el explorador ${data.explorerName} 
    sobre su expedición #${expeditionNumber.toString().padLeft(3, '0')} a ${data.placeName}, ${data.region}.
    
    DATOS DE LA EXPEDICIÓN:
    - Hora de llegada: ${data.arrivalTime} a una temperatura de ${data.temperature}.
    - Tono narrativo: ${data.tone.displayName}.
    - Matiz emocional detectado: ${data.audioNuance.name}.
    - Detalle sensorial único: "${data.uniqueDetail}".
    - Telemetría: ${data.distanceKm} km recorridos con un desnivel de ${data.elevationGainM} m.

    ESTRUCTURA DE LA RESPUESTA:
    1. El primer renglón DEBE ser un título evocador y místico.
    2. El resto debe ser un relato profundo en primera persona.
    3. Divide el texto en 3 o 4 párrafos claros.
    4. No uses formato Markdown (ni asteriscos, ni negritas), solo texto plano en español.
    """;

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final text = response.text ?? '';

      if (text.isEmpty) throw Exception('La IA devolvió un cuerpo vacío.');

      // Procesamos la respuesta para separar título de párrafos
      final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
      final title = lines.isNotEmpty ? lines.first : 'Crónica de la Expedición';
      final paragraphs = lines.length > 1 ? lines.sublist(1) : [text];

    return ChronicleModel.create(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      title: title,
      paragraphs: paragraphs,
      expeditionData: data,
      generatedAt: DateTime.now(),
      expeditionNumber: expeditionNumber,
    );
    } catch (e) {
      AppLogger.e('Error generando crónica con Gemini: $e');
      rethrow;
    }
  }

  Future<void> saveChronicle({
    required String id,
    required String userId,
    required String title,
    required List<String> paragraphs,
    required ExpeditionData expeditionData, // Recibimos el objeto
    required DateTime generatedAt,
    int? expeditionNumber,
    String? imageUrl,
    String? visualMetaphor,
  }) async {
    final box = await Hive.openBox<ChronicleModel>('chronicles');

    // CAMBIO CLAVE: Usamos el Factory .create que encapsula la conversión a JSON
    final newChronicle = ChronicleModel.create(
      id: id,
      userId: userId,
      title: title,
      paragraphs: paragraphs,
      expeditionData: expeditionData,
      generatedAt: generatedAt,
      expeditionNumber: expeditionNumber,
      imageUrl: imageUrl,
      visualMetaphor: visualMetaphor,
    );

    await box.put(id, newChronicle);
  }
}