// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'travel_proposal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TravelProposalImpl _$$TravelProposalImplFromJson(Map<String, dynamic> json) =>
    _$TravelProposalImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      destinations: (json['destinations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      experiences: (json['experiences'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      emotionalProfile: json['emotionalProfile'] as String,
      safetyScore: (json['safetyScore'] as num?)?.toDouble() ?? 0.0,
      isSafe: json['isSafe'] as bool? ?? true,
      osintReport: json['osintReport'] as String,
      aiPrompt: json['aiPrompt'] as String,
      generatedText: json['generatedText'] as String,
      agencyRecommendation: json['agencyRecommendation'] as String?,
      warnings: (json['warnings'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      generatedAt: _dateFromJson(json['generatedAt'] as String),
    );

Map<String, dynamic> _$$TravelProposalImplToJson(
        _$TravelProposalImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'destinations': instance.destinations,
      'experiences': instance.experiences,
      'emotionalProfile': instance.emotionalProfile,
      'safetyScore': instance.safetyScore,
      'isSafe': instance.isSafe,
      'osintReport': instance.osintReport,
      'aiPrompt': instance.aiPrompt,
      'generatedText': instance.generatedText,
      'agencyRecommendation': instance.agencyRecommendation,
      'warnings': instance.warnings,
      'generatedAt': _dateToJson(instance.generatedAt),
    };
