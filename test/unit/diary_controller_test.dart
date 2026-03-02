import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:feeltrip_app/controllers/diary_controller.dart';
import 'package:feeltrip_app/services/database_service.dart';
import 'package:feeltrip_app/services/emotion_service.dart';
import 'package:feeltrip_app/services/location_service.dart';
import 'package:feeltrip_app/services/storage_service.dart';

class _MockEmotionService extends Mock implements EmotionService {}

class _MockDatabaseService extends Mock implements DatabaseService {}

class _MockLocationService extends Mock implements LocationService {}

class _MockStorageService extends Mock implements StorageService {}

void main() {
  late _MockEmotionService emotionService;
  late _MockDatabaseService databaseService;
  late _MockLocationService locationService;
  late _MockStorageService storageService;
  late DiaryController controller;

  setUp(() {
    emotionService = _MockEmotionService();
    databaseService = _MockDatabaseService();
    locationService = _MockLocationService();
    storageService = _MockStorageService();
    controller = DiaryController(
      emotionService: emotionService,
      databaseService: databaseService,
      locationService: locationService,
      storageService: storageService,
    );
  });

  test('analyzeText no hace nada con texto vacío', () async {
    await controller.analyzeText('   ');
    verifyNever(() => emotionService.analizarTexto(any()));
  });

  test('analyzeText analiza texto correctamente', () async {
    when(() => emotionService.analizarTexto('Hola')).thenAnswer((_) async =>
        AnalisisResultado(
            emociones: ['Alegría'], destino: 'Playa', explicacion: 'Test'));

    await controller.analyzeText(' Hola ');

    expect(controller.detectedEmotions, ['Alegría']);
    verify(() => emotionService.analizarTexto('Hola')).called(1);
  });

  test('saveDiary guarda entrada correctamente', () async {
    when(() => databaseService.guardarEntrada(
        texto: any(named: 'texto'),
        emociones: any(named: 'emociones'),
        destino: any(named: 'destino'),
        lat: any(named: 'lat'),
        lng: any(named: 'lng'),
        explicacion: any(named: 'explicacion'),
        rutaDetallada: any(named: 'rutaDetallada'))).thenAnswer((_) async {});

    // Primero analizamos texto para tener emociones detectadas
    when(() => emotionService.analizarTexto('Mi experiencia')).thenAnswer(
        (_) async => AnalisisResultado(
            emociones: ['Alegría'],
            destino: 'Playa',
            explicacion: 'Test',
            lat: null,
            lng: null,
            ruta: []));

    await controller.analyzeText('Mi experiencia');
    await controller.saveDiary('Mi experiencia');

    verify(() => databaseService.guardarEntrada(
        texto: 'Mi experiencia',
        emociones: ['Alegría'],
        destino: 'Playa',
        lat: null,
        lng: null,
        explicacion: 'Test',
        rutaDetallada: any(named: 'rutaDetallada'))).called(1);
  });
}
