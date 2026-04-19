// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'premium_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PremiumStateImpl _$$PremiumStateImplFromJson(Map<String, dynamic> json) =>
    _$PremiumStateImpl(
      isLoading: json['isLoading'] as bool? ?? false,
      isPremium: json['isPremium'] as bool? ?? false,
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$$PremiumStateImplToJson(_$PremiumStateImpl instance) =>
    <String, dynamic>{
      'isLoading': instance.isLoading,
      'isPremium': instance.isPremium,
      'errorMessage': instance.errorMessage,
    };
