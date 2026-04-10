import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../core/logger/app_logger.dart';
import '../models/momento_model.dart';
import '../models/proposal_model.dart';
import '../models/itinerary_model.dart';
import '../models/chronicle_model.dart';
import '../models/gps_models.dart';
import '../models/syncable_model.dart';
import '../models/booking_model.dart';

import 'package:feeltrip_app/features/profile/domain/user_profile_model.dart';

class IsarService {
  IsarService._internal();
  factory IsarService() => _instance;
  static final IsarService _instance = IsarService._internal();

  bool _isInitialized = false;

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
  Box<ProposalModel> get proposalsBox => _ensureBox(_proposalsBox, _proposalsBoxName);
  Box<ItineraryModel> get itinerariesBox => _ensureBox(_itinerariesBox, _itinerariesBoxName);
  Box<RouteModel> get routesBox => _ensureBox(_routesBox, _routesBoxName);
  Box<ChronicleModel> get chroniclesBox => _ensureBox(_chroniclesBox, _chroniclesBoxName);
  Box<dynamic> get metaBox => _ensureBox(_metaBox, _metaBoxName);
  Box<dynamic> get prefsBox => _ensureBox(_prefsBox, _prefsBoxName);
  Box<UserProfile> get profileBox => _ensureBox(_profileBox, _profileBoxName);

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
      AppLogger.i('FUTURE: Migrate to Isar using lib/core/local_storage/chronicle_schema.dart');
    } catch (e) {
      AppLogger.e('Hive init error: $e');
      rethrow;
    }
  }

  Future<void> putMomento(MomentoModel momento) async {
    await box.put(
        momento.firestoreId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        momento);
    AppLogger.d('Momento saved locally: ${momento.firestoreId}');
  }

  Future<void> putProposal(ProposalModel proposal) async {
    await proposalsBox.put(proposal.id, proposal);
    AppLogger.d('Proposal saved locally: ${proposal.id}');
  }

  Future<void> putItinerary(ItineraryModel itinerary) async {
    await itinerariesBox.put(itinerary.id, itinerary);
    AppLogger.d('Itinerary saved locally: ${itinerary.id}');
  }

  Future<List<T>> getDataByBoxName<T>(String boxName, {
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

  Future<List<MomentoModel>> getMomentos({
    String? userId,
    SyncStatus? syncStatus,
  }) async {
    return _getEntries(targetBox: box, userId: userId, syncStatus: syncStatus);
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

  Future<String> pushMomentoToCloud(MomentoModel momento) async {
    AppLogger.i('Pushing momento to cloud: ${momento.id}');
    return 'remote_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> markMomentoAsSynced(String key, String remoteId) async {
    final momento = box.get(int.tryParse(key) ?? key);
    if (momento != null) {
      momento.syncStatus = SyncStatus.synced;
      momento.firestoreId = remoteId;
      await box.put(key, momento);
      AppLogger.d('Momento marked synced: $key -> $remoteId');
    }
  }

  Future<void> markMomentoSyncError(String id, String error) async {
    final momento = box.values.firstWhere(
      (m) => m.id == id, 
      orElse: () => throw StateError('Momento $id not found')
    );
    momento.syncStatus = SyncStatus.error;
    await momento.save();
    AppLogger.w('Momento sync error: $id - $error');
  }

  Future<List<ProposalModel>> getPendingProposalsSync(String userId) async {
    return _getEntries(targetBox: proposalsBox, userId: userId, onlyPending: true);
  }

  Future<List<ProposalModel>> getPendingProposals(String userId) async {
    return _getEntries(targetBox: proposalsBox, userId: userId, onlyPending: true);
  }

  Future<void> pushProposalToCloud(ProposalModel proposal) async {
    throw UnimplementedError('Cloud push implementation pending');
  }

  Future<void> markProposalAsSynced(String id) async {
    final proposal = proposalsBox.values.firstWhere(
      (p) => p.id == id, 
      orElse: () => throw StateError('Proposal $id not found')
    );
    proposal.syncStatus = SyncStatus.synced;
    await proposal.save();
    AppLogger.d('Proposal marked synced: $id');
  }

  Future<void> markProposalSyncError(String id, String error) async {
    final proposal = proposalsBox.values.firstWhere(
      (p) => p.id == id, 
      orElse: () => throw StateError('Proposal $id not found')
    );
    proposal.syncStatus = SyncStatus.error;
    await proposal.save();
    AppLogger.w('Proposal sync error: $id - $error');
  }

  Future<List<ItineraryModel>> getPendingItinerariesSync(String userId) async {
    return _getEntries(targetBox: itinerariesBox, userId: userId, onlyPending: true);
  }

  Future<List<ItineraryModel>> getPendingItineraries(String userId) async {
    return _getEntries(targetBox: itinerariesBox, userId: userId, onlyPending: true);
  }

  Future<void> pushItineraryToCloud(ItineraryModel itinerary) async {
    throw UnimplementedError('Cloud push implementation pending');
  }

  Future<void> markItineraryAsSynced(String id) async {
    final itinerary = itinerariesBox.values.firstWhere(
      (i) => i.id == id, 
      orElse: () => throw StateError('Itinerary $id not found')
    );
    itinerary.syncStatus = SyncStatus.synced;
    await itinerary.save();
    AppLogger.d('Itinerary marked synced: $id');
  }

  Future<void> markItinerarySyncError(String id, String error) async {
    final itinerary = itinerariesBox.values.firstWhere(
      (i) => i.id == id, 
      orElse: () => throw StateError('Itinerary $id not found')
    );
    itinerary.syncStatus = SyncStatus.error;
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
    final rawBookings = bookingsBox.values.where((item) => 
      (item as Map<String, dynamic>)['userId'] == userId
    ).cast<Map<String, dynamic>>().toList();
    return rawBookings.map((json) => BookingModel.fromJson(json)).toList();
  }

  Future<void> saveBooking(BookingModel booking) async {
    final key = booking.key ?? booking.id;
    await bookingsBox.put(key, booking.toJson());
    AppLogger.d('Booking saved: ${booking.id}');
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
    final keys =
        box.values.where((m) => m.userId == userId).map((m) => m.key).toList();
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

  Future<void> close() async {
    await _box?.close();
    _box = null;
    AppLogger.i('Hive box closed');
  }
}

final isarServiceProvider = Provider<IsarService>((ref) => IsarService());
