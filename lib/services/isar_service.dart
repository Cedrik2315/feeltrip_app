import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../core/logger/app_logger.dart';
import '../models/booking_model.dart';
import '../models/chronicle_model.dart';
import '../models/gps_models.dart';
import '../models/itinerary_model.dart';
import '../models/momento_model.dart';
import '../models/proposal_model.dart';
import '../models/syncable_model.dart';
import '../models/diary_entry_model.dart';
import 'package:feeltrip_app/features/profile/domain/user_profile_model.dart';
import '../core/local_storage/app_schemas.dart';

class IsarService {
  IsarService._internal();
  static IsarService? _instance;
  factory IsarService() => _instance ??= IsarService._internal();

  bool _isInitialized = false;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  late Isar _isar;

  static const String _boxName = 'momentos';
  static const String _proposalsBoxName = 'proposals';
  static const String _itinerariesBoxName = 'itineraries';
  static const String _bookingsBoxName = 'bookings';
  static const String _chroniclesBoxName = 'chronicles';
  static const String _routesBoxName = 'routes';
  static const String _metaBoxName = 'chronicle_meta';
  static const String _prefsBoxName = 'user_preferences';
  static const String _profileBoxName = 'profile_box';

  Box<MomentoModel>? _box;
  Box<ProposalModel>? _proposalsBox;
  Box<ItineraryModel>? _itinerariesBox;
  Box<RouteModel>? _routesBox;
  Box<dynamic>? _bookingsBox;
  Box<UserProfile>? _profileBox;
  Box<dynamic> get bookingsBox => _bookingsBox!;
  Box<ChronicleModel>? _chroniclesBox;
  Box<dynamic>? _metaBox;
  Box<dynamic>? _prefsBox;

  Box<MomentoModel> get box => _ensureBox(_box, _boxName);
  Box<ProposalModel> get proposalsBox =>
      _ensureBox(_proposalsBox, _proposalsBoxName);
  Box<ItineraryModel> get itinerariesBox =>
      _ensureBox(_itinerariesBox, _itinerariesBoxName);
  Box<RouteModel> get routesBox => _ensureBox(_routesBox, _routesBoxName);
  Box<ChronicleModel> get chroniclesBox =>
      _ensureBox(_chroniclesBox, _chroniclesBoxName);
  Box<dynamic> get metaBox => _ensureBox(_metaBox, _metaBoxName);
  Box<dynamic> get prefsBox => _ensureBox(_prefsBox, _prefsBoxName);
  Box<UserProfile> get profileBox => _ensureBox(_profileBox, _profileBoxName);

  /// Acceso a la instancia de Isar para nuevos modelos
  Isar get isar {
    if (!_isInitialized) throw StateError('IsarService no inicializado');
    return _isar;
  }

  Box<T> _ensureBox<T>(Box<T>? box, String name) {
    if (box == null || !box.isOpen) {
      throw StateError('Hive box "$name" not initialized. Call init() first.');
    }
    return box;
  }

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      await Hive.initFlutter();
      
