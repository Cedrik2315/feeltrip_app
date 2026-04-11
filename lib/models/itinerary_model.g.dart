// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itinerary_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItineraryModelAdapter extends TypeAdapter<ItineraryModel> {
  @override
  final int typeId = 3;

  @override
  ItineraryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ItineraryModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      proposalId: fields[2] as String,
      content: fields[3] as String,
      createdAt: fields[4] as DateTime,
      status: fields[5] as String,
      impactSummary: fields[9] as String?,
      retryCount: fields[7] as int,
      lastAttempt: fields[8] as DateTime?,
    )..syncStatusName = fields[6] as String;
  }

  @override
  void write(BinaryWriter writer, ItineraryModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.proposalId)
      ..writeByte(3)
      ..write(obj.content)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.syncStatusName)
      ..writeByte(7)
      ..write(obj.retryCount)
      ..writeByte(8)
      ..write(obj.lastAttempt)
      ..writeByte(9)
      ..write(obj.impactSummary);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItineraryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
