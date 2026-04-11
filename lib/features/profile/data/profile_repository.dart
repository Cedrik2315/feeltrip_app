import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/user_profile_model.dart';

/// Repository for profile CRUD operations with Firestore.
/// Handles auth user profiles, creates initial profile if missing.
class ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Fetches user profile from Firestore, creates initial if missing.
  Future<UserProfile?> getUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('profiles').doc(user.uid).get();
      
      if (!doc.exists) {
        // Create initial profile (First Run)
        final newProfile = UserProfile.empty(user.uid, user.displayName ?? 'Explorador');
        await saveProfile(newProfile);
        return newProfile;
      }

      return _mapSnapshotToProfile(doc);
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('Profile fetch error: ${e.message}');
      }
      rethrow;
    }
  }

  /// Saves or merges full profile to Firestore.
  Future<void> saveProfile(UserProfile profile) async {
    try {
      await _firestore.collection('profiles').doc(profile.uid).set({
        'username': profile.username,
        'rank': profile.rank,
        'experienceProgress': profile.experienceProgress,
        'profileImageUrl': profile.profileImageUrl,
        'totalKm': profile.totalKm,
        'photosAnalyzed': profile.photosAnalyzed,
        'daysActive': profile.daysActive,
'emotionalStats': profile.emotionalStats,
        // Only unlocked badges to save space
'unlockedBadges': List<String>.from(profile.badges.where((b) => b.isUnlocked).map((b) => b.id)),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('Profile save error: ${e.message}');
      }
      rethrow;
    }
  }

  /// Atomically increments photo scan count, creates profile if missing.
  Future<void> incrementScanCount() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final docRef = _firestore.collection('profiles').doc(uid);
      final doc = await docRef.get();
      if (!doc.exists) {
        // Create minimal profile
        await docRef.set({
          'photosAnalyzed': 1,
          'username': 'Explorador',
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        await docRef.update({
          'photosAnalyzed': FieldValue.increment(1),
        });
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('Scan increment error: ${e.message}');
      }
    }
  }

  UserProfile _mapSnapshotToProfile(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    final unlockedIds = List<String>.from((data['unlockedBadges'] as Iterable?) ?? <String>[]);

    return UserProfile(
      uid: doc.id,
      username: data['username'] as String? ?? 'Explorador',
      rank: data['rank'] as String? ?? 'RECRUIT',
      experienceProgress: ((data['experienceProgress'] as num?) ?? 0.0).toDouble(),
      profileImageUrl: data['profileImageUrl'] as String?,
      totalKm: (data['totalKm'] as num?)?.toInt() ?? 0,
      photosAnalyzed: (data['photosAnalyzed'] as num?)?.toInt() ?? 0,
      daysActive: (data['daysActive'] as num?)?.toInt() ?? 1,
      emotionalStats: (data['emotionalStats'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, (v as num).toDouble())) ?? <String, double>{},
      badges: _getStaticBadgesList(unlockedIds),
    );
  }

  /// Reconstructs full badges list from unlocked IDs (static MVP data).
  List<BadgeModel> _getStaticBadgesList(List<String> unlockedIds) {
    final allBadges = [
      BadgeModel(
        id: 'vision_first',
        label: 'Vision',
        description: 'Primer análisis de escena completado.',
        iconCodePoint: 59369, // Icons.camera
      ),
      BadgeModel(
        id: 'travel_5',
        label: 'Rutas',
        description: 'Has guardado 5 destinos.',
        iconCodePoint: 59536, // Icons.map
      ),
      BadgeModel(
        id: 'mountain_climber',
        label: 'Cumbres',
        description: 'Destino detectado en alta montaña.',
        iconCodePoint: 59473, // Icons.terrain
      ),
    ];

    return allBadges.map((b) => b.copyWith(isUnlocked: unlockedIds.contains(b.id))).toList();
  }
}
