// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TripImpl _$$TripImplFromJson(Map<String, dynamic> json) => _$TripImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      destination: json['destination'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isFeatured: json['isFeatured'] as bool? ?? false,
      agencyId: json['agencyId'] as String?,
      difficulty: json['difficulty'] as String?,
      duration: (json['duration'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$TripImplToJson(_$TripImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'destination': instance.destination,
      'category': instance.category,
      'price': instance.price,
      'rating': instance.rating,
      'images': instance.images,
      'isFeatured': instance.isFeatured,
      'agencyId': instance.agencyId,
      'difficulty': instance.difficulty,
      'duration': instance.duration,
    };
