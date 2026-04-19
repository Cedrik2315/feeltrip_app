import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';
import 'package:feeltrip_app/features/diario/domain/models/momento_model.dart';
import 'package:uuid/uuid.dart';

class HistoricalContextService {
  final GenerativeModel _model;

  HistoricalContextService({required String apiKey})
      : _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

  /// Obtiene hitos históricos basados en coordenadas y el arquetipo del usuario
  Future<String> getHistoryForLocation(double lat, double lng, {String? archetype}) async {
    try {
      final prompt = '''
        Actúa como el sistema de inteligencia de campo de FeelTrip. 
        Ubicación: Latitud $lat, Longitud $lng.
        Arquetipo del usuario: ${archetype ?? 'Explorador'}.

        Tu misión es proporcionar contexto histórico y cultural para INSPIRAR al usuario a escribir en su bitácora.
        Utiliza datos reales del entorno si están disponibles en tu base de conocimiento.
        
        Comienza con un tono intrigante tipo "¿Sabías que...?" y proporciona hitos históricos o culturales fascinantes sobre este entorno específico.
        - Si el arquetipo es 'ACADÉMICO', incluye fechas precisas y datos técnicos.
        - Si es 'ALQUIMISTA', enfócate en cómo el lugar ha transformado a las personas.
        - Si es 'ERMITAÑO', destaca la paz ancestral o la geología antigua.
        
        Mantén un tono de "telemetría recuperada", místico pero tecnológico. Máximo 120 palabras.
      ''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'SEÑAL HISTÓRICA DÉBIL: Registros no encontrados en esta coordenada.';
    } catch (e) {
      AppLogger.e('Error en HistoricalContextService: $e');
      return 'ERROR_LINK_FAILED: Fallo en la conexión con el archivo histórico.';
    }
  }

  /// Genera un "Misterio de Campo" para fomentar la curiosidad en puntos aleatorios del mapa.
  /// Diseñado para cuando el usuario toca un área donde la app no tenía sugerencias previas.
  Future<String> getMysteryForLocation(double lat, double lng) async {
    try {
      final prompt = '''
        Actúa como un sensor de anomalías de FeelTrip. 
        Coordenadas: $lat, $lng.
        
        No proporciones un dato histórico seco. En su lugar, genera un "RUMOR DE CAMPO" críptico y fascinante.
        - Puede ser sobre un fenómeno natural extraño, una leyenda urbana local, o una vibración energética.
        - Usa frases como "Los locales evitan hablar de...", "Se dice que aquí el tiempo...", "Sensores detectan un eco de...".
        - El objetivo es que el usuario sienta una curiosidad irresistible por ir a investigar físicamente.
        
        Máximo 60 palabras. Tono: Místico, tecnológico, urgente.
      ''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'SEÑAL INTERRUMPIDA: Hay algo aquí, pero la interferencia es demasiada.';
    } catch (e) {
      AppLogger.e('Error generando misterio: $e');
      return 'ANOMALÍA DETECTADA: El archivo en esta coordenada parece haber sido borrado.';
    }
  }

  /// Crea un modelo de Momento listo para ser insertado en Isar/Firestore
  Momento createHistoricalCapsule({
    required String userId,
    required String content,
    required double lat,
    required double lng,
    String? locationName,
  }) {
    return Momento(
      id: const Uuid().v4(),
      userId: userId,
      title: 'CÁPSULA HISTÓRICA: ${locationName ?? "Ubicación Desconocida"}',
      description: content,
      createdAt: DateTime.now(),
      latitude: lat,
      longitude: lng,
      isSynced: false,
    );
  }

  /// Analiza las tendencias arquetípicas de una zona para el usuario.
  Future<String> getArchetypalTrendAnalysis(List<String> archetypes, String locationName) async {
    try {
      final counts = <String, int>{};
      for (var a in archetypes) {
        counts[a] = (counts[a] ?? 0) + 1;
      }
      
      final stats = counts.entries.map((e) => '${e.key}: ${e.value}').join(', ');

      final prompt = '''
        Actúa como el Analista de Frecuencias de FeelTrip.
        Zona: $locationName. Datos de la red: $stats.
        
        Interpreta estas tendencias para un explorador curioso. 
        - Si hay muchos 'EXPLORADORES', habla de la energía kinética.
        - Si hay 'ALQUIMISTAS', habla de la transmutación del lugar.
        - Sé breve, místico y tecnológico.
        
        Máximo 50 palabras.
      ''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'La zona vibra en una frecuencia inestable.';
    } catch (e) {
      AppLogger.e('Error en análisis de tendencias: $e');
      return 'ERROR_SYNC: No se pudo decodificar la firma de la red.';
    }
  }

  /// Genera una descripción de "Ambiente de Zona" basada en el arquetipo dominante.
  /// Esto se usa para que el mapa "vibre" visualmente de forma distinta según la zona.
  String getZoneVibeDescription(String archetype) {
    switch (archetype.toUpperCase()) {
      case 'EXPLORADOR':
        return 'ALERTA: Zona de alta intensidad. Pulso de adrenalina detectado.';
      case 'ERMITAÑO':
        return 'SILENCIO: Vacío acústico profundo. Ideal para desvanecerse.';
      case 'ALQUIMISTA':
        return 'TRANSFORMACIÓN: El aire aquí se siente cargado de historia personal.';
      case 'CONECTOR':
        return 'RESONANCIA: Redes humanas densas. Ecos de historias compartidas.';
      case 'ACADÉMICO':
        return 'ARCHIVOS: Capas de tiempo visibles en cada piedra.';
      default:
        return 'FRECUENCIA BASE: Territorio listo para ser nombrado.';
    }
  }
}