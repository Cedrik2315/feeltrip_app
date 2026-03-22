import 'package:cloud_firestore/cloud_firestore.dart';

class InstagramStory {
  InstagramStory({
    required this.id,
    required this.userId,
    required this.userName,
    required this.imageUrl,
    required this.destination,
    required this.expiresAt,
  });

  factory InstagramStory.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return InstagramStory(
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
