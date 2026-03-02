import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:feeltrip_app/controllers/auth_controller.dart';
import 'package:feeltrip_app/controllers/diary_controller.dart';
import 'package:feeltrip_app/screens/historial_screen.dart';
import 'package:feeltrip_app/screens/login_screen.dart';
import 'package:feeltrip_app/services/auth_service.dart';
import 'package:feeltrip_app/services/database_service.dart';
import 'package:feeltrip_app/services/emotion_service.dart';
import 'package:feeltrip_app/services/location_service.dart';
import 'package:feeltrip_app/services/storage_service.dart';
import 'package:feeltrip_app/screens/diary_screen.dart';

class MockAuthService extends Mock implements AuthService {}

class MockEmotionService extends Mock implements EmotionService {}

class MockDatabaseService extends Mock implements DatabaseService {}

class MockLocationService extends Mock implements LocationService {}

class MockStorageService extends Mock implements StorageService {}

void main() {
  testWidgets('smoke LoginScreen renderiza', (tester) async {
    final authService = MockAuthService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthController>(create: (_) => AuthController(authService)),
        ],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    await tester.pump();

    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.byType(TextField), findsAtLeastNWidgets(2));
  });

  testWidgets('smoke DiaryScreen renderiza y muestra prompt', (tester) async {
    final authService = MockAuthService();
    final emotionService = MockEmotionService();
    final databaseService = MockDatabaseService();
    final locationService = MockLocationService();
    final storageService = MockStorageService();

    when(() => emotionService.analizarTexto(any())).thenAnswer((_) async =>
        AnalisisResultado(
            emociones: ['Calma'],
            destino: 'Playa',
            explicacion: 'Test',
            lat: null,
            lng: null,
            ruta: []));
    when(() => databaseService.guardarEntrada(
        texto: any(named: 'texto'),
        emociones: any(named: 'emociones'),
        destino: any(named: 'destino'),
        lat: any(named: 'lat'),
        lng: any(named: 'lng'),
        explicacion: any(named: 'explicacion'),
        rutaDetallada: any(named: 'rutaDetallada'))).thenAnswer((_) async {});
    when(() => databaseService.obtenerEntradas())
        .thenAnswer((_) => Stream.value(const <DiarioRegistro>[]));
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
            ),
          ),
        ],
        child: MaterialApp(
          home: DiaryScreen(
            databaseService: databaseService,
            enableCamera: false,
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Mi Diario Emocional'), findsOneWidget);
  });

  testWidgets('smoke HistorialScreen renderiza vacío', (tester) async {
    final databaseService = MockDatabaseService();
    when(() => databaseService.obtenerEntradas())
        .thenAnswer((_) => Stream.value(const <DiarioRegistro>[]));

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
