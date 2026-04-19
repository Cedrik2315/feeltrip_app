import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:feeltrip_app/services/emotional_engine_service.dart';
import 'dart:io';

void main() async {
  // 1. Cargar API Key
  await dotenv.load(fileName: '.env');
  final service = EmotionalEngineService();

  const testEntry = 'Hoy llegué a la cima del volcán. Hacía mucho frío y el viento era fuerte, pero ver el cráter activo me dejó sin palabras. Sentí una mezcla de miedo y una paz inmensa.';

  print('--- SIMULACIÓN DE CRÓNICAS FEELTRIP ---\n');

  print('[TEST 1: USUARIO ESTÁNDAR]');
  final standard = await service.generateChronicle(
    diaryEntry: testEntry,
    isPremium: false,
    username: 'Carlos',
  );
  print(standard ?? 'Error en generación');
  print('\n-----------------------------------\n');

  print('[TEST 2: USUARIO PREMIUM TRIAL (REGALO)]');
  final premium = await service.generateChronicle(
    diaryEntry: testEntry,
    isPremium: true,
    username: 'Carlos',
  );
  print(premium ?? 'Error en generación');
  
  exit(0);
}
