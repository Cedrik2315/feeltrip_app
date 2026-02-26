import 'package:cloud_functions/cloud_functions.dart';
import 'dart:developer' as developer;

class AnalisisResultado {
  final List<String> emociones;
  final String destino;
  final String explicacion;

  AnalisisResultado(
      {required this.emociones,
      required this.destino,
      required this.explicacion});
}

class EmotionService {
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'us-east1');

  Future<AnalisisResultado?> analizarTexto(String texto) async {
    try {
      HttpsCallable callable = _functions.httpsCallable('analyzeDiaryEntry');
      final results = await callable.call({'text': texto});

      final data = results.data;
      return AnalisisResultado(
        emociones: List<String>.from(data['emociones']),
        destino: data['destino_sugerido'],
        explicacion: data['explicacion'],
      );
    } catch (e, st) {
      developer.log(
        'Error llamando a la IA',
        name: 'EmotionService',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }
}
