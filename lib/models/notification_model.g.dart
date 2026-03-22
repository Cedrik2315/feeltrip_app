// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationModelImpl _$$NotificationModelImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationModelImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      actionId: json['actionId'] as String?,
      actionType: json['actionType'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: const ServerTimestampConverter().fromJson(json['createdAt']),
      imageUrl: json['imageUrl'] as String?,
      badgeCount: (json['badgeCount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$NotificationModelImplToJson(
        _$NotificationModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'type': instance.type,
      'title': instance.title,
      'body': instance.body,
      'actionId': instance.actionId,
      'actionType': instance.actionType,
      'isRead': instance.isRead,
      'createdAt': _$JsonConverterToJson<Object?, FieldValue>(
          instance.createdAt, const ServerTimestampConverter().toJson),
      'imageUrl': instance.imageUrl,
      'badgeCount': instance.badgeCount,
    };

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
