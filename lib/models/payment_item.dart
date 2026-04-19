import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_item.freezed.dart';
part 'payment_item.g.dart';

@freezed
class PaymentItem with _$PaymentItem {
  const PaymentItem._(); // Ensure this is present to allow custom methods

  const factory PaymentItem({
    required String id,          // ID interno (ej: 'premium_annual')
    required String title,       // Nombre que verá el usuario
    required double unitPrice,   // Precio unitario
    @Default(1) int quantity,    // Cantidad (por defecto 1)
    @Default('CLP') String currencyId, // Moneda (CLP para Chile)
    String? description,         // Detalles adicionales
    String? categoryId,          // Categoría (ej: 'services', 'travel')
  }) = _PaymentItem;

  factory PaymentItem.fromJson(Map<String, dynamic> json) => 
      _$PaymentItemFromJson(json);

  // Helper para convertir al formato exacto que pide Mercado Pago
  Map<String, dynamic> toMpJson() => {
    'title': title,
    'unit_price': unitPrice,
    'quantity': quantity,
    'currency_id': currencyId,
  };
}
