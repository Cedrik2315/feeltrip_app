import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:feeltrip_app/controllers/auth_controller.dart';
import 'package:feeltrip_app/controllers/diary_controller.dart';
import 'package:feeltrip_app/screens/diario_screen.dart';
import 'package:feeltrip_app/screens/historial_screen.dart';
import 'package:feeltrip_app/screens/login_screen.dart';
import 'package:feeltrip_app/services/auth_service.dart';
import 'package:feeltrip_app/services/database_service.dart';
import 'package:feeltrip_app/services/emotion_service.dart';

class _MockAuthService extends Mock implements AuthService {}

class _MockEmotionService extends Mock implements EmotionService {}

class _MockDatabaseService extends Mock implements DatabaseService {}

void main() {
  testWidgets('smoke LoginScreen renderiza', (tester) async {
    final authService = _MockAuthService();

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

  testWidgets('smoke DiarioScreen renderiza y muestra prompt', (tester) async {
    final authService = _MockAuthService();
    final emotionService = _MockEmotionService();
    final databaseService = _MockDatabaseService();
    when(() => emotionService.analizarTexto(any())).thenAnswer((_) async => ['Calma']);
    when(() => databaseService.guardarEntrada(texto: any(named: 'texto'), emociones: any(named: 'emociones')))
        .thenAnswer((_) async {});
    when(() => authService.signOut()).thenAnswer((_) async {});

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthService>.value(value: authService),
          Provider<DiaryController>(
            create: (_) => DiaryController(
              emotionService: emotionService,
              databaseService: databaseService,
            ),
          ),
        ],
        child: const MaterialApp(home: DiarioScreen(enableAds: false)),
      ),
    );

    await tester.pump();

    expect(find.text('FeelTrip - Diario IA'), findsOneWidget);
    expect(find.text('¿Qué descubriste hoy?'), findsOneWidget);
  });

  testWidgets('smoke HistorialScreen renderiza vacío', (tester) async {
    final databaseService = _MockDatabaseService();
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
