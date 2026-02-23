class Trip {
  final String id;
  final String title;
  final String description;
  final String destination;
  final String country;
  final double price;
  final double rating;
  final int reviews;
  final int duration;
  final String difficulty;
  final List<String> images;
  final List<String> highlights;
  final DateTime startDate;
  final DateTime endDate;
  final int maxParticipants;
  final int currentParticipants;
  final String category;
  final List<String> amenities;
  final String guide;
  final bool isFeatured;
  // Vivenciales
  final String experienceType;
  final List<String> emotions;
  final List<String> learnings;
  final String transformationMessage;
  final List<String> culturalConnections;
  final bool isTransformative;

  Trip({
    required this.id,
    required this.title,
    required this.description,
    required this.destination,
    required this.country,
    required this.price,
    this.rating = 0.0,
    this.reviews = 0,
    required this.duration,
    required this.difficulty,
    required this.images,
    required this.highlights,
    required this.startDate,
    required this.endDate,
    required this.maxParticipants,
    this.currentParticipants = 0,
    required this.category,
    this.amenities = const [],
    required this.guide,
    this.isFeatured = false,
    this.experienceType = '',
    this.emotions = const [],
    this.learnings = const [],
    this.transformationMessage = '',
    this.culturalConnections = const [],
    this.isTransformative = false,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      destination: json['destination'] ?? '',
      country: json['country'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      rating: (json['rating'] ?? 0).toDouble(),
      reviews: json['reviews'] ?? 0,
      duration: json['duration'] ?? 0,
      difficulty: json['difficulty'] ?? 'Moderado',
      images: List<String>.from(json['images'] ?? []),
      highlights: List<String>.from(json['highlights'] ?? []),
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : DateTime.now(),
      maxParticipants: json['maxParticipants'] ?? 0,
      currentParticipants: json['currentParticipants'] ?? 0,
      category: json['category'] ?? '',
      amenities: List<String>.from(json['amenities'] ?? []),
      guide: json['guide'] ?? '',
      isFeatured: json['isFeatured'] ?? false,
      experienceType: json['experienceType'] ?? '',
      emotions: List<String>.from(json['emotions'] ?? []),
      learnings: List<String>.from(json['learnings'] ?? []),
      transformationMessage: json['transformationMessage'] ?? '',
      culturalConnections: List<String>.from(json['culturalConnections'] ?? []),
      isTransformative: json['isTransformative'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'destination': destination,
      'country': country,
      'price': price,
      'rating': rating,
      'reviews': reviews,
      'duration': duration,
      'difficulty': difficulty,
      'images': images,
      'highlights': highlights,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'maxParticipants': maxParticipants,
      'currentParticipants': currentParticipants,
      'category': category,
      'amenities': amenities,
      'guide': guide,
      'isFeatured': isFeatured,
      'experienceType': experienceType,
      'emotions': emotions,
      'learnings': learnings,
      'transformationMessage': transformationMessage,
      'culturalConnections': culturalConnections,
      'isTransformative': isTransformative,
      'guide': guide,
      'isFeatured': isFeatured,
    };
  }
}
