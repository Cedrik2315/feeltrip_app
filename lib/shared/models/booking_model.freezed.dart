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

Booking _$BookingFromJson(Map<String, dynamic> json) {
  return _Booking.fromJson(json);
}

/// @nodoc
mixin _$Booking {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get tripId => throw _privateConstructorUsedError;
  String get tripTitle => throw _privateConstructorUsedError;
  int get numberOfPeople => throw _privateConstructorUsedError;
  double get totalPrice => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parseRequiredDateTime, toJson: _toJsonDateTime)
  DateTime get bookingDate => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parseRequiredDateTime, toJson: _toJsonDateTime)
  DateTime get startDate => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  List<String> get passengers => throw _privateConstructorUsedError;
  String get paymentMethod => throw _privateConstructorUsedError;
  bool get isPaid => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BookingCopyWith<Booking> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookingCopyWith<$Res> {
  factory $BookingCopyWith(Booking value, $Res Function(Booking) then) =
      _$BookingCopyWithImpl<$Res, Booking>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String tripId,
      String tripTitle,
      int numberOfPeople,
      double totalPrice,
      @JsonKey(fromJson: _parseRequiredDateTime, toJson: _toJsonDateTime)
      DateTime bookingDate,
      @JsonKey(fromJson: _parseRequiredDateTime, toJson: _toJsonDateTime)
      DateTime startDate,
      String status,
      List<String> passengers,
      String paymentMethod,
      bool isPaid});
}

/// @nodoc
class _$BookingCopyWithImpl<$Res, $Val extends Booking>
    implements $BookingCopyWith<$Res> {
  _$BookingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? tripId = null,
    Object? tripTitle = null,
    Object? numberOfPeople = null,
    Object? totalPrice = null,
    Object? bookingDate = null,
    Object? startDate = null,
    Object? status = null,
    Object? passengers = null,
    Object? paymentMethod = null,
    Object? isPaid = null,
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
      tripId: null == tripId
          ? _value.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String,
      tripTitle: null == tripTitle
          ? _value.tripTitle
          : tripTitle // ignore: cast_nullable_to_non_nullable
              as String,
      numberOfPeople: null == numberOfPeople
          ? _value.numberOfPeople
          : numberOfPeople // ignore: cast_nullable_to_non_nullable
              as int,
      totalPrice: null == totalPrice
          ? _value.totalPrice
          : totalPrice // ignore: cast_nullable_to_non_nullable
              as double,
      bookingDate: null == bookingDate
          ? _value.bookingDate
          : bookingDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      passengers: null == passengers
          ? _value.passengers
          : passengers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as String,
      isPaid: null == isPaid
          ? _value.isPaid
          : isPaid // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BookingImplCopyWith<$Res> implements $BookingCopyWith<$Res> {
  factory _$$BookingImplCopyWith(
          _$BookingImpl value, $Res Function(_$BookingImpl) then) =
      __$$BookingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String tripId,
      String tripTitle,
      int numberOfPeople,
      double totalPrice,
      @JsonKey(fromJson: _parseRequiredDateTime, toJson: _toJsonDateTime)
      DateTime bookingDate,
      @JsonKey(fromJson: _parseRequiredDateTime, toJson: _toJsonDateTime)
      DateTime startDate,
      String status,
      List<String> passengers,
      String paymentMethod,
      bool isPaid});
}

