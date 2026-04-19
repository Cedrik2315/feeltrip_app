import 'package:cloud_firestore/cloud_firestore.dart';

class InstagramStory {
  InstagramStory({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.createdAt,
    required this.expiresAt,
  });

  factory InstagramStory.fromJson(Map<String, dynamic> json) {
    return InstagramStory(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
              DateTime.now(),
      expiresAt: json['expiresAt'] is Timestamp
          ? (json['expiresAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['expiresAt']?.toString() ?? '') ??
              DateTime.now().add(const Duration(hours: 24)),
    );
  }

  final String id;
  final String userId;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime expiresAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
    };
  }
}
