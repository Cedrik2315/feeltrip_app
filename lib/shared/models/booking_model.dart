import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking_model.freezed.dart';
part 'booking_model.g.dart';

DateTime _parseRequiredDateTime(dynamic date) {
  if (date is Timestamp) return date.toDate();
  if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
  if (date is DateTime) return date;
  return DateTime.now();
}

dynamic _toJsonDateTime(DateTime date) => Timestamp.fromDate(date);

@freezed
class Booking with _$Booking {
  const factory Booking({
    required String id,
    required String userId,
    required String tripId,
    required String tripTitle,
    required int numberOfPeople,
    required double totalPrice,
    @JsonKey(fromJson: _parseRequiredDateTime, toJson: _toJsonDateTime)
    required DateTime bookingDate,
    @JsonKey(fromJson: _parseRequiredDateTime, toJson: _toJsonDateTime)
    required DateTime startDate,
    @Default('Confirmada') String status,
    @Default(<String>[]) List<String> passengers,
    @Default('Tarjeta de Credito') String paymentMethod,
    @Default(false) bool isPaid,
  }) = _Booking;

  factory Booking.fromJson(Map<String, dynamic> json) =>
      _$BookingFromJson(json);

  factory Booking.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return Booking.fromJson({
      ...data,
      'id': (data['id'] as String?) ?? doc.id,
    });
  }
}
