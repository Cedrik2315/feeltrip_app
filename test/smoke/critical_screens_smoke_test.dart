import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:feeltrip_app/controllers/auth_controller.dart';
import 'package:feeltrip_app/controllers/diary_controller.dart';
import 'package:feeltrip_app/models/experience_model.dart';
import 'package:feeltrip_app/screens/historial_screen.dart';
import 'package:feeltrip_app/screens/login_screen.dart';
import 'package:feeltrip_app/screens/diario_screen.dart';
import 'package:feeltrip_app/services/auth_service.dart';
import 'package:feeltrip_app/services/achievements_service.dart';
import 'package:feeltrip_app/services/database_service.dart';
import 'package:feeltrip_app/services/emotion_service.dart';
import 'package:feeltrip_app/services/location_service.dart';
import 'package:feeltrip_app/services/storage_service.dart';

class MockAuthService extends Mock implements AuthService {}

class MockEmotionService extends Mock implements EmotionService {}

class MockDatabaseService extends Mock implements DatabaseService {}

class MockLocationService extends Mock implements LocationService {}

class MockStorageService extends Mock implements StorageService {}

class MockDiaryAchievementsService extends Mock
    implements DiaryAchievementsService {}

class MockAchievementService extends Mock implements AchievementService {}

// Mock para AuthController que extiende GetxController para ser compatible con Get.put
class MockAuthController extends GetxController
    with Mock
    implements AuthController {}

void main() {
  late MockAuthController mockAuthController;

  setUp(() {
    mockAuthController = MockAuthController();
    // Registramos el AuthController en GetX para que LoginScreen pueda encontrarlo
    Get.put<AuthController>(mockAuthController);
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('smoke LoginScreen renderiza', (tester) async {
    final authService = MockAuthService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthService>.value(value: authService),
        ],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    await tester.pump();

    expect(find.text('Iniciar Sesión'), findsOneWidget);
    expect(find.byType(TextField), findsAtLeastNWidgets(2));
  });

  testWidgets('smoke DiaryScreen renderiza y muestra prompt', (tester) async {
    final authService = MockAuthService();
    final emotionService = MockEmotionService();
    final databaseService = MockDatabaseService();
    final locationService = MockLocationService();
    final storageService = MockStorageService();
    final diaryAchievementsService = MockDiaryAchievementsService();
    final achievementService = MockAchievementService();

    when(() => emotionService.analizarTexto(any())).thenAnswer((_) async =>
        AnalisisResultado(
            emociones: ['Calma'],
            destino: 'Playa',
            explicacion: 'Test',
            lat: null,
            lng: null,
            ruta: []));
    when(() => databaseService.obtenerEntradas())
        .thenAnswer((_) => Stream.value(<DiaryEntry>[]));
    when(() => authService.signOut()).thenAnswer((_) async {});

    // Usar ChangeNotifierProvider en lugar de Provider para DiaryController
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthService>.value(value: authService),
          ChangeNotifierProvider<DiaryController>(
            create: (_) => DiaryController(
              emotionService: emotionService,
              databaseService: databaseService,
              locationService: locationService,
              storageService: storageService,
              diaryAchievementsService: diaryAchievementsService,
              achievementService: achievementService,
            ),
          ),
        ],
        child: const MaterialApp(
          home: DiarioScreen(),
        ),
      ),
    );

    await tester.pump();

    // Check for the translate icon which is present in the AppBar actions of DiarioScreen
    expect(find.byIcon(Icons.translate), findsOneWidget);
  });

  testWidgets('smoke HistorialScreen renderiza vacío', (tester) async {
    final databaseService = MockDatabaseService();
    when(() => databaseService.obtenerEntradas())
        .thenAnswer((_) => Stream.value(<DiaryEntry>[]));

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<DatabaseService>.value(value: databaseService),
        ],
        child: const MaterialApp(home: HistorialScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Mis viajes emocionales'), findsOneWidget);
  });
}
