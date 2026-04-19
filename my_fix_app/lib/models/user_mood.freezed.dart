// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_mood.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserMood _$UserMoodFromJson(Map<String, dynamic> json) {
  return _UserMood.fromJson(json);
}

/// @nodoc
mixin _$UserMood {
  String get primaryTrait => throw _privateConstructorUsedError;
  String get badgeText => throw _privateConstructorUsedError;
  String get emoji => throw _privateConstructorUsedError;
  double? get sentimentScore => throw _privateConstructorUsedError;
  List<String>? get imageLabels => throw _privateConstructorUsedError;
  String? get recognizedText => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserMoodCopyWith<UserMood> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserMoodCopyWith<$Res> {
  factory $UserMoodCopyWith(UserMood value, $Res Function(UserMood) then) =
      _$UserMoodCopyWithImpl<$Res, UserMood>;
  @useResult
  $Res call(
      {String primaryTrait,
      String badgeText,
      String emoji,
      double? sentimentScore,
      List<String>? imageLabels,
      String? recognizedText});
}

/// @nodoc
class _$UserMoodCopyWithImpl<$Res, $Val extends UserMood>
    implements $UserMoodCopyWith<$Res> {
  _$UserMoodCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? primaryTrait = null,
    Object? badgeText = null,
    Object? emoji = null,
    Object? sentimentScore = freezed,
    Object? imageLabels = freezed,
    Object? recognizedText = freezed,
  }) {
    return _then(_value.copyWith(
      primaryTrait: null == primaryTrait
          ? _value.primaryTrait
          : primaryTrait // ignore: cast_nullable_to_non_nullable
              as String,
      badgeText: null == badgeText
          ? _value.badgeText
          : badgeText // ignore: cast_nullable_to_non_nullable
              as String,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
      sentimentScore: freezed == sentimentScore
          ? _value.sentimentScore
          : sentimentScore // ignore: cast_nullable_to_non_nullable
              as double?,
      imageLabels: freezed == imageLabels
          ? _value.imageLabels
          : imageLabels // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      recognizedText: freezed == recognizedText
          ? _value.recognizedText
          : recognizedText // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserMoodImplCopyWith<$Res>
    implements $UserMoodCopyWith<$Res> {
  factory _$$UserMoodImplCopyWith(
          _$UserMoodImpl value, $Res Function(_$UserMoodImpl) then) =
      __$$UserMoodImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String primaryTrait,
      String badgeText,
      String emoji,
      double? sentimentScore,
      List<String>? imageLabels,
      String? recognizedText});
}

/// @nodoc
class __$$UserMoodImplCopyWithImpl<$Res>
    extends _$UserMoodCopyWithImpl<$Res, _$UserMoodImpl>
    implements _$$UserMoodImplCopyWith<$Res> {
  __$$UserMoodImplCopyWithImpl(
      _$UserMoodImpl _value, $Res Function(_$UserMoodImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? primaryTrait = null,
    Object? badgeText = null,
    Object? emoji = null,
    Object? sentimentScore = freezed,
    Object? imageLabels = freezed,
    Object? recognizedText = freezed,
  }) {
    return _then(_$UserMoodImpl(
      primaryTrait: null == primaryTrait
          ? _value.primaryTrait
          : primaryTrait // ignore: cast_nullable_to_non_nullable
              as String,
      badgeText: null == badgeText
          ? _value.badgeText
          : badgeText // ignore: cast_nullable_to_non_nullable
              as String,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
      sentimentScore: freezed == sentimentScore
          ? _value.sentimentScore
          : sentimentScore // ignore: cast_nullable_to_non_nullable
              as double?,
      imageLabels: freezed == imageLabels
          ? _value._imageLabels
          : imageLabels // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      recognizedText: freezed == recognizedText
          ? _value.recognizedText
          : recognizedText // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserMoodImpl implements _UserMood {
  const _$UserMoodImpl(
      {required this.primaryTrait,
      required this.badgeText,
      required this.emoji,
      this.sentimentScore,
      final List<String>? imageLabels,
      this.recognizedText})
      : _imageLabels = imageLabels;

  factory _$UserMoodImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserMoodImplFromJson(json);

  @override
  final String primaryTrait;
  @override
  final String badgeText;
  @override
  final String emoji;
  @override
  final double? sentimentScore;
  final List<String>? _imageLabels;
  @override
  List<String>? get imageLabels {
    final value = _imageLabels;
    if (value == null) return null;
    if (_imageLabels is EqualUnmodifiableListView) return _imageLabels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? recognizedText;

  @override
  String toString() {
    return 'UserMood(primaryTrait: $primaryTrait, badgeText: $badgeText, emoji: $emoji, sentimentScore: $sentimentScore, imageLabels: $imageLabels, recognizedText: $recognizedText)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserMoodImpl &&
            (identical(other.primaryTrait, primaryTrait) ||
                other.primaryTrait == primaryTrait) &&
            (identical(other.badgeText, badgeText) ||
                other.badgeText == badgeText) &&
            (identical(other.emoji, emoji) || other.emoji == emoji) &&
            (identical(other.sentimentScore, sentimentScore) ||
                other.sentimentScore == sentimentScore) &&
            const DeepCollectionEquality()
                .equals(other._imageLabels, _imageLabels) &&
            (identical(other.recognizedText, recognizedText) ||
                other.recognizedText == recognizedText));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      primaryTrait,
      badgeText,
      emoji,
      sentimentScore,
      const DeepCollectionEquality().hash(_imageLabels),
      recognizedText);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserMoodImplCopyWith<_$UserMoodImpl> get copyWith =>
      __$$UserMoodImplCopyWithImpl<_$UserMoodImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserMoodImplToJson(
      this,
    );
  }
}

abstract class _UserMood implements UserMood {
  const factory _UserMood(
      {required final String primaryTrait,
      required final String badgeText,
      required final String emoji,
      final double? sentimentScore,
      final List<String>? imageLabels,
      final String? recognizedText}) = _$UserMoodImpl;

  factory _UserMood.fromJson(Map<String, dynamic> json) =
      _$UserMoodImpl.fromJson;

  @override
  String get primaryTrait;
  @override
  String get badgeText;
  @override
  String get emoji;
  @override
  double? get sentimentScore;
  @override
  List<String>? get imageLabels;
  @override
  String? get recognizedText;
  @override
  @JsonKey(ignore: true)
  _$$UserMoodImplCopyWith<_$UserMoodImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
