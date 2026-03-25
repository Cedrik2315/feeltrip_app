import 'package:cloud_firestore/cloud_firestore.dart';

class TravelAgency {
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
    required this.rating,
    required this.reviewCount,
    required this.experiences,
    required this.followers,
    required this.verified,
    required this.createdAt,
    required this.socialMedia,
    this.ownerUid,
  });

  factory TravelAgency.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TravelAgency(
      id: doc.id,
      name: (data['name'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      logo: (data['logo'] as String?) ?? '',
      phoneNumber: (data['phoneNumber'] as String?) ?? '',
      email: (data['email'] as String?) ?? '',
      website: (data['website'] as String?) ?? '',
      address: (data['address'] as String?) ?? '', // Corregido
      city: (data['city'] as String?) ?? '',
      country: (data['country'] as String?) ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      specialties:
          List<String>.from(data['specialties'] as Iterable<dynamic>? ?? []),
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (data['reviewCount'] as int?) ?? 0,
      experiences:
          List<String>.from(data['experiences'] as Iterable<dynamic>? ?? []),
      followers: (data['followers'] as int?) ?? 0,
      verified: (data['verified'] as bool?) ?? false,
      socialMedia:
          List<String>.from(data['socialMedia'] as Iterable<dynamic>? ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      ownerUid: data['ownerUid'] as String?,
    );
  }

  final String id;
  final String name;
  final String description;
  final String logo;
  final String phoneNumber;
  final String email;
  final String website;
  final String address; // Estaba declarado pero no mapeado
  final String city;
  final String country;
  final double latitude;
  final double longitude;
  final List<String> specialties;
  final double rating;
  final int reviewCount;
  final List<String> experiences;
  final int followers;
  final bool verified;
  final DateTime createdAt;
  final List<String> socialMedia;
  final String? ownerUid;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'logo': logo,
      'phoneNumber': phoneNumber,
      'email': email,
      'website': website,
      'address': address, // Corregido
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
      'socialMedia': socialMedia,
      'createdAt': Timestamp.fromDate(createdAt),
      'ownerUid': ownerUid, // Corregido
    };
  }

  // MÃ©todo esencial para actualizar el estado en Riverpod u OSINT AI
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
    String? ownerUid,
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
      ownerUid: ownerUid ?? this.ownerUid,
    );
  }
}
