import 'package:cloud_firestore/cloud_firestore.dart';

class Trip {
  final String id;
  final String title;
  final String destination;
  final String description;
  final double price;
  final int duration;
  final double rating;
  final String imageUrl;
  final String difficulty;
  final int maxGroupSize;
  final GeoPoint? location;

  Trip({
    required this.id,
    required this.title,
    required this.destination,
    required this.description,
    required this.price,
    required this.duration,
    required this.rating,
    required this.imageUrl,
    this.difficulty = 'Moderada',
    this.maxGroupSize = 12,
    this.location,
  });

  factory Trip.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Trip(
      id: doc.id,
      title: data['title'] as String? ?? '',
      destination: data['destination'] as String? ?? '',
      description: data['description'] as String? ?? '',
      price: (data['price'] as num? ?? 0).toDouble(),
      duration: data['duration'] as int? ?? 1,
      rating: (data['rating'] as num? ?? 0.0).toDouble(),
      imageUrl: data['imageUrl'] as String? ?? 'https://images.unsplash.com/photo-1596324268112-78a3c89d90d8',
      difficulty: data['difficulty'] as String? ?? 'Moderada',
      maxGroupSize: data['maxGroupSize'] as int? ?? 12,
      location: data['location'] as GeoPoint?,
    );
  }
}