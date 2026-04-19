import 'dart:typed_data';
import 'dart:convert';
import 'nearby_connections.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/logger/app_logger.dart';
import 'package:permission_handler/permission_handler.dart';
/// Provider para los mensajes recibidos mediante P2P.
final p2pMessagesProvider = StateProvider<List<String>>((ref) => []);

/// Provider para acceder al servicio de comunicación P2P desde cualquier parte de la app.
final p2pServiceProvider = Provider((ref) => P2PService(ref));

/// Servicio encargado de la comunicación Offline mediante Google Nearby Connections.
/// Ideal para guías que desean transmitir crónicas o datos históricos en zonas remotas.
class P2PService {
  final Ref _ref;
  final Strategy _strategy = Strategy.P2P_STAR;
  final Map<String, ConnectionInfo> _endpointMap = {};

  P2PService(this._ref);

  /// Verifica y solicita permisos de Ubicación y Bluetooth.
  /// Es vital llamar a esto antes de iniciar cualquier operación P2P.
  Future<bool> checkAndRequestPermissions() async {
    final statuses = await [
      Permission.location,
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
    ].request();

    bool locationFinal = statuses[Permission.location]?.isGranted ?? false;
    bool bluetoothFinal = (statuses[Permission.bluetoothScan]?.isGranted ?? false) &&
        (statuses[Permission.bluetoothAdvertise]?.isGranted ?? false) &&
        (statuses[Permission.bluetoothConnect]?.isGranted ?? false);

    return locationFinal && bluetoothFinal;
  }

  /// Inicia el modo Anuncio para ser descubierto por otros viajeros.
  /// @param userName Nombre que verán los demás dispositivos.
  Future<void> startAdvertising(String userName) async {
    try {
      final success = await Nearby().startAdvertising(
        userName,
        _strategy,
        onConnectionInitiated: _onConnectionInit,
        onConnectionResult: (id, status) {
          AppLogger.i('P2PService: Resultado de conexión con $id: $status');
        },
        onDisconnected: (id) {
          _endpointMap.remove(id);
          AppLogger.i('P2PService: Dispositivo $id desconectado.');
        },
      );
      AppLogger.i('P2PService: Estado de inicio de anuncio: $success');
    } catch (e) {
      AppLogger.e('P2PService: Error al iniciar anuncio: $e');
    }
  }

  /// Inicia la búsqueda de dispositivos cercanos (Modo Viajero).
  Future<void> startDiscovery(String userName) async {
    try {
      final success = await Nearby().startDiscovery(
        userName,
        _strategy,
        onEndpointFound: (id, name, serviceId) {
          AppLogger.i('P2PService: Endpoint detectado: $name ($id). Solicitando conexión...');
          Nearby().requestConnection(
            userName,
            id,
            onConnectionInitiated: _onConnectionInit,
            onConnectionResult: (id, status) {
              AppLogger.i('P2PService: Resultado de conexión con $id: $status');
            },
            onDisconnected: (id) {
              _endpointMap.remove(id);
              AppLogger.i('P2PService: Dispositivo $id desconectado.');
            },
          );
        },
        onEndpointLost: (id) {
          AppLogger.i('P2PService: Endpoint fuera de rango: $id');
        },
      );
      AppLogger.i('P2PService: Estado de inicio de descubrimiento: $success');
    } catch (e) {
      AppLogger.e('P2PService: Error al iniciar descubrimiento: $e');
    }
  }

  /// Detiene todos los servicios y limpia la lista de conexiones.
  void stopAll() {
    Nearby().stopAdvertising();
    Nearby().stopDiscovery();
    Nearby().stopAllEndpoints();
    _endpointMap.clear();
    AppLogger.i('P2PService: Servicios P2P detenidos correctamente.');
  }

  /// Lógica de aceptación de conexión y recepción de payloads.
  void _onConnectionInit(String id, ConnectionInfo info) {
    AppLogger.i('P2PService: Intento de conexión de ${info.endpointName}');
    _endpointMap[id] = info;

    // En FeelTrip aceptamos automáticamente para facilitar la experiencia en grupo.
    Nearby().acceptConnection(
      id,
      onPayLoadRecieved: (id, payload) {
        _handlePayload(id, payload);
      },
    );
  }

  void _handlePayload(String id, Payload payload) {
    if (payload.type == PayloadType.BYTES && payload.bytes != null) {
      final message = utf8.decode(payload.bytes!);
      final sender = _endpointMap[id]?.endpointName ?? 'Desconocido';
      
      AppLogger.i('P2PService: Mensaje de $sender: $message');
      
      // Actualizamos el estado para que la UI reaccione
      _ref.read(p2pMessagesProvider.notifier).update((state) => 
        [...state, '$sender: $message']
      );
    }
  }

  /// Envía un mensaje a todos los dispositivos conectados.
  void broadcastMessage(String message) {
    for (String id in _endpointMap.keys) {
      sendMessage(id, message);
    }
  }

  /// Envía un mensaje de texto a un par específico.
  Future<void> sendMessage(String endpointId, String message) async {
    try {
      await Nearby().sendBytesPayload(
        endpointId,
        Uint8List.fromList(utf8.encode(message)),
      );
    } catch (e) {
      AppLogger.e('P2PService: Error al enviar mensaje: $e');
    }
  }

  /// Devuelve la lista de dispositivos conectados actualmente.
  List<String> get connectedEndpoints => _endpointMap.keys.toList();
}