// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaymentItemImpl _$$PaymentItemImplFromJson(Map<String, dynamic> json) =>
    _$PaymentItemImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      currencyId: json['currencyId'] as String? ?? 'CLP',
      description: json['description'] as String?,
      categoryId: json['categoryId'] as String?,
    );

Map<String, dynamic> _$$PaymentItemImplToJson(_$PaymentItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'unitPrice': instance.unitPrice,
      'quantity': instance.quantity,
      'currencyId': instance.currencyId,
      'description': instance.description,
      'categoryId': instance.categoryId,
    };
