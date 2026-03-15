import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/comment_model.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static bool useMockData = false; // Real Firestore enabled

  Stream<List<Comment>> getComments(String storyId) {
    return _firestore
        .collection('comments')
        .where('storyId', isEqualTo: storyId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList());
  }

  Future<void> addComment(String storyId, String userId, String text) async {
    try {
      final commentId = const Uuid().v4();
      final user = FirebaseAuth.instance.currentUser;
      final comment = Comment(
        id: commentId,
        storyId: storyId,
        userId: userId,
        userName: user?.displayName ?? 'Anonymous',
        userAvatar: user?.photoURL ?? '',
        content: text,
        reactions: [],
        createdAt: DateTime.now(),
        likes: 0,
      );

      await _firestore
          .collection('comments')
          .doc(commentId)
          .set(comment.toFirestore());
    } catch (e) {
      print('❌ Error adding comment: $e');
      rethrow;
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      await _firestore.collection('comments').doc(commentId).delete();
    } catch (e) {
      print('❌ Error deleting comment: $e');
      rethrow;
    }
  }

  Future<void> likeComment(String commentId) async {
    try {
      await _firestore
          .collection('comments')
          .doc(commentId)
          .update({'likes': FieldValue.increment(1)});
    } catch (e) {
      print('❌ Error liking comment: $e');
    }
  }

  Future<void> addReaction(String commentId, String reaction) async {
    try {
      await _firestore.collection('comments').doc(commentId).update({
        'reactions': FieldValue.arrayUnion([reaction])
      });
    } catch (e) {
      print('❌ Error adding reaction: $e');
    }
  }
}
