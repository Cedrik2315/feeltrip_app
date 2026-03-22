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
      country: json['country'] as String,
      price: (json['price'] as num).toDouble(),
      duration: (json['duration'] as num).toInt(),
      difficulty: json['difficulty'] as String,
      category: json['category'] as String? ?? 'General',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviews: (json['reviews'] as List<dynamic>?)
              ?.map((e) => Review.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Review>[],
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      highlights: (json['highlights'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      amenities: (json['amenities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      isFeatured: json['isFeatured'] as bool? ?? false,
      isTransformative: json['isTransformative'] as bool? ?? false,
      guide: json['guide'] as String?,
      agencyId: json['agencyId'] as String?,
      startDate: _parseDateTime(json['startDate']),
      endDate: _parseDateTime(json['endDate']),
      maxParticipants: (json['maxParticipants'] as num?)?.toInt() ?? 0,
      currentParticipants: (json['currentParticipants'] as num?)?.toInt() ?? 0,
      experienceType: json['experienceType'] as String?,
      emotions: (json['emotions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      learnings: (json['learnings'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      transformationMessage: json['transformationMessage'] as String?,
      culturalConnections: (json['culturalConnections'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$$TripImplToJson(_$TripImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'destination': instance.destination,
      'country': instance.country,
      'price': instance.price,
      'duration': instance.duration,
      'difficulty': instance.difficulty,
      'category': instance.category,
      'rating': instance.rating,
      'reviews': instance.reviews,
      'images': instance.images,
      'highlights': instance.highlights,
      'amenities': instance.amenities,
      'isFeatured': instance.isFeatured,
      'isTransformative': instance.isTransformative,
      'guide': instance.guide,
      'agencyId': instance.agencyId,
      'startDate': _toJsonDateTime(instance.startDate),
      'endDate': _toJsonDateTime(instance.endDate),
      'maxParticipants': instance.maxParticipants,
      'currentParticipants': instance.currentParticipants,
      'experienceType': instance.experienceType,
      'emotions': instance.emotions,
      'learnings': instance.learnings,
      'transformationMessage': instance.transformationMessage,
      'culturalConnections': instance.culturalConnections,
    };
