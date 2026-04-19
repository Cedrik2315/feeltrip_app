import 'package:drift/drift.dart';
import 'package:feeltrip_app/features/city_mode/data/drift_database.dart';

class CityModeSeedData {
  static List<HitosCompanion> get QuillotaHitos => [
    const HitosCompanion(
      id: Value('consistorial_01'),
      lat: Value(-32.88038),
      lng: Value(-71.24754), // Edificio Consistorial real
      titulo: Value('hito_consistorial_title'),
      descripcionCorta: Value('hito_consistorial_desc'),
      categoria: Value('historia'),
      radio: Value(50.0),
      puntosRecompensa: Value(150),
    ),
    const HitosCompanion(
      id: Value('museo_01'),
      lat: Value(-32.88095),
      lng: Value(-71.24823), // Museo Histórico Arqueológico real
      titulo: Value('hito_museo_title'),
      descripcionCorta: Value('hito_museo_desc'),
      categoria: Value('historia'),
      radio: Value(40.0),
      puntosRecompensa: Value(200),
    ),
    const HitosCompanion(
      id: Value('plaza_01'),
      lat: Value(-32.87985),
      lng: Value(-71.24712), // Plaza de Armas (Centro)
      titulo: Value('hito_plaza_title'),
      descripcionCorta: Value('hito_plaza_desc'),
      categoria: Value('social'),
      radio: Value(50.0),
      puntosRecompensa: Value(120),
    ),
    const HitosCompanion(
      id: Value('estacion_01'),
      lat: Value(-32.8850),
      lng: Value(-71.2410),
      titulo: Value('hito_estacion_title'),
      descripcionCorta: Value('hito_estacion_desc'),
      categoria: Value('diseno'),
      radio: Value(70.0),
      puntosRecompensa: Value(180),
    ),
    const HitosCompanion(
      id: Value('mercado_01'),
      lat: Value(-32.8760),
      lng: Value(-71.2510),
      titulo: Value('hito_mercado_title'),
      descripcionCorta: Value('hito_mercado_desc'),
      categoria: Value('tecnico'),
      radio: Value(30.0),
      puntosRecompensa: Value(300),
    ),
  ];
}
