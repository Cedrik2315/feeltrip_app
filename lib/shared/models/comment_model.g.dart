// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CommentImpl _$$CommentImplFromJson(Map<String, dynamic> json) =>
    _$CommentImpl(
      id: json['id'] as String,
      storyId: json['storyId'] as String,
      userId: json['userId'] as String,
      content: json['content'] as String,
      userName: json['userName'] as String,
      userAvatar: json['userAvatar'] as String?,
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      reactions: (json['reactions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: _parseDateTime(json['createdAt']),
    );

Map<String, dynamic> _$$CommentImplToJson(_$CommentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'storyId': instance.storyId,
      'userId': instance.userId,
      'content': instance.content,
      'userName': instance.userName,
      'userAvatar': instance.userAvatar,
      'likes': instance.likes,
      'reactions': instance.reactions,
      'createdAt': _toJsonDateTime(instance.createdAt),
    };
