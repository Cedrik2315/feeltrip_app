import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../core/app_logger.dart';
import '../models/comment_model.dart';
import '../mock_data.dart';

abstract class CommentRepository {
  Future<void> addComment({
    required String storyId,
    required String userId,
    required String userName,
    required String userAvatar,
    required String content,
  });

  Stream<List<Comment>> getComments(String storyId);

  Future<void> addReaction({
    required String storyId,
    required String commentId,
    required String reaction,
  });

  Future<void> likeComment({
    required String storyId,
    required String commentId,
  });

  Future<void> deleteComment({
    required String storyId,
    required String commentId,
  });
}

class MockCommentRepository implements CommentRepository {
  @override
  Future<void> addComment({
    required String storyId,
    required String userId,
    required String userName,
    required String userAvatar,
    required String content,
  }) async {
    final commentId = const Uuid().v4();
    final newComment = {
      'id': commentId,
      'storyId': storyId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'content': content,
      'reactions': [],
      'createdAt': Timestamp.now(),
      'likes': 0,
    };
    MockData.mockComments.putIfAbsent(storyId, () => []);
    MockData.mockComments[storyId]!.insert(0, newComment);
    AppLogger.debug('Comentario mock agregado: $commentId', name: 'CommentRepository');
  }

  @override
  Stream<List<Comment>> getComments(String storyId) {
    final mockCommentsList = MockData.mockComments[storyId] ?? [];
    final comments = mockCommentsList.map((data) {
      return Comment(
        id: data['id'],
        storyId: data['storyId'],
        userId: data['userId'],
        userName: data['userName'],
        userAvatar: data['userAvatar'],
        content: data['content'],
        reactions: List<String>.from(data['reactions']),
        createdAt: data['createdAt'].toDate(),
        likes: data['likes'],
      );
    }).toList();
    return Stream.value(comments);
  }

  @override
  Future<void> addReaction({
    required String storyId,
    required String commentId,
    required String reaction,
  }) async {
    final comments = MockData.mockComments[storyId] ?? [];
    final comment = comments.firstWhere((c) => c['id'] == commentId, orElse: () => {});
    if (comment.isNotEmpty) {
      final reactions = List<String>.from(comment['reactions']);
      reactions.add(reaction);
      comment['reactions'] = reactions;
    }
  }

  @override
  Future<void> likeComment({required String storyId, required String commentId}) async {
    final comments = MockData.mockComments[storyId] ?? [];
    final comment = comments.firstWhere((c) => c['id'] == commentId, orElse: () => {});
    if (comment.isNotEmpty) {
      comment['likes'] = (comment['likes'] ?? 0) + 1;
    }
  }

  @override
  Future<void> deleteComment({required String storyId, required String commentId}) async {
    final comments = MockData.mockComments[storyId] ?? [];
    comments.removeWhere((c) => c['id'] == commentId);
  }
}

class FirestoreCommentRepository implements CommentRepository {
  FirestoreCommentRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<void> addComment({
    required String storyId,
    required String userId,
    required String userName,
    required String userAvatar,
    required String content,
  }) async {
    final commentId = const Uuid().v4();
    final comment = Comment(
      id: commentId,
      storyId: storyId,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      content: content,
      reactions: [],
      createdAt: DateTime.now(),
      likes: 0,
    );

    await _firestore
        .collection('stories')
        .doc(storyId)
        .collection('comments')
        .doc(commentId)
        .set(comment.toMap());
  }

  @override
  Stream<List<Comment>> getComments(String storyId) {
    return _firestore
        .collection('stories')
        .doc(storyId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Comment.fromFirestore).toList());
  }

  @override
  Future<void> addReaction({
    required String storyId,
    required String commentId,
    required String reaction,
  }) async {
    await _firestore
        .collection('stories')
        .doc(storyId)
        .collection('comments')
        .doc(commentId)
        .update({'reactions': FieldValue.arrayUnion([reaction])});
  }

  @override
  Future<void> likeComment({required String storyId, required String commentId}) async {
    await _firestore
        .collection('stories')
        .doc(storyId)
        .collection('comments')
        .doc(commentId)
        .update({'likes': FieldValue.increment(1)});
  }

  @override
  Future<void> deleteComment({required String storyId, required String commentId}) async {
    await _firestore
        .collection('stories')
        .doc(storyId)
        .collection('comments')
        .doc(commentId)
        .delete();
  }
}