      final dir = await getApplicationDocumentsDirectory();
      _isar = await Isar.open(
        [
          DiaryEntrySchema, 
          MomentoDbSchema, 
          ChronicleDbSchema, 
          ProposalDbSchema, 
          ItineraryDbSchema, 
          BookingDbSchema,
          AiCacheDbSchema
        ],
        directory: dir.path,
      );

      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(MomentoModelAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(SyncStatusAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(ProposalModelAdapter());
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(ItineraryModelAdapter());
      }
      if (!Hive.isAdapterRegistered(10)) {
        Hive.registerAdapter(ChronicleModelAdapter());
      }
      if (!Hive.isAdapterRegistered(12)) {
        Hive.registerAdapter(BadgeModelAdapter());
      }
      if (!Hive.isAdapterRegistered(13)) {
        Hive.registerAdapter(UserProfileAdapter());
      }

      _box = await Hive.openBox<MomentoModel>(_boxName);
      _proposalsBox = await Hive.openBox<ProposalModel>(_proposalsBoxName);
      _itinerariesBox = await Hive.openBox<ItineraryModel>(_itinerariesBoxName);
      _bookingsBox = await Hive.openBox<dynamic>(_bookingsBoxName);
      _chroniclesBox = await Hive.openBox<ChronicleModel>(_chroniclesBoxName);
      _routesBox = await Hive.openBox<RouteModel>(_routesBoxName);
      _metaBox = await Hive.openBox<dynamic>(_metaBoxName);
      _prefsBox = await Hive.openBox<dynamic>(_prefsBoxName);
      _profileBox = await Hive.openBox<UserProfile>(_profileBoxName);
      _isInitialized = true;
      AppLogger.i('IsarService (Hive backend) initialized');
      AppLogger.i(
        'FUTURE: Migrate to Isar using lib/core/local_storage/chronicle_schema.dart',
      );
    } catch (e) {
      AppLogger.e('Hive init error: $e');
      rethrow;
    }
  }

  Future<void> putMomento(MomentoModel momento) async {
    // 1. Hive (Legacy para retrocompatibilidad inmediata)
    if (momento.syncStatus == SyncStatus.local) {
      momento.syncStatus = SyncStatus.pending;
      momento.lastAttempt = DateTime.now();
    }
    final storageKey = momento.key ?? momento.firestoreId ?? DateTime.now().millisecondsSinceEpoch.toString();
    await box.put(storageKey, momento);

    // 2. Isar (Nueva infraestructura escalable)
    final db = MomentoDb()
      ..firestoreId = momento.firestoreId
      ..userId = momento.userId
      ..title = momento.title
      ..description = momento.description
      ..emotionTags = momento.emotionTags
      ..latitude = momento.locationLat
      ..longitude = momento.locationLng
      ..imageUrls = momento.imageUrls
      ..createdAt = momento.createdAt
      ..syncStatus = momento.syncStatus.name
      ..errorMessage = momento.errorMessage
      ..retryCount = momento.retryCount
      ..lastAttempt = momento.lastAttempt
      ..updatedAt = momento.updatedAt;

    await _isar.writeTxn(() => _isar.momentoDbs.put(db));
    AppLogger.d('Momento saved in both Hive and Isar (dual-write)');
  }

  // --- IA CACHE METHODS ---

  Future<void> putAiResponse(String promptHash, String response) async {
    final expiresAt = DateTime.now().add(const Duration(days: 30));
    final db = AiCacheDb()
      ..promptHash = promptHash
      ..response = response
      ..createdAt = DateTime.now()
      ..expiresAt = expiresAt;

    await _isar.writeTxn(() => _isar.aiCacheDbs.put(db));
  }

  Future<String?> getAiResponse(String promptHash) async {
    final entry = await _isar.aiCacheDbs.where().promptHashEqualTo(promptHash).findFirst();
    if (entry != null && entry.expiresAt.isAfter(DateTime.now())) {
      return entry.response;
    }
    return null;
  }

  Future<void> putChronicle(ChronicleModel chronicle) async {
    // Save in Hive
    await chroniclesBox.put(chronicle.id, chronicle);
    
    // Save in Isar
    final db = ChronicleDb()
      ..localId = chronicle.id
      ..userId = chronicle.userId
      ..title = chronicle.title
      ..paragraphs = chronicle.paragraphs
      ..expeditionDataJson = chronicle.expeditionDataJson.toString()
      ..generatedAt = chronicle.generatedAt
      ..expeditionNumber = chronicle.expeditionNumber
      ..imageUrl = chronicle.imageUrl
      ..visualMetaphor = chronicle.visualMetaphor
      ..syncStatus = chronicle.syncStatus.name;

    await _isar.writeTxn(() => _isar.chronicleDbs.put(db));
  }

  Future<List<MomentoModel>> getMomentos({
    String? userId,
    SyncStatus? syncStatus,
  }) async {
    // Usamos Isar para búsquedas rápidas si es posible
    final query = _isar.momentoDbs.where();
    List<MomentoDb> results;
    
    if (userId != null && syncStatus != null) {
      results = await query.filter()
          .userIdEqualTo(userId)
          .syncStatusEqualTo(syncStatus.name)
          .findAll();
    } else if (userId != null) {
      results = await query.filter().userIdEqualTo(userId).findAll();
    } else {
      results = await query.findAll();
    }

    return results.map((db) => MomentoModel(
      userId: db.userId,
      title: db.title,
      description: db.description,
      emotionTags: db.emotionTags,
      locationLat: db.latitude,
      locationLng: db.longitude,
      imageUrls: db.imageUrls,
      createdAt: db.createdAt,
      syncStatus: SyncStatus.values.byName(db.syncStatus),
      firestoreId: db.firestoreId,
      errorMessage: db.errorMessage,
      retryCount: db.retryCount,
      lastAttempt: db.lastAttempt,
      updatedAt: db.updatedAt,
    )).toList();
  }

  Future<void> putProposal(ProposalModel proposal) async {
    // 1. Hive
    if (proposal.syncStatus == SyncStatus.local) {
      proposal.syncStatus = SyncStatus.pending;
      proposal.lastAttempt = DateTime.now();
    }
    await proposalsBox.put(proposal.id, proposal);

    // 2. Isar
    final db = ProposalDb()
      ..firestoreId = proposal.id
      ..userId = proposal.userId
      ..title = 'Propuesta IA' // Placeholder o extraer de content
      ..description = proposal.content
      ..destination = '' 
      ..budget = 0.0
      ..startDate = proposal.createdAt
      ..endDate = proposal.createdAt
      ..syncStatus = proposal.syncStatus.name;

    await _isar.writeTxn(() => _isar.proposalDbs.put(db));
    AppLogger.d('Proposal saved in dual-write (Hive/Isar)');
  }

  Future<void> putItinerary(ItineraryModel itinerary) async {
    // 1. Hive
    if (itinerary.syncStatus == SyncStatus.local) {
      itinerary.syncStatus = SyncStatus.pending;
      itinerary.lastAttempt = DateTime.now();
    }
    await itinerariesBox.put(itinerary.id, itinerary);

    // 2. Isar
    final db = ItineraryDb()
      ..firestoreId = itinerary.id
      ..userId = itinerary.userId
      ..title = 'Itinerario Generado'
      ..proposalId = itinerary.proposalId
      ..contentJson = itinerary.content
      ..syncStatus = itinerary.syncStatus.name;

    await _isar.writeTxn(() => _isar.itineraryDbs.put(db));
    AppLogger.d('Itinerary saved in dual-write (Hive/Isar)');
  }

  Future<void> saveBooking(BookingModel booking) async {
    // 1. Hive
    final key = booking.key ?? booking.id;
    await bookingsBox.put(key, booking.toJson());

    // 2. Isar
    final db = BookingDb()
      ..firestoreId = booking.id
      ..userId = booking.userId
      ..experienceId = booking.experienceId
      ..status = booking.status.name
      ..amount = booking.amount
      ..date = booking.createdAt;

    await _isar.writeTxn(() => _isar.bookingDbs.put(db));
    AppLogger.d('Booking saved in dual-write (Hive/Isar)');
  }

  Future<List<T>> getDataByBoxName<T>(
    String boxName, {
    String? userId,
    SyncStatus? syncStatus,
    String? status,
    bool onlyPending = false,
  }) async {
    final targetBox = Hive.box<T>(boxName);
    return _getEntries(
      targetBox: targetBox,
      userId: userId,
      syncStatus: syncStatus,
      status: status,
      onlyPending: onlyPending,
    );
  }

  Future<List<T>> _getEntries<T>({
    required Box<T> targetBox,
    String? userId,
    SyncStatus? syncStatus,
    String? status,
    bool onlyPending = false,
  }) async {
    Iterable<T> results = targetBox.values;

    if (userId != null) {
      results = results.where((item) {
        final syncable = item as SyncableModel?;
        return syncable?.userId == userId;
      });
    }
    if (syncStatus != null) {
      results = results.where((item) {
        final syncable = item as SyncableModel?;
        return syncable?.syncStatus == syncStatus;
      });
    }
    if (onlyPending) {
      results = results.where((item) {
        final syncable = item as SyncableModel?;
        return syncable?.syncStatus.needsSync == true;
      });
    }
    if (status != null) {
      results = results.where((item) {
        return (item as Map<String, dynamic>)['status'] == status;
      });
    }

    final list = results.toList();
    AppLogger.d('IsarService: Fetched ${list.length} items from ${targetBox.name}');
    return list;
  }

  Future<List<MomentoModel>> getPendingSync(String userId) async {
    return _getEntries(targetBox: box, userId: userId, onlyPending: true);
  }

  Future<void> enqueueMomentoSync(MomentoModel item) async {
    item.syncStatus = SyncStatus.pending;
    if (item.isInBox) {
      await item.save();
    } else {
      await box.add(item);
    }
    AppLogger.d('Momento enqueued for sync: ${item.key}');
  }

  Future<List<MomentoModel>> getPendingMomentos(String userId) async {
    return _getEntries(targetBox: box, userId: userId, onlyPending: true);
  }
  Future<void> mergeMomentosFromCloud(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('momentos')
        .orderBy('createdAt', descending: true)
        .get();
    final remoteIds = <String>{};
    for (final doc in snapshot.docs) {
      remoteIds.add(doc.id);
      final remoteMomento = MomentoModel.fromFirestore(doc.id, doc.data());
      final localMomento = box.get(doc.id) ?? box.values.cast<MomentoModel?>().firstWhere(
        (item) => item?.firestoreId == doc.id,
        orElse: () => null,
      );

      // RESOLUCIÓN DE CONFLICTOS: 
      // Si el local tiene cambios pendientes, comprobamos cuál es más reciente.
      if (localMomento != null && localMomento.syncStatus.needsSync) {
        if (localMomento.updatedAt.isAfter(remoteMomento.updatedAt)) {
          AppLogger.d('Conflicto detectado: Manteniendo versión local más reciente.');
          continue; 
        } else {
          AppLogger.w('Conflicto detectado: Cloud es más reciente. Sobrescribiendo local.');
        }
      }

      remoteMomento.syncStatus = SyncStatus.synced;
      remoteMomento.errorMessage = null;
      remoteMomento.lastAttempt = DateTime.now();
      await box.put(doc.id, remoteMomento);
      
      // Sincronizar también en Isar
      final isarDb = await _isar.momentoDbs.where().firestoreIdEqualTo(doc.id).findFirst() ?? MomentoDb();
      isarDb
        ..firestoreId = doc.id
        ..userId = remoteMomento.userId
        ..title = remoteMomento.title
        ..description = remoteMomento.description
        ..updatedAt = remoteMomento.updatedAt
        ..syncStatus = 'synced';
      await _isar.writeTxn(() => _isar.momentoDbs.put(isarDb));
    }
    final staleKeys = box.keys.where((key) {
      final momento = box.get(key);
      if (momento == null || momento.userId != userId) {
        return false;
      }
      if (momento.syncStatus != SyncStatus.synced) {
        return false;
      }
      final remoteId = momento.firestoreId;
      return remoteId != null && remoteId.isNotEmpty && !remoteIds.contains(remoteId);
    }).toList();
    if (staleKeys.isNotEmpty) {
      await box.deleteAll(staleKeys);
    }
    AppLogger.d('Merged momentos from cloud for ');
  }

  Future<String> pushMomentoToCloud(MomentoModel momento) async {
    AppLogger.i('Pushing momento to cloud: ${momento.id}');
    momento.lastAttempt = DateTime.now();
    momento.retryCount += 1;

    final collection = _firestore
        .collection('users')
        .doc(momento.userId)
        .collection('momentos');

    final remoteId = momento.firestoreId ?? collection.doc().id;
    await collection.doc(remoteId).set(momento.toFirestore(), SetOptions(merge: true));
    return remoteId;
  }

  Future<void> markMomentoAsSynced(String key, String remoteId) async {
    final resolvedKey = int.tryParse(key) ?? key;
    final momento = box.get(resolvedKey);
    if (momento == null) return;

    final previousKey = momento.key;
    momento.syncStatus = SyncStatus.synced;
    momento.firestoreId = remoteId;
    momento.errorMessage = null;
    momento.lastAttempt = DateTime.now();

    await box.put(remoteId, momento);
    if (previousKey != null && previousKey != remoteId) {
      await box.delete(previousKey);
    }

    AppLogger.d('Momento marked synced: $resolvedKey -> $remoteId');
  }

  Future<void> markMomentoSyncError(String id, String error) async {
    final momento = box.values.firstWhere(
      (m) => m.id == id,
      orElse: () => throw StateError('Momento $id not found'),
    );
    momento.syncStatus = SyncStatus.error;
    momento.errorMessage = error;
    momento.lastAttempt = DateTime.now();
    await momento.save();
    AppLogger.w('Momento sync error: $id - $error');
  }

  Future<void> deleteMomentoFromCloud(MomentoModel momento) async {
    final remoteId = momento.firestoreId;
    if (remoteId == null || remoteId.isEmpty) {
      return;
    }

    await _firestore
        .collection('users')
        .doc(momento.userId)
        .collection('momentos')
        .doc(remoteId)
        .delete();

    AppLogger.d('Momento deleted from cloud: ');
  }
  Future<List<ProposalModel>> getPendingProposalsSync(String userId) async {
    return _getEntries(
      targetBox: proposalsBox,
      userId: userId,
      onlyPending: true,
    );
  }

  Future<List<ProposalModel>> getPendingProposals(String userId) async {
    return _getEntries(
      targetBox: proposalsBox,
      userId: userId,
      onlyPending: true,
    );
  }

  Future<void> pushProposalToCloud(ProposalModel proposal) async {
    proposal.lastAttempt = DateTime.now();
    proposal.retryCount += 1;
    await _firestore
        .collection('users')
        .doc(proposal.userId)
        .collection('proposals')
        .doc(proposal.id)
        .set(proposal.toFirestore(), SetOptions(merge: true));
  }

  Future<void> markProposalAsSynced(String id) async {
    final proposal = proposalsBox.values.firstWhere(
      (p) => p.id == id,
      orElse: () => throw StateError('Proposal $id not found'),
    );
    proposal.syncStatus = SyncStatus.synced;
    proposal.lastAttempt = DateTime.now();
    await proposal.save();
    AppLogger.d('Proposal marked synced: $id');
  }

  Future<void> markProposalSyncError(String id, String error) async {
    final proposal = proposalsBox.values.firstWhere(
      (p) => p.id == id,
      orElse: () => throw StateError('Proposal $id not found'),
    );
    proposal.syncStatus = SyncStatus.error;
    proposal.lastAttempt = DateTime.now();
    await proposal.save();
    AppLogger.w('Proposal sync error: $id - $error');
  }

  Future<List<ItineraryModel>> getPendingItinerariesSync(String userId) async {
    return _getEntries(
      targetBox: itinerariesBox,
      userId: userId,
      onlyPending: true,
    );
  }

  Future<List<ItineraryModel>> getPendingItineraries(String userId) async {
    return _getEntries(
      targetBox: itinerariesBox,
      userId: userId,
      onlyPending: true,
    );
  }

  Future<void> pushItineraryToCloud(ItineraryModel itinerary) async {
    itinerary.lastAttempt = DateTime.now();
    itinerary.retryCount += 1;
    await _firestore
        .collection('users')
        .doc(itinerary.userId)
        .collection('itineraries')
        .doc(itinerary.id)
        .set(itinerary.toFirestore(), SetOptions(merge: true));
  }

  Future<void> markItineraryAsSynced(String id) async {
    final itinerary = itinerariesBox.values.firstWhere(
      (i) => i.id == id,
      orElse: () => throw StateError('Itinerary $id not found'),
    );
    itinerary.syncStatus = SyncStatus.synced;
    itinerary.lastAttempt = DateTime.now();
    await itinerary.save();
    AppLogger.d('Itinerary marked synced: $id');
  }

  Future<void> markItinerarySyncError(String id, String error) async {
    final itinerary = itinerariesBox.values.firstWhere(
      (i) => i.id == id,
      orElse: () => throw StateError('Itinerary $id not found'),
    );
    itinerary.syncStatus = SyncStatus.error;
    itinerary.lastAttempt = DateTime.now();
    await itinerary.save();
    AppLogger.w('Itinerary sync error: $id - $error');
  }

  Future<List<ItineraryModel>> getItineraries({
    String? userId,
    String? status,
  }) async {
    return _getEntries(targetBox: itinerariesBox, userId: userId, status: status);
  }

  Future<List<String>> getDiaryReflectionsInDateRange({
    required String userId,
    required DateTime start,
    required DateTime end,
  }) async {
    return box.values
        .where((m) =>
            m.userId == userId &&
            (m.createdAt.isAtSameMomentAs(start) || m.createdAt.isAfter(start)) &&
            (m.createdAt.isAtSameMomentAs(end) || m.createdAt.isBefore(end)))
        .map((m) => m.description ?? '')
        .where((desc) => desc.isNotEmpty)
        .toList();
  }

  Future<Map<String, dynamic>?> getBookingById(String id) async => null;

  Future<List<BookingModel>> getBookingsForUser(String userId) async {
    final rawBookings = bookingsBox.values
        .where((item) => (item as Map<String, dynamic>)['userId'] == userId)
        .cast<Map<String, dynamic>>()
        .toList();
    return rawBookings.map((json) => BookingModel.fromJson(json)).toList();
  }


  Future<void> deleteMomento(dynamic key) async {
    final momento = box.get(key);
    if (momento != null) {
      momento.syncStatus = SyncStatus.deleted;
      await momento.save();
    }
    AppLogger.d('Momento marked deleted: $key');
  }

  Future<void> permanentDelete(dynamic key) async {
    await box.delete(key);
    AppLogger.d('Momento permanently deleted: $key');
  }

  Future<void> clearUserMomentos(String userId) async {
    final keys = box.values.where((m) => m.userId == userId).map((m) => m.key).toList();
    await box.deleteAll(keys);
    AppLogger.i('Cleared ${keys.length} momentos for $userId');
  }

  Future<void> clearAll() async {
    if (!_isInitialized) return;
    await Future.wait([
      chroniclesBox.clear(),
      box.clear(),
      proposalsBox.clear(),
      itinerariesBox.clear(),
      bookingsBox.clear(),
      profileBox.clear(),
    ]);
  }

  Future<int> countMomentos({String? userId, SyncStatus? status}) async {
    final results = await getMomentos(userId: userId, syncStatus: status);
    return results.length;
  }

  bool get supportsProposalCloudSync => true;
  bool get supportsItineraryCloudSync => true;

  Future<void> close() async {
    await _box?.close();
    _box = null;
    AppLogger.i('Hive box closed');
  }
}

final isarServiceProvider = Provider<IsarService>((ref) => IsarService());
