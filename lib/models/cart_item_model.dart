class CartItem {
  CartItem({
    required this.id,
    required this.experienceId,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    this.tripId = '',
    this.tripTitle = '',
    this.destination = '',
    this.image = '',
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String? ?? '',
      experienceId: json['experienceId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] as int? ?? 1,
      tripId: json['tripId'] as String? ?? '',
      tripTitle: json['tripTitle'] as String? ?? '',
      destination: json['destination'] as String? ?? '',
      image: json['image'] as String? ?? json['imageUrl'] as String? ?? '',
    );
  }

  final String id;
  final String experienceId;
  final String title;
  final String imageUrl;
  final double price;
  final int quantity;
  final String tripId;
  final String tripTitle;
  final String destination;
  final String image;

  double get total => price * quantity;

  CartItem copyWith({
    String? id,
    String? experienceId,
    String? title,
    String? imageUrl,
    double? price,
    int? quantity,
    String? tripId,
    String? tripTitle,
    String? destination,
    String? image,
  }) {
    return CartItem(
      id: id ?? this.id,
      experienceId: experienceId ?? this.experienceId,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      tripId: tripId ?? this.tripId,
      tripTitle: tripTitle ?? this.tripTitle,
      destination: destination ?? this.destination,
      image: image ?? this.image,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'experienceId': experienceId,
      'title': title,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
      'tripId': tripId,
      'tripTitle': tripTitle,
      'destination': destination,
      'image': image,
    };
  }
}