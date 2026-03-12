import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/comment_model.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addComment(String storyId, String content) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final commentId = const Uuid().v4();
      final comment = Comment(
        id: commentId,
        storyId: storyId,
        userId: user.uid,
        userName: user.displayName ?? 'Anonymous',
        userAvatar: user.photoURL ?? '',
        content: content,
        reactions: [],
        likes: 0,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('stories')
          .doc(storyId)
          .collection('comments')
          .doc(commentId)
          .set(comment.toMap());
    } catch (e) {
      throw Exception('Failed to add comment: \$e');
    }
  }

  Stream<List<Comment>> getComments(String storyId) {
    return _firestore
        .collection('stories')
        .doc(storyId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Comment.fromFirestore(doc))
            .toList());
  }

  Future<void> likeComment(String storyId, String commentId) async {
    try {
      await _firestore
          .collection('stories')
          .doc(storyId)
          .collection('comments')
          .doc(commentId)
          .update({
            'likes': FieldValue.increment(1),
          });
    } catch (e) {
      throw Exception('Failed to like comment: \$e');
    }
  }

  Future<void> addReaction(String storyId, String commentId, String emoji) async {
    try {
      await _firestore
          .collection('stories')
          .doc(storyId)
          .collection('comments')
          .doc(commentId)
          .update({
            'reactions': FieldValue.arrayUnion([emoji]),
          });
    } catch (e) {
      throw Exception('Failed to add reaction: \$e');
    }
  }

  Future<void> deleteComment(String storyId, String commentId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final doc = await _firestore
          .collection('stories')
          .doc(storyId)
          .collection('comments')
          .doc(commentId)
          .get();

      final comment = Comment.fromFirestore(doc);
      if (comment.userId != user.uid) {
        throw Exception('You can only delete your own comments');
      }

      await doc.reference.delete();
    } catch (e) {
      throw Exception('Failed to delete comment: \$e');
    }
  }
}