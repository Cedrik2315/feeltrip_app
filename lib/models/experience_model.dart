import 'package:cloud_firestore/cloud_firestore.dart';

class TravelerStory {

  const TravelerStory({
    required this.id,
    required this.userId,
    required this.destination,
    required this.title,
    required this.story,
    required this.emotionalHighlights,
    required this.tags,
    required this.rating,
    required this.likes,
    required this.likedBy,
    required this.reaction,
    required this.createdAt,
    this.imageUrl,
  });

  factory TravelerStory.fromJson(Map<String, dynamic> json) {
    return TravelerStory(
      id: (json['id'] as String?) ?? '',
      userId: (json['userId'] as String?) ?? '',
      destination: (json['destination'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      story: (json['story'] as String?) ?? '',
      emotionalHighlights: List<String>.from((json['emotionalHighlights'] as List<dynamic>?) ?? []),
      tags: List<String>.from((json['tags'] as List<dynamic>?) ?? []),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      likes: (json['likes'] as int?) ?? 0,
      likedBy: List<String>.from((json['likedBy'] as List<dynamic>?) ?? []),
      reaction: (json['reaction'] as String?) ?? '',
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse((json['createdAt'] as String?) ?? '') ?? DateTime.now(),
      imageUrl: json['imageUrl'] as String?,
    );
  }
  final String id;
  final String userId;
  final String destination;
  final String title;
  final String story;
  final List<String> emotionalHighlights;
  final List<String> tags;
  final double rating;
  final int likes;
  final List<String> likedBy;
  final String reaction;
  final DateTime createdAt;
  final String? imageUrl;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'destination': destination,
      'title': title,
      'story': story,
      'emotionalHighlights': emotionalHighlights,
      'tags': tags,
      'rating': rating,
      'likes': likes,
      'likedBy': likedBy,
      'reaction': reaction,
      'createdAt': createdAt.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }
}

class DiaryEntry {

  const DiaryEntry({
    required this.id,
    required this.tripId,
    required this.userId,
    required this.location,
    required this.content,
    required this.emotions,
    required this.photos,
    required this.reflectionDepth,
    required this.createdAt,
  });

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: (json['id'] as String?) ?? '',
      tripId: (json['tripId'] as String?) ?? '',
      userId: (json['userId'] as String?) ?? '',
      location: (json['location'] as String?) ?? '',
      content: (json['content'] as String?) ?? '',
      emotions: List<String>.from((json['emotions'] as List<dynamic>?) ?? []),
      photos: List<String>.from((json['photos'] as List<dynamic>?) ?? []),
      reflectionDepth: (json['reflectionDepth'] as int?) ?? 3,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse((json['createdAt'] as String?) ?? '') ?? DateTime.now(),
    );
  }
  final String id;
  final String tripId;
  final String userId;
  final String location;
  final String content;
  final List<String> emotions;
  final List<String> photos;
  final int reflectionDepth;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tripId': tripId,
      'userId': userId,
      'location': location,
      'content': content,
      'emotions': emotions,
      'photos': photos,
      'reflectionDepth': reflectionDepth,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

