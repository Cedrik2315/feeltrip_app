import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'user_profile_model.g.dart'; // Archivo que generará build_runner

@HiveType(typeId: 12)
class BadgeModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String label;
  @HiveField(2)
  final String description;
  
  // No guardamos IconData en Hive porque es un objeto complejo de Flutter.
  // Guardamos el codePoint (int) para reconstruirlo.
  @HiveField(3)
  final int iconCodePoint;
  
  @HiveField(4)
  final bool isUnlocked;

  const BadgeModel({
    required this.id,
    required this.label,
    required this.description,
    required this.iconCodePoint,
    this.isUnlocked = false,
  });

  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  BadgeModel copyWith({bool? isUnlocked}) {
    return BadgeModel(
      id: id,
      label: label,
      description: description,
      iconCodePoint: iconCodePoint,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}

@HiveType(typeId: 13)
class UserProfile {
  @HiveField(0)
  final String uid;
  @HiveField(1)
  final String username;
  @HiveField(2)
  final String rank;
  @HiveField(3)
  final double experienceProgress;
  @HiveField(4)
  final String? profileImageUrl;
  @HiveField(5)
  final int totalKm;
  @HiveField(6)
  final int photosAnalyzed;
  @HiveField(7)
  final int daysActive;
  @HiveField(8)
  final Map<String, double> emotionalStats;
  @HiveField(9)
  final List<BadgeModel> badges;

  const UserProfile({
    required this.uid,
    required this.username,
    required this.rank,
    required this.experienceProgress,
    this.profileImageUrl,
    required this.totalKm,
    required this.photosAnalyzed,
    required this.daysActive,
    required this.emotionalStats,
    required this.badges,
  });

  factory UserProfile.empty(String uid, String username) {
    return UserProfile(
      uid: uid,
      username: username,
      rank: 'RECRUIT',
      experienceProgress: 0.1,
      totalKm: 0,
      photosAnalyzed: 0,
      daysActive: 1,
      emotionalStats: {
        'Calma': 0.2, 'Adrenalina': 0.2, 'Asombro': 0.2, 'Euforia': 0.2, 'Nostalgia': 0.2,
      },
      badges: [],
    );
  }

  UserProfile copyWith({
    String? username,
    String? rank,
    double? experienceProgress,
    int? totalKm,
    int? photosAnalyzed,
    int? daysActive,
    Map<String, double>? emotionalStats,
    List<BadgeModel>? badges,
  }) {
    return UserProfile(
      uid: uid,
      username: username ?? this.username,
      rank: rank ?? this.rank,
      experienceProgress: experienceProgress ?? this.experienceProgress,
      totalKm: totalKm ?? this.totalKm,
      photosAnalyzed: photosAnalyzed ?? this.photosAnalyzed,
      daysActive: daysActive ?? this.daysActive,
      emotionalStats: emotionalStats ?? this.emotionalStats,
      badges: badges ?? this.badges,
      profileImageUrl: profileImageUrl,
    );
  }
}