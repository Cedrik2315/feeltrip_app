import 'package:freezed_annotation/freezed_annotation.dart';

part 'travel_proposal.freezed.dart';
part 'travel_proposal.g.dart';

@freezed
class TravelProposal with _$TravelProposal {
  const factory TravelProposal({
    required String id,
    required String title,
    required String subtitle,
    required List<String> destinations,
    required List<String> experiences,
    required String emotionalProfile,
    @Default(0.0) double safetyScore,
    @Default(true) bool isSafe,
    required String osintReport,
    required String aiPrompt,
    required String generatedText,
    String? agencyRecommendation,
    @Default([]) List<String> warnings,
    @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
    required DateTime generatedAt,
  }) = _TravelProposal;

  factory TravelProposal.fromJson(Map<String, dynamic> json) =>
      _$TravelProposalFromJson(json);
}

DateTime _dateFromJson(String json) => DateTime.parse(json);
String _dateToJson(DateTime dateTime) => dateTime.toIso8601String();
