import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'trip_model.freezed.dart';
part 'trip_model.g.dart';

DateTime? _parseDateTime(dynamic date) {
  if (date == null) return null;
  if (date is Timestamp) return date.toDate();
  if (date is String) return DateTime.tryParse(date);
  return null;
}

dynamic _toJsonDateTime(DateTime? date) => date?.toIso8601String();

@freezed
class Trip with _$Trip {
  const factory Trip({
    required String id,
    required String title,
    required String description,
    required String destination,
    required String country,
    required String category,
    required double price,
    @Default(0.0) double rating,
    @Default([]) List<dynamic> reviews,
    @Default([]) List<String> images,
    @Default([]) List<String> highlights,
    @Default([]) List<String> amenities,
    @Default(false) bool isFeatured,
    @Default(false) bool isTransformative,
    String? guide,
    String? agencyId,
    required String difficulty,
    required int duration,
    @JsonKey(fromJson: _parseDateTime, toJson: _toJsonDateTime) DateTime? startDate,
    @JsonKey(fromJson: _parseDateTime, toJson: _toJsonDateTime) DateTime? endDate,
    @Default(0) int maxParticipants,
    @Default(0) int currentParticipants,
    String? experienceType,
    @Default([]) List<String> emotions,
    @Default([]) List<String> learnings,
    String? transformationMessage,
    @Default([]) List<String> culturalConnections,
  }) = _Trip;

  factory Trip.fromJson(Map<String, dynamic> json) => _$TripFromJson(json);
}
