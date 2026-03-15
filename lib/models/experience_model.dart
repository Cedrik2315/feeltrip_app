import 'package:cloud_firestore/cloud_firestore.dart';

enum ExperienceTypeEnum {
  adventure,
  connection,
  reflection,
  nature,
  culturalImmersion
}

class ExperienceType {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final List<String> keywords;

  ExperienceType({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.keywords,
  });
}

class ExperienceImpact {
  final String id;
  final String tripId;
  final List<String> emotions;
  final List<String> learnings;
  final String transformationStory;
  final int impactScore;
  final List<String> connectedWith;
  final DateTime createdAt;

  ExperienceImpact({
    required this.id,
    required this.tripId,
    required this.emotions,
    required this.learnings,
    required this.transformationStory,
    required this.impactScore,
    required this.connectedWith,
    required this.createdAt,
  });

  factory ExperienceImpact.fromJson(Map<String, dynamic> json) {
    return ExperienceImpact(
      id: json['id'] ?? '',
      tripId: json['tripId'] ?? '',
      emotions: List<String>.from(json['emotions'] ?? []),
      learnings: List<String>.from(json['learnings'] ?? []),
      transformationStory: json['transformationStory'] ?? '',
      impactScore: json['impactScore'] ?? 0,
      connectedWith: List<String>.from(json['connectedWith'] ?? []),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  factory ExperienceImpact.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExperienceImpact(
      id: data['id'] ?? doc.id,
      tripId: data['tripId'] ?? '',
      emotions: List<String>.from(data['emotions'] ?? []),
      learnings: List<String>.from(data['learnings'] ?? []),
      transformationStory: data['transformationStory'] ?? '',
      impactScore: data['impactScore'] ?? 0,
      connectedWith: List<String>.from(data['connectedWith'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'emotions': emotions,
      'learnings': learnings,
      'transformationStory': transformationStory,
      'impactScore': impactScore,
      'connectedWith': connectedWith,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'tripId': tripId,
      'emotions': emotions,
      'learnings': learnings,
      'transformationStory': transformationStory,
      'impactScore': impactScore,
      'connectedWith': connectedWith,
      'createdAt': createdAt,
    };
  }
}

class TravelerStory {
  final String id;
  final String author;
  final String title;
  final String story;
  final List<String> emotionalHighlights;
  final List<String> tags;
  final double rating;
  int likes;
  List<String> likedBy;
  String reaction;
  final DateTime createdAt;

  TravelerStory({
    required this.id,
    required this.author,
    required this.title,
    required this.story,
    required this.emotionalHighlights,
    this.tags = const [],
    required this.rating,
    required this.likes,
    this.likedBy = const [],
    this.reaction = '',
    required this.createdAt,
  });

  factory TravelerStory.fromJson(Map<String, dynamic> json) {
    return TravelerStory(
      id: json['id'] ?? '',
      author: json['author'] ?? '',
      title: json['title'] ?? '',
      story: json['story'] ?? '',
      emotionalHighlights: List<String>.from(json['emotionalHighlights'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      rating: (json['rating'] ?? 0).toDouble(),
      likes: json['likes'] ?? 0,
      likedBy: List<String>.from(json['likedBy'] ?? []),
      reaction: json['reaction'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  factory TravelerStory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TravelerStory(
      id: data['id'] ?? doc.id,
      author: data['author'] ?? '',
      title: data['title'] ?? '',
      story: data['story'] ?? '',
      emotionalHighlights: List<String>.from(data['emotionalHighlights'] ?? []),
      tags: List<String>.from(data['tags'] ?? []),
      rating: (data['rating'] ?? 0).toDouble(),
      likes: data['likes'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      reaction: data['reaction'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author,
      'title': title,
      'story': story,
      'emotionalHighlights': emotionalHighlights,
      'tags': tags,
      'rating': rating,
      'likes': likes,
      'likedBy': likedBy,
      'reaction': reaction,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'author': author,
      'title': title,
      'story': story,
      'emotionalHighlights': emotionalHighlights,
      'tags': tags,
      'rating': rating,
      'likes': likes,
      'likedBy': likedBy,
      'reaction': reaction,
      'createdAt': createdAt,
    };
  }
}

class DiaryEntry {
  final String id;
  final String location;
  final String content;
  final List<String> emotions;
  final List<String> photos;
  final int reflectionDepth;
  final DateTime createdAt;
  final String tripId;
  final String userId;

  DiaryEntry({
    required this.id,
    required this.tripId,
    required this.userId,
    required this.location,
    required this.content,
    required this.emotions,
    this.photos = const [],
    required this.reflectionDepth,
    required this.createdAt,
  });

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['id'] ?? '',
      tripId: json['tripId'] ?? '',
      userId: json['userId'] ?? '',
      location: json['location'] ?? '',
      content: json['content'] ?? '',
      emotions: List<String>.from(json['emotions'] ?? []),
      photos: List<String>.from(json['photos'] ?? []),
      reflectionDepth: json['reflectionDepth'] ?? 1,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  factory DiaryEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DiaryEntry(
      id: data['id'] ?? doc.id,
      tripId: data['tripId'] ?? '',
      userId: data['userId'] ?? '',
      location: data['location'] ?? '',
      content: data['content'] ?? '',
      emotions: List<String>.from(data['emotions'] ?? []),
      photos: List<String>.from(data['photos'] ?? []),
      reflectionDepth: data['reflectionDepth'] ?? 1,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
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

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'tripId': tripId,
      'userId': userId,
      'location': location,
      'content': content,
      'emotions': emotions,
      'photos': photos,
      'reflectionDepth': reflectionDepth,
      'createdAt': createdAt,
    };
  }
}
