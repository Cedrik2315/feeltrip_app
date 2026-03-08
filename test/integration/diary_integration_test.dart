import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:feeltrip_app/screens/travel_diary_screen.dart';
import 'package:feeltrip_app/controllers/experience_controller.dart';
import 'package:feeltrip_app/services/diary_service.dart';
import 'package:feeltrip_app/services/story_service.dart';
import 'package:feeltrip_app/services/storage_service.dart';
import 'package:feeltrip_app/models/experience_model.dart';

// Mocks
class MockDiaryService extends Mock implements DiaryService {}

class MockStoryService extends Mock implements StoryService {}

class MockStorageService extends Mock implements StorageService {}

class FakeDiaryEntry extends Fake implements DiaryEntry {}

void main() {
  late MockDiaryService mockDiaryService;
  late MockStoryService mockStoryService;
  late MockStorageService mockStorageService;
  late ExperienceController controller;

  setUpAll(() {
    registerFallbackValue(FakeDiaryEntry());
  });

  setUp(() {
    mockDiaryService = MockDiaryService();
    mockStoryService = MockStoryService();
    mockStorageService = MockStorageService();

    // Setup default responses
    when(() => mockDiaryService.getDiaryEntries(any()))
        .thenAnswer((_) async => []);
    when(() => mockDiaryService.getDiaryStats(any()))
        .thenAnswer((_) async => {});
    when(() => mockStoryService.getPublicStories()).thenAnswer((_) async => []);
    when(() => mockDiaryService.createDiaryEntry(any(), any()))
        .thenAnswer((_) async => 'new-id');

    // Initialize controller
    controller = ExperienceController(
      diaryService: mockDiaryService,
      storyService: mockStoryService,
      storageService: mockStorageService,
    );

    // Inject controller into GetX
    Get.put<ExperienceController>(controller);

    // Set a dummy user ID for the controller
    controller.userId = 'test-user';
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('TravelDiaryScreen integration test: Add new entry',
      (WidgetTester tester) async {
    // Build the widget wrapped in GetMaterialApp
    await tester.pumpWidget(
      const GetMaterialApp(
        home: TravelDiaryScreen(),
      ),
    );

    // Wait for async operations in initState to complete (e.g., loadAllData)
    await tester.pumpAndSettle();

    // Verify initial state (empty list)
    expect(find.text('Aún no tienes entradas'), findsOneWidget);

    // Tap on Add button
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Verify form is shown
    expect(find.text('Nueva Entrada en el Diario'), findsOneWidget);

    // Fill the form
    await tester.enterText(
        find.widgetWithText(TextField, 'Ubicación'), 'Paris');
    await tester.enterText(find.widgetWithText(TextField, 'Tus Pensamientos'),
        'This is a test entry content that is long enough.');

    // Select an emotion (Chip)
    await tester.tap(find.text('Alegría'));
    await tester.pump();

    // Tap Save
    await tester.ensureVisible(find.text('Guardar'));
    await tester.tap(find.text('Guardar'));
    await tester.pump(); // Start animation

    // Wait for async operation in controller
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    // Verify service was called
    verify(() => mockDiaryService.createDiaryEntry(any(), any())).called(1);

    // Verify we are back to list (form title not found)
    expect(find.text('Nueva Entrada en el Diario'), findsNothing);

    // Verify the new entry is in the list (Controller updates local state)
    // First, find the collapsed tile by its title
    expect(find.text('Paris'), findsOneWidget);
    // Then, tap the tile to expand it and reveal the content
    await tester.ensureVisible(find.text('Paris'));
    await tester.tap(find.text('Paris'));
    await tester.pumpAndSettle(); // Wait for expansion animation
    // Now, verify the content is visible
    expect(find.text('This is a test entry content that is long enough.'),
        findsOneWidget);
  });
}
