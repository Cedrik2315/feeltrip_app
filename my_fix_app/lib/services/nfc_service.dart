import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';

/// Servicio encargado de la interacción con etiquetas NFC para artefactos físicos.
/// En un escenario real, usaría 'nfc_manager' o similar.
class NfcService {

  NfcService();

  /// Simula la escritura de un Viaje en un sticker NFC físico.
  Future<bool> writeTripToArtifact(int viajeId) async {
    AppLogger.i('🛰️ Iniciando protocolo de escritura NFC para Viaje #$viajeId');
    
    // Simulación de latencia de hardware
    await Future.delayed(const Duration(seconds: 2));
    
    // Aquí iría la lógica de:
    // 1. Verificar si el dispositivo soporta NFC.
    // 2. Esperar a que el usuario acerque el sticker.
    // 3. Escribir el NDEF Record: 'feeltrip://artifact/$viajeId'
    
    AppLogger.i('✅ Vínculo físico-digital establecido para el Artefacto.');
    return true;
  }

  /// Procesa un link escaneado vía NFC.
  void processNfcTag(String deepLink) {
    if (deepLink.startsWith('feeltrip://artifact/')) {
      final viajeId = deepLink.split('/').last;
      AppLogger.i('🔍 Artefacto escaneado detectado. Viaje ID: $viajeId');
      // TODO: Navegar a la pantalla de Resumen de Impacto
    }
  }
}

final nfcServiceProvider = Provider((ref) => NfcService());
