import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';


import '../core/logger/app_logger.dart';
import '../core/network/sync_user_id_collector.dart';
import '../models/booking_model.dart';
import '../models/itinerary_model.dart';
import '../models/momento_model.dart';
import '../models/proposal_model.dart';
import '../models/syncable_model.dart';
import 'isar_service.dart';


class SyncService {
  SyncService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  late IsarService _isar;
  bool _isInitialized = false;
  bool _isSyncing = false;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  Future<void> init(IsarService isar) async {
    if (_isInitialized) return;
    _isar = isar;
    await _isar.init();

    _isInitialized = true;
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (ConnectivityResult result) {
        if (result != ConnectivityResult.none) {
          AppLogger.i('SyncService: Conexión detectada. Disparando sync soportado...');
          unawaited(performGlobalSync());
        }
      },
    );

    AppLogger.i('SyncService: Inicializado correctamente.');
  }

  Future<void> performGlobalSync() async {
    if (!_isInitialized || _isSyncing) return;

    _isSyncing = true;
    AppLogger.i('SyncService: Iniciando sincronización global soportada...');
    try {
      final pendingMomentos = await _isar.getMomentos(syncStatus: SyncStatus.pending);
      final pendingLocalMomentos = await _isar.getMomentos(syncStatus: SyncStatus.local);
      final pendingErrors = await _isar.getMomentos(syncStatus: SyncStatus.error);
      final deletedMomentos = await _isar.getMomentos(syncStatus: SyncStatus.deleted);
      final pendingProposals = _isar.proposalsBox.values
          .where((proposal) => proposal.syncStatus.needsSync)
          .toList();
      final pendingItineraries = _isar.itinerariesBox.values
          .where((itinerary) => itinerary.syncStatus.needsSync)
          .toList();

      final userIds = collectPendingSyncUserIds(
        pendingMomentos: pendingMomentos,
        localMomentos: pendingLocalMomentos,
        errorMomentos: pendingErrors,
        deletedMomentos: deletedMomentos,
        pendingProposals: pendingProposals,
        pendingItineraries: pendingItineraries,
      );

      AppLogger.d(
        'SyncService: ${pendingMomentos.length} momentos pending, '
        '${pendingLocalMomentos.length} momentos local, '
        '${pendingErrors.length} momentos error, '
        '${deletedMomentos.length} momentos deleted, '
        '${pendingProposals.length} proposals pendientes y '
        '${pendingItineraries.length} itineraries pendientes.',
      );

      for (final userId in userIds) {
        await syncUserEntries(userId);
      }

      AppLogger.i('SyncService: Sincronización global soportada finalizada.');
    } catch (e, stackTrace) {
      AppLogger.e(
        'SyncService: Error durante la sincronización global: $e',
        e,
        stackTrace,
      );
    } finally {
      _isSyncing = false;
    }
  }

  bool get hasPendingActions {
    final momentoBox = _isar.box;
    final hasMomentos = momentoBox.values.any((m) => m.syncStatus.needsSync);
    final hasProposals = _isar.proposalsBox.values.any((p) => p.syncStatus.needsSync);
    final hasItineraries = _isar.itinerariesBox.values.any((i) => i.syncStatus.needsSync);
    return hasMomentos || hasProposals || hasItineraries;
  }

  Future<void> addToSyncQueue(dynamic item) async {
    if (item is MomentoModel) {
      await _isar.enqueueMomentoSync(item);
      return;
    }

    if (item is BookingModel) {
      AppLogger.i(
        'Booking ${item.id} guardado localmente; su confirmación sigue atada al flujo de pago.',
      );
      return;
    }

    if (item is ProposalModel) {
      item.syncStatus = SyncStatus.pending;
      item.lastAttempt = DateTime.now();
      await _isar.putProposal(item);
      return;
    }

    if (item is ItineraryModel) {
      item.syncStatus = SyncStatus.pending;
      item.lastAttempt = DateTime.now();
      await _isar.putItinerary(item);
      return;
    }

    AppLogger.w('Tipo no soportado en cola de sync: ${item.runtimeType}');
  }

  Future<void> syncPendingMomentos(String userId) async {
    final pendingMomentos = await _isar.getPendingMomentos(userId);

    for (final momento in pendingMomentos) {
      try {
        if (momento.syncStatus == SyncStatus.deleted) {
          await _isar.deleteMomentoFromCloud(momento);
          await _isar.permanentDelete(momento.key);
          continue;
        }

        final remoteId = await _isar.pushMomentoToCloud(momento);
        await _isar.markMomentoAsSynced(momento.key.toString(), remoteId);
      } catch (error, stackTrace) {
        await _isar.markMomentoSyncError(momento.id, error.toString());
        AppLogger.e(
          'Error sincronizando momento ${momento.id}: $error',
          error,
          stackTrace,
        );
      }
    }

    await _isar.mergeMomentosFromCloud(userId);
  }

  Future<void> syncPendingProposals(String userId) async {
    final pendingProposals = await _isar.getPendingProposals(userId);
    if (pendingProposals.isEmpty) return;

    for (final proposal in pendingProposals) {
      try {
        await _isar.pushProposalToCloud(proposal);
        await _isar.markProposalAsSynced(proposal.id);
      } catch (error, stackTrace) {
        await _isar.markProposalSyncError(proposal.id, error.toString());
        AppLogger.e(
          'Error sincronizando propuesta ${proposal.id}: $error',
          error,
          stackTrace,
        );
      }
    }
  }

  Future<void> syncPendingItineraries(String userId) async {
    final pendingItineraries = await _isar.getPendingItineraries(userId);
    if (pendingItineraries.isEmpty) return;

    for (final itinerary in pendingItineraries) {
      try {
        await _isar.pushItineraryToCloud(itinerary);
        await _isar.markItineraryAsSynced(itinerary.id);
      } catch (error, stackTrace) {
        await _isar.markItinerarySyncError(itinerary.id, error.toString());
        AppLogger.e(
          'Error sincronizando itinerario ${itinerary.id}: $error',
          error,
          stackTrace,
        );
      }
    }
  }

  Future<void> syncUserEntries(String userId) async {
    await syncPendingMomentos(userId);
    await syncPendingProposals(userId);
    await syncPendingItineraries(userId);
  }

  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }
}
