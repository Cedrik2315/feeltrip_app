import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'drift_database.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final cityModeRepositoryProvider = Provider<CityModeRepository>((ref) {
  return CityModeRepository(ref.watch(appDatabaseProvider));
});

class CityModeRepository {
  final AppDatabase _db;

  CityModeRepository(this._db);

  // Obtener todos los hitos (Reactivo)
  Stream<List<Hito>> watchTodosLosHitos() {
    return _db.select(_db.hitos).watch();
  }

  // Descargar e inyectar un "Paquete de Ciudad" Over-The-Air a la DB offline
  Future<void> insertHitosBatch(List<HitosCompanion> hitos) async {
    await _db.batch((batch) {
      batch.insertAll(
        _db.hitos, 
        hitos, 
        mode: InsertMode.insertOrReplace, // Actualiza si el hito ya existe
      );
    });
  }

  // Marcar hito como descubierto
  Future<void> desbloquearHito(String id) async {
    await (_db.update(_db.hitos)..where((h) => h.id.equals(id))).write(
      const HitosCompanion(descubierto: Value(true)),
    );
  }

  // Obtener aportes de un hito
  Stream<List<AportesUsuario>> watchAportesDeHito(String hitoId) {
    return (_db.select(_db.aportesUsuarios)..where((a) => a.hitoId.equals(hitoId))).watch();
  }

  // Crear un aporte (Muro de la memoria)
  Future<void> addAporte(String hitoId, String comentario, {String? imagePath, String? condicionTemporal}) async {
    await _db.into(_db.aportesUsuarios).insert(
      AportesUsuariosCompanion.insert(
        hitoId: hitoId,
        comentario: comentario,
        fotoLocalPath: Value(imagePath),
        condicionTemporal: Value(condicionTemporal),
      )
    );
  }

  // EL MURO DEL TIEMPO: Obtener aportes solo si sus condiciones temporales se cumplen
  Stream<List<AportesUsuario>> watchAportesVisibles(String hitoId) {
    return (_db.select(_db.aportesUsuarios)
          ..where((a) => a.hitoId.equals(hitoId))
          ..orderBy([(t) => OrderingTerm(expression: t.fecha, mode: OrderingMode.desc)]))
        .watch()
        .map((aportes) {
      final currentHour = DateTime.now().hour;
      final isNocturnal = currentHour >= 19 || currentHour <= 6; // Noche de 7 PM a 6 AM

      return aportes.where((aporte) {
        final condicion = aporte.condicionTemporal;
        if (condicion == null || condicion.isEmpty) return true; // Visible siempre
        
        if (condicion == 'nocturno') return isNocturnal;
        if (condicion == 'diurno') return !isNocturnal;
        
        return true; 
      }).toList();
    });
  }

  // MODO COLMENA: Observar anomalías emocionales detectadas por la comunidad
  Stream<List<AnomaliasEmocionale>> watchAnomaliasEmocionales() {
    return (_db.select(_db.anomaliasEmocionales)..orderBy([(t) => OrderingTerm(expression: t.fechaDeteccion, mode: OrderingMode.desc)])).watch();
  }

  // --- GESTIÓN DE VIAJE / ARTEFACTOS ---

  /// Observar todos los viajes para el Muro de la Memoria
  Stream<List<Viaje>> watchViajes() {
    return (_db.select(_db.viajes)..orderBy([(t) => OrderingTerm(expression: t.fechaViaje, mode: OrderingMode.desc)])).watch();
  }

  /// Crear un nuevo registro de viaje
  Future<int> crearViaje(ViajesCompanion viaje) async {
    return await _db.into(_db.viajes).insert(viaje);
  }

  /// Inyectar datos de prueba para Quillota
  Future<void> insertSeedViajes() async {
    await _db.batch((batch) {
      batch.insertAll(_db.viajes, [
        ViajesCompanion.insert(
          nombre: 'Expedición Valle del Aconcagua',
          moodMusical: const Value('Indie Folk, Melancólico'),
          hasPurchasedArtifact: const Value(true),
          fechaViaje: Value(DateTime.now().subtract(const Duration(days: 2))),
        ),
        ViajesCompanion.insert(
          nombre: 'Vuelo Arqueológico Quillota',
          moodMusical: const Value('Experimental, Techno Minimal'),
          hasPurchasedArtifact: const Value(false),
          fechaViaje: Value(DateTime.now().subtract(const Duration(days: 5))),
        ),
      ]);
    });
  }
}
