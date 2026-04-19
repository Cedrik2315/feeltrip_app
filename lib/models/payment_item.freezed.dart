// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PaymentItem _$PaymentItemFromJson(Map<String, dynamic> json) {
  return _PaymentItem.fromJson(json);
}

/// @nodoc
mixin _$PaymentItem {
  String get id =>
      throw _privateConstructorUsedError; // ID interno (ej: 'premium_annual')
  String get title =>
      throw _privateConstructorUsedError; // Nombre que verá el usuario
  double get unitPrice => throw _privateConstructorUsedError; // Precio unitario
  int get quantity =>
      throw _privateConstructorUsedError; // Cantidad (por defecto 1)
  String get currencyId =>
      throw _privateConstructorUsedError; // Moneda (CLP para Chile)
  String? get description =>
      throw _privateConstructorUsedError; // Detalles adicionales
  String? get categoryId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PaymentItemCopyWith<PaymentItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentItemCopyWith<$Res> {
  factory $PaymentItemCopyWith(
          PaymentItem value, $Res Function(PaymentItem) then) =
      _$PaymentItemCopyWithImpl<$Res, PaymentItem>;
  @useResult
  $Res call(
      {String id,
      String title,
      double unitPrice,
      int quantity,
      String currencyId,
      String? description,
      String? categoryId});
}

/// @nodoc
class _$PaymentItemCopyWithImpl<$Res, $Val extends PaymentItem>
    implements $PaymentItemCopyWith<$Res> {
  _$PaymentItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? unitPrice = null,
    Object? quantity = null,
    Object? currencyId = null,
    Object? description = freezed,
    Object? categoryId = freezed,
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
      unitPrice: null == unitPrice
          ? _value.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as double,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      currencyId: null == currencyId
          ? _value.currencyId
          : currencyId // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PaymentItemImplCopyWith<$Res>
    implements $PaymentItemCopyWith<$Res> {
  factory _$$PaymentItemImplCopyWith(
          _$PaymentItemImpl value, $Res Function(_$PaymentItemImpl) then) =
      __$$PaymentItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      double unitPrice,
      int quantity,
      String currencyId,
      String? description,
      String? categoryId});
}

/// @nodoc
class __$$PaymentItemImplCopyWithImpl<$Res>
    extends _$PaymentItemCopyWithImpl<$Res, _$PaymentItemImpl>
    implements _$$PaymentItemImplCopyWith<$Res> {
  __$$PaymentItemImplCopyWithImpl(
      _$PaymentItemImpl _value, $Res Function(_$PaymentItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? unitPrice = null,
    Object? quantity = null,
    Object? currencyId = null,
    Object? description = freezed,
    Object? categoryId = freezed,
  }) {
    return _then(_$PaymentItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      unitPrice: null == unitPrice
          ? _value.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as double,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      currencyId: null == currencyId
          ? _value.currencyId
          : currencyId // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PaymentItemImpl extends _PaymentItem {
  const _$PaymentItemImpl(
      {required this.id,
      required this.title,
      required this.unitPrice,
      this.quantity = 1,
      this.currencyId = 'CLP',
      this.description,
      this.categoryId})
      : super._();

  factory _$PaymentItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaymentItemImplFromJson(json);

  @override
  final String id;
// ID interno (ej: 'premium_annual')
  @override
  final String title;
// Nombre que verá el usuario
  @override
  final double unitPrice;
// Precio unitario
  @override
  @JsonKey()
  final int quantity;
// Cantidad (por defecto 1)
  @override
  @JsonKey()
  final String currencyId;
// Moneda (CLP para Chile)
  @override
  final String? description;
// Detalles adicionales
  @override
  final String? categoryId;

  @override
  String toString() {
    return 'PaymentItem(id: $id, title: $title, unitPrice: $unitPrice, quantity: $quantity, currencyId: $currencyId, description: $description, categoryId: $categoryId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.currencyId, currencyId) ||
                other.currencyId == currencyId) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, unitPrice, quantity,
      currencyId, description, categoryId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentItemImplCopyWith<_$PaymentItemImpl> get copyWith =>
      __$$PaymentItemImplCopyWithImpl<_$PaymentItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PaymentItemImplToJson(
      this,
    );
  }
}

abstract class _PaymentItem extends PaymentItem {
  const factory _PaymentItem(
      {required final String id,
      required final String title,
      required final double unitPrice,
      final int quantity,
      final String currencyId,
      final String? description,
      final String? categoryId}) = _$PaymentItemImpl;
  const _PaymentItem._() : super._();

  factory _PaymentItem.fromJson(Map<String, dynamic> json) =
      _$PaymentItemImpl.fromJson;

  @override
  String get id;
  @override // ID interno (ej: 'premium_annual')
  String get title;
  @override // Nombre que verá el usuario
  double get unitPrice;
  @override // Precio unitario
  int get quantity;
  @override // Cantidad (por defecto 1)
  String get currencyId;
  @override // Moneda (CLP para Chile)
  String? get description;
  @override // Detalles adicionales
  String? get categoryId;
  @override
  @JsonKey(ignore: true)
  _$$PaymentItemImplCopyWith<_$PaymentItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
