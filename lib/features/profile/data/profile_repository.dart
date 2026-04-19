import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/user_profile_model.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';

/// Repository for profile CRUD operations with Firestore.
/// Handles auth user profiles, creates initial profile if missing.
class ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Fetches user profile from Firestore, creates initial if missing.
  Future<UserProfile?> getUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        // Cambiamos a nivel info ya que es un estado normal antes del login
        AppLogger.i('ProfileRepository: No authenticated user. Skipping profile fetch.');
        return null;
      }

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        // Create initial profile (First Run)
        final newProfile = UserProfile.empty(user.uid, user.displayName ?? 'Explorador');
        await saveProfile(newProfile);
        return newProfile;
      }

      return _mapSnapshotToProfile(doc);
    } on FirebaseException catch (e) {
      AppLogger.e('ProfileRepository: Error fetching profile', e);
      rethrow;
    }
  }

  /// Saves or merges full profile to Firestore.
  Future<void> saveProfile(UserProfile profile) async {
    try {
      await _firestore.collection('users').doc(profile.uid).set({
        'username': profile.username,
        'rank': profile.rank,
        'experienceProgress': profile.experienceProgress,
        'profileImageUrl': profile.profileImageUrl,
        'totalKm': profile.totalKm,
        'photosAnalyzed': profile.photosAnalyzed,
        'daysActive': profile.daysActive,
        'emotionalStats': profile.emotionalStats,
        'archetype': profile.archetype,
        // Only unlocked badges to save space
        'unlockedBadges': List<String>.from(
            profile.badges.where((b) => b.isUnlocked).map((b) => b.id)),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      AppLogger.e('ProfileRepository: Error saving profile', e);
      rethrow;
    }
  }

  /// Atomically increments photo scan count, creates profile if missing.
  Future<void> incrementScanCount() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final docRef = _firestore.collection('users').doc(uid);
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
      AppLogger.e('ProfileRepository: Error incrementing scan count', e);
    }
  }

  UserProfile _mapSnapshotToProfile(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final unlockedIds = List<String>.from(
        (data['unlockedBadges'] as Iterable?) ?? <String>[]);

    return UserProfile(
      uid: doc.id,
      username: data['username'] as String? ?? 'Explorador',
      rank: data['rank'] as String? ?? 'RECRUIT',
      experienceProgress:
          ((data['experienceProgress'] as num?) ?? 0.0).toDouble(),
      profileImageUrl: data['profileImageUrl'] as String?,
      totalKm: (data['totalKm'] as num?)?.toInt() ?? 0,
      photosAnalyzed: (data['photosAnalyzed'] as num?)?.toInt() ?? 0,
      daysActive: (data['daysActive'] as num?)?.toInt() ?? 1,
      emotionalStats: (data['emotionalStats'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, (v as num).toDouble())) ??
          <String, double>{},
      badges: _getStaticBadgesList(unlockedIds),
      archetype: data['archetype'] as String?,
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
