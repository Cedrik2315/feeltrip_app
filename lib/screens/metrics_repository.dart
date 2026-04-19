import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';

class MetricsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Obtiene el impacto real acumulado del usuario
  Stream<Map<String, dynamic>> getImpactMetrics(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) {
          final data = doc.data() ?? {};
          return {
            'total_km': data['totalKm'] ?? 0.0,
            'photos_analyzed': data['photosAnalyzed'] ?? 0,
            'days_active': data['daysActive'] ?? 1,
            'avg_hrv': (data['biometrics'] as Map<String, dynamic>?)?['avgHRV'] ?? 72.0, // Dato de Wear OS
            'emotional_balance': (data['ai_profile'] as Map<String, dynamic>?)?['balance'] ?? 0.5,
          };
        });
  }

  /// Sincroniza datos biométricos reales capturados desde Wear OS
  Future<void> syncBiometrics(String uid, double hrv, int pulse) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'biometrics': {
          'lastHRV': hrv,
          'lastPulse': pulse,
          'updatedAt': FieldValue.serverTimestamp(),
        }
      }, SetOptions(merge: true));
      AppLogger.i('Métricas biométricas actualizadas en producción.');
    } catch (e) {
      AppLogger.e('Error sincronizando biometría: $e');
    }
  }
}