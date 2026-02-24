import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:feeltrip_app/controllers/diary_controller.dart';
import 'package:feeltrip_app/services/database_service.dart';
import 'package:feeltrip_app/services/emotion_service.dart';

class _MockEmotionService extends Mock implements EmotionService {}

class _MockDatabaseService extends Mock implements DatabaseService {}

void main() {
  late _MockEmotionService emotionService;
  late _MockDatabaseService databaseService;
  late DiaryController controller;

  setUp(() {
    emotionService = _MockEmotionService();
    databaseService = _MockDatabaseService();
    controller = DiaryController(
      emotionService: emotionService,
      databaseService: databaseService,
    );
  });

  test('analizarYGuardar falla con texto vacío', () async {
    expect(
      () => controller.analizarYGuardar('   '),
      throwsA(isA<Exception>()),
    );
    verifyNever(() => emotionService.analizarTexto(any()));
  });

  test('analizarYGuardar analiza y guarda', () async {
    when(() => emotionService.analizarTexto('Hola')).thenAnswer((_) async => ['Alegría']);
    when(() => databaseService.guardarEntrada(texto: any(named: 'texto'), emociones: any(named: 'emociones')))
        .thenAnswer((_) async {});

    final result = await controller.analizarYGuardar(' Hola ');

    expect(result, ['Alegría']);
    verify(() => emotionService.analizarTexto('Hola')).called(1);
    verify(() => databaseService.guardarEntrada(texto: 'Hola', emociones: ['Alegría'])).called(1);
  });
}
