import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Follow a user (task #3)
  Future<void> followUser(String currentUserId, String targetUserId) async {
    try {
      // Add to current user's following
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('following')
          .doc(targetUserId)
          .set({'followedAt': FieldValue.serverTimestamp()});

      // Add to target user's followers
      await _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('followers')
          .doc(currentUserId)
          .set({'followedBy': FieldValue.serverTimestamp()});

      // log eliminado: ✅ Followed user $targetUserId
    } catch (e) {
      // log eliminado: ❌ Error following user: $e
      rethrow;
    }
  }

  /// Unfollow a user (task #3)
  Future<void> unfollowUser(String currentUserId, String targetUserId) async {
    try {
      // Remove from current user's following
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('following')
          .doc(targetUserId)
          .delete();

      // Remove from target user's followers
      await _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('followers')
          .doc(currentUserId)
          .delete();

      // log eliminado: ✅ Unfollowed user $targetUserId
    } catch (e) {
      print('❌ Error unfollowing user: $e');
      rethrow;
    }
  }

  /// Get followers stream (task #3)
  Stream<List<String>> getFollowers(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('followers')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  /// Get following stream (task #3)
  Stream<List<String>> getFollowing(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('following')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  /// Check if current user is following target (task #4)
  Future<bool> isFollowing(String currentUserId, String targetUserId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('following')
          .doc(targetUserId)
          .get();
      return doc.exists;
    } catch (e) {
      print('❌ Error checking following status: $e');
      return false;
    }
  }
}
