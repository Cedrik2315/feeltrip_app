// story_service.dart
import '../models/experience_model.dart';
import '../core/app_logger.dart';
import '../models/comment_model.dart';
import '../repositories/story_repository.dart';

class StoryService {
  static final StoryService _instance = StoryService._internal();
  final StoryRepository _repository;

  factory StoryService() {
    return _instance;
  }

  StoryService._internal({StoryRepository? repository})
      : _repository = repository ?? StoryRepository();

  Future<List<TravelerStory>> getPublicStories({int limit = 50}) async {
    try {
      return await _repository.getPublicStories(limit: limit);
    } catch (e, st) {
      AppLogger.error('Error en StoryService.getPublicStories',
          error: e, stackTrace: st, name: 'StoryService');
      rethrow;
    }
  }

  Future<List<TravelerStory>> getUserStories(String userId) async {
    try {
      return await _repository.getUserStories(userId);
    } catch (e, st) {
      AppLogger.error('Error en StoryService.getUserStories',
          error: e, stackTrace: st, name: 'StoryService');
      rethrow;
    }
  }

  Future<TravelerStory?> getStory(String storyId) async {
    try {
      return await _repository.getStory(storyId);
    } catch (e, st) {
      AppLogger.error('Error en StoryService.getStory',
          error: e, stackTrace: st, name: 'StoryService');
      rethrow;
    }
  }

  Future<String> createStory(String userId, TravelerStory story) async {
    try {
      return await _repository.createStory(userId, story);
    } catch (e, st) {
      AppLogger.error('Error en StoryService.createStory',
          error: e, stackTrace: st, name: 'StoryService');
      rethrow;
    }
  }

  Future<void> updateStory(
      String userId, String storyId, Map<String, dynamic> updates) async {
    try {
      await _repository.updateStory(userId, storyId, updates);
    } catch (e, st) {
      AppLogger.error('Error en StoryService.updateStory',
          error: e, stackTrace: st, name: 'StoryService');
      rethrow;
    }
  }

  Future<void> likeStory(String storyId) async {
    try {
      await _repository.likeStory(storyId);
    } catch (e, st) {
      AppLogger.error('Error en StoryService.likeStory',
          error: e, stackTrace: st, name: 'StoryService');
      rethrow;
    }
  }

  Future<void> unlikeStory(String storyId) async {
    try {
      await _repository.unlikeStory(storyId);
    } catch (e, st) {
      AppLogger.error('Error en StoryService.unlikeStory',
          error: e, stackTrace: st, name: 'StoryService');
      rethrow;
    }
  }

  Future<void> deleteStory(String userId, String storyId) async {
    try {
      await _repository.deleteStory(userId, storyId);
    } catch (e, st) {
      AppLogger.error('Error en StoryService.deleteStory',
          error: e, stackTrace: st, name: 'StoryService');
      rethrow;
    }
  }

  Stream<List<TravelerStory>> getPublicStoriesStream({int limit = 50}) {
    return _repository.getPublicStoriesStream(limit: limit);
  }

  Stream<List<TravelerStory>> getUserStoriesStream(String userId) {
    return _repository.getUserStoriesStream(userId);
  }

  Future<List<TravelerStory>> searchStoriesByTitle(String query) async {
    try {
      return await _repository.searchStoriesByTitle(query);
    } catch (e, st) {
      AppLogger.error('Error en StoryService.searchStoriesByTitle',
          error: e, stackTrace: st, name: 'StoryService');
      rethrow;
    }
  }

  Future<List<TravelerStory>> searchStoriesByEmotion(String emotion) async {
    try {
      return await _repository.searchStoriesByEmotion(emotion);
    } catch (e, st) {
      AppLogger.error('Error en StoryService.searchStoriesByEmotion',
          error: e, stackTrace: st, name: 'StoryService');
      rethrow;
    }
  }

  Future<List<Comment>> getCommentsForStory(String storyId) async {
    try {
      return await _repository.getCommentsForStory(storyId);
    } catch (e, st) {
      AppLogger.error('Error en StoryService.getCommentsForStory',
          error: e, stackTrace: st, name: 'StoryService');
      rethrow;
    }
  }

  Future<void> addComment({
    required String storyId,
    required String content,
  }) async {
    try {
      await _repository.addComment(storyId: storyId, content: content);
    } catch (e, st) {
      AppLogger.error('Error en StoryService.addComment',
          error: e, stackTrace: st, name: 'StoryService');
      rethrow;
    }
  }
}
