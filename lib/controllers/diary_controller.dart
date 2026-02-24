import '../services/database_service.dart';
import '../services/emotion_service.dart';
import '../services/observability_service.dart';

class DiaryController {
  DiaryController({
    required EmotionService emotionService,
    required DatabaseService databaseService,
  })  : _emotionService = emotionService,
        _databaseService = databaseService;

  final EmotionService _emotionService;
  final DatabaseService _databaseService;

  Future<List<String>> analizarYGuardar(String texto) async {
    final limpio = texto.trim();
    if (limpio.isEmpty) {
      throw Exception('El texto está vacío');
    }

    return ObservabilityService.trace(
      name: 'diary_analizar_y_guardar',
      action: () async {
        final emociones = await _emotionService.analizarTexto(limpio);
        await _databaseService.guardarEntrada(texto: limpio, emociones: emociones);
        await ObservabilityService.logEvent(
          'diary_saved',
          parameters: {'emotions_count': emociones.length},
        );
        return emociones;
      },
    );
  }
}
