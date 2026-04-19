import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.actionId,
    this.actionType,
    this.isRead = false,
    this.createdAt,
    this.imageUrl,
    this.badgeCount,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      actionId: (json['actionId'] ?? json['storyId']) as String?,
      actionType: json['actionType'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      imageUrl: json['imageUrl'] as String?,
      badgeCount: json['badgeCount'] as int?,
    );
  }

  factory NotificationModel.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return NotificationModel.fromJson({
      ...data,
      'id': id,
    });
  }

  final String id;
  final String userId;
  final String type;
  final String title;
  final String body;
  final String? actionId;
  final String? actionType;
  final bool isRead;
  final DateTime? createdAt;
  final String? imageUrl;
  final int? badgeCount;

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type,
      'title': title,
      'body': body,
      'actionId': actionId,
      'actionType': actionType,
      'isRead': isRead,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'imageUrl': imageUrl,
      'badgeCount': badgeCount,
    };
  }
}
