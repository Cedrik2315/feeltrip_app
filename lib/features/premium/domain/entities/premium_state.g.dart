// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'premium_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PremiumStateImpl _$$PremiumStateImplFromJson(Map<String, dynamic> json) =>
    _$PremiumStateImpl(
      isLoading: json['isLoading'] as bool? ?? false,
      isPremium: json['isPremium'] as bool? ?? false,
      offerings: (json['offerings'] as List<dynamic>?)
              ?.map((e) => Offering.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      activePackage: json['activePackage'] == null
          ? null
          : Package.fromJson(json['activePackage'] as Map<String, dynamic>),
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$$PremiumStateImplToJson(_$PremiumStateImpl instance) =>
    <String, dynamic>{
      'isLoading': instance.isLoading,
      'isPremium': instance.isPremium,
      'offerings': instance.offerings,
      'activePackage': instance.activePackage,
      'errorMessage': instance.errorMessage,
    };
