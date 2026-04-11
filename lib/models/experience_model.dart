import 'package:cloud_firestore/cloud_firestore.dart';

class TravelerStory {
  TravelerStory({
    required this.id,
    required this.author,
    required this.title,
    required this.story,
    required this.emotionalHighlights,
    required this.likes,
    required this.rating,
    required this.createdAt,
    this.imageUrl = '',
    this.likedBy = const [],
    this.reaction = '',
    this.agencyId,
  });

  factory TravelerStory.fromJson(Map<String, dynamic> json) {
    return TravelerStory(
      id: json['id'] as String? ?? '',
      author: json['author'] as String? ?? '',
      title: json['title'] as String? ?? '',
      story: json['story'] as String? ?? '',
      emotionalHighlights: List<String>.from(
          json['emotionalHighlights'] as Iterable<dynamic>? ?? []),
      likes: json['likes'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] as String? ?? '',
      likedBy: List<String>.from(json['likedBy'] as Iterable<dynamic>? ?? []),
      reaction: json['reaction'] as String? ?? '',
      agencyId: json['agencyId'] as String?,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
              DateTime.now(),
    );
  }

  factory TravelerStory.fromFirestore(DocumentSnapshot doc) {
    final data = Map<String, dynamic>.from(doc.data() as Map? ?? {});
    data['id'] = doc.id;
    return TravelerStory.fromJson(data);
  }

  final String id;
  final String author;
  final String title;
  final String story;
  final List<String> emotionalHighlights;
  final int likes;
  final double rating;
  final String imageUrl;
  final List<String> likedBy;
  final String reaction;
  final String? agencyId;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author,
      'title': title,
      'story': story,
      'emotionalHighlights': emotionalHighlights,
      'likes': likes,
      'rating': rating,
      'imageUrl': imageUrl,
      'likedBy': likedBy,
      'reaction': reaction,
      'agencyId': agencyId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class DiaryEntry {
  DiaryEntry({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.emotions,
    required this.createdAt,
    this.photoUrls = const [],
    this.reflectionDepth = 0,
    this.tags = const [],
  });

  factory DiaryEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return DiaryEntry(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',
      emotions: List<String>.from(data['emotions'] as Iterable<dynamic>? ?? []),
      photoUrls:
          List<String>.from(data['photoUrls'] as Iterable<dynamic>? ?? []),
      reflectionDepth: data['reflectionDepth'] as int? ?? 0,
      tags: List<String>.from(data['tags'] as Iterable<dynamic>? ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      emotions:
          List<String>.from(json['emotions'] as Iterable<dynamic>? ?? []),
      photoUrls:
          List<String>.from(json['photoUrls'] as Iterable<dynamic>? ?? []),
      reflectionDepth: json['reflectionDepth'] as int? ?? 0,
      tags: List<String>.from(json['tags'] as Iterable<dynamic>? ?? []),
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  final String id;
  final String userId;
  final String title;
  final String content;
  final List<String> emotions;
  final List<String> photoUrls;
  final int reflectionDepth;
  final List<String> tags;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'emotions': emotions,
      'photoUrls': photoUrls,
      'reflectionDepth': reflectionDepth,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  DiaryEntry copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    List<String>? emotions,
    List<String>? photoUrls,
    int? reflectionDepth,
    List<String>? tags,
    DateTime? createdAt,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      emotions: emotions ?? this.emotions,
      photoUrls: photoUrls ?? this.photoUrls,
      reflectionDepth: reflectionDepth ?? this.reflectionDepth,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}