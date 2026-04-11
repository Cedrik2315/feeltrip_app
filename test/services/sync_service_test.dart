import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:feeltrip_app/features/diario/domain/models/momento_model.dart';
import 'package:feeltrip_app/models/itinerary_model.dart';
import 'package:feeltrip_app/models/momento_model.dart';
import 'package:feeltrip_app/models/proposal_model.dart';
import 'package:feeltrip_app/models/syncable_model.dart';
import 'package:feeltrip_app/core/network/sync_user_id_collector.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Sync model infrastructure', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('feeltrip_sync_test');
      Hive.init(tempDir.path);
    });

    tearDown(() async {
      await Hive.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('Hive environment should be ready for sync operations', () async {
      final testBox = await Hive.openBox('sync_test_box');
      expect(testBox.isOpen, isTrue);
      await testBox.close();
    });
  });

  group('SyncStatus.needsSync', () {
    test('returns true for local pending error and deleted statuses', () {
      expect(SyncStatus.local.needsSync, isTrue);
      expect(SyncStatus.pending.needsSync, isTrue);
      expect(SyncStatus.error.needsSync, isTrue);
      expect(SyncStatus.deleted.needsSync, isTrue);
    });

    test('returns false for synced status', () {
      expect(SyncStatus.synced.needsSync, isFalse);
    });
  });

  group('collectPendingSyncUserIds', () {
    test('collects unique user ids across momentos proposals and itineraries', () {
      final now = DateTime(2026, 4, 8, 16, 0);
      final userIds = collectPendingSyncUserIds(
        pendingMomentos: [
          MomentoModel(
            userId: 'user_a',
            title: 'Pendiente',
            createdAt: now,
            syncStatus: SyncStatus.pending,
          ),
        ],
        localMomentos: [
          MomentoModel(
            userId: 'user_b',
            title: 'Local',
            createdAt: now,
            syncStatus: SyncStatus.local,
          ),
        ],
        errorMomentos: [
          MomentoModel(
            userId: 'user_c',
            title: 'Error',
            createdAt: now,
            syncStatus: SyncStatus.error,
          ),
        ],
        deletedMomentos: [
          MomentoModel(
            userId: 'user_d',
            title: 'Deleted',
            createdAt: now,
            syncStatus: SyncStatus.deleted,
          ),
        ],
        pendingProposals: [
          ProposalModel(
            id: 'proposal_1',
            userId: 'user_a',
            content: 'contenido',
            createdAt: now,
            syncStatus: SyncStatus.pending,
          ),
          ProposalModel(
            id: 'proposal_2',
            userId: '',
            content: 'sin usuario',
            createdAt: now,
            syncStatus: SyncStatus.pending,
          ),
        ],
        pendingItineraries: [
          ItineraryModel(
            id: 'itinerary_1',
            userId: 'user_e',
            proposalId: 'proposal_1',
            content: 'ruta',
            createdAt: now,
            syncStatus: SyncStatus.pending,
          ),
        ],
      );

      expect(userIds, {'user_a', 'user_b', 'user_c', 'user_d', 'user_e'});
    });
  });

  group('MomentoModel sync contract', () {
    test('fromFirestore hydrates remote ids and timestamps correctly', () {
      final createdAt = DateTime(2026, 4, 8, 12, 30);
      final lastAttempt = DateTime(2026, 4, 8, 13, 0);

      final model = MomentoModel.fromFirestore('remote_123', {
        'userId': 'user_1',
        'title': 'Atardecer',
        'description': 'Momento de calma',
        'emotionTags': ['calm'],
        'location': {'latitude': -33.45, 'longitude': -70.66},
        'imageUrls': ['https://example.com/a.jpg'],
        'createdAt': Timestamp.fromDate(createdAt),
        'syncStatus': 'synced',
        'retryCount': 2,
        'lastAttempt': Timestamp.fromDate(lastAttempt),
      });

      expect(model.firestoreId, 'remote_123');
      expect(model.id, 'remote_123');
      expect(model.userId, 'user_1');
      expect(model.createdAt, createdAt);
      expect(model.lastAttempt, lastAttempt);
      expect(model.syncStatus, SyncStatus.synced);
      expect(model.locationLat, -33.45);
      expect(model.locationLng, -70.66);
    });

    test('toFirestore preserves sync metadata for cloud writes', () {
      final now = DateTime(2026, 4, 8, 14, 0);
      final model = MomentoModel(
        userId: 'user_2',
        title: 'Bitacora',
        description: 'Entrada offline',
        createdAt: now,
        syncStatus: SyncStatus.pending,
        firestoreId: 'remote_456',
        retryCount: 3,
        lastAttempt: now,
      );

      final payload = model.toFirestore();

      expect(payload['userId'], 'user_2');
      expect(payload['title'], 'Bitacora');
      expect(payload['syncStatus'], 'pending');
      expect(payload['retryCount'], 3);
      expect(payload['createdAt'], isA<Timestamp>());
      expect(payload['lastAttempt'], isA<Timestamp>());
    });

    test('fromDomain keeps remote-looking ids as firestoreId', () {
      final domain = Momento(
        id: 'remote_999999999999999',
        userId: 'user_3',
        title: 'Recuerdo',
        description: 'Sincronizado',
        createdAt: DateTime(2026, 4, 8, 15, 0),
        isSynced: true,
      );

      final model = MomentoModel.fromDomain(domain);

      expect(model.firestoreId, 'remote_999999999999999');
      expect(model.syncStatus, SyncStatus.synced);
    });
  });
}



