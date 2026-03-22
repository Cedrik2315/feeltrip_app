import 'package:flutter/foundation.dart';

@immutable
class CartItem {
  const CartItem({
    required this.id,
    required this.tripId,
    required this.tripTitle,
    required this.destination,
    required this.price,
    required this.quantity,
    required this.image,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String? ?? '',
      tripId: json['tripId'] as String? ?? '',
      tripTitle: json['tripTitle'] as String? ?? '',
      destination: json['destination'] as String? ?? '',
      price: (json['price'] as num? ?? 0).toDouble(),
      quantity: json['quantity'] as int? ?? 1,
      image: json['image'] as String? ?? '✈️',
    );
  }
  final String id;
  final String tripId;
  final String tripTitle;
  final String destination;
  final double price;
  final int quantity;
  final String image; // Emoji or URL

  double get total => price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'tripId': tripId,
      'tripTitle': tripTitle,
      'destination': destination,
      'price': price,
      'quantity': quantity,
      'image': image,
    };
  }
}
