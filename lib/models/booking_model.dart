import 'package:freezed_annotation/freezed_annotation.dart';
part 'booking_model.freezed.dart';
part 'booking_model.g.dart';

@freezed
class BookingModel with _$BookingModel {
  const factory BookingModel({
    required String id,
    required String userId,
    required String destinationId,
    required String tripDates,
    @JsonKey(name: 'price_usd') required double priceUsd,
    required String currency,
    @Default('pending') String status,
    @Default(0.0) double commission,
    DateTime? createdAt,
    @Default(false) bool isSynced,
  }) = _BookingModel;

  factory BookingModel.fromJson(Map<String, dynamic> json) =>
      _$BookingModelFromJson(json);
}
