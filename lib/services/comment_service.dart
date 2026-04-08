import 'package:feeltrip_app/models/comment_model.dart';

class CommentService {
  Future<List<Comment>> getComments(String storyId) async {
    // Placeholder para la implementación real
    return [];
  }

  Future<void> addComment(String storyId, String content) async {
    // Placeholder para la implementación real
  }
  Future<void> deleteComment(String storyId, String commentId) async {
    // Placeholder para la implementación real
  }
  Future<void> likeComment(String storyId, String commentId) async {}
  Future<void> addReaction(
      String storyId, String commentId, String reaction) async {}
}
