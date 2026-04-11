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
  void monitorConnection() {
    // CORRECCIÓN: En la versión 5.0.2 se recibe un solo ConnectivityResult, no una lista.
    _connectivity.onConnectivityChanged
        .listen((ConnectivityResult result) {
      final voice = _ref.read(voiceServiceProvider);

      // Verificamos si el resultado es 'none'
      if (result == ConnectivityResult.none) {
        AppLogger.w('Conexión perdida');
        voice.speak(
            'Atención Cedrik, se ha perdido la conexión a internet. Activando modo local.');
        _wasOffline = true;
      } else if (_wasOffline) {
        // Si antes estábamos offline y ahora el resultado no es 'none', hemos vuelto.
        AppLogger.i('Conexión restablecida');
        voice.speak('Conexión restablecida. Sincronizando datos de FeelTrip.');
        _wasOffline = false;
      }
    });
  }
}