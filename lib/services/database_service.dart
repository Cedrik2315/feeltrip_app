import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/experience_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Getter for current user ID
  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  // GUARDAR UNA NUEVA ENTRADA (guardarEntrada)
  Future<void> guardarEntrada({
    required String texto,
    required List<String> emociones,
    String? destino,
    double? lat,
    double? lng,
    String? explicacion,
    List<Map<String, dynamic>>? rutaDetallada,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final entryData = {
        'texto': texto,
        'emociones': emociones,
        'destino': destino,
        'lat': lat,
        'lng': lng,
        'explicacion': explicacion,
        'rutaDetallada': rutaDetallada,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _db.collection('entries').add(entryData);
      debugPrint("¡Recuerdo guardado con éxito!");
    } catch (e) {
      debugPrint("Error al guardar: $e");
      rethrow;
    }
  }

  // Stream de entradas (obtenerEntradas)
  Stream<List<DiaryEntry>> obtenerEntradas() {
    final currentUid = uid;
    if (currentUid == null) {
      return Stream.value([]);
    }

    return _db
        .collection('entries')
        .where('userId', isEqualTo: currentUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return DiaryEntry(
                id: doc.id,
                userId: data['userId'] ?? '',
                imageUrl: data['imageUrl'] ?? '',
                title: data['title'] ?? data['texto'] ?? '',
                content: data['content'] ?? data['texto'] ?? '',
                emotions: List<String>.from(
                    data['emotions'] ?? data['emociones'] ?? []),
                reflectionDepth: data['reflectionDepth'] ?? 3,
                createdAt: (data['createdAt'] as Timestamp?)?.toDate() ??
                    DateTime.now(),
              );
            }).toList());
  }

  // Obtener estadísticas semanales (obtenerEstadisticasSemanales)
  Future<Map<String, int>> obtenerEstadisticasSemanales() async {
    try {
      final userId = currentUserId;
      if (userId == null) return {};

      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));

      final snapshot = await _db
          .collection('entries')
          .where('userId', isEqualTo: userId)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(weekAgo))
          .get();

      // Count emotions from entries
      final emotionCounts = <String, int>{};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final emociones = List<String>.from(data['emociones'] ?? []);
        for (var emotion in emociones) {
          emotionCounts[emotion] = (emotionCounts[emotion] ?? 0) + 1;
        }
      }

      return emotionCounts;
    } catch (e) {
      debugPrint("Error getting stats: $e");
      return {};
    }
  }

  // GUARDAR UNA NUEVA ENTRADA (alias for saveEntry)
  Future<void> saveEntry(DiaryEntry entry) async {
    try {
      await _db.collection('entries').add(entry.toMap());
      debugPrint("¡Recuerdo guardado con éxito!");
    } catch (e) {
      debugPrint("Error al guardar: $e");
      rethrow;
    }
  }

  // LEER TODAS LAS ENTRADAS (Para tu Diario de Lujo)
  Stream<List<DiaryEntry>> get entries {
    final currentUid = uid;
    if (currentUid == null) {
      return Stream.value([]);
    }

    return _db
        .collection('entries')
        .where('userId', isEqualTo: currentUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return DiaryEntry.fromFirestore(doc);
            }).toList());
  }
}
