import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String storyId;
  final String userId;
  final String userName;
  final String userAvatar;
  final String content;
  final List<String> reactions; // ['❤️', '😂', '🔥', etc]
  final DateTime createdAt;
  final int likes;

  Comment({
    required this.id,
    required this.storyId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.content,
    required this.reactions,
    required this.createdAt,
    required this.likes,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? '',
      storyId: json['storyId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? 'Usuario',
      userAvatar: json['userAvatar'] ?? '',
      content: json['content'] ?? '',
      reactions: List<String>.from(json['reactions'] ?? []),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      likes: json['likes'] ?? 0,
    );
  }

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: data['id'] ?? doc.id,
      storyId: data['storyId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Usuario',
      userAvatar: data['userAvatar'] ?? '',
      content: data['content'] ?? '',
      reactions: List<String>.from(data['reactions'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likes: data['likes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storyId': storyId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'content': content,
      'reactions': reactions,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'storyId': storyId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'content': content,
      'reactions': reactions,
      'createdAt': Timestamp.fromDate(createdAt),
      'likes': likes,
    };
  }
}
