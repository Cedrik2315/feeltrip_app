// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BookingModel _$BookingModelFromJson(Map<String, dynamic> json) {
  return _BookingModel.fromJson(json);
}

/// @nodoc
mixin _$BookingModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get destinationId => throw _privateConstructorUsedError;
  String get tripDates => throw _privateConstructorUsedError;
  @JsonKey(name: 'price_usd')
  double get priceUsd => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  double get commission => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  bool get isSynced => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BookingModelCopyWith<BookingModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookingModelCopyWith<$Res> {
  factory $BookingModelCopyWith(
          BookingModel value, $Res Function(BookingModel) then) =
      _$BookingModelCopyWithImpl<$Res, BookingModel>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String destinationId,
      String tripDates,
      @JsonKey(name: 'price_usd') double priceUsd,
      String currency,
      String status,
      double commission,
      DateTime? createdAt,
      bool isSynced});
}

/// @nodoc
class _$BookingModelCopyWithImpl<$Res, $Val extends BookingModel>
    implements $BookingModelCopyWith<$Res> {
  _$BookingModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? destinationId = null,
    Object? tripDates = null,
    Object? priceUsd = null,
    Object? currency = null,
    Object? status = null,
    Object? commission = null,
    Object? createdAt = freezed,
    Object? isSynced = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      destinationId: null == destinationId
          ? _value.destinationId
          : destinationId // ignore: cast_nullable_to_non_nullable
              as String,
      tripDates: null == tripDates
          ? _value.tripDates
          : tripDates // ignore: cast_nullable_to_non_nullable
              as String,
      priceUsd: null == priceUsd
          ? _value.priceUsd
          : priceUsd // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      commission: null == commission
          ? _value.commission
          : commission // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isSynced: null == isSynced
          ? _value.isSynced
          : isSynced // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BookingModelImplCopyWith<$Res>
    implements $BookingModelCopyWith<$Res> {
  factory _$$BookingModelImplCopyWith(
          _$BookingModelImpl value, $Res Function(_$BookingModelImpl) then) =
      __$$BookingModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String destinationId,
      String tripDates,
      @JsonKey(name: 'price_usd') double priceUsd,
      String currency,
      String status,
      double commission,
      DateTime? createdAt,
      bool isSynced});
}

/// @nodoc
class __$$BookingModelImplCopyWithImpl<$Res>
    extends _$BookingModelCopyWithImpl<$Res, _$BookingModelImpl>
    implements _$$BookingModelImplCopyWith<$Res> {
  __$$BookingModelImplCopyWithImpl(
      _$BookingModelImpl _value, $Res Function(_$BookingModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? destinationId = null,
    Object? tripDates = null,
    Object? priceUsd = null,
    Object? currency = null,
    Object? status = null,
    Object? commission = null,
    Object? createdAt = freezed,
    Object? isSynced = null,
  }) {
    return _then(_$BookingModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      destinationId: null == destinationId
          ? _value.destinationId
          : destinationId // ignore: cast_nullable_to_non_nullable
              as String,
      tripDates: null == tripDates
          ? _value.tripDates
          : tripDates // ignore: cast_nullable_to_non_nullable
              as String,
      priceUsd: null == priceUsd
          ? _value.priceUsd
          : priceUsd // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      commission: null == commission
          ? _value.commission
          : commission // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isSynced: null == isSynced
          ? _value.isSynced
          : isSynced // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BookingModelImpl implements _BookingModel {
  const _$BookingModelImpl(
      {required this.id,
      required this.userId,
      required this.destinationId,
      required this.tripDates,
      @JsonKey(name: 'price_usd') required this.priceUsd,
      required this.currency,
      this.status = 'pending',
      this.commission = 0.0,
      this.createdAt,
      this.isSynced = false});

  factory _$BookingModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookingModelImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String destinationId;
  @override
  final String tripDates;
  @override
  @JsonKey(name: 'price_usd')
  final double priceUsd;
  @override
  final String currency;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey()
  final double commission;
  @override
  final DateTime? createdAt;
  @override
  @JsonKey()
  final bool isSynced;

  @override
  String toString() {
    return 'BookingModel(id: $id, userId: $userId, destinationId: $destinationId, tripDates: $tripDates, priceUsd: $priceUsd, currency: $currency, status: $status, commission: $commission, createdAt: $createdAt, isSynced: $isSynced)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookingModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.destinationId, destinationId) ||
                other.destinationId == destinationId) &&
            (identical(other.tripDates, tripDates) ||
                other.tripDates == tripDates) &&
            (identical(other.priceUsd, priceUsd) ||
                other.priceUsd == priceUsd) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.commission, commission) ||
                other.commission == commission) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isSynced, isSynced) ||
                other.isSynced == isSynced));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, destinationId,
      tripDates, priceUsd, currency, status, commission, createdAt, isSynced);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BookingModelImplCopyWith<_$BookingModelImpl> get copyWith =>
      __$$BookingModelImplCopyWithImpl<_$BookingModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BookingModelImplToJson(
      this,
    );
  }
}

abstract class _BookingModel implements BookingModel {
  const factory _BookingModel(
      {required final String id,
      required final String userId,
      required final String destinationId,
      required final String tripDates,
      @JsonKey(name: 'price_usd') required final double priceUsd,
      required final String currency,
      final String status,
      final double commission,
      final DateTime? createdAt,
      final bool isSynced}) = _$BookingModelImpl;

  factory _BookingModel.fromJson(Map<String, dynamic> json) =
      _$BookingModelImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get destinationId;
  @override
  String get tripDates;
  @override
  @JsonKey(name: 'price_usd')
  double get priceUsd;
  @override
  String get currency;
  @override
  String get status;
  @override
  double get commission;
  @override
  DateTime? get createdAt;
  @override
  bool get isSynced;
  @override
  @JsonKey(ignore: true)
  _$$BookingModelImplCopyWith<_$BookingModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
