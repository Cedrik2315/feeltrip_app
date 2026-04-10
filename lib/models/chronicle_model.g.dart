// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chronicle_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChronicleModelAdapter extends TypeAdapter<ChronicleModel> {
  @override
  final int typeId = 10;

  @override
  ChronicleModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChronicleModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      title: fields[2] as String,
      paragraphs: (fields[3] as List).cast<String>(),
      expeditionDataJson: (fields[4] as Map).cast<String, dynamic>(),
      generatedAt: fields[5] as DateTime,
      syncStatus: fields[6] as SyncStatus,
      expeditionNumber: fields[7] as int,
      imageUrl: fields[8] as String?,
      visualMetaphor: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ChronicleModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.paragraphs)
      ..writeByte(4)
      ..write(obj.expeditionDataJson)
      ..writeByte(5)
      ..write(obj.generatedAt)
      ..writeByte(6)
      ..write(obj.syncStatus)
      ..writeByte(7)
      ..write(obj.expeditionNumber)
      ..writeByte(8)
      ..write(obj.imageUrl)
      ..writeByte(9)
      ..write(obj.visualMetaphor);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChronicleModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
