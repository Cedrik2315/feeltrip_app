// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'travel_proposal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TravelProposal _$TravelProposalFromJson(Map<String, dynamic> json) {
  return _TravelProposal.fromJson(json);
}

/// @nodoc
mixin _$TravelProposal {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get subtitle => throw _privateConstructorUsedError;
  List<String> get destinations => throw _privateConstructorUsedError;
  List<String> get experiences => throw _privateConstructorUsedError;
  String get emotionalProfile => throw _privateConstructorUsedError;
  double get safetyScore => throw _privateConstructorUsedError;
  bool get isSafe => throw _privateConstructorUsedError;
  String get osintReport => throw _privateConstructorUsedError;
  String get aiPrompt => throw _privateConstructorUsedError;
  String get generatedText => throw _privateConstructorUsedError;
  String? get agencyRecommendation => throw _privateConstructorUsedError;
  List<String> get warnings => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
  DateTime get generatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TravelProposalCopyWith<TravelProposal> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TravelProposalCopyWith<$Res> {
  factory $TravelProposalCopyWith(
          TravelProposal value, $Res Function(TravelProposal) then) =
      _$TravelProposalCopyWithImpl<$Res, TravelProposal>;
  @useResult
  $Res call(
      {String id,
      String title,
      String subtitle,
      List<String> destinations,
      List<String> experiences,
      String emotionalProfile,
      double safetyScore,
      bool isSafe,
      String osintReport,
      String aiPrompt,
      String generatedText,
      String? agencyRecommendation,
      List<String> warnings,
      @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
      DateTime generatedAt});
}

/// @nodoc
class _$TravelProposalCopyWithImpl<$Res, $Val extends TravelProposal>
    implements $TravelProposalCopyWith<$Res> {
  _$TravelProposalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? subtitle = null,
    Object? destinations = null,
    Object? experiences = null,
    Object? emotionalProfile = null,
    Object? safetyScore = null,
    Object? isSafe = null,
    Object? osintReport = null,
    Object? aiPrompt = null,
    Object? generatedText = null,
    Object? agencyRecommendation = freezed,
    Object? warnings = null,
    Object? generatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      subtitle: null == subtitle
          ? _value.subtitle
          : subtitle // ignore: cast_nullable_to_non_nullable
              as String,
      destinations: null == destinations
          ? _value.destinations
          : destinations // ignore: cast_nullable_to_non_nullable
              as List<String>,
      experiences: null == experiences
          ? _value.experiences
          : experiences // ignore: cast_nullable_to_non_nullable
              as List<String>,
      emotionalProfile: null == emotionalProfile
          ? _value.emotionalProfile
          : emotionalProfile // ignore: cast_nullable_to_non_nullable
              as String,
      safetyScore: null == safetyScore
          ? _value.safetyScore
          : safetyScore // ignore: cast_nullable_to_non_nullable
              as double,
      isSafe: null == isSafe
          ? _value.isSafe
          : isSafe // ignore: cast_nullable_to_non_nullable
              as bool,
      osintReport: null == osintReport
          ? _value.osintReport
          : osintReport // ignore: cast_nullable_to_non_nullable
              as String,
      aiPrompt: null == aiPrompt
          ? _value.aiPrompt
          : aiPrompt // ignore: cast_nullable_to_non_nullable
              as String,
      generatedText: null == generatedText
          ? _value.generatedText
          : generatedText // ignore: cast_nullable_to_non_nullable
              as String,
      agencyRecommendation: freezed == agencyRecommendation
          ? _value.agencyRecommendation
          : agencyRecommendation // ignore: cast_nullable_to_non_nullable
              as String?,
      warnings: null == warnings
          ? _value.warnings
          : warnings // ignore: cast_nullable_to_non_nullable
              as List<String>,
      generatedAt: null == generatedAt
          ? _value.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TravelProposalImplCopyWith<$Res>
    implements $TravelProposalCopyWith<$Res> {
  factory _$$TravelProposalImplCopyWith(_$TravelProposalImpl value,
          $Res Function(_$TravelProposalImpl) then) =
      __$$TravelProposalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String subtitle,
      List<String> destinations,
      List<String> experiences,
      String emotionalProfile,
      double safetyScore,
      bool isSafe,
      String osintReport,
      String aiPrompt,
      String generatedText,
      String? agencyRecommendation,
      List<String> warnings,
      @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
      DateTime generatedAt});
}

