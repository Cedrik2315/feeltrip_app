import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/achievement_model.dart';

class DiaryAchievementsService {
  DiaryAchievementsService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String _collection = 'user_achievements';
  static const String _firstStepId = 'primer_paso';
  static const String _emotionalAlchemistId = 'alquimista_emocional';
  static const String _lightHunterId = 'cazador_de_luces';

  Future<List<Achievement>> evaluateDiarySave({
    required String userId,
    required List<String> emotions,
    required List<Map<String, dynamic>> routeDetails,
  }) async {
    if (userId.trim().isEmpty) return <Achievement>[];

    final now = DateTime.now();
    final unlocked = <Achievement>[];

    final firstStepRef = _achievementRef(userId, _firstStepId);
    final emotionalRef = _achievementRef(userId, _emotionalAlchemistId);
    final lightHunterRef = _achievementRef(userId, _lightHunterId);

    final docs = await Future.wait([
      firstStepRef.get(),
      emotionalRef.get(),
      lightHunterRef.get(),
    ]);

    final hasFirstStep = docs[0].exists;
    final hasEmotionalAlchemist = docs[1].exists;
    final hasLightHunter = docs[2].exists;

    if (!hasFirstStep) {
      final anyEntry = await _firestore
          .collection('users')
          .doc(userId)
          .collection('diaryEntries')
          .limit(1)
          .get();
      if (anyEntry.docs.isNotEmpty) {
        unlocked.add(
          Achievement(
            id: _firstStepId,
            title: 'Primer Paso',
            description: 'Guardaste tu primer viaje en el diario.',
            iconName: 'explore',
            dateUnlocked: now,
          ),
        );
      }
    }

    if (!hasEmotionalAlchemist) {
      final weekAgo = Timestamp.fromDate(now.subtract(const Duration(days: 7)));
      final weeklyEntries = await _firestore
          .collection('users')
          .doc(userId)
          .collection('diaryEntries')
          .where('fecha', isGreaterThanOrEqualTo: weekAgo)
          .limit(100)
          .get();

      final unique = <String>{};
      for (final doc in weeklyEntries.docs) {
        final data = doc.data();
        final list = data['emociones'];
        if (list is List) {
          for (final raw in list) {
            final emotion = raw.toString().trim().toLowerCase();
            if (emotion.isNotEmpty) unique.add(emotion);
          }
        }
      }
      for (final raw in emotions) {
        final emotion = raw.trim().toLowerCase();
        if (emotion.isNotEmpty) unique.add(emotion);
      }

      if (unique.length >= 3) {
        unlocked.add(
          Achievement(
            id: _emotionalAlchemistId,
            title: 'Alquimista Emocional',
            description: 'Registraste 3 emociones diferentes en una semana.',
            iconName: 'auto_awesome',
            dateUnlocked: now,
          ),
        );
      }
    }

    if (!hasLightHunter) {
      final hasPhoto = routeDetails.any((stop) {
        final photoUrl = (stop['fotoUrl'] ?? '').toString().trim();
        return photoUrl.isNotEmpty;
      });
      if (hasPhoto) {
        unlocked.add(
          Achievement(
            id: _lightHunterId,
            title: 'Cazador de Luces',
            description: 'Subiste tu primera foto a un punto del mapa.',
            iconName: 'camera_alt',
            dateUnlocked: now,
          ),
        );
      }
    }

    if (unlocked.isEmpty) return unlocked;

    final batch = _firestore.batch();
    for (final achievement in unlocked) {
      batch.set(
        _achievementRef(userId, achievement.id),
        {
          ...achievement.toMap(),
          'userId': userId,
        },
      );
    }

    // Fórmula de Crecimiento: +200 XP por cada logro desbloqueado
    final xpBonus = unlocked.length * 200;
    batch.update(
      _firestore.collection('users').doc(userId),
      {'totalXP': FieldValue.increment(xpBonus)},
    );

    await batch.commit();

    return unlocked;
  }

  DocumentReference<Map<String, dynamic>> _achievementRef(
      String userId, String achievementId) {
    return _firestore.collection(_collection).doc('${userId}_$achievementId');
  }
}

/// Servicio compatible con la firma solicitada por el usuario.
/// Mantiene el estilo de uso simple y evita romper la implementación actual.
class AchievementService {
  AchievementService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  String? get _userId => _auth.currentUser?.uid;

  Stream<List<Map<String, dynamic>>> getUserAchievements(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('achievements')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'title': doc['title'] ?? 'Logro',
                  'emoji': _getEmojiForId(doc.id),
                  'unlocked': true, // Si existe en Firestore está desbloqueado
                  ...doc.data(),
                })
            .toList());
  }

  String _getEmojiForId(String id) {
    final emojis = {
      'primer_paso': '🌍',
      'cazador_luces': '📸',
      'alquimista_emocional': '✨',
      // Agregar más según sea necesario
    };
    return emojis[id] ?? '🏆';
  }

  Future<void> verificarYOtorgarLogros() async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) return;

    // 1) "Primer Paso": primer registro (trips o diaryEntries)
    final trips =
        await _db.collection('users').doc(userId).collection('trips').get();
    final diaryEntries = await _db
        .collection('users')
        .doc(userId)
        .collection('diaryEntries')
        .get();

    final totalEntries = trips.docs.length + diaryEntries.docs.length;
    if (totalEntries == 1) {
      await _otorgarLogro(
        userId,
        'primer_paso',
        'Primer Paso',
        '¡Tu viaje interior ha comenzado!',
      );
    }

    // 2) "Cazador de Luces": primera foto en trips o en rutaDetallada
    final tieneFotosEnTrips = trips.docs.any((doc) {
      final data = doc.data();
      final imageUrl = (data['imageUrl'] ?? '').toString().trim();
      return imageUrl.isNotEmpty;
    });

    final tieneFotosEnDiario = diaryEntries.docs.any((doc) {
      final data = doc.data();
      final routeDetails = data['rutaDetallada'];
      if (routeDetails is! List) return false;
      for (final stop in routeDetails) {
        if (stop is Map) {
          final photoUrl = (stop['fotoUrl'] ?? '').toString().trim();
          if (photoUrl.isNotEmpty) return true;
        }
      }
      return false;
    });

    if (tieneFotosEnTrips || tieneFotosEnDiario) {
      await _otorgarLogro(
        userId,
        'cazador_luces',
        'Cazador de Luces',
        'Capturaste tu primera memoria visual.',
      );
    }
  }

  Future<void> _otorgarLogro(
    String userId,
    String id,
    String title,
    String desc,
  ) async {
    final docRef =
        _db.collection('users').doc(userId).collection('achievements').doc(id);
    final doc = await docRef.get();
    if (doc.exists) return;

    await docRef.set({
      'id': id,
      'title': title,
      'description': desc,
      'unlockedAt': FieldValue.serverTimestamp(),
    });
  }
}
