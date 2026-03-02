import 'package:cloud_functions/cloud_functions.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:developer' as developer;

import 'observability_service.dart';

class RouteStop {
  final String nombre;
  final String descripcion;
  final double lat;
  final double lng;

  RouteStop({
    required this.nombre,
    required this.descripcion,
    required this.lat,
    required this.lng,
  });
}

class AnalisisResultado {
  final List<String> emociones;
  final String destino;
  final String explicacion;
  final double? lat;
  final double? lng;
  final List<RouteStop> ruta;

  AnalisisResultado({
    required this.emociones,
    required this.destino,
    required this.explicacion,
    this.lat,
    this.lng,
    this.ruta = const [],
  });
}

class EmotionService {
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'us-east1');

  // Caché simple en memoria: Map<Texto, Resultado>
  final Map<String, AnalisisResultado> _cache = {};

  Future<AnalisisResultado?> analizarTexto(String texto) async {
    if (_cache.containsKey(texto)) {
      developer.log(
          'Usando resultado en caché para: "${texto.substring(0, 10)}..."');
      // Registrar evento de caché hit para análisis de costos
      await ObservabilityService.logEvent('ai_cache_hit');
      return _cache[texto];
    }

    try {
      // Registrar inicio de llamada costosa
      final stopwatch = Stopwatch()..start();
      await ObservabilityService.logEvent('ai_request_start');

      HttpsCallable callable = _functions.httpsCallable('analyzeDiaryEntry');
      final results = await callable.call({'text': texto});

      final data = results.data;
      final destino = data['destino_sugerido'] as String;

      // Obtener coordenadas mediante geocoding
      double? lat;
      double? lng;
      try {
        final locations = await locationFromAddress(destino);
        if (locations.isNotEmpty) {
          lat = locations.first.latitude;
          lng = locations.first.longitude;
        }
      } catch (e) {
        developer.log(
          'Error obteniendo coordenadas para $destino',
          name: 'EmotionService',
          error: e,
        );
      }

      // Procesar ruta sugerida (mini-itinerario)
      List<RouteStop> ruta = [];
      if (data['ruta_sugerida'] != null && data['ruta_sugerida'] is List) {
        // Optimización: Ejecutar geocoding en paralelo para todas las paradas
        final futures = (data['ruta_sugerida'] as List).map((item) async {
          final nombrePunto = item['nombre'] as String?;
          final descPunto = item['descripcion'] as String?;

          if (nombrePunto != null && nombrePunto.isNotEmpty) {
            try {
              final locationsPunto = await locationFromAddress(nombrePunto);
              if (locationsPunto.isNotEmpty) {
                return RouteStop(
                  nombre: nombrePunto,
                  descripcion: descPunto ?? '',
                  lat: locationsPunto.first.latitude,
                  lng: locationsPunto.first.longitude,
                );
              }
            } catch (e) {
              developer.log('Error geocoding stop: $nombrePunto', error: e);
            }
          }
          return null;
        });

        final results = await Future.wait(futures);
        ruta = results.whereType<RouteStop>().toList();
      }

      final resultado = AnalisisResultado(
        emociones: List<String>.from(data['emociones']),
        destino: destino,
        explicacion: data['explicacion'],
        lat: lat,
        lng: lng,
        ruta: ruta,
      );

      _cache[texto] = resultado;
      
      stopwatch.stop();
      await ObservabilityService.logEvent('ai_request_success', parameters: {
        'duration_ms': stopwatch.elapsedMilliseconds,
        'emotions_count': resultado.emociones.length,
      });
      return resultado;
    } catch (e, st) {
      developer.log(
        'Error llamando a la IA',
        name: 'EmotionService',
        error: e,
        stackTrace: st,
      );
      await ObservabilityService.logEvent('ai_request_error', parameters: {'error': e.toString()});
      return null;
    }
  }
}
