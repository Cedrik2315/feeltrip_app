// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BookingModelImpl _$$BookingModelImplFromJson(Map<String, dynamic> json) =>
    _$BookingModelImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      destinationId: json['destinationId'] as String,
      tripDates: json['tripDates'] as String,
      priceUsd: (json['price_usd'] as num).toDouble(),
      currency: json['currency'] as String,
      status: json['status'] as String? ?? 'pending',
      commission: (json['commission'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      isSynced: json['isSynced'] as bool? ?? false,
    );

Map<String, dynamic> _$$BookingModelImplToJson(_$BookingModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'destinationId': instance.destinationId,
      'tripDates': instance.tripDates,
      'price_usd': instance.priceUsd,
      'currency': instance.currency,
      'status': instance.status,
      'commission': instance.commission,
      'createdAt': instance.createdAt?.toIso8601String(),
      'isSynced': instance.isSynced,
    };
