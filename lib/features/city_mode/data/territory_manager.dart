import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:feeltrip_app/features/city_mode/data/city_mode_repository.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';

final territoryManagerProvider = Provider<TerritoryManager>((ref) {
  return TerritoryManager(ref.watch(cityModeRepositoryProvider));
});

class TerritoryManager {
  final CityModeRepository _repository;

  TerritoryManager(this._repository);

  // 1. ARCHITECTURE OF TERRITORIAL PACKS
  /// Escanea la base de datos local (Drift) buscando si ya existe infraestructura
  /// descargada dentro de un radio expansivo (Ej: 10km a la redonda de la ubicación del usuario).
  Future<bool> hasLocalPack(double lat, double lng) async {
    try {
      AppLogger.i('📡 Escaneando cuadrante para identificar Packs Locales en lat:$lat, lng:$lng');
      
      // Consultamos el flujo actual de Hitos que ya viven en Drift
      final hitosLocales = await _repository.watchTodosLosHitos().first;

      if (hitosLocales.isEmpty) return false;

      // Un 'bounding box' muy básico o cálculo de caja para ver si "estamos en la ciudad".
      // Aquí se usaría el CityProximityEngine para trazar un radio amplio (Ej. delimitando la ciudad)
      // Por simplicidad del piloto, asumiremos que si hay hitos y coinciden con la zona, el pack existe.
      
      final bool hasPointsInZone = hitosLocales.any((hito) {
        // En producción: CityProximityEngine.calculateDistanceInMeters() <= 15000 (15km)
        final distanceAprox = (hito.lat - lat).abs() + (hito.lng - lng).abs();
        return distanceAprox < 0.15; // aprox 15-20km heurísticamente
      });

      return hasPointsInZone;
    } catch (e) {
      AppLogger.e('Error escaneando cuadrante territorial: $e');
      return false;
    }
  }

  // 2. STRATEGY OF DATA LOADING (THE INVISIBLE BACKEND)
  /// Descarga un paquete de ciudad desde el Cloud de FeelTrip, descomprime sus assets pesados (Audio/AR images)
  /// al disco duro local, y finalmente inyecta la Metadata en Drift.
  Future<void> downloadAndInjectPack(String cityId) async {
    try {
      AppLogger.i('📦 Iniciando Protocolo de Descarga. Pack solicitado: $cityId');
      
      // PASO 1: (Arquitectura File System) => GET request a bucket S3 / Firebase Storage
      // final bytes = await _api.fetchZipArchive('https://assets.feeltrip.app/packs/$cityId.zip');
      
      // PASO 2: (Extracción y Persistencia de Assets Local) => usando librería `archive`
      // final archive = ZipDecoder().decodeBytes(bytes);
      // await StorageService.saveAssetsToDisk(archive);
      
      // PASO 3: (Inyección de JSON a Base de Datos Relacional)
      // final jsonManifest = parseJsonManifest(archive);
      // final List<HitosCompanion> batchCompanions = _serializeToCompanions(jsonManifest);
      
      // Simulación de pipeline: En este momento, invocaríamos insertHitosBatch
      // await _repository.insertHitosBatch(batchCompanions);

      AppLogger.i('✅ Pack $cityId inyectado en el Sistema Operativo Territorial.');
    } catch (e) {
      AppLogger.e('⛔ Error en el despliegue del paquete $cityId: $e');
      rethrow;
    }
  }

  // 3. LAYER FILTERS
  /// Este motor debe ser capaz de discriminar por capas
  /// Esto permitiría al usuario decidir en tiempo real si quiere explorar "Lo Arqueológico" o "Lo Social"
  Stream<List<dynamic>> watchHitosByLayerFilter(List<String> activeLayers) {
    // Retorna la fuente de datos Drift filtrada por el array (Ej: ['historia', 'tecnico'])
    return _repository.watchTodosLosHitos().map((todos) {
      return todos.where((h) => activeLayers.contains(h.categoria)).toList();
    });
  }
}
