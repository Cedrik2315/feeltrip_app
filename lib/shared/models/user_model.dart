import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class UserProfile {
  const UserProfile({
    required this.uid,
    required this.email,
    required this.name,
    this.phone,
    this.avatarUrl,
    this.travelerType,
    this.archetype,
  });

  factory UserProfile.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return UserProfile(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      name: data['name'] as String? ?? '',
      phone: data['phone'] as String?,
      avatarUrl: data['avatarUrl'] as String?,
      travelerType: data['travelerType'] as String?,
      archetype: data['archetype'] as String?,
    );
  }

  final String uid;
  final String email;
  final String name;
  final String? phone;
  final String? avatarUrl;
  final String? travelerType;
  final String? archetype;
}

@immutable
class UserModel {
  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.profileImage = '',
    this.preferences = '',
    DateTime? createdAt,
    this.favoriteTrips = const <String>[],
    this.badges = const <String>[],
    this.bio = '',
  }) : createdAt = createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String?,
      profileImage: json['profileImage'] as String? ?? '',
      preferences: json['preferences'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      favoriteTrips: List<String>.from(
        json['favoriteTrips'] as List<dynamic>? ?? const <dynamic>[],
      ),
      badges: List<String>.from(
        json['badges'] as List<dynamic>? ?? const <dynamic>[],
      ),
      bio: json['bio'] as String? ?? '',
    );
  }

  final String id;
  final String email;
  final String name;
  final String? phone;
  final String profileImage;
  final String preferences;
  final DateTime createdAt;
  final List<String> favoriteTrips;
  final List<String> badges;
  final String bio;

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
      'badges': badges,
      'bio': bio,
    };
  }
}
