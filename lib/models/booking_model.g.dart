// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BookingModelAdapter extends TypeAdapter<BookingModel> {
  @override
  final int typeId = 12;

  @override
  BookingModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BookingModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      experienceId: fields[2] as String,
      preferenceId: fields[3] as String?,
      paymentId: fields[4] as String?,
      externalReference: fields[5] as String?,
      status: fields[6] as BookingStatus,
      provider: fields[7] as String,
      amount: fields[8] as double,
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime,
    )..syncStatus = fields[11] as SyncStatus;
  }

  @override
  void write(BinaryWriter writer, BookingModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.experienceId)
      ..writeByte(3)
      ..write(obj.preferenceId)
      ..writeByte(4)
      ..write(obj.paymentId)
      ..writeByte(5)
      ..write(obj.externalReference)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.provider)
      ..writeByte(8)
      ..write(obj.amount)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt)
      ..writeByte(11)
      ..write(obj.syncStatus);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookingModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
