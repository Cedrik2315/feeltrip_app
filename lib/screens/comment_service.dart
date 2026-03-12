import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment_model.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Comment>> getComments(String storyId) {
    return _firestore
        .collection('stories')
        .doc(storyId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList());
  }

  Future<void> addComment({
    required String storyId,
    required String userId,
    required String userName,
    required String userAvatar,
    required String content,
  }) async {
    final comment = Comment(
      id: '', // Firestore generates ID
      storyId: storyId,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      content: content,
      createdAt: DateTime.now(), reactions: [], likes: 0,
    );

    await _firestore
        .collection('stories')
        .doc(storyId)
        .collection('comments')
        .add(comment.toMap());
  }

  Future<void> deleteComment(String storyId, String commentId) async {
    await _firestore
        .collection('stories')
        .doc(storyId)
        .collection('comments')
        .doc(commentId)
        .delete();
  }

  Future<void> likeComment({
    required String storyId,
    required String commentId,
  }) async {
    await _firestore
        .collection('stories')
        .doc(storyId)
        .collection('comments')
        .doc(commentId)
        .update({'likes': FieldValue.increment(1)});
  }
}
