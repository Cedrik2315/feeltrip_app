import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'comment_model.freezed.dart';
part 'comment_model.g.dart';

DateTime? _parseDateTime(dynamic date) {
  if (date == null) return null;
  if (date is Timestamp) return date.toDate();
  if (date is String) return DateTime.tryParse(date);
  return null;
}

dynamic _toJsonDateTime(DateTime? date) => date?.toIso8601String();

@freezed
class Comment with _$Comment {
  const Comment._();

  const factory Comment({
    required String id,
    required String storyId,
    required String userId,
    required String content,
    required String userName,
    String? userAvatar,
    @Default(0) int likes,
    @Default([]) List<String> reactions,
    @JsonKey(fromJson: _parseDateTime, toJson: _toJsonDateTime) DateTime? createdAt,
  }) = _Comment;

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    // Map 'text' to 'content' if legacy data exists
    if (data['content'] == null && data['text'] != null) {
      data['content'] = data['text'];
    }
    return Comment.fromJson(data);
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    if (createdAt != null) {
      json['createdAt'] = Timestamp.fromDate(createdAt!);
    }
    return json;
  }
}
