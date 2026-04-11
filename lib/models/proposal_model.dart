import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'syncable_model.dart';

part 'proposal_model.g.dart';

@HiveType(typeId: 2)
class ProposalModel extends HiveObject {
  ProposalModel({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
    SyncStatus syncStatus = SyncStatus.local,
    this.retryCount = 0,
    this.lastAttempt,
  }) : syncStatusName = syncStatus.name;
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  String syncStatusName;

  @HiveField(5)
  int retryCount;

  @HiveField(6)
  DateTime? lastAttempt;

  SyncStatus get syncStatus => SyncStatus.values.byName(syncStatusName);
  set syncStatus(SyncStatus value) => syncStatusName = value.name;

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'type': 'gemini_proposal',
      'syncStatus': syncStatus.name,
      'retryCount': retryCount,
      'lastAttempt':
          lastAttempt != null ? Timestamp.fromDate(lastAttempt!) : null,
    };
  }
}
