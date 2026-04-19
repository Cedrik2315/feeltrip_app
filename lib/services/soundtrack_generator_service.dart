import 'package:feeltrip_app/core/logger/app_logger.dart';
import 'package:feeltrip_app/features/city_mode/data/drift_database.dart';
import 'package:drift/drift.dart' as drift;

class SoundtrackGeneratorService {
  final AppDatabase _db;

  SoundtrackGeneratorService(this._db);

  /// Orquesta la generación de una canción basada en la experiencia vivida en un Viaje.
  /// 
  /// Utiliza un mix de las palabras clave del diario, ubicación (ej: Quillota o Cerro Mayaca)
  /// y el arquetipo del usuario para solicitar un Soundtrack dinámico a Lyria/Suno AI.
  Future<void> generarMusicaDelViaje(int viajeId) async {
    try {
      AppLogger.i('🎵 Iniciando Engine de Musicalización para Viaje #$viajeId');

      // 1. Extraer Metadata Sensible y Semántica del Viaje desde SQLite
      final viajeConsulta = await (_db.select(_db.viajes)..where((v) => v.id.equals(viajeId))).getSingleOrNull();
      
      if (viajeConsulta == null) {
        AppLogger.e('Viaje #$viajeId no encontrado.');
        return;
      }

      // 2. Extracción simulada de palabras clave (Mood)
      // En prod, esto se fusiona el texto de la bitácora con `moodMusical`
      final moodPrompt = viajeConsulta.moodMusical ?? 'Indie Folk, acústico, sensación de libertad y viento austral';
      AppLogger.i('🎹 Compilando Prompt de Audio: "$moodPrompt"');

      // 3. Trigger a API Externa (Mock: Lyria / Suno / MusicGen)
      AppLogger.i('📡 Enviando Prompt a API generativa neuronal...');
      await Future.delayed(const Duration(seconds: 3)); // Simulación latencia de red/GPU

      // 4. Descarga y Persistencia Local
      final String fakeLocalAudioPath = '/data/user/0/app.feeltrip/app_flutter/sountracks/viaje_$viajeId.mp3';
      AppLogger.i('⬇️ Descargando binario de audio (.mp3)... guardado en: $fakeLocalAudioPath');

      // 5. Actualizar la base de datos con la ruta de la obra de arte
      await (_db.update(_db.viajes)..where((v) => v.id.equals(viajeId))).write(
        ViajesCompanion(
          cancionGeneradaPath: drift.Value(fakeLocalAudioPath),
        ),
      );

      AppLogger.i('✅ Soundtrack Masterizado y Sincronizado exitosamente.');
    } catch (e) {
      AppLogger.e('Error fatal al musicalizar viaje: $e');
    }
  }
}
