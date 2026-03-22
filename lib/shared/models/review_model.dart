import 'package:freezed_annotation/freezed_annotation.dart';

part 'review_model.freezed.dart';
part 'review_model.g.dart';

DateTime? _parseDateTime(dynamic date) {
  if (date == null) return null;

  if (date is String) return DateTime.tryParse(date);

  if (date is Map && date.containsKey('_seconds')) {
    return DateTime.fromMillisecondsSinceEpoch(
        (date['_seconds'] as int) * 1000);
  }

  return null;
}

dynamic _toJsonDateTime(DateTime? date) => date?.toIso8601String();

@freezed
class Review with _$Review {
  const factory Review({
    required String id,
    required String userId,
    required String userName,
    required double rating,
    required String comment,
    @JsonKey(fromJson: _parseDateTime, toJson: _toJsonDateTime)
    DateTime? createdAt,
  }) = _Review;

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
}
