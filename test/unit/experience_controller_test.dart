import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:feeltrip_app/controllers/experience_controller.dart';
import 'package:feeltrip_app/services/story_service.dart';
import 'package:feeltrip_app/services/diary_service.dart';
import 'package:feeltrip_app/models/experience_model.dart';
import 'package:feeltrip_app/services/storage_service.dart';

// Mocks de los servicios
class MockStoryService extends Mock implements StoryService {}

class MockDiaryService extends Mock implements DiaryService {}

// Fakes para argumentos complejos
class FakeTravelerStory extends Fake implements TravelerStory {}

class MockStorageService extends Mock implements StorageService {}

class FakeDiaryEntry extends Fake implements DiaryEntry {}

void main() {
  late ExperienceController controller;
  late MockStoryService mockStoryService;
  late MockDiaryService mockDiaryService;
  late MockStorageService mockStorageService;

  setUpAll(() {
    // Registrar valores por defecto para argumentos tipados
    registerFallbackValue(FakeTravelerStory());
    registerFallbackValue(FakeDiaryEntry());
  });

  setUp(() {
    mockStoryService = MockStoryService();
    mockDiaryService = MockDiaryService();
    mockStorageService = MockStorageService();

    // Inyectamos los mocks en el controlador
    controller = ExperienceController(
      storyService: mockStoryService,
      diaryService: mockDiaryService,
      storageService: mockStorageService,
    );
  });

  group('ExperienceController Tests', () {
    const userId = 'test-user-123';

    test('initialize carga todos los datos correctamente', () async {
      // Arrange (Configuración)
      when(() => mockStoryService.getPublicStories())
          .thenAnswer((_) async => []);
      when(() => mockDiaryService.getDiaryEntries(userId))
          .thenAnswer((_) async => []);
      when(() => mockDiaryService.getDiaryStats(userId))
          .thenAnswer((_) async => {});

      // Act (Ejecución)
      await controller.initialize(userId);

      // Assert (Verificación)
      expect(controller.userId, userId);
      verify(() => mockStoryService.getPublicStories()).called(1);
      verify(() => mockDiaryService.getDiaryEntries(userId)).called(1);
      verify(() => mockDiaryService.getDiaryStats(userId)).called(1);
      expect(controller.isLoading, false);
    });

    test('createStory llama al servicio y actualiza la lista local', () async {
      // Arrange
      controller.userId = userId;
      when(() => mockStoryService.createStory(any(), any()))
          .thenAnswer((_) async => 'new-story-id');

      // Act
      await controller.createStory(
        author: 'Test Author',
        title: 'Test Title',
        story:
            'Esta es una historia de prueba con suficiente longitud para pasar la validacion minima.',
        emotionalHighlights: ['Joy'],
        rating: 5.0,
      );

      // Assert
      verify(() => mockStoryService.createStory(userId, any())).called(1);
      expect(controller.stories.length, 1);
      expect(controller.stories.first.title, 'Test Title');
      expect(controller.successMessage.value?.isNotEmpty, true);
    });

    test('createDiaryEntry guarda entrada y recarga estadísticas', () async {
      // Arrange
      controller.userId = userId;
      when(() => mockDiaryService.createDiaryEntry(any(), any()))
          .thenAnswer((_) async => 'new-entry-id');
      // Simulamos que las stats cambian después de guardar
      when(() => mockDiaryService.getDiaryStats(userId))
          .thenAnswer((_) async => {'totalEntries': 1});

      // Act
      await controller.createDiaryEntry(
        location: 'Home',
        content: 'Dear Diary',
        emotions: ['Calm'],
        reflectionDepth: 3,
      );

      // Assert
      verify(() => mockDiaryService.createDiaryEntry(userId, any())).called(1);
      verify(() => mockDiaryService.getDiaryStats(userId))
          .called(1); // Verifica recarga
      expect(controller.diaryEntries.length, 1);
    });
  });
}
