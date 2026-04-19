import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:feeltrip_app/core/logger/app_logger.dart';
import 'package:feeltrip_app/features/diario/domain/models/momento_model.dart';
import 'package:feeltrip_app/models/syncable_model.dart';
import 'package:feeltrip_app/services/isar_service.dart';
import 'package:feeltrip_app/core/di/providers.dart'; // Importa el archivo donde syncServiceProvider está definido
import 'package:feeltrip_app/services/sync_service.dart';
import 'package:feeltrip_app/models/momento_model.dart';

final momentoProvider =
    StateNotifierProvider<MomentoNotifier, AsyncValue<List<Momento>>>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  final syncService = ref.watch(syncServiceProvider);
  return MomentoNotifier(isarService, syncService);
});

class MomentoNotifier extends StateNotifier<AsyncValue<List<Momento>>> {
  MomentoNotifier(this._isarService, this._syncService)
      : super(const AsyncValue.data([]));

  final IsarService _isarService;
  final SyncService _syncService;

  Future<void> loadMomentos(String userId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final data = await _isarService.getMomentos();
      return data
          .where((m) => m.userId == userId && m.syncStatus != SyncStatus.deleted)
          .map((m) => m.toDomain())
          .toList();
    });
  }

  Future<void> addMomento(Momento momento) async {
    final current = state.valueOrNull ?? <Momento>[];
    final model = MomentoModel.fromDomain(momento.copyWith(isSynced: false));

    await _isarService.putMomento(model);
    await _syncService.addToSyncQueue(model);

    state = AsyncValue.data([model.toDomain(), ...current]);

    await syncMomentos(momento.userId);
  }

  Future<void> deleteMomento(Momento momento) async {
    await _isarService.deleteMomento(momento.id);
    final current = state.valueOrNull ?? <Momento>[];
    state = AsyncValue.data(
      current.where((item) => item.id != momento.id).toList(),
    );
  }

  Future<void> syncMomentos(String userId) async {
    try {
      await _syncService.syncPendingMomentos(userId);
    } catch (e) {
      AppLogger.e('Error general durante la sincronización: $e');
    } finally {
      final data = await _isarService.getMomentos();
      final filtered = data
          .where((m) => m.userId == userId && m.syncStatus != SyncStatus.deleted)
          .map((m) => m.toDomain())
          .toList();
      state = AsyncValue.data(filtered);
    }
  }

  Future<void> retryPendingSync(String userId) async {
    await syncMomentos(userId);
  }
}
