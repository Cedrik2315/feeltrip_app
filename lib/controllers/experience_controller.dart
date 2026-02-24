import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../core/app_logger.dart';
import '../models/experience_model.dart';
import '../services/diary_service.dart';
import '../services/story_service.dart';

class ExperienceController extends GetxController {
  final StoryService _storyService = StoryService();
  final DiaryService _diaryService = DiaryService();

  // Observables
  RxList<TravelerStory> stories = <TravelerStory>[].obs;
  RxList<DiaryEntry> diaryEntries = <DiaryEntry>[].obs;
  RxMap<String, dynamic> diaryStats = <String, dynamic>{}.obs;
  RxBool isLoading = false.obs;
  RxBool isSavingStory = false.obs;
  RxBool isSavingDiary = false.obs;
  RxString errorMessage = ''.obs;
  RxString successMessage = ''.obs;

  // Variables
  String? userId;


  // ============ INITIALIZATION ============

  /// Inicializar con userId (llamar despuÃ©s de login)
  Future<void> initialize(String uid) async {
    userId = uid;
    await loadAllData();
  }

  /// Cargar todos los datos
  Future<void> loadAllData() async {
    if (userId == null) return;
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      await Future.wait([
        loadStories(),
        loadDiaryEntries(),
        loadDiaryStats(),
      ]);
    } catch (e) {
      errorMessage.value = 'Error: $e';
      AppLogger.debug('âŒ Error loading data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ============ STORIES ============

  /// Cargar historias pÃºblicas
  Future<void> loadStories() async {
    try {
      final fetchedStories = await _storyService.getPublicStories();
      stories.assignAll(fetchedStories);
    } catch (e) {
      AppLogger.debug('âŒ Error loading stories: $e');
      errorMessage.value = 'Error cargando historias';
    }
  }

  /// Stream de historias pÃºblicas
  Stream<List<TravelerStory>> getStoriesStream() {
    return _storyService.getPublicStoriesStream();
  }

  /// Crear nueva historia
  Future<void> createStory({
    required String author,
    required String title,
    required String story,
    required List<String> emotionalHighlights,
    required double rating,
  }) async {
    if (userId == null) {
      errorMessage.value = 'Usuario no autenticado';
      return;
    }

    try {
      isSavingStory.value = true;
      errorMessage.value = '';

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
      
      // Agregar a la lista local
      stories.insert(0, newStory);
      
      successMessage.value = 'Â¡Historia compartida exitosamente!';
      AppLogger.debug('âœ… Story created: ${newStory.id}');
    } catch (e) {
      errorMessage.value = 'Error: $e';
      AppLogger.debug('âŒ Error creating story: $e');
    } finally {
      isSavingStory.value = false;
    }
  }

  /// Like a una historia
  Future<void> likeStory(String storyId) async {
    try {
      await _storyService.likeStory(storyId);
      
      // Actualizar en lista local
      final index = stories.indexWhere((s) => s.id == storyId);
      if (index != -1) {
        stories[index].likes++;
        stories.refresh();
      }
      
      AppLogger.debug('âœ… Story liked: $storyId');
    } catch (e) {
      errorMessage.value = 'Error: $e';
      AppLogger.debug('âŒ Error liking story: $e');
    }
  }

  /// Unlike a una historia
  Future<void> unlikeStory(String storyId) async {
    try {
      await _storyService.unlikeStory(storyId);
      
      // Actualizar en lista local
      final index = stories.indexWhere((s) => s.id == storyId);
      if (index != -1) {
        stories[index].likes--;
        stories.refresh();
      }
      
      AppLogger.debug('âœ… Story unliked: $storyId');
    } catch (e) {
      errorMessage.value = 'Error: $e';
      AppLogger.debug('âŒ Error unliking story: $e');
    }
  }

  /// Eliminar historia
  Future<void> deleteStory(String storyId) async {
    if (userId == null) return;
    
    try {
      await _storyService.deleteStory(userId!, storyId);
      stories.removeWhere((s) => s.id == storyId);
      successMessage.value = 'Historia eliminada';
      AppLogger.debug('âœ… Story deleted: $storyId');
    } catch (e) {
      errorMessage.value = 'Error: $e';
      AppLogger.debug('âŒ Error deleting story: $e');
    }
  }

  /// Buscar historias por emociÃ³n
  Future<void> searchStoriesByEmotion(String emotion) async {
    try {
      isLoading.value = true;
      final results = await _storyService.searchStoriesByEmotion(emotion);
      stories.assignAll(results);
    } catch (e) {
      errorMessage.value = 'Error buscando historias';
      AppLogger.debug('âŒ Error searching stories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ============ DIARY ============

  /// Cargar entradas del diario
  Future<void> loadDiaryEntries() async {
    if (userId == null) return;
    try {
      final entries = await _diaryService.getDiaryEntries(userId!);
      diaryEntries.assignAll(entries);
    } catch (e) {
      AppLogger.debug('âŒ Error loading diary entries: $e');
      errorMessage.value = 'Error cargando diario';
    }
  }

  /// Stream de entradas del diario
  Stream<List<DiaryEntry>> getDiaryEntriesStream() {
    if (userId == null) return const Stream.empty();
    return _diaryService.getDiaryEntriesStream(userId!);
  }

  /// Crear nueva entrada de diario
  Future<void> createDiaryEntry({
    required String location,
    required String content,
    required List<String> emotions,
    required int reflectionDepth,
  }) async {
    if (userId == null) {
      errorMessage.value = 'Usuario no autenticado';
      return;
    }

    try {
      isSavingDiary.value = true;
      errorMessage.value = '';

      final entry = DiaryEntry(
        id: const Uuid().v4(),
        location: location,
        content: content,
        emotions: emotions,
        reflectionDepth: reflectionDepth,
        createdAt: DateTime.now(),
      );

      await _diaryService.createDiaryEntry(userId!, entry);
      
      // Agregar a lista local
      diaryEntries.insert(0, entry);
      
      // Recargar estadÃ­sticas
      await loadDiaryStats();
      
      successMessage.value = 'Â¡Entrada guardada!';
      AppLogger.debug('âœ… Diary entry created: ${entry.id}');
    } catch (e) {
      errorMessage.value = 'Error: $e';
      AppLogger.debug('âŒ Error creating diary entry: $e');
    } finally {
      isSavingDiary.value = false;
    }
  }

  /// Actualizar entrada del diario
  Future<void> updateDiaryEntry(String entryId, {
    required String location,
    required String content,
    required List<String> emotions,
    required int reflectionDepth,
  }) async {
    if (userId == null) return;

    try {
      isSavingDiary.value = true;
      
      final updates = {
        'location': location,
        'content': content,
        'emotions': emotions,
        'reflectionDepth': reflectionDepth,
      };

      await _diaryService.updateDiaryEntry(userId!, entryId, updates);
      
      // Actualizar en lista local
      final index = diaryEntries.indexWhere((e) => e.id == entryId);
      if (index != -1) {
        diaryEntries[index] = DiaryEntry(
          id: entryId,
          location: location,
          content: content,
          emotions: emotions,
          reflectionDepth: reflectionDepth,
          createdAt: diaryEntries[index].createdAt,
        );
        diaryEntries.refresh();
      }
      
      // Recargar estadÃ­sticas
      await loadDiaryStats();
      
      successMessage.value = 'Entrada actualizada';
      AppLogger.debug('âœ… Diary entry updated: $entryId');
    } catch (e) {
      errorMessage.value = 'Error: $e';
      AppLogger.debug('âŒ Error updating diary entry: $e');
    } finally {
      isSavingDiary.value = false;
    }
  }

  /// Eliminar entrada del diario
  Future<void> deleteDiaryEntry(String entryId) async {
    if (userId == null) return;

    try {
      await _diaryService.deleteDiaryEntry(userId!, entryId);
      diaryEntries.removeWhere((e) => e.id == entryId);
      await loadDiaryStats();
      successMessage.value = 'Entrada eliminada';
      AppLogger.debug('âœ… Diary entry deleted: $entryId');
    } catch (e) {
      errorMessage.value = 'Error: $e';
      AppLogger.debug('âŒ Error deleting diary entry: $e');
    }
  }

  // ============ STATISTICS ============

  /// Cargar estadÃ­sticas del diario
  Future<void> loadDiaryStats() async {
    if (userId == null) return;
    try {
      final stats = await _diaryService.getDiaryStats(userId!);
      diaryStats.assignAll(stats);
    } catch (e) {
      AppLogger.debug('âŒ Error loading diary stats: $e');
    }
  }

  /// Obtener estadÃ­sticas del diario
  Map<String, dynamic> getDiaryStats() {
    return {
      'totalEntries': diaryStats['totalEntries'] ?? 0,
      'totalWords': diaryStats['totalWords'] ?? 0,
      'avgReflectionDepth': diaryStats['avgReflectionDepth'] ?? 0,
      'emotionsTracked': diaryStats['emotionsTracked'] ?? [],
      'lastEntryDate': diaryStats['lastEntryDate'],
    };
  }

  /// Contar entradas totales
  int getTotalEntries() {
    return diaryEntries.length;
  }

  /// Obtener profundidad promedio
  double getAverageDepth() {
    if (diaryEntries.isEmpty) return 0;
    final sum = diaryEntries
        .map((e) => e.reflectionDepth)
        .reduce((a, b) => a + b);
    return sum / diaryEntries.length;
  }

  /// Obtener emociones Ãºnicas
  Set<String> getUniqueEmotions() {
    final emotions = <String>{};
    for (var entry in diaryEntries) {
      emotions.addAll(entry.emotions);
    }
    return emotions;
  }

  /// Obtener frecuencia de emociones
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

  /// Filtrar entradas por emociÃ³n
  Future<void> filterByEmotion(String emotion) async {
    if (userId == null) return;
    try {
      isLoading.value = true;
      final entries = await _diaryService.getEntriesByEmotion(userId!, emotion);
      diaryEntries.assignAll(entries);
    } catch (e) {
      errorMessage.value = 'Error filtrando';
      AppLogger.debug('âŒ Error filtering: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Filtrar entradas por rango de fechas
  Future<void> filterByDateRange(DateTime startDate, DateTime endDate) async {
    if (userId == null) return;
    try {
      isLoading.value = true;
      final entries = await _diaryService.getEntriesByDateRange(
        userId!,
        startDate,
        endDate,
      );
      diaryEntries.assignAll(entries);
    } catch (e) {
      errorMessage.value = 'Error filtrando';
      AppLogger.debug('âŒ Error filtering by date: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ============ CLEANUP ============

  /// Limpiar datos cuando el usuario hace logout
  void clearData() {
    stories.clear();
    diaryEntries.clear();
    diaryStats.clear();
    userId = null;
    errorMessage.value = '';
    successMessage.value = '';
  }
}


