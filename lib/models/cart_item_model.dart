import 'package:cloud_firestore/cloud_firestore.dart';
import 'trip_model.dart';

class CartItem {
  final String id;
  final String tripId;
  final String tripTitle;
  final String image;
  final String destination;
  final double price;
  int quantity;
  final Timestamp addedAt;

  CartItem({
    this.id = '',
    this.tripId = '',
    this.tripTitle = '',
    this.image = '',
    this.destination = '',
    this.price = 0.0,
    this.quantity = 1,
    Timestamp? addedAt,
  }) : addedAt = addedAt ?? Timestamp.now();

  factory CartItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CartItem(
      id: doc.id,
      tripId: data['tripId'] ?? '',
      tripTitle: data['tripTitle'] ?? '',
      image: data['tripImage'] ?? '',
      destination: data['destination'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      quantity: data['quantity'] ?? 1,
      addedAt: data['addedAt'] ?? Timestamp.now(),
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? json['tripId'] ?? '',
      tripId: json['tripId'] ?? '',
      tripTitle: json['tripTitle'] ?? '',
      image: json['tripImage'] ?? json['image'] ?? '',
      destination: json['destination'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      quantity: json['quantity'] ?? 1,
      addedAt: json['addedAt'] is Timestamp
          ? json['addedAt']
          : (json['addedAt'] != null
              ? Timestamp.fromDate(DateTime.parse(json['addedAt']))
              : Timestamp.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'tripTitle': tripTitle,
      'tripImage': image,
      'destination': destination,
      'price': price,
      'quantity': quantity,
      'addedAt': addedAt.toDate().toIso8601String(),
    };
  }

  static Map<String, dynamic> toFirestore(Trip trip, int quantity) {
    return {
      'tripId': trip.id,
      'tripTitle': trip.title,
      'tripImage': trip.images.isNotEmpty ? trip.images.first : '',
      'destination': trip.destination,
      'price': trip.price,
      'quantity': quantity,
      'addedAt': Timestamp.now(),
    };
  }
}
