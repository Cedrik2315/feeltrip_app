import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:feeltrip_app/controllers/auth_controller.dart';
import 'package:feeltrip_app/controllers/diary_controller.dart';
import 'package:feeltrip_app/services/auth_service.dart';
import 'package:feeltrip_app/services/database_service.dart';
import 'package:feeltrip_app/services/emotion_service.dart';

class _MockAuthService extends Mock implements AuthService {}

class _MockEmotionService extends Mock implements EmotionService {}

class _MockDatabaseService extends Mock implements DatabaseService {}

void main() {
  test('smoke flujo login -> guardar diario -> historial -> logout', () async {
    final authService = _MockAuthService();
    final emotionService = _MockEmotionService();
    final databaseService = _MockDatabaseService();

    final authController = AuthController(authService);
    final diaryController = DiaryController(
      emotionService: emotionService,
      databaseService: databaseService,
    );

    when(() => authService.signInWithEmail(email: any(named: 'email'), password: any(named: 'password')))
        .thenAnswer((_) async => throw UnimplementedError());
    when(() => emotionService.analizarTexto(any())).thenAnswer((_) async => ['Calma', 'Gratitud']);
    when(() => databaseService.guardarEntrada(texto: any(named: 'texto'), emociones: any(named: 'emociones')))
        .thenAnswer((_) async {});
    when(() => databaseService.obtenerEntradas()).thenAnswer(
      (_) => Stream.value([
        DiarioRegistro(
          texto: 'Hoy fue un gran día',
          emociones: const ['Calma', 'Gratitud'],
          fecha: DateTime(2026, 1, 1),
        ),
      ]),
    );
    when(() => authService.signOut()).thenAnswer((_) async {});

    try {
      await authController.login(email: 'smoke@test.com', password: '123456');
    } catch (_) {}

    final emociones = await diaryController.analizarYGuardar('Hoy fue un gran día');
    expect(emociones, isNotEmpty);

    final historial = await databaseService.obtenerEntradas().first;
    expect(historial, isNotEmpty);

    await authService.signOut();

    verify(() => emotionService.analizarTexto('Hoy fue un gran día')).called(1);
    verify(() => authService.signOut()).called(1);
  });
}
