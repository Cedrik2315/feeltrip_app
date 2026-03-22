import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

enum ExperienceTypeEnum {
  adventure,
  connection,
  reflection,
  nature,
  culturalImmersion
}

@immutable
class ExperienceType {
  const ExperienceType({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.keywords,
  });
  final String id;
  final String name;
  final String emoji;
  final String description;
  final List<String> keywords;
}

@immutable
class ExperienceImpact {
  const ExperienceImpact({
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
      id: json['id'] as String? ?? '',
      tripId: json['tripId'] as String? ?? '',
      emotions: List<String>.from(json['emotions'] as List<dynamic>? ?? []),
      learnings: List<String>.from(json['learnings'] as List<dynamic>? ?? []),
      transformationStory: json['transformationStory'] as String? ?? '',
      impactScore: json['impactScore'] as int? ?? 0,
      connectedWith:
          List<String>.from(json['connectedWith'] as List<dynamic>? ?? []),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  factory ExperienceImpact.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ExperienceImpact(
      id: data['id'] as String? ?? doc.id,
      tripId: data['tripId'] as String? ?? '',
      emotions: List<String>.from(data['emotions'] as List<dynamic>? ?? []),
      learnings: List<String>.from(data['learnings'] as List<dynamic>? ?? []),
      transformationStory: data['transformationStory'] as String? ?? '',
      impactScore: data['impactScore'] as int? ?? 0,
      connectedWith:
          List<String>.from(data['connectedWith'] as List<dynamic>? ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
  final String id;
  final String tripId;
  final List<String> emotions;
  final List<String> learnings;
  final String transformationStory;
  final int impactScore;
  final List<String> connectedWith;
  final DateTime createdAt;

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

@immutable
class TravelerStory {
  const TravelerStory({
    required this.id,
    required this.author,
    required this.title,
    required this.story,
    required this.emotionalHighlights,
    required this.rating,
    required this.likes,
    required this.createdAt,
    this.tags = const [],
    this.likedBy = const [],
    this.reaction = '',
  });

  factory TravelerStory.fromJson(Map<String, dynamic> json) {
    return TravelerStory(
      id: json['id'] as String? ?? '',
      author: json['author'] as String? ?? '',
      title: json['title'] as String? ?? '',
      story: json['story'] as String? ?? '',
      emotionalHighlights: List<String>.from(
        json['emotionalHighlights'] as List<dynamic>? ?? [],
      ),
      tags: List<String>.from(json['tags'] as List<dynamic>? ?? []),
      rating: (json['rating'] as num? ?? 0).toDouble(),
      likes: json['likes'] as int? ?? 0,
      likedBy: List<String>.from(json['likedBy'] as List<dynamic>? ?? []),
      reaction: json['reaction'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  factory TravelerStory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TravelerStory(
      id: data['id'] as String? ?? doc.id,
      author: data['author'] as String? ?? '',
      title: data['title'] as String? ?? '',
      story: data['story'] as String? ?? '',
      emotionalHighlights: List<String>.from(
        data['emotionalHighlights'] as List<dynamic>? ?? [],
      ),
      tags: List<String>.from(data['tags'] as List<dynamic>? ?? []),
      rating: (data['rating'] as num? ?? 0).toDouble(),
      likes: data['likes'] as int? ?? 0,
      likedBy: List<String>.from(data['likedBy'] as List<dynamic>? ?? []),
      reaction: data['reaction'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
  final String id;
  final String author;
  final String title;
  final String story;
  final List<String> emotionalHighlights;
  final List<String> tags;
  final double rating;
  final int likes;
  final List<String> likedBy;
  final String reaction;
  final DateTime createdAt;

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

@immutable
class DiaryEntry {
  const DiaryEntry({
    required this.id,
    required this.tripId,
    required this.userId,
    required this.location,
    required this.content,
    required this.emotions,
    required this.reflectionDepth,
    required this.createdAt,
    this.photos = const [],
  });

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['id'] as String? ?? '',
      tripId: json['tripId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      location: json['location'] as String? ?? '',
      content: json['content'] as String? ?? '',
      emotions: List<String>.from(json['emotions'] as List<dynamic>? ?? []),
      photos: List<String>.from(json['photos'] as List<dynamic>? ?? []),
      reflectionDepth: json['reflectionDepth'] as int? ?? 1,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  factory DiaryEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return DiaryEntry(
      id: data['id'] as String? ?? doc.id,
      tripId: data['tripId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      location: data['location'] as String? ?? '',
      content: data['content'] as String? ?? '',
      emotions: List<String>.from(data['emotions'] as List<dynamic>? ?? []),
      photos: List<String>.from(data['photos'] as List<dynamic>? ?? []),
      reflectionDepth: data['reflectionDepth'] as int? ?? 1,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
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

/// Estado inmutable para el controlador de experiencias con Riverpod.
@immutable
class ExperienceState {
  const ExperienceState({
    this.stories = const [],
    this.diaryEntries = const [],
    this.diaryStats = const {},
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  final List<TravelerStory> stories;
  final List<DiaryEntry> diaryEntries;
  final Map<String, dynamic> diaryStats;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  ExperienceState copyWith({
    List<TravelerStory>? stories,
    List<DiaryEntry>? diaryEntries,
    Map<String, dynamic>? diaryStats,
    bool? isLoading,
    // Permite establecer el error a null
    String? Function()? errorMessage,
    String? Function()? successMessage,
  }) {
    return ExperienceState(
      stories: stories ?? this.stories,
      diaryEntries: diaryEntries ?? this.diaryEntries,
      diaryStats: diaryStats ?? this.diaryStats,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      successMessage:
          successMessage != null ? successMessage() : this.successMessage,
    );
  }
}
