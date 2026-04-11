import 'package:cloud_firestore/cloud_firestore.dart';

class Trip {
  Trip({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.destination,
    required this.duration,
    required this.isFeatured,
    required this.tags,
    required this.rating,
    required this.createdAt,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      destination: json['destination'] as String? ?? '',
      duration: json['duration'] as int? ?? 1,
      isFeatured: json['isFeatured'] as bool? ?? false,
      tags: List<String>.from(json['tags'] as Iterable<dynamic>? ?? []),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  factory Trip.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    data['id'] = doc.id;
    return Trip.fromJson(data);
  }

  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double price;
  final String destination;
  final int duration;
  final bool isFeatured;
  final List<String> tags;
  final double rating;
  final DateTime createdAt;

  // Getter para verificar si el viaje es transformativo
  bool get isTransformative => tags.contains('transformative') || tags.contains('experiencia transformadora');

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      'destination': destination,
      'duration': duration,
      'isFeatured': isFeatured,
      'tags': tags,
      'rating': rating,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}