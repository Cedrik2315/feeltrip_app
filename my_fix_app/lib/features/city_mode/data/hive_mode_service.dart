import 'dart:async';
import 'package:feeltrip_app/core/logger/app_logger.dart';
import 'package:feeltrip_app/features/city_mode/data/drift_database.dart';
import 'package:drift/drift.dart' as drift;
import 'package:geolocator/geolocator.dart';

class HiveModeService {
  final AppDatabase _db;
  StreamSubscription<Position>? _gpsSubscription;

  HiveModeService(this._db);

  /// Inicia el monitoreo sigiloso del "Modo Colmena".
  /// Analiza biometría (simulada) y geolocalización para detectar asombro espontáneo.
  void startHiveMonitoring() {
    AppLogger.i('🧿 Modo Colmena Activado: Escaneando resonancia emocional del territorio...');

    _gpsSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      _analyzeBiometricSpike(position);
    });
  }

  /// Simulación de análisis de HRV (Heart Rate Variability).
  /// Si detecta una calma profunda (paz) o una excitación súbita (asombro),
  /// crea un nodo emocional en el mapa de forma autónoma.
  void _analyzeBiometricSpike(Position position) async {
    // Simulación: 5% de probabilidad de encontrar un momento de "asombro" en cada escaneo
    final randomValue = DateTime.now().millisecond % 100;
    
    if (randomValue < 5) {
      AppLogger.i('🔥 ¡Pico Emocional Detectado! Asombro registrado en lat:${position.latitude}');
      
      // 1. Grabación Silenciosa (Simulada)
      final String fakeAudioPath = '/storage/hive_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      AppLogger.i('🎤 Grabando 10s de ambiente para capturar el "espíritu del lugar"...');
      
      // 2. Persistencia en la Base de Datos Global
      await _db.into(_db.anomaliasEmocionales).insert(
        AnomaliasEmocionalesCompanion.insert(
          lat: position.latitude,
          lng: position.longitude,
          tipoEmocion: 'asombro',
          intensidadHrv: 95, // Representa impacto profundo
          audioAmbientalPath: drift.Value(fakeAudioPath),
        ),
      );
      
      AppLogger.i('✅ Anomalía Emocional sellada en el tejido del mapa.');
    }
  }

  void stopHiveMonitoring() {
    _gpsSubscription?.cancel();
    AppLogger.i('🛑 Modo Colmena Desactivado.');
  }
}
