// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BookingImpl _$$BookingImplFromJson(Map<String, dynamic> json) =>
    _$BookingImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      tripId: json['tripId'] as String,
      tripTitle: json['tripTitle'] as String,
      numberOfPeople: (json['numberOfPeople'] as num).toInt(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      bookingDate: _parseRequiredDateTime(json['bookingDate']),
      startDate: _parseRequiredDateTime(json['startDate']),
      status: json['status'] as String? ?? 'Confirmada',
      passengers: (json['passengers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      paymentMethod: json['paymentMethod'] as String? ?? 'Tarjeta de Credito',
      isPaid: json['isPaid'] as bool? ?? false,
    );

Map<String, dynamic> _$$BookingImplToJson(_$BookingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'tripId': instance.tripId,
      'tripTitle': instance.tripTitle,
      'numberOfPeople': instance.numberOfPeople,
      'totalPrice': instance.totalPrice,
      'bookingDate': _toJsonDateTime(instance.bookingDate),
      'startDate': _toJsonDateTime(instance.startDate),
      'status': instance.status,
      'passengers': instance.passengers,
      'paymentMethod': instance.paymentMethod,
      'isPaid': instance.isPaid,
    };
