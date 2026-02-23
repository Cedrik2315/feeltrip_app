import 'package:cloud_firestore/cloud_firestore.dart';

class TravelAgency {
  final String id;
  final String name;
  final String description;
  final String logo;
  final String phoneNumber;
  final String email;
  final String website;
  final String address;
  final String city;
  final String country;
  final double latitude;
  final double longitude;
  final List<String> specialties; // ['adventure', 'cultural', 'relaxation']
  final double rating;
  final int reviewCount;
  final List<String> experiences; // IDs de experiencias
  final int followers;
  final bool verified;
  final DateTime createdAt;
  final List<String> socialMedia; // Instagram, Facebook, WhatsApp

  TravelAgency({
    required this.id,
    required this.name,
    required this.description,
    required this.logo,
    required this.phoneNumber,
    required this.email,
    required this.website,
    required this.address,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.specialties,
    this.rating = 0,
    this.reviewCount = 0,
    this.experiences = const [],
    this.followers = 0,
    this.verified = false,
    required this.createdAt,
    this.socialMedia = const [],
  });

  // Convertir de JSON a objeto
  factory TravelAgency.fromJson(Map<String, dynamic> json) {
    return TravelAgency(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      logo: json['logo'] as String,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String,
      website: json['website'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      country: json['country'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      specialties: List<String>.from(json['specialties'] ?? []),
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      experiences: List<String>.from(json['experiences'] ?? []),
      followers: json['followers'] as int? ?? 0,
      verified: json['verified'] as bool? ?? false,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      socialMedia: List<String>.from(json['socialMedia'] ?? []),
    );
  }

  // Convertir de Firestore a objeto
  factory TravelAgency.fromFirestore(DocumentSnapshot doc) {
    return TravelAgency.fromJson({
      'id': doc.id,
      ...doc.data() as Map<String, dynamic>,
    });
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logo': logo,
      'phoneNumber': phoneNumber,
      'email': email,
      'website': website,
      'address': address,
      'city': city,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'specialties': specialties,
      'rating': rating,
      'reviewCount': reviewCount,
      'experiences': experiences,
      'followers': followers,
      'verified': verified,
      'createdAt': createdAt,
      'socialMedia': socialMedia,
    };
  }

  // Convertir a Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'logo': logo,
      'phoneNumber': phoneNumber,
      'email': email,
      'website': website,
      'address': address,
      'city': city,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'specialties': specialties,
      'rating': rating,
      'reviewCount': reviewCount,
      'experiences': experiences,
      'followers': followers,
      'verified': verified,
      'createdAt': Timestamp.fromDate(createdAt),
      'socialMedia': socialMedia,
    };
  }

  // Copiar con cambios
  TravelAgency copyWith({
    String? id,
    String? name,
    String? description,
    String? logo,
    String? phoneNumber,
    String? email,
    String? website,
    String? address,
    String? city,
    String? country,
    double? latitude,
    double? longitude,
    List<String>? specialties,
    double? rating,
    int? reviewCount,
    List<String>? experiences,
    int? followers,
    bool? verified,
    DateTime? createdAt,
    List<String>? socialMedia,
  }) {
    return TravelAgency(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      logo: logo ?? this.logo,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      website: website ?? this.website,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      specialties: specialties ?? this.specialties,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      experiences: experiences ?? this.experiences,
      followers: followers ?? this.followers,
      verified: verified ?? this.verified,
      createdAt: createdAt ?? this.createdAt,
      socialMedia: socialMedia ?? this.socialMedia,
    );
  }
}
