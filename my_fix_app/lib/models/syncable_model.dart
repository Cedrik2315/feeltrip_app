import 'package:hive/hive.dart';

part 'syncable_model.g.dart';

/// Estados posibles de sincronización
@HiveType(typeId: 11)
enum SyncStatus {
  @HiveField(0)
  local,
  @HiveField(1)
  pending,
  @HiveField(2)
  synced,
  @HiveField(3)
  error,
  @HiveField(4)
  deleted
}

extension SyncStatusExt on SyncStatus {
  bool get needsSync => this == SyncStatus.local || this == SyncStatus.pending || this == SyncStatus.error || this == SyncStatus.deleted;
}

/// Mixin que deben implementar todos los modelos que viajan a Firestore.
mixin SyncableModel on HiveObject {
  String? get id; // ID local o de Firestore
  String get userId;
  SyncStatus get syncStatus;
  set syncStatus(SyncStatus status);
  
  Map<String, dynamic> toJson();
  Map<String, dynamic> toFirestore() => toJson();
}