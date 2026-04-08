// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proposal_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProposalModelAdapter extends TypeAdapter<ProposalModel> {
  @override
  final int typeId = 2;

  @override
  ProposalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProposalModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      content: fields[2] as String,
      createdAt: fields[3] as DateTime,
      retryCount: fields[5] as int,
      lastAttempt: fields[6] as DateTime?,
    )..syncStatusName = fields[4] as String;
  }

  @override
  void write(BinaryWriter writer, ProposalModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.syncStatusName)
      ..writeByte(5)
      ..write(obj.retryCount)
      ..writeByte(6)
      ..write(obj.lastAttempt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProposalModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
