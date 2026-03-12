import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Comment {
  final String id;
  final String storyId;
  final String userId;
  final String userName;
  final String userAvatar;
  final String content;
  final List<String> reactions;
  final int likes;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.storyId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.content,
    required this.reactions,
    required this.likes,
    required this.createdAt,
  });

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      storyId: data['storyId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userAvatar: data['userAvatar'] ?? '',
      content: data['content'] ?? '',
      reactions: List<String>.from(data['reactions'] ?? []),
      likes: data['likes'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'storyId': storyId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'content': content,
      'reactions': reactions,
      'likes': likes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Comment copyWith({
    String? id,
    String? storyId,
    String? userId,
    String? userName,
    String? userAvatar,
    String? content,
    List<String>? reactions,
    int? likes,
    DateTime? createdAt,
  }) {
    return Comment(
      id: id ?? this.id,
      storyId: storyId ?? this.storyId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      content: content ?? this.content,
      reactions: reactions ?? this.reactions,
      likes: likes ?? this.likes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'Comment(\$id, \$content) by \$userName';
}