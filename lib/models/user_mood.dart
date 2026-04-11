import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_mood.freezed.dart';
part 'user_mood.g.dart';

@freezed
class UserMood with _$UserMood {
  const factory UserMood({
    required String primaryTrait,
    required String badgeText,
    required String emoji,
    double? sentimentScore,
    List<String>? imageLabels,
    String? recognizedText,
  }) = _UserMood;

  factory UserMood.fromJson(Map<String, dynamic> json) =>
      _$UserMoodFromJson(json);
}
