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
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              // Adapta campos de Firestore al nuevo modelo
              data['text'] = data['content'] ?? '';
              return Comment.fromJson(data);
            }).toList());
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
        likes: 0,
        reactions: [],
        createdAt: DateTime.now(),
      );

      // toJson crea un Map que Firestore entiende
      final json = comment.toJson();
      json['content'] = json['text']; // Mantener compatibilidad si es necesario

      await _firestore
          .collection('comments')
          .doc(commentId)
          .set(json);
    } catch (e) {
      // log eliminado: ❌ Error adding comment: $e
      rethrow;
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      await _firestore.collection('comments').doc(commentId).delete();
    } catch (e) {
      // log eliminado: ❌ Error deleting comment: $e
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
      // log eliminado: ❌ Error liking comment: $e
    }
  }

  Future<void> addReaction(String commentId, String reaction) async {
    try {
      await _firestore.collection('comments').doc(commentId).update({
        'reactions': FieldValue.arrayUnion([reaction])
      });
    } catch (e) {
      // log eliminado: ❌ Error adding reaction: $e
    }
  }
}
