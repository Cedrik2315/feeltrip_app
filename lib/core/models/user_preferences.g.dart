// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserPreferencesImpl _$$UserPreferencesImplFromJson(
        Map<String, dynamic> json) =>
    _$UserPreferencesImpl(
      isQuietModeEnabled: json['isQuietModeEnabled'] as bool? ?? false,
      startHour: (json['startHour'] as num?)?.toInt() ?? 22,
      endHour: (json['endHour'] as num?)?.toInt() ?? 8,
    );

Map<String, dynamic> _$$UserPreferencesImplToJson(
        _$UserPreferencesImpl instance) =>
    <String, dynamic>{
      'isQuietModeEnabled': instance.isQuietModeEnabled,
      'startHour': instance.startHour,
      'endHour': instance.endHour,
    };
