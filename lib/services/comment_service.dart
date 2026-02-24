import '../config/app_flags.dart';
import '../core/app_logger.dart';
import '../models/comment_model.dart';
import '../repositories/comment_repository.dart';

class CommentService {
  CommentService({CommentRepository? repository})
      : _repository = repository ??
            (useMockData ? MockCommentRepository() : FirestoreCommentRepository());

  final CommentRepository _repository;

  Future<void> addComment({
    required String storyId,
    required String userId,
    required String userName,
    required String userAvatar,
    required String content,
  }) async {
    try {
      await _repository.addComment(
        storyId: storyId,
        userId: userId,
        userName: userName,
        userAvatar: userAvatar,
        content: content,
      );
    } catch (e, st) {
      AppLogger.error(
        'Error en CommentService.addComment',
        error: e,
        stackTrace: st,
        name: 'CommentService',
      );
      rethrow;
    }
  }

  Stream<List<Comment>> getComments(String storyId) {
    return _repository.getComments(storyId);
  }

  Future<void> addReaction({
    required String storyId,
    required String commentId,
    required String reaction,
  }) async {
    try {
      await _repository.addReaction(
        storyId: storyId,
        commentId: commentId,
        reaction: reaction,
      );
    } catch (e, st) {
      AppLogger.error(
        'Error en CommentService.addReaction',
        error: e,
        stackTrace: st,
        name: 'CommentService',
      );
      rethrow;
    }
  }

  Future<void> likeComment({
    required String storyId,
    required String commentId,
  }) async {
    try {
      await _repository.likeComment(storyId: storyId, commentId: commentId);
    } catch (e, st) {
      AppLogger.error(
        'Error en CommentService.likeComment',
        error: e,
        stackTrace: st,
        name: 'CommentService',
      );
      rethrow;
    }
  }

  Future<void> deleteComment({
    required String storyId,
    required String commentId,
  }) async {
    try {
      await _repository.deleteComment(storyId: storyId, commentId: commentId);
    } catch (e, st) {
      AppLogger.error(
        'Error en CommentService.deleteComment',
        error: e,
        stackTrace: st,
        name: 'CommentService',
      );
      rethrow;
    }
  }
}
