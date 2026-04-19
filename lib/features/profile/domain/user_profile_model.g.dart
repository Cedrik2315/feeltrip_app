// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BadgeModelAdapter extends TypeAdapter<BadgeModel> {
  @override
  final int typeId = 12;

  @override
  BadgeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BadgeModel(
      id: fields[0] as String,
      label: fields[1] as String,
      description: fields[2] as String,
      iconCodePoint: fields[3] as int,
      isUnlocked: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, BadgeModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.label)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.iconCodePoint)
      ..writeByte(4)
      ..write(obj.isUnlocked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BadgeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 13;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      uid: fields[0] as String,
      username: fields[1] as String,
      rank: fields[2] as String,
      experienceProgress: fields[3] as double,
      profileImageUrl: fields[4] as String?,
      totalKm: fields[5] as int,
      photosAnalyzed: fields[6] as int,
      daysActive: fields[7] as int,
      emotionalStats: (fields[8] as Map).cast<String, double>(),
      badges: (fields[9] as List).cast<BadgeModel>(),
      isPremiumTrial: fields[10] as bool,
      trialExpiresAt: fields[11] as DateTime?,
      archetype: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.rank)
      ..writeByte(3)
      ..write(obj.experienceProgress)
      ..writeByte(4)
      ..write(obj.profileImageUrl)
      ..writeByte(5)
      ..write(obj.totalKm)
      ..writeByte(6)
      ..write(obj.photosAnalyzed)
      ..writeByte(7)
      ..write(obj.daysActive)
      ..writeByte(8)
      ..write(obj.emotionalStats)
      ..writeByte(9)
      ..write(obj.badges)
      ..writeByte(10)
      ..write(obj.isPremiumTrial)
      ..writeByte(11)
      ..write(obj.trialExpiresAt)
      ..writeByte(12)
      ..write(obj.archetype);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
