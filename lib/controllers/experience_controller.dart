import 'package:get/get.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

import '../core/app_logger.dart';
import '../models/experience_model.dart';
import '../services/diary_service.dart';
import '../services/story_service.dart';
import '../services/storage_service.dart';
import 'base_controller.dart';

class ExperienceController extends BaseController {
  final StoryService _storyService;
  final DiaryService _diaryService;
  final StorageService _storageService;

  ExperienceController({
    required StoryService storyService,
    required DiaryService diaryService,
    required StorageService storageService,
  })  : _storyService = storyService,
        _diaryService = diaryService,
        _storageService = storageService;

  // State
  final stories = <TravelerStory>[].obs;
  final diaryEntries = <DiaryEntry>[].obs;
  final diaryStats = <String, dynamic>{}.obs;
  final successMessage = Rx<String?>(null);

  // Getters
  // isLoading y errorMessage vienen de BaseController

  // Variables
  String? userId;

  // ============ INITIALIZATION ============

  Future<void> initialize(String uid) async {
    userId = uid;
    await loadAllData();
  }

  Future<void> loadAllData() async {
    if (userId == null) return;
    await runBusyFuture(
      Future.wait([
        loadStories(),
        loadDiaryEntries(),
        loadDiaryStats(),
      ]),
    );
  }

  // ============ STORIES ============

  Future<void> loadStories() async {
    try {
      final fetchedStories = await _storyService.getPublicStories();
      stories.assignAll(fetchedStories);
    } catch (e) {
      AppLogger.debug('Error loading stories: $e');
      setError('Error cargando historias');
    }
  }

  Stream<List<TravelerStory>> getStoriesStream() {
    return _storyService.getPublicStoriesStream();
  }

