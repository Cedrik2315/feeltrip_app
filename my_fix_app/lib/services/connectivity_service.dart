import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:feeltrip_app/services/voice_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';

/// Provider para el servicio de conectividad.
final connectivityServiceProvider = Provider((ref) => ConnectivityService(ref));

class ConnectivityService {
  ConnectivityService(this._ref);
  final Ref _ref;
  final Connectivity _connectivity = Connectivity();
  bool _wasOffline = false;

  /// Inicia el monitoreo del estado de red.
  Future<void> monitorConnection() async {
    // Esperamos un momento a que el sistema operativo estabilice los servicios de red para la app
    await Future.delayed(const Duration(seconds: 3));
    
    final initialResults = await _connectivity.checkConnectivity();
    await _handleResult(initialResults.first, isInitial: true);

    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        _handleResult(results.first);
      }
    });
  }

  Future<void> _handleResult(ConnectivityResult result, {bool isInitial = false}) async {
    final voice = _ref.read(voiceServiceProvider);
    
    if (result == ConnectivityResult.none) {
      // Doble verificación: ¿Realmente no hay internet o es un error del plugin?
      final hasRealInternet = await _confirmRealInternet();
      
      if (!hasRealInternet && !_wasOffline) {
        AppLogger.w('Conexión perdida real confirmada');
        if (!isInitial) {
           voice.speak('Atención Cedrik, señal satelital perdida. Entrando en protocolo de cache local.');
        }
        _wasOffline = true;
      }
    } else {
      if (_wasOffline) {
        AppLogger.i('Conexión restablecida');
        voice.speak('Señal recuperada. Sincronizando con la red FeelTrip.');
        _wasOffline = false;
      }
    }
  }

  /// Verifica si realmente hay acceso a internet intentando una resolución DNS simple.
  Future<bool> _confirmRealInternet() async {
    try {
      final result = await Future.any([
        InternetAddress.lookup('google.com'),
        Future.delayed(const Duration(seconds: 2), () => <InternetAddress>[]),
      ]);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}