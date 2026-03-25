class InstagramStory {
  InstagramStory({
    required this.id,
    required this.imageUrl,
    required this.authorName,
    required this.authorAvatar,
    required this.createdAt,
    this.seen = false,
  });

  factory InstagramStory.fromJson(Map<String, dynamic> json) {
    return InstagramStory(
      id: json['id'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      authorName: json['authorName'] as String? ?? '',
      authorAvatar: json['authorAvatar'] as String? ?? '',
      seen: json['seen'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  final String id;
  final String imageUrl;
  final String authorName;
  final String authorAvatar;
  final bool seen;
  final DateTime createdAt;
}