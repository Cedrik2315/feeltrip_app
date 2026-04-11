class CreatorStatsModel {
  const CreatorStatsModel({
    required this.totalStories,
    required this.totalLikes,
    required this.totalComments,
    required this.monthlyActivity,
  });

  final int totalStories;
  final int totalLikes;
  final int totalComments;
  final List<int> monthlyActivity;
}
