class Momento {
  const Momento({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.photoUrl,
    this.latitude,
    this.longitude,
    required this.createdAt,
    this.isSynced = false,
  });

  factory Momento.fromJson(Map<String, dynamic> json) => Momento(
        id: json['id'] as String? ?? '',
        userId: json['userId'] as String? ?? '',
        title: json['title'] as String? ?? '',
        description: json['description'] as String?,
        photoUrl: json['photoUrl'] as String?,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
            DateTime.now(),
        isSynced: json['isSynced'] as bool? ?? false,
      );
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String? photoUrl;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final bool isSynced;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'description': description,
        'photoUrl': photoUrl,
        'latitude': latitude,
        'longitude': longitude,
        'createdAt': createdAt.toIso8601String(),
        'isSynced': isSynced,
      };
}
