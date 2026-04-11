import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/firebase_config.dart';
import '../models/experience_model.dart';

class DiaryService {
  factory DiaryService() {
    return _instance;
  }

  DiaryService._internal();
  static final DiaryService _instance = DiaryService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============ CRUD OPERATIONS ============

  /// Obtener todas las entradas del diario de un usuario
  Future<List<DiaryEntry>> getDiaryEntries(String userId, {int limit = 100}) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(userId)
          .collection(FirebaseConfig.diaryEntriesSubcollection)
          .orderBy(FirebaseConfig.createdAtField, descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => DiaryEntry.fromFirestore(doc)).toList();
    } catch (e) {
      // log eliminado: ❌ Error fetching diary entries: $e
      rethrow;
    }
  }

  /// Obtener una entrada específica
  Future<DiaryEntry?> getDiaryEntry(String userId, String entryId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(userId)
          .collection(FirebaseConfig.diaryEntriesSubcollection)
          .doc(entryId)
          .get();

      if (doc.exists) {
        return DiaryEntry.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      // log eliminado: ❌ Error fetching diary entry: $e
      rethrow;
    }
  }

  /// Crear una nueva entrada de diario
  Future<String> createDiaryEntry(String userId, DiaryEntry entry) async {
    try {
      final now = DateTime.now();
      final entryData = {
        'id': entry.id,
        'content': entry.content,
        'emotions': entry.emotions,
        'reflectionDepth': entry.reflectionDepth,
        'createdAt': now,
        'updatedAt': now,
      };

      await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(userId)
          .collection(FirebaseConfig.diaryEntriesSubcollection)
          .doc(entry.id)
          .set(entryData);

      // Actualizar estadísticas del usuario
      await _updateUserDiaryStats(userId);
      return entry.id;
    } catch (e) {
      rethrow;
    }
  }

  /// Actualizar una entrada
  Future<void> updateDiaryEntry(String userId, String entryId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = DateTime.now();

      await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(userId)
          .collection(FirebaseConfig.diaryEntriesSubcollection)
          .doc(entryId)
          .update(updates);

      // Actualizar estadísticas
      await _updateUserDiaryStats(userId);
    } catch (e) {
      rethrow;
    }
  }

  /// Eliminar una entrada
  Future<void> deleteDiaryEntry(String userId, String entryId) async {
    try {
      await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(userId)
          .collection(FirebaseConfig.diaryEntriesSubcollection)
          .doc(entryId)
          .delete();

      // Actualizar estadísticas
      await _updateUserDiaryStats(userId);
    } catch (e) {
      rethrow;
    }
  }

  // ============ STREAM OPERATIONS ============

  /// Stream de entradas del diario en tiempo real
  Stream<List<DiaryEntry>> getDiaryEntriesStream(String userId) {
    try {
      return _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(userId)
          .collection(FirebaseConfig.diaryEntriesSubcollection)
          .orderBy(FirebaseConfig.createdAtField, descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => DiaryEntry.fromFirestore(doc)).toList());
    } catch (e) {
      rethrow;
    }
  }

  // ============ STATISTICS ============

  /// Obtener estadísticas del diario
  Future<Map<String, dynamic>> getDiaryStats(String userId) async {
    try {
      final doc = await _firestore.collection(FirebaseConfig.usersCollection).doc(userId).get();

      final Map<String, dynamic> stats =
          Map<String, dynamic>.from((doc.data()?['diaryStats'] as Map<String, dynamic>?) ?? {});
      return stats;
    } catch (_) {
      return {};
    }
  }

  /// Actualizar estadísticas del diario automáticamente
  Future<void> _updateUserDiaryStats(String userId) async {
    try {
      final entries = await getDiaryEntries(userId, limit: 1000);

      if (entries.isEmpty) {
        await _firestore.collection(FirebaseConfig.usersCollection).doc(userId).set({
          'diaryStats': {
            'entryCount': 0,
            'avgReflectionDepth': 0.0,
            'uniqueEmotionCount': 0,
            'overallImpactScore': 0,
            'lastEntryDate': null,
          },
        }, SetOptions(merge: true));
        return;
      }

      // Calcular profundidad promedio
      final double avgDepth =
          entries.map((e) => e.reflectionDepth).reduce((a, b) => a + b) / entries.length;

      // Contar emociones únicas
      final uniqueEmotions = <String>{};
      for (var entry in entries) {
        uniqueEmotions.addAll(entry.emotions);
      }

      // Calcular puntuación de impacto
      final int impactScore = ((avgDepth / 5) * 100).toInt();

      // Guardar estadísticas
      await _firestore.collection(FirebaseConfig.usersCollection).doc(userId).set({
        'diaryStats': {
          'entryCount': entries.length,
          'avgReflectionDepth': double.parse(avgDepth.toStringAsFixed(2)),
          'uniqueEmotionCount': uniqueEmotions.length,
          'overallImpactScore': impactScore,
          'lastEntryDate': entries.isNotEmpty ? entries.first.createdAt : null,
          'lastUpdated': DateTime.now(),
        },
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  // ============ FILTERS ============

  /// Obtener entradas por emoción específica
  Future<List<DiaryEntry>> getEntriesByEmotion(String userId, String emotion) async {
    try {
      final entries = await getDiaryEntries(userId);
      return entries.where((entry) => entry.emotions.contains(emotion)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener entradas en un rango de fechas
  Future<List<DiaryEntry>> getEntriesByDateRange(
      String userId, DateTime startDate, DateTime endDate) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(userId)
          .collection(FirebaseConfig.diaryEntriesSubcollection)
          .where(FirebaseConfig.createdAtField, isGreaterThanOrEqualTo: startDate)
          .where(FirebaseConfig.createdAtField, isLessThanOrEqualTo: endDate)
          .orderBy(FirebaseConfig.createdAtField, descending: true)
          .get();

      return snapshot.docs.map((doc) => DiaryEntry.fromFirestore(doc)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener entradas por profundidad mínima
  Future<List<DiaryEntry>> getEntriesByMinDepth(String userId, int minDepth) async {
    try {
      final entries = await getDiaryEntries(userId);
      return entries.where((entry) => entry.reflectionDepth >= minDepth).toList();
    } catch (e) {
      rethrow;
    }
  }

  // ============ EXPORT ============

  /// Exportar todas las entradas a JSON
  Future<List<Map<String, dynamic>>> exportDiaryAsJson(String userId) async {
    try {
      final entries = await getDiaryEntries(userId, limit: 10000);
      return entries.map((entry) => entry.toJson()).toList();
    } catch (e) {
      rethrow;
    }
  }
}
