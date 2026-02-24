import 'package:cloud_functions/cloud_functions.dart';
import 'dart:developer' as developer;

class EmotionService {
  // Configuramos la instancia para apuntar a la regiÃ³n donde vive tu funciÃ³n
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(region: 'us-east1');

  Future<List<String>> analizarTexto(String texto) async {
    try {
      // Nombre exacto de la funciÃ³n desplegada en index.ts
      HttpsCallable callable = _functions.httpsCallable('analyzeDiaryEntry');
      
      // Enviamos el texto en el formato que espera el backend
      final results = await callable.call({'text': texto});

      // La respuesta exitosa que vimos en PowerShell llega aquÃ­
      if (results.data['suggestions'] != null) {
        String sugerencias = results.data['suggestions'];
        // Convierte el String "AlegrÃ­a, Alivio" en una lista real de Flutter
        return sugerencias.split(',').map((e) => e.trim()).toList();
      }
      return [];
    } catch (e, st) {
      developer.log(
        'Error llamando a la IA',
        name: 'EmotionService',
        error: e,
        stackTrace: st,
      );
      return [];
    }
  }
}
