import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

@freezed
class NotificationModel with _$NotificationModel {
  const factory NotificationModel({
    required String id,
    required String userId,
    required String
        type, // 'streak', 'like', 'comment', 'booking_confirm', 'agency_update', 'share'
    required String title,
    required String body,
    String? actionId, // storyId, bookingId, agencyId
    String? actionType, // 'story', 'booking', 'profile'
    @Default(false) bool isRead,
    @ServerTimestampConverter() FieldValue? createdAt,
    String? imageUrl, // para notifs visuales
    int? badgeCount, // para streaks
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);
}

class ServerTimestampConverter implements JsonConverter<FieldValue, Object?> {
  const ServerTimestampConverter();
  @override
  FieldValue fromJson(Object? json) => FieldValue.serverTimestamp();
  @override
  Object? toJson(FieldValue object) => null;
}