/// @nodoc
class __$$BookingImplCopyWithImpl<$Res>
    extends _$BookingCopyWithImpl<$Res, _$BookingImpl>
    implements _$$BookingImplCopyWith<$Res> {
  __$$BookingImplCopyWithImpl(
      _$BookingImpl _value, $Res Function(_$BookingImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? tripId = null,
    Object? tripTitle = null,
    Object? numberOfPeople = null,
    Object? totalPrice = null,
    Object? bookingDate = null,
    Object? startDate = null,
    Object? status = null,
    Object? passengers = null,
    Object? paymentMethod = null,
    Object? isPaid = null,
  }) {
    return _then(_$BookingImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      tripId: null == tripId
          ? _value.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String,
      tripTitle: null == tripTitle
          ? _value.tripTitle
          : tripTitle // ignore: cast_nullable_to_non_nullable
              as String,
      numberOfPeople: null == numberOfPeople
          ? _value.numberOfPeople
          : numberOfPeople // ignore: cast_nullable_to_non_nullable
              as int,
      totalPrice: null == totalPrice
          ? _value.totalPrice
          : totalPrice // ignore: cast_nullable_to_non_nullable
              as double,
      bookingDate: null == bookingDate
          ? _value.bookingDate
          : bookingDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      passengers: null == passengers
          ? _value._passengers
          : passengers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as String,
      isPaid: null == isPaid
          ? _value.isPaid
          : isPaid // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BookingImpl implements _Booking {
  const _$BookingImpl(
      {required this.id,
      required this.userId,
      required this.tripId,
      required this.tripTitle,
      required this.numberOfPeople,
      required this.totalPrice,
      @JsonKey(fromJson: _parseRequiredDateTime, toJson: _toJsonDateTime)
      required this.bookingDate,
      @JsonKey(fromJson: _parseRequiredDateTime, toJson: _toJsonDateTime)
      required this.startDate,
      this.status = 'Confirmada',
      final List<String> passengers = const <String>[],
      this.paymentMethod = 'Tarjeta de Credito',
      this.isPaid = false})
      : _passengers = passengers;

  factory _$BookingImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookingImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String tripId;
  @override
  final String tripTitle;
  @override
  final int numberOfPeople;
  @override
  final double totalPrice;
  @override
  @JsonKey(fromJson: _parseRequiredDateTime, toJson: _toJsonDateTime)
  final DateTime bookingDate;
  @override
  @JsonKey(fromJson: _parseRequiredDateTime, toJson: _toJsonDateTime)
  final DateTime startDate;
  @override
  @JsonKey()
  final String status;
  final List<String> _passengers;
  @override
  @JsonKey()
  List<String> get passengers {
    if (_passengers is EqualUnmodifiableListView) return _passengers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_passengers);
  }

  @override
  @JsonKey()
  final String paymentMethod;
  @override
  @JsonKey()
  final bool isPaid;

  @override
  String toString() {
    return 'Booking(id: $id, userId: $userId, tripId: $tripId, tripTitle: $tripTitle, numberOfPeople: $numberOfPeople, totalPrice: $totalPrice, bookingDate: $bookingDate, startDate: $startDate, status: $status, passengers: $passengers, paymentMethod: $paymentMethod, isPaid: $isPaid)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.tripId, tripId) || other.tripId == tripId) &&
            (identical(other.tripTitle, tripTitle) ||
                other.tripTitle == tripTitle) &&
            (identical(other.numberOfPeople, numberOfPeople) ||
                other.numberOfPeople == numberOfPeople) &&
            (identical(other.totalPrice, totalPrice) ||
                other.totalPrice == totalPrice) &&
            (identical(other.bookingDate, bookingDate) ||
                other.bookingDate == bookingDate) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality()
                .equals(other._passengers, _passengers) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.isPaid, isPaid) || other.isPaid == isPaid));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      tripId,
      tripTitle,
      numberOfPeople,
      totalPrice,
      bookingDate,
      startDate,
      status,
      const DeepCollectionEquality().hash(_passengers),
      paymentMethod,
      isPaid);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BookingImplCopyWith<_$BookingImpl> get copyWith =>
      __$$BookingImplCopyWithImpl<_$BookingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BookingImplToJson(
      this,
    );
  }
}

abstract class _Booking implements Booking {
  const factory _Booking(
      {required final String id,
      required final String userId,
      required final String tripId,
      required final String tripTitle,
      required final int numberOfPeople,
      required final double totalPrice,
      @JsonKey(fromJson: _parseRequiredDateTime, toJson: _toJsonDateTime)
      required final DateTime bookingDate,
      @JsonKey(fromJson: _parseRequiredDateTime, toJson: _toJsonDateTime)
      required final DateTime startDate,
      final String status,
      final List<String> passengers,
      final String paymentMethod,
      final bool isPaid}) = _$BookingImpl;

  factory _Booking.fromJson(Map<String, dynamic> json) = _$BookingImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get tripId;
  @override
  String get tripTitle;
  @override
  int get numberOfPeople;
  @override
  double get totalPrice;
  @override
  @JsonKey(fromJson: _parseRequiredDateTime, toJson: _toJsonDateTime)
  DateTime get bookingDate;
  @override
  @JsonKey(fromJson: _parseRequiredDateTime, toJson: _toJsonDateTime)
  DateTime get startDate;
  @override
  String get status;
  @override
  List<String> get passengers;
  @override
  String get paymentMethod;
  @override
  bool get isPaid;
  @override
  @JsonKey(ignore: true)
  _$$BookingImplCopyWith<_$BookingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
