// ignore_for_file: invalid_annotation_target

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feeltrip_app/shared/models/review_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

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
    required double price,
    required int duration,
    required String difficulty,
    @Default('General') String category,
    @Default(0.0) double rating,
    @Default(<Review>[]) List<Review> reviews,
    @Default(<String>[]) List<String> images,
    @Default(<String>[]) List<String> highlights,
    @Default(<String>[]) List<String> amenities,
    @Default(false) bool isFeatured,
    @Default(false) bool isTransformative,
    String? guide,
    String? agencyId,
    @JsonKey(fromJson: _parseDateTime, toJson: _toJsonDateTime)
    DateTime? startDate,
    @JsonKey(fromJson: _parseDateTime, toJson: _toJsonDateTime)
    DateTime? endDate,
    @Default(0) int maxParticipants,
    @Default(0) int currentParticipants,
    String? experienceType,
    @Default(<String>[]) List<String> emotions,
    @Default(<String>[]) List<String> learnings,
    String? transformationMessage,
    @Default(<String>[]) List<String> culturalConnections,
  }) = _Trip;

  factory Trip.fromJson(Map<String, dynamic> json) => _$TripFromJson(json);

  factory Trip.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return Trip.fromJson({
      ...data,
      'id': (data['id'] as String?) ?? doc.id,
    });
  }
}
