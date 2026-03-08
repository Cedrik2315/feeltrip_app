import 'package:cloud_firestore/cloud_firestore.dart';

class TravelAgency {
  final String id;
  final String name;
  final String description;
  final String logo;
  final String city;
  final String country;
  final double latitude;
  final double longitude;
  final List<String> specialties;
  final double rating;
  final int reviewCount;
  final int followers;
  final bool verified;
  final String phoneNumber;
  final String email;
  final String website;
  final DateTime createdAt;

  TravelAgency({
    required this.id,
    required this.name,
    required this.description,
    required this.logo,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.specialties,
    required this.rating,
    required this.reviewCount,
    required this.followers,
    required this.verified,
    required this.phoneNumber,
    required this.email,
    required this.website,
    required this.createdAt,
  });

  factory TravelAgency.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TravelAgency(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      logo: data['logo'] ?? '',
      city: data['city'] ?? '',
      country: data['country'] ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      specialties: List<String>.from(data['specialties'] ?? []),
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (data['reviewCount'] as num?)?.toInt() ?? 0,
      followers: (data['followers'] as num?)?.toInt() ?? 0,
      verified: data['verified'] ?? false,
      phoneNumber: data['phoneNumber'] ?? '',
      email: data['email'] ?? '',
      website: data['website'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'logo': logo,
      'city': city,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'specialties': specialties,
      'rating': rating,
      'reviewCount': reviewCount,
      'followers': followers,
      'verified': verified,
      'phoneNumber': phoneNumber,
      'email': email,
      'website': website,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
