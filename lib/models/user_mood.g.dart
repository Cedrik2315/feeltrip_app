// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_mood.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserMoodImpl _$$UserMoodImplFromJson(Map<String, dynamic> json) =>
    _$UserMoodImpl(
      primaryTrait: json['primaryTrait'] as String,
      badgeText: json['badgeText'] as String,
      emoji: json['emoji'] as String,
      sentimentScore: (json['sentimentScore'] as num?)?.toDouble(),
      imageLabels: (json['imageLabels'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      recognizedText: json['recognizedText'] as String?,
    );

Map<String, dynamic> _$$UserMoodImplToJson(_$UserMoodImpl instance) =>
    <String, dynamic>{
      'primaryTrait': instance.primaryTrait,
      'badgeText': instance.badgeText,
      'emoji': instance.emoji,
      'sentimentScore': instance.sentimentScore,
      'imageLabels': instance.imageLabels,
      'recognizedText': instance.recognizedText,
    };
