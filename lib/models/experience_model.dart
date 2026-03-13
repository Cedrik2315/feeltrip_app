import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
    this.id = '',
    this.name = '',
    this.emoji = '',
    this.description = '',
    this.keywords = const [],
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
    this.id = '',
    this.tripId = '',
    this.emotions = const [],
    this.learnings = const [],
    this.transformationStory = '',
    this.impactScore = 0,
    this.connectedWith = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

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

class ParadaViaje {
  String nombre;
  LatLng posicion;
  String? descripcion;
  String? imagePath; // Ruta local de la foto tomada

  ParadaViaje({
    required this.nombre,
    required this.posicion,
    this.descripcion,
    this.imagePath,
  });
}

class TravelerStory {
  final String id;
  final String userId;
  final String author;
  final String title;
  final String story;
  final String? destination;
  final List<String> emotionalHighlights;
  final double rating;
  int likes;
  final DateTime createdAt;
  final String? imageUrl;

  TravelerStory({
    this.id = '',
    this.userId = '',
    this.author = '',
    this.title = '',
    this.story = '',
    this.destination,
    this.emotionalHighlights = const [],
    this.rating = 0.0,
    this.likes = 0,
    DateTime? createdAt,
    this.imageUrl,
  }) : createdAt = createdAt ?? DateTime.now();

  factory TravelerStory.fromJson(Map<String, dynamic> json) {
    return TravelerStory(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      author: json['author'] ?? '',
      title: json['title'] ?? '',
      story: json['story'] ?? '',
      destination: json['destination'] as String?,
      emotionalHighlights: List<String>.from(json['emotionalHighlights'] ?? []),
      rating: (json['rating'] ?? 0).toDouble(),
      likes: json['likes'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      imageUrl: json['imageUrl'],
    );
  }

  factory TravelerStory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TravelerStory(
      id: data['id'] ?? doc.id,
      userId: data['userId'] ?? '',
      author: data['author'] ?? '',
      title: data['title'] ?? '',
      story: data['story'] ?? '',
      destination: data['destination'] as String?,
      emotionalHighlights: List<String>.from(data['emotionalHighlights'] ?? []),
      rating: (data['rating'] ?? 0).toDouble(),
      likes: data['likes'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'author': author,
      'title': title,
      'story': story,
      'destination': destination,
      'emotionalHighlights': emotionalHighlights,
      'rating': rating,
      'likes': likes,
      'createdAt': createdAt.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }

  Map<String, dynamic> toFirestore() {
    final map = {
      'id': id,
      'userId': userId,
      'author': author,
      'title': title,
      'story': story,
      'emotionalHighlights': emotionalHighlights,
      'rating': rating,
      'likes': likes,
      'createdAt': createdAt,
      'imageUrl': imageUrl,
    };
    if (destination != null) {
      map['destination'] = destination;
    }
    return map;
  }
}

class DiaryEntry {
  final String id;
  final String userId;
  final String imageUrl;
  final String title;
  final String content; // Texto generado por IA o escrito
  final List<String>
      emotions; // Lista de emociones: Ej: ["Nostalgia", "Asombro"]
  final int reflectionDepth; // Profundidad de reflexión (1-5)
  final DateTime createdAt;

  DiaryEntry({
    this.id = '',
    required this.userId,
    required this.imageUrl,
    required this.title,
    required this.content,
    required this.emotions,
    this.reflectionDepth = 3,
    required this.createdAt,
  });

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      emotions: List<String>.from(json['emotions'] ?? []),
      reflectionDepth: json['reflectionDepth'] ?? 3,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  factory DiaryEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DiaryEntry(
      id: data['id'] ?? doc.id,
      userId: data['userId'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      emotions: List<String>.from(data['emotions'] ?? []),
      reflectionDepth: data['reflectionDepth'] ?? 3,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ??
          (data['createdAt'] is String
              ? DateTime.parse(data['createdAt'])
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'imageUrl': imageUrl,
      'title': title,
      'content': content,
      'emotions': emotions,
      'reflectionDepth': reflectionDepth,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Convertir a Map para guardar en Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'imageUrl': imageUrl,
      'title': title,
      'content': content,
      'emotions': emotions,
      'reflectionDepth': reflectionDepth,
      'createdAt': createdAt,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'imageUrl': imageUrl,
      'title': title,
      'content': content,
      'emotions': emotions,
      'reflectionDepth': reflectionDepth,
      'createdAt': createdAt,
    };
  }
}
