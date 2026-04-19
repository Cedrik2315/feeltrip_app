import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:feeltrip_app/core/di/providers.dart'; // Contiene el emotionalEngineProvider

/// Script de utilidad para probar el Motor Emocional de forma aislada.
/// Para ejecutarlo: flutter pub run lib/scripts/test_emotional_engine.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Es fundamental cargar el .env para que el servicio obtenga la API KEY
  await dotenv.load();

  final container = ProviderContainer();
  final engine = container.read(emotionalEngineProvider);

  // Un diario de viaje real para la prueba
  const testEntry = '''
    Hoy caminé por las calles viejas de Limache. Hay una nostalgia extraña en las 
    casonas abandonadas, pero a la vez me sentí muy inspirado por la arquitectura 
    y la paz del lugar. Fue un día tranquilo, de mucha reflexión histórica.
  ''';

  print('--- INICIANDO ANÁLISIS EMOCIONAL ---');
  
  final result = await engine.analyzeDiaryEntry(testEntry);

  if (result != null) {
    print('✅ ANÁLISIS EXITOSO:');
    print('Puntaje de Sentimiento: ${result.sentimentScore}'); // Debería ser positivo (>0)
    print('Emociones Detectadas: ${result.dominantEmotions.join(', ')}');
    print('Etiquetas de Viaje: ${result.travelTags.join(', ')}');
  } else {
    print('❌ EL ANÁLISIS FALLÓ. Revisa tu API Key y conexión.');
  }
}