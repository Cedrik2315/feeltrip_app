// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'momento_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MomentoModelAdapter extends TypeAdapter<MomentoModel> {
  @override
  final int typeId = 0;

  @override
  MomentoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MomentoModel(
      userId: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      emotionTags: (fields[3] as List).cast<String>(),
      locationLat: fields[4] as double?,
      locationLng: fields[5] as double?,
      imageUrls: (fields[6] as List).cast<String>(),
      createdAt: fields[7] as DateTime,
      firestoreId: fields[9] as String?,
      errorMessage: fields[10] as String?,
      retryCount: fields[11] as int,
      lastAttempt: fields[12] as DateTime?,
    )..syncStatusName = fields[8] as String;
  }

  @override
  void write(BinaryWriter writer, MomentoModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.emotionTags)
      ..writeByte(4)
      ..write(obj.locationLat)
      ..writeByte(5)
      ..write(obj.locationLng)
      ..writeByte(6)
      ..write(obj.imageUrls)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.syncStatusName)
      ..writeByte(9)
      ..write(obj.firestoreId)
      ..writeByte(10)
      ..write(obj.errorMessage)
      ..writeByte(11)
      ..write(obj.retryCount)
      ..writeByte(12)
      ..write(obj.lastAttempt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MomentoModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
