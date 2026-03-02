import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../core/app_logger.dart';
import '../models/experience_model.dart';
import '../services/diary_service.dart';
import '../services/story_service.dart';

class ExperienceController extends ChangeNotifier {
  final StoryService _storyService;
  final DiaryService _diaryService;

  ExperienceController({
    required StoryService storyService,
    required DiaryService diaryService,
  })  : _storyService = storyService,
        _diaryService = diaryService;

  // State
  List<TravelerStory> _stories = [];
  List<DiaryEntry> _diaryEntries = [];
  Map<String, dynamic> _diaryStats = {};
  bool _isLoading = false;
  bool _isSavingStory = false;
  bool _isSavingDiary = false;
  String _errorMessage = '';
  String _successMessage = '';

  // Getters
  List<TravelerStory> get stories => _stories;
  List<DiaryEntry> get diaryEntries => _diaryEntries;
  Map<String, dynamic> get diaryStats => _diaryStats;
  bool get isLoading => _isLoading;
  bool get isSavingStory => _isSavingStory;
  bool get isSavingDiary => _isSavingDiary;
  String get errorMessage => _errorMessage;
  String get successMessage => _successMessage;

  // Variables
  String? userId;

  // ============ INITIALIZATION ============

  Future<void> initialize(String uid) async {
    userId = uid;
    await loadAllData();
  }

