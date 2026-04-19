import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:feeltrip_app/models/chronicle_model.dart';
import 'package:feeltrip_app/models/expedition_data.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';
import 'package:feeltrip_app/services/isar_service.dart';

class ChronicleService {
  final String apiKey;
  final GenerativeModel? customModel;
  late final GenerativeModel _model;

  ChronicleService({required this.apiKey, this.customModel}) {
    _model = customModel ?? GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
  }

  /// Genera una nueva crónica basada en los datos de la expedición utilizando IA.
  Future<ChronicleModel> generateChronicle({
    required ExpeditionData data,
    required String userId,
    required int expeditionNumber,
    String archetype = 'Aventurero', // Arquetipo por defecto
  }) async {
    // ... mismo código de generación ...
    final prompt = """
    Actúa como un cronista de viajes literario y mentor existencialista de FeelTrip.
    Tu estilo narrativo DEBE adaptarse al arquetipo del explorador: $archetype.
    
    INSTRUCCIONES DE ESTILO POR ARQUETIPO:
    - Aventurero: Usa verbos de acción, lenguaje visceral, enfoque en el desafío y la superación física.
    - Contemplativo: Usa lenguaje poético, metáforas sobre la luz y el silencio, enfoque en la belleza y la paz.
    - Conector: Enfócate en los encuentros, la calidez humana, la pertenencia y las historias compartidas.
    - Aprendiz: Usa un tono curioso, datos culturales sutiles y reflexiones sobre el saber del lugar.
    - Transformado: Enfócate en el cambio interno, el simbolismo de la mariposa y el dejar atrás la vieja versión.

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
    2. El segundo renglón DEBE ser una 'Metáfora Visual' breve (3-5 palabras en inglés) para buscar una imagen, enmarcada entre corchetes así: [METAPHOR: keyword1 keyword2].
    3. El resto debe ser un relato profundo en primera persona dividido en 3 o 4 párrafos.
    4. No uses formato Markdown, solo texto plano en español.
    """;

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final text = response.text ?? '';

      if (text.isEmpty) throw Exception('La IA devolvió un cuerpo vacío.');
      // Sugerencia: El parseo manual de líneas es frágil si Gemini cambia el formato ligeramente.
      final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
      final title = lines.isNotEmpty ? lines.first : 'Crónica de la Expedición';
      
      String? visualMetaphor;
      String? finalTitle = title;
      List<String> paragraphs = [];

      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.contains('[METAPHOR:')) {
          visualMetaphor = line.split(':').last.replaceAll(']', '').trim();
          continue;
        }
        if (i == 0) continue; 
        paragraphs.add(line);
      }

      if (paragraphs.isEmpty) paragraphs = [text];

      return ChronicleModel.create(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        title: finalTitle,
        paragraphs: paragraphs,
        expeditionData: data,
        generatedAt: DateTime.now(),
        expeditionNumber: expeditionNumber,
        visualMetaphor: visualMetaphor,
      );
    } catch (e) {
      AppLogger.e('Error generando crónica con Gemini: $e');
      rethrow;
    }
  }

  Future<void> saveChronicle(ChronicleModel chronicle) async {
    // Usamos el IsarService centralizado para persistencia unificada
    await IsarService().putChronicle(chronicle);
  }
}