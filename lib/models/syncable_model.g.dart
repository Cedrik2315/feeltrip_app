// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'syncable_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SyncStatusAdapter extends TypeAdapter<SyncStatus> {
  @override
  final int typeId = 11;

  @override
  SyncStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SyncStatus.local;
      case 1:
        return SyncStatus.pending;
      case 2:
        return SyncStatus.synced;
      case 3:
        return SyncStatus.error;
      case 4:
        return SyncStatus.deleted;
      default:
        return SyncStatus.local;
    }
  }

  @override
  void write(BinaryWriter writer, SyncStatus obj) {
    switch (obj) {
      case SyncStatus.local:
        writer.writeByte(0);
        break;
      case SyncStatus.pending:
        writer.writeByte(1);
        break;
      case SyncStatus.synced:
        writer.writeByte(2);
        break;
      case SyncStatus.error:
        writer.writeByte(3);
        break;
      case SyncStatus.deleted:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
