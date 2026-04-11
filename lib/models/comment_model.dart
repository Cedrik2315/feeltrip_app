import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  Comment({
    required this.id,
    required this.storyId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.content,
    required this.reactions,
    required this.createdAt,
    this.likes = 0,
  });

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Comment(
      id: doc.id,
      storyId: data['storyId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? 'Anonymous',
      userAvatar: data['userAvatar'] as String? ?? '',
      content: data['content'] as String? ?? '',
      reactions: List<String>.from(data['reactions'] as Iterable<dynamic>? ?? []),
      likes: data['likes'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  final String id;
  final String storyId;
  final String userId;
  final String userName;
  final String userAvatar;
  final String content;
  final List<String> reactions;
  final int likes;
  final DateTime createdAt;

  Map<String, dynamic> toFirestore() {
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
}