import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../core/logger/app_logger.dart';

/// Modelo de la Cápsula del Tiempo (Anónima)
class LegacyCapsule {
  final String phrase;
  final double latitude;
  final double longitude;
  final String emotionalState;
  final DateTime timestamp;

  LegacyCapsule({
    required this.phrase,
    required this.latitude,
    required this.longitude,
    required this.emotionalState,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'phrase': phrase,
    'location': GeoPoint(latitude, longitude),
    'emotionalState': emotionalState,
    'timestamp': FieldValue.serverTimestamp(),
    'isLegacy': true, // Marca para distinguir de momentos normales
  };
}

final legacyCapsuleServiceProvider = Provider((ref) => LegacyCapsuleService());

/// 🏺 SERVICIO DE TESTAMENTO DEL EXPLORADOR
/// 
/// Gestiona la creación de huellas anónimas y permanentes en el mapa.
class LegacyCapsuleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Guarda una cápsula anónima e indestructible
  Future<bool> leaveLegacy({
    required String phrase,
    required String emotionalState,
  }) async {
    try {
      AppLogger.i('LegacyService: Intentando dejar Testamento del Explorador...');
      
      // Obtenemos ubicación actual para la huella
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 5),
        );
      } catch (e) {
        AppLogger.w('LegacyService: No se pudo obtener GPS, usando coordenadas 0,0');
      }

      final capsule = LegacyCapsule(
        phrase: phrase,
        latitude: position?.latitude ?? 0.0,
        longitude: position?.longitude ?? 0.0,
        emotionalState: emotionalState,
        timestamp: DateTime.now(),
      );

      // Guardamos en una colección PÚBLICA y ANÓNIMA
      // Esta colección NO se borra cuando el usuario elimina su cuenta
      await _firestore.collection('legacy_capsules').add(capsule.toJson());

      AppLogger.i('LegacyService: Huella grabada en el territorio con éxito. ✅');
      return true;
    } catch (e) {
      AppLogger.e('LegacyService: Error al dejar huella: $e');
      return false;
    }
  }

  /// Recupera cápsulas cercanas para futuros exploradores
  Stream<List<LegacyCapsule>> getNearbyCapsules(double lat, double lng, double radiusKm) {
    // Implementación simplificada para el mapa
    return _firestore.collection('legacy_capsules')
        .limit(20)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            final geo = data['location'] as GeoPoint;
            return LegacyCapsule(
              phrase: data['phrase'] as String,
              latitude: geo.latitude,
              longitude: geo.longitude,
              emotionalState: data['emotionalState'] as String,
              timestamp: (data['timestamp'] as Timestamp).toDate(),
            );
          }).toList();
        });
  }
}
