import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:feeltrip_app/models/expedition_data.dart';
import 'package:feeltrip_app/services/chronicle_service.dart';


void main() async {
  // 1. Cargar variables de entorno
  await dotenv.load(fileName: '.env');
  final apiKey = dotenv.env['GOOGLE_AI_API_KEY'] ?? '';
  
  if (apiKey.isEmpty) {
    print('ERROR: GOOGLE_AI_API_KEY no encontrada.');
    return;
  }

  final service = ChronicleService(apiKey: apiKey);

  final data = ExpeditionData(
    placeName: 'Parque Nacional La Campana',
    region: 'Valparaíso',
    arrivalTime: '17:30',
    temperature: '22°C',
    uniqueDetail: 'El olor a tierra mojada tras la llovizna y el crujir de las hojas secas.',
    explorerName: 'Cedrik',
    tone: NarrativeTone.lirico,
    distanceKm: 8.5,
    elevationGainM: 450,
  );

  print('--- GENERANDO TEST DE ARQUETIPOS ---');

  // Caso 1: Aventurero
  print('\n[TEST 1: ARQUETIPO AVENTURERO]');
  final cronicaAventurero = await service.generateChronicle(
    data: data,
    userId: 'test_user',
    expeditionNumber: 1,
    archetype: 'Aventurero',
  );
  print('TÍTULO: ${cronicaAventurero.title}');
  print('CONTENIDO:\n${cronicaAventurero.paragraphs.join('\n\n')}');

  print('\n-----------------------------------');

  // Caso 2: Contemplativo
  print('\n[TEST 2: ARQUETIPO CONTEMPLATIVO]');
  final cronicaContemplativo = await service.generateChronicle(
    data: data,
    userId: 'test_user',
    expeditionNumber: 2,
    archetype: 'Contemplativo',
  );
  print('TÍTULO: ${cronicaContemplativo.title}');
  print('CONTENIDO:\n${cronicaContemplativo.paragraphs.join('\n\n')}');
}
