import 'package:cloud_firestore/cloud_firestore.dart';

class InstagramStory {
  final String id;
  final String userId;
  final String userName;
  final String imageUrl;
  final String destination;
  final DateTime expiresAt;

  InstagramStory({
    required this.id,
    required this.userId,
    required this.userName,
    required this.imageUrl,
    required this.destination,
    required this.expiresAt,
  });

  factory InstagramStory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InstagramStory(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Unknown',
      imageUrl: data['imageUrl'] ?? '',
      destination: data['destination'] ?? '',
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'imageUrl': imageUrl,
      'destination': destination,
      'expiresAt': Timestamp.fromDate(expiresAt),
    };
  }
}
