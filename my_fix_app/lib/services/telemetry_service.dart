import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';

final telemetryServiceProvider = Provider<TelemetryService>((ref) => TelemetryService());

/// Servicio encargado de alimentar el Dashboard Externo B2B.
/// Envía eventos estandarizados a Firestore para análisis de KPIs.
class TelemetryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Registra un evento agéntico para análisis de conversión y comportamiento.
  Future<void> logAgentEvent({
    required String eventName,
    required Map<String, dynamic> metadata,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('telemetry_events').add({
        'userId': user.uid,
        'event': eventName,
        'timestamp': FieldValue.serverTimestamp(),
        'platform': 'mobile',
        'metadata': metadata,
      });
      AppLogger.d('TelemetryService: Evento $eventName registrado.');
    } catch (e) {
      AppLogger.e('TelemetryService: Error al registrar evento', e);
    }
  }

  /// Registra un cambio de arquetipo detectado por el Scout Agent.
  /// Vital para el "Mapa de Calor Emocional" del Dashboard B2B.
  Future<void> logArchetypeShift({
    required String oldArchetype,
    required String newArchetype,
    required double intensity,
  }) async {
    await logAgentEvent(
      eventName: 'archetype_shift',
      metadata: {
        'from': oldArchetype,
        'to': newArchetype,
        'intensity': intensity,
      },
    );
  }

  /// Registra una intención de compra o uso de enlace de afiliado.
  Future<void> logConversionIntent(String provider, String destination) async {
    await logAgentEvent(
      eventName: 'conversion_intent',
      metadata: {'provider': provider, 'destination': destination},
    );
  }
}