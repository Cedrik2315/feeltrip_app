import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:feeltrip_app/features/city_mode/data/city_mode_seed_data.dart';

part 'drift_database.g.dart';

// Esquema de la Tabla Hitos (Drift/Dart)
class Hitos extends Table {
  // Identificador único (ej: 'consistorial_01')
  TextColumn get id => text()();
  
  // Datos de Geofencing
  RealColumn get lat => real()();
  RealColumn get lng => real()();
  RealColumn get radio => real().withDefault(const Constant(50.0))(); // Radio en metros

  // Contenido Narrativo
  TextColumn get titulo => text().withLength(min: 1, max: 100)();
  TextColumn get descripcionCorta => text()();
  
  // Rutas a archivos locales (Assets/Storage) para el efecto Offline
  TextColumn get audioPath => text().nullable()(); // Ruta al archivo .m4a
  TextColumn get imagePath => text().nullable()(); // Imagen del "pasado" o plano
  TextColumn get filtroMapaStyle => text().nullable()(); // JSON de estilo para esa época

  // Lógica de Juego (Gamificación)
  BoolColumn get descubierto => boolean().withDefault(const Constant(false))();
  IntColumn get puntosRecompensa => integer().withDefault(const Constant(100))();
  TextColumn get categoria => text()(); // 'historia', 'tecnico', 'social'

  @override
  Set<Column> get primaryKey => {id};
}

// Tabla para los aportes de los usuarios (El "Muro de la Memoria")
class AportesUsuarios extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get hitoId => text().references(Hitos, #id)(); // Relación con el hito
  TextColumn get comentario => text()();
  DateTimeColumn get fecha => dateTime().withDefault(currentDateAndTime)();
  TextColumn get fotoLocalPath => text().nullable()(); // Foto capturada por el usuario
  TextColumn get condicionTemporal => text().nullable()(); // Ej: 'nocturno', 'diurno', 'lluvia'
}

// Tabla para almacenar expediciones/rutas y sus canciones generadas
class Viajes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text()();
  TextColumn get moodMusical => text().nullable()(); // Prompt o sentimiento para la música
  TextColumn get cancionGeneradaPath => text().nullable()(); // Ruta local al audio generado
  TextColumn get artifactDesignPath => text().nullable()(); // Ruta local al diseño técnico generado por IA
  BoolColumn get hasPurchasedArtifact => boolean().withDefault(const Constant(false))();
  DateTimeColumn get fechaViaje => dateTime().withDefault(currentDateAndTime)();
}

// Tabla para el "Modo Colmena": Anomalías Emocionales detectadas automáticamente
class AnomaliasEmocionales extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get lat => real()();
  RealColumn get lng => real()();
  TextColumn get tipoEmocion => text()(); // Ej: 'asombro', 'paz', 'euforia'
  IntColumn get intensidadHrv => integer()(); // Nivel de impacto biométrico
  TextColumn get audioAmbientalPath => text().nullable()(); // Ruta al audio de 10s
  DateTimeColumn get fechaDeteccion => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Hitos, AportesUsuarios, Viajes, AnomaliasEmocionales])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        // Insertando Semillas Iniciales usando CityModeSeedData
        await batch((batch) {
          batch.insertAll(hitos, CityModeSeedData.quillotaHitos);
        });
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'feeltrip_city_mode.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
