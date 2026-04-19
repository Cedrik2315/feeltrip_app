import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/logger/app_logger.dart';
import 'package:permission_handler/permission_handler.dart';

final p2pMessagesProvider = StateProvider<List<String>>((ref) => []);

final p2pServiceProvider = Provider((ref) => P2PService(ref));

class P2PService {
  final Map<String, dynamic> _endpointMap = {};

  P2PService(Ref ref); // ref kept in signature for provider compatibility

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

  Future<void> startAdvertising(String userName) async {
    AppLogger.i('[MOCK] P2PService: startAdvertising called (disabled)');
  }

  Future<void> startDiscovery(String userName) async {
    AppLogger.i('[MOCK] P2PService: startDiscovery called (disabled)');
  }

  void stopAll() {
    _endpointMap.clear();
    AppLogger.i('[MOCK] P2PService: Servicios P2P detenidos correctamente.');
  }

  void broadcastMessage(String message) {
    AppLogger.i('[MOCK] P2PService: broadcastMessage called: $message');
  }

  Future<void> sendMessage(String endpointId, String message) async {
    AppLogger.i('[MOCK] P2PService: sendMessage called: $message');
  }

  List<String> get connectedEndpoints => _endpointMap.keys.toList();
}