  Future<void> createStory({
    required String author,
    required String title,
    required String story,
    String? destination,
    required List<String> emotionalHighlights,
    required double rating,
    File? imageFile,
  }) async {
    final validationError = _validateStoryInput(title, story);
    if (validationError != null) {
      setError(validationError);
      return;
    }

    if (userId == null) {
      setError('Usuario no autenticado');
      return;
    }

    await runBusyFuture(() async {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _storageService.uploadStoryImage(imageFile, userId!);
      }

      final newStory = TravelerStory(
        id: const Uuid().v4(),
        userId: userId!,
        author: author,
        title: title,
        story: story,
        destination: destination,
        emotionalHighlights: emotionalHighlights,
        likes: 0,
        rating: rating,
        createdAt: DateTime.now(),
        imageUrl: imageUrl,
      );

      await _storyService.createStory(userId!, newStory);
      stories.insert(0, newStory);
      successMessage.value = 'Historia compartida exitosamente!';
      AppLogger.debug('Story created: ${newStory.id}');
    }());
  }

  Future<void> likeStory(String storyId) async {
    try {
      await _storyService.likeStory(storyId);
      final index = stories.indexWhere((s) => s.id == storyId);
      if (index != -1) {
        stories[index].likes++;
        stories.refresh();
      }
      AppLogger.debug('Story liked: $storyId');
    } catch (e) {
      AppLogger.debug('Error liking story: $e');
    }
  }

  Future<void> unlikeStory(String storyId) async {
    try {
      await _storyService.unlikeStory(storyId);
      final index = stories.indexWhere((s) => s.id == storyId);
      if (index != -1) {
        stories[index].likes--;
        stories.refresh();
      }
      AppLogger.debug('Story unliked: $storyId');
    } catch (e) {
      AppLogger.debug('Error unliking story: $e');
    }
  }

  Future<void> deleteStory(String storyId) async {
    if (userId == null) return;
    try {
      await _storyService.deleteStory(userId!, storyId);
      stories.removeWhere((s) => s.id == storyId);
      successMessage.value = 'Historia eliminada';
      AppLogger.debug('Story deleted: $storyId');
    } catch (e) {
      AppLogger.debug('Error deleting story: $e');
      setError('Error eliminando historia');
    }
  }

  Future<void> searchStoriesByEmotion(String emotion) async {
    await runBusyFuture(() async {
      final results = await _storyService.searchStoriesByEmotion(emotion);
      stories.assignAll(results);
    }());
  }

  // ============ DIARY ============

  Future<void> loadDiaryEntries() async {
    if (userId == null) return;
    try {
      final entries = await _diaryService.getDiaryEntries(userId!);
      diaryEntries.assignAll(entries);
    } catch (e) {
      AppLogger.debug('Error loading diary entries: $e');
      setError('Error cargando diario');
    }
  }

  Stream<List<DiaryEntry>> getDiaryEntriesStream() {
    if (userId == null) return const Stream.empty();
    return _diaryService.getDiaryEntriesStream(userId!);
  }

  Future<void> createDiaryEntry({
    required String title,
    required String content,
    required String emotion,
    required File imageFile,
  }) async {
    if (title.trim().isEmpty ||
        content.trim().isEmpty ||
        emotion.trim().isEmpty) {
      setError('Por favor, completa el título, contenido y emoción.');
      return;
    }

    if (userId == null) {
      setError('Usuario no autenticado');
      return;
    }

    await runBusyFuture(() async {
      final imageUrl =
          await _storageService.uploadStoryImage(imageFile, userId!);
      final entry = DiaryEntry(
        id: const Uuid().v4(),
        userId: userId!,
        imageUrl: imageUrl,
        title: title,
        content: content,
        emotions: [emotion], // Convert single emotion to list
        createdAt: DateTime.now(),
      );

      await _diaryService.createDiaryEntry(userId!, entry);
      diaryEntries.insert(0, entry);
      await loadDiaryStats();

      successMessage.value = 'Entrada guardada!';
      AppLogger.debug('Diary entry created: ${entry.id}');
    }());
  }

  Future<void> updateDiaryEntry(
    String entryId, {
    required String title,
    required String content,
    required String emotion,
  }) async {
    if (userId == null) return;

    await runBusyFuture(() async {
      final updates = {
        'title': title,
        'content': content,
        'emotions': [emotion], // Convert single emotion to list
      };

      await _diaryService.updateDiaryEntry(userId!, entryId, updates);

      final index = diaryEntries.indexWhere((e) => e.id == entryId);
      if (index != -1) {
        final oldEntry = diaryEntries[index];
        diaryEntries[index] = DiaryEntry(
          id: entryId,
          userId: oldEntry.userId,
          imageUrl: oldEntry.imageUrl,
          title: title,
          content: content,
          emotions: [emotion],
          createdAt: oldEntry.createdAt,
        );
      }

      await loadDiaryStats();
      successMessage.value = 'Entrada actualizada';
      AppLogger.debug('Diary entry updated: $entryId');
    }());
  }

  Future<void> deleteDiaryEntry(String entryId) async {
    if (userId == null) return;
    try {
      await _diaryService.deleteDiaryEntry(userId!, entryId);
      diaryEntries.removeWhere((e) => e.id == entryId);
      await loadDiaryStats();
      successMessage.value = 'Entrada eliminada';
      AppLogger.debug('Diary entry deleted: $entryId');
    } catch (e) {
      AppLogger.debug('Error deleting diary entry: $e');
      setError('Error eliminando entrada');
    }
  }

  // ============ STATISTICS ============

  Future<void> loadDiaryStats() async {
    if (userId == null) return;
    try {
      final stats = await _diaryService.getDiaryStats(userId!);
      diaryStats.value = stats;
    } catch (e) {
      AppLogger.debug('Error loading diary stats: $e');
    }
  }

  Map<String, dynamic> getDiaryStats() {
    return {
      'totalEntries': diaryStats['totalEntries'] ?? 0,
      'totalWords': diaryStats['totalWords'] ?? 0,
      'avgReflectionDepth': diaryStats['avgReflectionDepth'] ?? 0,
      'emotionsTracked': diaryStats['emotionsTracked'] ?? [],
      'lastEntryDate': diaryStats['lastEntryDate'],
    };
  }

  int getTotalEntries() {
    return diaryEntries.length;
  }

  double getAverageDepth() {
    if (diaryEntries.isEmpty) return 0;
    final sum =
        diaryEntries.map((e) => e.reflectionDepth).reduce((a, b) => a + b);
    return sum / diaryEntries.length;
  }

  Set<String> getUniqueEmotions() {
    final emotions = <String>{};
    for (var entry in diaryEntries) {
      emotions.addAll(entry.emotions);
    }
    return emotions;
  }

  Map<String, int> getEmotionFrequency() {
    final frequency = <String, int>{};
    for (var entry in diaryEntries) {
      for (var emotion in entry.emotions) {
        frequency[emotion] = (frequency[emotion] ?? 0) + 1;
      }
    }
    return frequency;
  }

  // ============ FILTERS ============

  Future<void> filterByEmotion(String emotion) async {
    if (userId == null) return;
    await runBusyFuture(() async {
      final entries = await _diaryService.getEntriesByEmotion(userId!, emotion);
      diaryEntries.assignAll(entries);
    }());
  }

  Future<void> filterByDateRange(DateTime startDate, DateTime endDate) async {
    if (userId == null) return;
    await runBusyFuture(() async {
      final entries = await _diaryService.getEntriesByDateRange(
        userId!,
        startDate,
        endDate,
      );
      diaryEntries.assignAll(entries);
    }());
  }

  // ============ CLEANUP ============

  void clearData() {
    stories.clear();
    diaryEntries.clear();
    diaryStats.clear();
    userId = null;
    setError(null);
    successMessage.value = null;
  }

  // ============ VALIDATIONS ============

  String? _validateStoryInput(String title, String story) {
    if (title.trim().length < 5) {
      return 'El titulo es demasiado corto';
    }
    if (story.trim().length < 50) {
      return 'Cuentanos mas, la historia es muy breve (min. 50 caracteres)';
    }
    return null;
  }
}
