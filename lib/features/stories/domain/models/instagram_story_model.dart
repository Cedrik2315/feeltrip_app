import 'package:cloud_firestore/cloud_firestore.dart';

class InstagramStory {
  final String id;
  final String userId;
  final String mediaUrl;
  final String? thumbnailUrl;
  final int durationSeconds;
  final DateTime createdAt;

  InstagramStory({
    required this.id,
    required this.userId,
    required this.mediaUrl,
    this.thumbnailUrl,
    this.durationSeconds = 5,
    required this.createdAt,
  });

  factory InstagramStory.fromJson(Map<String, dynamic> json) {
    return InstagramStory(
      id: json['id'] as String,
      userId: json['userId'] as String,
      mediaUrl: json['mediaUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      durationSeconds: json['durationSeconds'] as int? ?? 5,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }
}