import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/comment_model.dart';
import 'notification_service.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Comment>> getCommentsStream(String storyId) {
    return _firestore
        .collection('stories')
        .doc(storyId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return Comment.fromFirestore(doc);
            }).toList());
  }

  Future<void> addComment(String storyId, String content) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final commentRef = _firestore
          .collection('stories')
          .doc(storyId)
          .collection('comments')
          .doc();

      final comment = Comment(
        id: commentRef.id,
        storyId: storyId,
        userId: user.uid,
        userName: user.displayName ?? 'Anonymous',
        userAvatar: user.photoURL ?? '',
        content: content,
        reactions: [],
        createdAt: DateTime.now(),
      );

      await commentRef.set(comment.toFirestore());

      // Trigger agency notification if story belongs to agency
      try {
        final storyDoc =
            await _firestore.collection('stories').doc(storyId).get();
        if (storyDoc.exists) {
          final data = storyDoc.data()!;
          final agencyId = data['agencyId'] as String?;
          if (agencyId != null) {
            final agencyDoc =
                await _firestore.collection('agencies').doc(agencyId).get();
            final ownerUid = agencyDoc.data()?['ownerUid'] as String?;
            if (ownerUid != null) {
              final storyTitle = data['title'] as String? ?? 'tu experiencia';
              final notificationService = NotificationService();
              await notificationService.sendCommentNotification(
                  ownerUid, storyTitle, storyId);
            }
          }
        }
      } catch (notifError) {
        // Log silent, don't fail comment save
        AppLogger.e('Notification trigger error: $notifError');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteComment(String storyId, String commentId) async {
    try {
      // Security enforced by Firestore rules (isResourceOwner)
      await _firestore
          .collection('stories')
          .doc(storyId)
          .collection('comments')
          .doc(commentId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> likeComment(String storyId, String commentId) async {
    try {
      await _firestore
          .collection('stories')
          .doc(storyId)
          .collection('comments')
          .doc(commentId)
          .update({'likes': FieldValue.increment(1)});
    } catch (e) {
      // Ignore if not exists
    }
  }

  Future<void> addReaction(
      String storyId, String commentId, String reaction) async {
    try {
      await _firestore
          .collection('stories')
          .doc(storyId)
          .collection('comments')
          .doc(commentId)
          .update({
        'reactions': FieldValue.arrayUnion([reaction])
      });
    } catch (e) {
      // Ignore if not exists
    }
  }
}
