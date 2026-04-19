import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'isar_service.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';

class AiCacheService {
  final IsarService _isar = IsarService();

  /// Genera una llave única basada en el prompt para el cache.
  String _generateKey(String prompt) {
    return sha256.convert(utf8.encode(prompt.trim().toLowerCase())).toString();
  }

  /// Intenta obtener una respuesta cacheada localmente.
  Future<String?> getCachedResponse(String prompt) async {
    final key = _generateKey(prompt);
    try {
      final cached = await _isar.getAiResponse(key);
      if (cached != null) {
        AppLogger.i('AiCacheService: Cache HIT local.');
        return cached;
      }
    } catch (e) {
      AppLogger.e('AiCacheService: Error al leer cache local: $e');
    }
    return null;
  }

  /// Guarda una respuesta en el cache local de Isar.
  Future<void> cacheResponse(String prompt, String response) async {
    final key = _generateKey(prompt);
    try {
      await _isar.putAiResponse(key, response);
      AppLogger.i('AiCacheService: Respuesta guardada en cache local (30 días de TTL).');
    } catch (e) {
      AppLogger.e('AiCacheService: Error al guardar en cache local: $e');
    }
  }
}