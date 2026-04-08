import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:math';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import '../core/logger/app_logger.dart';
import '../models/syncable_model.dart';
import '../models/momento_model.dart';
import '../models/booking_model.dart';
import '../models/proposal_model.dart';
import '../models/itinerary_model.dart';
import 'isar_service.dart';





class SyncService {

  SyncService({FirebaseFirestore? firestore, Connectivity? connectivity}) 
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _connectivity = connectivity ?? Connectivity();
  final FirebaseFirestore _firestore;
  final Connectivity _connectivity;
  late IsarService _isar;
  bool _isInitialized = false;
  bool _isSyncing = false;

  /// Registro de boxes que deben sincronizarse con Firestore (Fase 2)
  final List<String> _syncableBoxes = [
    'momentos',
    'proposals',
    'itineraries',
    'bookings',
    'chronicles'
  ];

  Future<void> init(IsarService isar) async {
    if (_isInitialized) return;
    _isar = isar;
    // Aseguramos que Hive esté listo
    await _isar.init();
    
    // Register adapter if not already

    
    _isInitialized = true;

    // Listener de conectividad para disparar sync automático
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        AppLogger.i('SyncService: Conexión detectada. Disparando sync...');
        performGlobalSync();
      }
    });

    AppLogger.i('SyncService: Inicializado correctamente.');
  }
  
  /// Dispara la sincronización global (usado en login, foreground y reconexión).
  Future<void> performGlobalSync() async {
    if (!_isInitialized || _isSyncing) return;
    
    _isSyncing = true;
    AppLogger.i('SyncService: Iniciando sincronización global...');
    try {
      // Loop de Sincronización Único (Fase 2)
      for (final boxName in _syncableBoxes) {
        final box = Hive.box<dynamic>(boxName);
        await _syncCollection(boxName, box);
      }
      
      AppLogger.i('SyncService: Sincronización completada con éxito.');
    } catch (e) {
      AppLogger.e('SyncService: Error durante la sincronización: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Método genérico para sincronizar cualquier box de Hive con una colección de Firestore.
Future<void> _syncCollection(String collectionName, Box<dynamic> box) async {
    final pending = box.values
.where((item) => (item as SyncableModel).syncStatus.needsSync)
        .toList();
        
    if (pending.isEmpty) return;
    
    AppLogger.d('SyncService: Sincronizando ${pending.length} items de $collectionName');
    await _processBatch(collectionName, pending);
  }

  /// Lógica genérica para procesar batches de Firestore
  Future<void> _processBatch(String collection, List<dynamic> items, {int attempt = 0}) async {
    try {
      final batch = _firestore.batch();
      final List<dynamic> processedItems = [];
      
      for (var item in items.take(50)) {
        // Asumimos que todos los modelos implementan toJson() o toFirestore()
final data = (item as SyncableModel).toJson();
        final docRef = _firestore
.collection('users')
            .doc((item).userId)
            .collection(collection)
.doc((item).id ?? 'temp_${DateTime.now().millisecondsSinceEpoch}');

        batch.set(docRef, {
          ...data,
          'syncedAt': FieldValue.serverTimestamp(),
          'syncStatus': 'synced',
        });
        processedItems.add(item);
      }

      await batch.commit();
      
      // Actualizar estado local tras éxito
      for (var item in processedItems) {
(item as SyncableModel).syncStatus = SyncStatus.synced;
(item as HiveObject).save();
      }
      
      AppLogger.i('SyncService: Lote de 50 items completado para $collection.');
    } catch (e) {
      if (attempt < 3) {
        // Backoff exponencial: 2, 4, 8 segundos...
        final retryDelay = pow(2, attempt + 1).toInt();
        AppLogger.w('SyncService: Error en $collection. Reintentando en $retryDelay s (Intento ${attempt + 1})...');
        
await Future<void>.delayed(Duration(seconds: retryDelay));
        return _processBatch(collection, items, attempt: attempt + 1);
      } else {
        AppLogger.e('SyncService: Fallo definitivo tras 3 reintentos en $collection: $e');
        rethrow;
      }
    }
  }

bool get hasPendingActions {
  // Casts for dynamic box access
  final momentoBox = Hive.box<dynamic>('momentos');
  final proposalsBox = Hive.box<dynamic>('proposals');
  return momentoBox.values.cast<SyncableModel>().any((m) => m.syncStatus.needsSync) ||
         proposalsBox.values.cast<SyncableModel>().any((p) => p.syncStatus.needsSync);
}

  Future<void> addToSyncQueue(dynamic item) async {
    if (item is MomentoModel) {
      await _isar.enqueueMomentoSync(item);
      return;
    }

    if (item is BookingModel) {
      AppLogger.i(
        'Booking ${item.id} guardado localmente; su confirmacion sigue atada al flujo de pago.',
      );
      return;
    }

    if (item is ProposalModel || item is ItineraryModel) {
      AppLogger.i('Item ${item.runtimeType} listo para sincronizacion diferida.');
      return;
    }

    AppLogger.w('Tipo no soportado en cola de sync: ${item.runtimeType}');
  }

  Future<void> syncPendingMomentos(String userId) async {
    final pendingMomentos = await _isar.getPendingMomentos(userId);

    for (final momento in pendingMomentos) {
      try {
        final remoteId = await _isar.pushMomentoToCloud(momento);
        await _isar.markMomentoAsSynced(momento.key.toString(), remoteId);
      } catch (error) {
        await _isar.markMomentoSyncError(momento.id, error.toString());
        AppLogger.e('Error sincronizando momento ${momento.id}: $error');
      }
    }
  }

  Future<void> syncPendingProposals(String userId) async {
    final pendingProposals = await _isar.getPendingProposals(userId);

    for (final proposal in pendingProposals) {
      try {
        await _isar.pushProposalToCloud(proposal);
        await _isar.markProposalAsSynced(proposal.id);
      } catch (error) {
        await _isar.markProposalSyncError(proposal.id, error.toString());
        AppLogger.e('Error sincronizando propuesta ${proposal.id}: $error');
      }
    }
  }

  Future<void> syncPendingItineraries(String userId) async {
    final pendingItineraries = await _isar.getPendingItineraries(userId);

    for (final itinerary in pendingItineraries) {
      try {
        await _isar.pushItineraryToCloud(itinerary);
        await _isar.markItineraryAsSynced(itinerary.id);
      } catch (error) {
        await _isar.markItinerarySyncError(itinerary.id, error.toString());
        AppLogger.e('Error sincronizando itinerario ${itinerary.id}: $error');
      }
    }
  }

  Future<void> syncUserEntries(String userId) async {
    await syncPendingMomentos(userId);
    await syncPendingProposals(userId);
    await syncPendingItineraries(userId);
  }
}

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService();
});
