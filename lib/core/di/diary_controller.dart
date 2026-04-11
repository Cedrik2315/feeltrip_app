import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:feeltrip_app/core/di/providers.dart';
import 'package:feeltrip_app/models/diary_entry_model.dart';
import 'package:feeltrip_app/user_preferences.dart';

/// Controlador para la gestión de diarios con análisis emocional.
class DiaryController extends AutoDisposeNotifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  /// Orquesta el guardado del texto, consulta a Gemini y persiste en Isar.
  Future<void> saveEntry(String text) async {
    state = const AsyncValue.loading();

    final prefs = ref.read(userPreferencesProvider);
    final isar = ref.read(isarProvider);
    final engine = ref.read(emotionalEngineProvider);

    // 1. Instancia inicial
    final entry = DiaryEntry()
      ..content = text
      ..date = DateTime.now();

    // 2. Proceso de IA: Solo si está habilitado en ajustes
    if (prefs.emotionalAnalytics) {
      try {
        final analysis = await engine.analyzeDiaryEntry(text);
        if (analysis != null) {
          entry
            ..sentimentScore = analysis.sentimentScore
            ..emotions = analysis.dominantEmotions
            ..tags = analysis.travelTags
            ..analyzed = true;
        }
      } catch (e) {
        debugPrint(
        'DiaryController: Error analizando con Gemini: $e');
        // Se guarda con analyzed = false para reintento manual o automático posterior
      }
    }

    // 3. Persistencia atómica en Isar
    state = await AsyncValue.guard(() async {
      await isar.writeTxn(() async {
        await isar.collection<DiaryEntry>().put(entry);
      });
    });
  }
}

final diaryControllerProvider = NotifierProvider.autoDispose<DiaryController, AsyncValue<void>>(DiaryController.new);