  Future<void> loadAllData() async {
    if (userId == null) return;
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      await Future.wait([
        loadStories(),
        loadDiaryEntries(),
        loadDiaryStats(),
      ]);
    } catch (e) {
      _errorMessage = 'Error: $e';
      AppLogger.debug('Error loading data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============ STORIES ============

  Future<void> loadStories() async {
    try {
      final fetchedStories = await _storyService.getPublicStories();
      _stories = fetchedStories;
      notifyListeners();
    } catch (e) {
      AppLogger.debug('Error loading stories: $e');
      _errorMessage = 'Error cargando historias';
      notifyListeners();
    }
  }

  Stream<List<TravelerStory>> getStoriesStream() {
    return _storyService.getPublicStoriesStream();
  }

  Future<void> createStory({
    required String author,
    required String title,
    required String story,
    required List<String> emotionalHighlights,
    required double rating,
  }) async {
    if (!_validateStoryInput(title, story)) {
      return;
    }

    if (userId == null) {
      _errorMessage = 'Usuario no autenticado';
      notifyListeners();
      return;
    }

    try {
      _isSavingStory = true;
      _errorMessage = '';
      notifyListeners();

      final newStory = TravelerStory(
        id: const Uuid().v4(),
        author: author,
        title: title,
        story: story,
        emotionalHighlights: emotionalHighlights,
        likes: 0,
        rating: rating,
        createdAt: DateTime.now(),
      );

      await _storyService.createStory(userId!, newStory);
      _stories.insert(0, newStory);
      _successMessage = 'Historia compartida exitosamente!';
      AppLogger.debug('Story created: ${newStory.id}');
    } catch (e) {
      _errorMessage = 'Error: $e';
      AppLogger.debug('Error creating story: $e');
    } finally {
      _isSavingStory = false;
      notifyListeners();
    }
  }

  Future<void> likeStory(String storyId) async {
    try {
      await _storyService.likeStory(storyId);
      final index = _stories.indexWhere((s) => s.id == storyId);
      if (index != -1) {
        _stories[index].likes++;
        notifyListeners();
      }
      AppLogger.debug('Story liked: $storyId');
    } catch (e) {
      _errorMessage = 'Error: $e';
      AppLogger.debug('Error liking story: $e');
    }
  }

  Future<void> unlikeStory(String storyId) async {
    try {
      await _storyService.unlikeStory(storyId);
      final index = _stories.indexWhere((s) => s.id == storyId);
      if (index != -1) {
        _stories[index].likes--;
        notifyListeners();
      }
      AppLogger.debug('Story unliked: $storyId');
    } catch (e) {
      _errorMessage = 'Error: $e';
      AppLogger.debug('Error unliking story: $e');
    }
  }

  Future<void> deleteStory(String storyId) async {
    if (userId == null) return;
    try {
      await _storyService.deleteStory(userId!, storyId);
      _stories.removeWhere((s) => s.id == storyId);
      _successMessage = 'Historia eliminada';
      AppLogger.debug('Story deleted: $storyId');
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error: $e';
      AppLogger.debug('Error deleting story: $e');
      notifyListeners();
    }
  }

  Future<void> searchStoriesByEmotion(String emotion) async {
    try {
      _isLoading = true;
      notifyListeners();
      final results = await _storyService.searchStoriesByEmotion(emotion);
      _stories = results;
    } catch (e) {
      _errorMessage = 'Error buscando historias';
      AppLogger.debug('Error searching stories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============ DIARY ============

  Future<void> loadDiaryEntries() async {
    if (userId == null) return;
    try {
      final entries = await _diaryService.getDiaryEntries(userId!);
      _diaryEntries = entries;
      notifyListeners();
    } catch (e) {
      AppLogger.debug('Error loading diary entries: $e');
      _errorMessage = 'Error cargando diario';
      notifyListeners();
    }
  }

  Stream<List<DiaryEntry>> getDiaryEntriesStream() {
    if (userId == null) return const Stream.empty();
    return _diaryService.getDiaryEntriesStream(userId!);
  }

  Future<void> createDiaryEntry({
    required String location,
    required String content,
    required List<String> emotions,
    required int reflectionDepth,
  }) async {
    if (content.trim().length < 10) {
      _errorMessage = 'El contenido es muy breve. Expresate mas!';
      notifyListeners();
      return;
    }

    if (userId == null) {
      _errorMessage = 'Usuario no autenticado';
      notifyListeners();
      return;
    }

    try {
      _isSavingDiary = true;
      _errorMessage = '';
      notifyListeners();

      final entry = DiaryEntry(
        id: const Uuid().v4(),
        location: location,
        content: content,
        emotions: emotions,
        reflectionDepth: reflectionDepth,
        createdAt: DateTime.now(),
      );

      await _diaryService.createDiaryEntry(userId!, entry);
      _diaryEntries.insert(0, entry);
      await loadDiaryStats();

      _successMessage = 'Entrada guardada!';
      AppLogger.debug('Diary entry created: ${entry.id}');
    } catch (e) {
      _errorMessage = 'Error: $e';
      AppLogger.debug('Error creating diary entry: $e');
    } finally {
      _isSavingDiary = false;
      notifyListeners();
    }
  }

  Future<void> updateDiaryEntry(
    String entryId, {
    required String location,
    required String content,
    required List<String> emotions,
    required int reflectionDepth,
  }) async {
    if (userId == null) return;

    try {
      _isSavingDiary = true;
      notifyListeners();

      final updates = {
        'location': location,
        'content': content,
        'emotions': emotions,
        'reflectionDepth': reflectionDepth,
      };

      await _diaryService.updateDiaryEntry(userId!, entryId, updates);

      final index = _diaryEntries.indexWhere((e) => e.id == entryId);
      if (index != -1) {
        _diaryEntries[index] = DiaryEntry(
          id: entryId,
          location: location,
          content: content,
          emotions: emotions,
          reflectionDepth: reflectionDepth,
          createdAt: _diaryEntries[index].createdAt,
        );
        notifyListeners();
      }

      await loadDiaryStats();
      _successMessage = 'Entrada actualizada';
      AppLogger.debug('Diary entry updated: $entryId');
    } catch (e) {
      _errorMessage = 'Error: $e';
      AppLogger.debug('Error updating diary entry: $e');
    } finally {
      _isSavingDiary = false;
      notifyListeners();
    }
  }

  Future<void> deleteDiaryEntry(String entryId) async {
    if (userId == null) return;
    try {
      await _diaryService.deleteDiaryEntry(userId!, entryId);
      _diaryEntries.removeWhere((e) => e.id == entryId);
      await loadDiaryStats();
      _successMessage = 'Entrada eliminada';
      AppLogger.debug('Diary entry deleted: $entryId');
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error: $e';
      AppLogger.debug('Error deleting diary entry: $e');
      notifyListeners();
    }
  }

  // ============ STATISTICS ============

  Future<void> loadDiaryStats() async {
    if (userId == null) return;
    try {
      final stats = await _diaryService.getDiaryStats(userId!);
      _diaryStats = stats;
      notifyListeners();
    } catch (e) {
      AppLogger.debug('Error loading diary stats: $e');
    }
  }

  Map<String, dynamic> getDiaryStats() {
    return {
      'totalEntries': _diaryStats['totalEntries'] ?? 0,
      'totalWords': _diaryStats['totalWords'] ?? 0,
      'avgReflectionDepth': _diaryStats['avgReflectionDepth'] ?? 0,
      'emotionsTracked': _diaryStats['emotionsTracked'] ?? [],
      'lastEntryDate': _diaryStats['lastEntryDate'],
    };
  }

  int getTotalEntries() {
    return _diaryEntries.length;
  }

  double getAverageDepth() {
    if (_diaryEntries.isEmpty) return 0;
    final sum =
        _diaryEntries.map((e) => e.reflectionDepth).reduce((a, b) => a + b);
    return sum / _diaryEntries.length;
  }

  Set<String> getUniqueEmotions() {
    final emotions = <String>{};
    for (var entry in _diaryEntries) {
      emotions.addAll(entry.emotions);
    }
    return emotions;
  }

  Map<String, int> getEmotionFrequency() {
    final frequency = <String, int>{};
    for (var entry in _diaryEntries) {
      for (var emotion in entry.emotions) {
        frequency[emotion] = (frequency[emotion] ?? 0) + 1;
      }
    }
    return frequency;
  }

  // ============ FILTERS ============

  Future<void> filterByEmotion(String emotion) async {
    if (userId == null) return;
    try {
      _isLoading = true;
      notifyListeners();
      final entries = await _diaryService.getEntriesByEmotion(userId!, emotion);
      _diaryEntries = entries;
    } catch (e) {
      _errorMessage = 'Error filtrando';
      AppLogger.debug('Error filtering: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> filterByDateRange(DateTime startDate, DateTime endDate) async {
    if (userId == null) return;
    try {
      _isLoading = true;
      notifyListeners();
      final entries = await _diaryService.getEntriesByDateRange(
        userId!,
        startDate,
        endDate,
      );
      _diaryEntries = entries;
    } catch (e) {
      _errorMessage = 'Error filtrando';
      AppLogger.debug('Error filtering by date: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============ CLEANUP ============

  void clearData() {
    _stories.clear();
    _diaryEntries.clear();
    _diaryStats.clear();
    userId = null;
    _errorMessage = '';
    _successMessage = '';
    notifyListeners();
  }

  // ============ VALIDATIONS ============

  bool _validateStoryInput(String title, String story) {
    if (title.trim().length < 5) {
      _errorMessage = 'El titulo es demasiado corto';
      return false;
    }
    if (story.trim().length < 50) {
      _errorMessage =
          'Cuentanos mas, la historia es muy breve (min. 50 caracteres)';
      return false;
    }
    return true;
  }
}
