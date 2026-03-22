import 'package:cloud_firestore/cloud_firestore.dart';

class Story {
  Story({
    required this.id,
    required this.userId,
    required this.userName,
    required this.imageUrl,
    required this.destination,
    required this.expiresAt,
  });

  factory Story.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return Story(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? 'Unknown',
      imageUrl: data['imageUrl'] as String? ?? '',
      destination: data['destination'] as String? ?? '',
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
  final String id;
  final String userId;
  final String userName;
  final String imageUrl;
  final String destination;
  final DateTime expiresAt;
}
