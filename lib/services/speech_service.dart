import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';

/// Provider para el servicio de reconocimiento de voz.
final speechServiceProvider = Provider((ref) => SpeechService());

class SpeechService {
  final SpeechToText _speechToText = SpeechToText();

  /// Escucha una frase del usuario y la devuelve como texto.
  Future<String> listenOnce() async {
    final bool available = await _speechToText.initialize(
      onStatus: (status) => AppLogger.i('STT Status: $status'),
      onError: (error) => AppLogger.e('STT Error: $error'),
    );

    if (!available) {
      AppLogger.w('El reconocimiento de voz no está disponible.');
      return '';
    }

    String recognizedText = '';

    // Iniciamos la escucha
    await _speechToText.listen(
      onResult: (result) {
        recognizedText = result.recognizedWords;
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      cancelOnError: true,
    );

    // Esperamos a que deje de escuchar para retornar el resultado
    // En una implementación real, esto se manejaría con streams en la UI
    await Future<void>.delayed(const Duration(seconds: 5));
    await _speechToText.stop();

    return recognizedText;
  }
}
