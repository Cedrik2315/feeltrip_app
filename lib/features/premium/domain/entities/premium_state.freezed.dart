// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'premium_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PremiumState _$PremiumStateFromJson(Map<String, dynamic> json) {
  return _PremiumState.fromJson(json);
}

/// @nodoc
mixin _$PremiumState {
  bool get isPremium => throw _privateConstructorUsedError;
  List<Offering> get offerings => throw _privateConstructorUsedError;
  Package? get activePackage => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PremiumStateCopyWith<PremiumState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PremiumStateCopyWith<$Res> {
  factory $PremiumStateCopyWith(
          PremiumState value, $Res Function(PremiumState) then) =
      _$PremiumStateCopyWithImpl<$Res, PremiumState>;
  @useResult
  $Res call(
      {bool isPremium,
      List<Offering> offerings,
      Package? activePackage,
      String? errorMessage});

  $PackageCopyWith<$Res>? get activePackage;
}

/// @nodoc
class _$PremiumStateCopyWithImpl<$Res, $Val extends PremiumState>
    implements $PremiumStateCopyWith<$Res> {
  _$PremiumStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isPremium = null,
    Object? offerings = null,
    Object? activePackage = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      isPremium: null == isPremium
          ? _value.isPremium
          : isPremium // ignore: cast_nullable_to_non_nullable
              as bool,
      offerings: null == offerings
          ? _value.offerings
          : offerings // ignore: cast_nullable_to_non_nullable
              as List<Offering>,
      activePackage: freezed == activePackage
          ? _value.activePackage
          : activePackage // ignore: cast_nullable_to_non_nullable
              as Package?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $PackageCopyWith<$Res>? get activePackage {
    if (_value.activePackage == null) {
      return null;
    }

    return $PackageCopyWith<$Res>(_value.activePackage!, (value) {
      return _then(_value.copyWith(activePackage: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PremiumStateImplCopyWith<$Res>
    implements $PremiumStateCopyWith<$Res> {
  factory _$$PremiumStateImplCopyWith(
          _$PremiumStateImpl value, $Res Function(_$PremiumStateImpl) then) =
      __$$PremiumStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isPremium,
      List<Offering> offerings,
      Package? activePackage,
      String? errorMessage});

  @override
  $PackageCopyWith<$Res>? get activePackage;
}

/// @nodoc
class __$$PremiumStateImplCopyWithImpl<$Res>
    extends _$PremiumStateCopyWithImpl<$Res, _$PremiumStateImpl>
    implements _$$PremiumStateImplCopyWith<$Res> {
  __$$PremiumStateImplCopyWithImpl(
      _$PremiumStateImpl _value, $Res Function(_$PremiumStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isPremium = null,
    Object? offerings = null,
    Object? activePackage = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(_$PremiumStateImpl(
      isPremium: null == isPremium
          ? _value.isPremium
          : isPremium // ignore: cast_nullable_to_non_nullable
              as bool,
      offerings: null == offerings
          ? _value._offerings
          : offerings // ignore: cast_nullable_to_non_nullable
              as List<Offering>,
      activePackage: freezed == activePackage
          ? _value.activePackage
          : activePackage // ignore: cast_nullable_to_non_nullable
              as Package?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PremiumStateImpl implements _PremiumState {
  const _$PremiumStateImpl(
      {this.isPremium = false,
      final List<Offering> offerings = const [],
      this.activePackage = null,
      this.errorMessage})
      : _offerings = offerings;

  factory _$PremiumStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$PremiumStateImplFromJson(json);

  @override
  @JsonKey()
  final bool isPremium;
  final List<Offering> _offerings;
  @override
  @JsonKey()
  List<Offering> get offerings {
    if (_offerings is EqualUnmodifiableListView) return _offerings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_offerings);
  }

  @override
  @JsonKey()
  final Package? activePackage;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'PremiumState(isPremium: $isPremium, offerings: $offerings, activePackage: $activePackage, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PremiumStateImpl &&
            (identical(other.isPremium, isPremium) ||
                other.isPremium == isPremium) &&
            const DeepCollectionEquality()
                .equals(other._offerings, _offerings) &&
            (identical(other.activePackage, activePackage) ||
                other.activePackage == activePackage) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      isPremium,
      const DeepCollectionEquality().hash(_offerings),
      activePackage,
      errorMessage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PremiumStateImplCopyWith<_$PremiumStateImpl> get copyWith =>
      __$$PremiumStateImplCopyWithImpl<_$PremiumStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PremiumStateImplToJson(
      this,
    );
  }
}

abstract class _PremiumState implements PremiumState {
  const factory _PremiumState(
      {final bool isPremium,
      final List<Offering> offerings,
      final Package? activePackage,
      final String? errorMessage}) = _$PremiumStateImpl;

  factory _PremiumState.fromJson(Map<String, dynamic> json) =
      _$PremiumStateImpl.fromJson;

  @override
  bool get isPremium;
  @override
  List<Offering> get offerings;
  @override
  Package? get activePackage;
  @override
  String? get errorMessage;
  @override
  @JsonKey(ignore: true)
  _$$PremiumStateImplCopyWith<_$PremiumStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
