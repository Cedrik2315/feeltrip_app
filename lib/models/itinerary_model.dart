import 'package:hive/hive.dart';

import 'syncable_model.dart';

part 'itinerary_model.g.dart';

@HiveType(typeId: 3)
class ItineraryModel extends HiveObject {
  ItineraryModel({
    required this.id,
    required this.userId,
    required this.proposalId,
    required this.content,
    required this.createdAt,
    this.status = 'active',
    this.impactSummary,
    SyncStatus syncStatus = SyncStatus.local,
    this.retryCount = 0,
    this.lastAttempt,
  }) : syncStatusName = syncStatus.name;
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String proposalId;

  @HiveField(3)
  final String content;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  String status; // 'active', 'completed', 'cancelled'

  @HiveField(6)
  String syncStatusName;

  @HiveField(7)
  int retryCount;

  @HiveField(8)
  DateTime? lastAttempt;

  @HiveField(9)
  String? impactSummary;

  SyncStatus get syncStatus => SyncStatus.values.byName(syncStatusName);
  set syncStatus(SyncStatus value) => syncStatusName = value.name;

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'proposalId': proposalId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'impactSummary': impactSummary,
      'syncStatus': syncStatusName,
    };
  }
}
