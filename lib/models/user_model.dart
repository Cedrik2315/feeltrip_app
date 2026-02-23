import 'package:intl/intl.dart';

class User {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String profileImage;
  final String preferences;
  final DateTime createdAt;
  final List<String> favoriteTrips;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    this.profileImage = '',
    this.preferences = '',
    required this.createdAt,
    this.favoriteTrips = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      profileImage: json['profileImage'] ?? '',
      preferences: json['preferences'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      favoriteTrips: List<String>.from(json['favoriteTrips'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'profileImage': profileImage,
      'preferences': preferences,
      'createdAt': createdAt.toIso8601String(),
      'favoriteTrips': favoriteTrips,
    };
  }
}
