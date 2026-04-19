import 'package:flutter/services.dart';

/// Servicio de comunicación con dispositivo Wear OS.
/// Usa el canal nativo de Android (MethodChannel) para enviarel estado
/// de la expedición activa al módulo Wear OS vía Data Layer API.
class WearSyncService {
  static const _channel = MethodChannel('feeltrip.app/wear_sync');

  /// Envía el estado actual de la expedición al reloj.
  Future<void> syncExpeditionStatus({
    required String destination,
    required double distanceKm,
    required int heartRate,
    required bool isActive,
  }) async {
    try {
      await _channel.invokeMethod('syncExpedition', {
        'destination': destination,
        'distanceKm': distanceKm,
        'heartRate': heartRate,
        'isActive': isActive,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } on PlatformException catch (_) {
      // El reloj puede no estar conectado — falla silenciosamente
    }
  }

  /// Envía una alerta de punto de interés cercano al reloj.
  Future<void> notifyNearbyPOI({
    required String name,
    required double distanceMeters,
  }) async {
    try {
      await _channel.invokeMethod('notifyPOI', {
        'name': name,
        'distanceMeters': distanceMeters,
      });
    } on PlatformException catch (_) {}
  }

  /// Verifica si hay un reloj Wear OS conectado.
  Future<bool> isWatchConnected() async {
    try {
      final result = await _channel.invokeMethod<bool>('isConnected');
      return result ?? false;
    } on PlatformException catch (_) {
      return false;
    }
  }
}
