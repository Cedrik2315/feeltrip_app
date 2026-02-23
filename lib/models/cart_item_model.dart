class CartItem {
  final String tripId;
  final String tripTitle;
  final double price;
  int quantity;
  final String destination;
  final String image;

  CartItem({
    required this.tripId,
    required this.tripTitle,
    required this.price,
    this.quantity = 1,
    required this.destination,
    required this.image,
  });

  double get total => price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      tripId: json['tripId'] ?? '',
      tripTitle: json['tripTitle'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      destination: json['destination'] ?? '',
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tripId': tripId,
      'tripTitle': tripTitle,
      'price': price,
      'quantity': quantity,
      'destination': destination,
      'image': image,
    };
  }
}
