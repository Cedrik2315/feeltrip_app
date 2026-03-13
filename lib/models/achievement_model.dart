class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final DateTime dateUnlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.dateUnlocked,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'iconName': iconName,
        'dateUnlocked': dateUnlocked.toIso8601String(),
      };
}
