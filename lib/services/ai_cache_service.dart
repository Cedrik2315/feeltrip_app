import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:feeltrip_app/core/logger/app_logger.dart';

class AiCacheService {
  final _firestore = FirebaseFirestore.instance;
  final String _collection = 'ai_responses_cache';

  /// Genera una llave única basada en el prompt para el cache.
  String _generateKey(String prompt) {
    return sha256.convert(utf8.encode(prompt.trim().toLowerCase())).toString();
  }

  /// Intenta obtener una respuesta cacheada para un prompt.
  Future<String?> getCachedResponse(String prompt) async {
    final key = _generateKey(prompt);
    try {
      final doc = await _firestore.collection(_collection).doc(key).get();
      if (doc.exists) {
        AppLogger.i('AiCacheService: Cache hit para el prompt.');
        return doc.data()?['response'] as String?;
      }
    } catch (e) {
      AppLogger.e('AiCacheService: Error al leer cache: $e');
    }
    return null;
  }

  /// Guarda una respuesta en el cache de Firestore.
  Future<void> cacheResponse(String prompt, String response) async {
    final key = _generateKey(prompt);
    try {
      await _firestore.collection(_collection).doc(key).set({
        'prompt': prompt,
        'response': response,
        'createdAt': FieldValue.serverTimestamp(),
        'ttl': DateTime.now().add(const Duration(days: 7)).millisecondsSinceEpoch, // Expira en 7 días
      });
      AppLogger.i('AiCacheService: Respuesta cacheada con éxito.');
    } catch (e) {
      AppLogger.e('AiCacheService: Error al guardar en cache: $e');
    }
  }
}