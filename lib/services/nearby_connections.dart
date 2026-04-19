import 'dart:typed_data';

/// Estrategias de conexión para Nearby Connections.
enum Strategy {
  P2P_STAR,
  P2P_CLUSTER,
  P2P_POINT_TO_POINT,
}

/// Tipos de carga útil (payload).
enum PayloadType {
  BYTES,
  FILE,
  STREAM,
}

/// Estado de la conexión.
enum Status {
  CONNECTED,
  REJECTED,
  ERROR,
}

/// Información de la conexión recibida al iniciar un vínculo.
class ConnectionInfo {
  final String endpointName;
  final String authenticationToken;
  final bool isIncomingConnection;

  ConnectionInfo(this.endpointName, this.authenticationToken, this.isIncomingConnection);
}

/// Representación de los datos enviados o recibidos.
class Payload {
  final int id;
  final PayloadType type;
  final Uint8List? bytes;
  final String? filePath;

  Payload({required this.id, required this.type, this.bytes, this.filePath});
}

/// Estado de la transferencia de un payload.
enum PayloadStatus {
  IN_PROGRESS,
  SUCCESS,
  FAILURE,
}

class PayloadTransferUpdate {
  final int payloadId;
  final PayloadStatus status;
  final int bytesTransferred;
  final int totalBytes;

  PayloadTransferUpdate({
    required this.payloadId,
    required this.status,
    required this.bytesTransferred,
    required this.totalBytes,
  });
}

typedef OnConnectionInitiated = void Function(String endpointId, ConnectionInfo connectionInfo);
typedef OnConnectionResult = void Function(String endpointId, Status status);
typedef OnDisconnected = void Function(String endpointId);
typedef OnEndpointFound = void Function(String endpointId, String endpointName, String serviceId);
typedef OnEndpointLost = void Function(String endpointId);
typedef OnPayloadReceived = void Function(String endpointId, Payload payload);
typedef OnPayloadTransferUpdate = void Function(String endpointId, PayloadTransferUpdate payloadTransferUpdate);

/// Clase principal que maneja la lógica de Google Nearby Connections.
class Nearby {
  static final Nearby _instance = Nearby._internal();
  factory Nearby() => _instance;
  Nearby._internal();

  Future<bool> startAdvertising(
    String userNickname,
    Strategy strategy, {
    required OnConnectionInitiated onConnectionInitiated,
    required OnConnectionResult onConnectionResult,
    required OnDisconnected onDisconnected,
    String serviceId = "feeltrip_p2p_service",
  }) async {
    return true;
  }

  Future<bool> startDiscovery(
    String userNickname,
    Strategy strategy, {
    required OnEndpointFound onEndpointFound,
    required OnEndpointLost onEndpointLost,
    // ignore: prefer_single_quotes
    String serviceId = "feeltrip_p2p_service",
  }) async {
    return true;
  }

  void stopAdvertising() {}
  void stopDiscovery() {}
  void stopAllEndpoints() {}

  Future<void> acceptConnection(
    String endpointId, {
    required OnPayloadReceived onPayLoadRecieved,
    OnPayloadTransferUpdate? onPayloadTransferUpdate,
  }) async {}

  Future<void> requestConnection(
    String userNickname,
    String endpointId, {
    required OnConnectionInitiated onConnectionInitiated,
    required OnConnectionResult onConnectionResult,
    required OnDisconnected onDisconnected,
  }) async {}

  Future<void> sendBytesPayload(String endpointId, Uint8List bytes) async {}
}