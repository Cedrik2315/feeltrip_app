import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

DateTime? _parseDateTime(dynamic date) {
  if (date == null) return null;
  if (date is Timestamp) return date.toDate();
  if (date is String) return DateTime.tryParse(date);
  return null;
}

dynamic _toJsonDateTime(DateTime? date) => date?.toIso8601String();

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String name,
    required String email,
    @Default('') String bio,
    @Default('') String city,
    String? avatarUrl,
    String? profileImage,
    String? phone,
    String? archetype,
    @Default([]) List<String> badges,
    @Default([]) List<String> favoriteTrips,
    @JsonKey(fromJson: _parseDateTime, toJson: _toJsonDateTime) DateTime? birthDate,
    @JsonKey(fromJson: _parseDateTime, toJson: _toJsonDateTime) DateTime? createdAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
