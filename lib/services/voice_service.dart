import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Provider para acceder al servicio de voz en toda la aplicación.
final voiceServiceProvider = Provider((ref) => VoiceService());

class VoiceService {
  final FlutterTts _tts = FlutterTts();

  /// Configura el motor con un tono profesional y neutro.
  Future<void> initVoice({String language = 'es-MX'}) async {
    await _tts.setLanguage(language);
    await _tts.setPitch(1.0); // Tono estándar
    await _tts.setSpeechRate(0.45); // Un poco más pausado para mayor claridad
  }

  /// Emite un mensaje de estado del sistema basado en parámetros.
  Future<void> sayStatus(String name, String location) async {
    await initVoice();
    final String message =
        'Sistemas confirmados. Hola $name. Ubicación detectada en $location. FeelTrip está listo.';
    await _tts.speak(message);
  }

  /// Emite un mensaje de texto arbitrario (útil para traducciones).
  Future<void> speak(String message, {String language = 'es-MX'}) async {
    await initVoice(language: language);
    await _tts.speak(message);
  }
}