/// @nodoc
class __$$TravelProposalImplCopyWithImpl<$Res>
    extends _$TravelProposalCopyWithImpl<$Res, _$TravelProposalImpl>
    implements _$$TravelProposalImplCopyWith<$Res> {
  __$$TravelProposalImplCopyWithImpl(
      _$TravelProposalImpl _value, $Res Function(_$TravelProposalImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? subtitle = null,
    Object? destinations = null,
    Object? experiences = null,
    Object? emotionalProfile = null,
    Object? safetyScore = null,
    Object? isSafe = null,
    Object? osintReport = null,
    Object? aiPrompt = null,
    Object? generatedText = null,
    Object? agencyRecommendation = freezed,
    Object? warnings = null,
    Object? generatedAt = null,
  }) {
    return _then(_$TravelProposalImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      subtitle: null == subtitle
          ? _value.subtitle
          : subtitle // ignore: cast_nullable_to_non_nullable
              as String,
      destinations: null == destinations
          ? _value._destinations
          : destinations // ignore: cast_nullable_to_non_nullable
              as List<String>,
      experiences: null == experiences
          ? _value._experiences
          : experiences // ignore: cast_nullable_to_non_nullable
              as List<String>,
      emotionalProfile: null == emotionalProfile
          ? _value.emotionalProfile
          : emotionalProfile // ignore: cast_nullable_to_non_nullable
              as String,
      safetyScore: null == safetyScore
          ? _value.safetyScore
          : safetyScore // ignore: cast_nullable_to_non_nullable
              as double,
      isSafe: null == isSafe
          ? _value.isSafe
          : isSafe // ignore: cast_nullable_to_non_nullable
              as bool,
      osintReport: null == osintReport
          ? _value.osintReport
          : osintReport // ignore: cast_nullable_to_non_nullable
              as String,
      aiPrompt: null == aiPrompt
          ? _value.aiPrompt
          : aiPrompt // ignore: cast_nullable_to_non_nullable
              as String,
      generatedText: null == generatedText
          ? _value.generatedText
          : generatedText // ignore: cast_nullable_to_non_nullable
              as String,
      agencyRecommendation: freezed == agencyRecommendation
          ? _value.agencyRecommendation
          : agencyRecommendation // ignore: cast_nullable_to_non_nullable
              as String?,
      warnings: null == warnings
          ? _value._warnings
          : warnings // ignore: cast_nullable_to_non_nullable
              as List<String>,
      generatedAt: null == generatedAt
          ? _value.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TravelProposalImpl implements _TravelProposal {
  const _$TravelProposalImpl(
      {required this.id,
      required this.title,
      required this.subtitle,
      required final List<String> destinations,
      required final List<String> experiences,
      required this.emotionalProfile,
      this.safetyScore = 0.0,
      this.isSafe = true,
      required this.osintReport,
      required this.aiPrompt,
      required this.generatedText,
      this.agencyRecommendation,
      final List<String> warnings = const [],
      @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
      required this.generatedAt})
      : _destinations = destinations,
        _experiences = experiences,
        _warnings = warnings;

  factory _$TravelProposalImpl.fromJson(Map<String, dynamic> json) =>
      _$$TravelProposalImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String subtitle;
  final List<String> _destinations;
  @override
  List<String> get destinations {
    if (_destinations is EqualUnmodifiableListView) return _destinations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_destinations);
  }

  final List<String> _experiences;
  @override
  List<String> get experiences {
    if (_experiences is EqualUnmodifiableListView) return _experiences;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_experiences);
  }

  @override
  final String emotionalProfile;
  @override
  @JsonKey()
  final double safetyScore;
  @override
  @JsonKey()
  final bool isSafe;
  @override
  final String osintReport;
  @override
  final String aiPrompt;
  @override
  final String generatedText;
  @override
  final String? agencyRecommendation;
  final List<String> _warnings;
  @override
  @JsonKey()
  List<String> get warnings {
    if (_warnings is EqualUnmodifiableListView) return _warnings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_warnings);
  }

  @override
  @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
  final DateTime generatedAt;

  @override
  String toString() {
    return 'TravelProposal(id: $id, title: $title, subtitle: $subtitle, destinations: $destinations, experiences: $experiences, emotionalProfile: $emotionalProfile, safetyScore: $safetyScore, isSafe: $isSafe, osintReport: $osintReport, aiPrompt: $aiPrompt, generatedText: $generatedText, agencyRecommendation: $agencyRecommendation, warnings: $warnings, generatedAt: $generatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TravelProposalImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.subtitle, subtitle) ||
                other.subtitle == subtitle) &&
            const DeepCollectionEquality()
                .equals(other._destinations, _destinations) &&
            const DeepCollectionEquality()
                .equals(other._experiences, _experiences) &&
            (identical(other.emotionalProfile, emotionalProfile) ||
                other.emotionalProfile == emotionalProfile) &&
            (identical(other.safetyScore, safetyScore) ||
                other.safetyScore == safetyScore) &&
            (identical(other.isSafe, isSafe) || other.isSafe == isSafe) &&
            (identical(other.osintReport, osintReport) ||
                other.osintReport == osintReport) &&
            (identical(other.aiPrompt, aiPrompt) ||
                other.aiPrompt == aiPrompt) &&
            (identical(other.generatedText, generatedText) ||
                other.generatedText == generatedText) &&
            (identical(other.agencyRecommendation, agencyRecommendation) ||
                other.agencyRecommendation == agencyRecommendation) &&
            const DeepCollectionEquality().equals(other._warnings, _warnings) &&
            (identical(other.generatedAt, generatedAt) ||
                other.generatedAt == generatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      subtitle,
      const DeepCollectionEquality().hash(_destinations),
      const DeepCollectionEquality().hash(_experiences),
      emotionalProfile,
      safetyScore,
      isSafe,
      osintReport,
      aiPrompt,
      generatedText,
      agencyRecommendation,
      const DeepCollectionEquality().hash(_warnings),
      generatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TravelProposalImplCopyWith<_$TravelProposalImpl> get copyWith =>
      __$$TravelProposalImplCopyWithImpl<_$TravelProposalImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TravelProposalImplToJson(
      this,
    );
  }
}

abstract class _TravelProposal implements TravelProposal {
  const factory _TravelProposal(
      {required final String id,
      required final String title,
      required final String subtitle,
      required final List<String> destinations,
      required final List<String> experiences,
      required final String emotionalProfile,
      final double safetyScore,
      final bool isSafe,
      required final String osintReport,
      required final String aiPrompt,
      required final String generatedText,
      final String? agencyRecommendation,
      final List<String> warnings,
      @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
      required final DateTime generatedAt}) = _$TravelProposalImpl;

  factory _TravelProposal.fromJson(Map<String, dynamic> json) =
      _$TravelProposalImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get subtitle;
  @override
  List<String> get destinations;
  @override
  List<String> get experiences;
  @override
  String get emotionalProfile;
  @override
  double get safetyScore;
  @override
  bool get isSafe;
  @override
  String get osintReport;
  @override
  String get aiPrompt;
  @override
  String get generatedText;
  @override
  String? get agencyRecommendation;
  @override
  List<String> get warnings;
  @override
  @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
  DateTime get generatedAt;
  @override
  @JsonKey(ignore: true)
  _$$TravelProposalImplCopyWith<_$TravelProposalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
