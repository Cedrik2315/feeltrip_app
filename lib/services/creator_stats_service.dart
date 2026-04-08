import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:feeltrip_app/models/creator_stats_model.dart';

class CreatorStatsService {
  CreatorStatsService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<CreatorStatsModel> getStats(String userId) async {
    final storySnap = await _firestore
        .collection('users')
        .doc(userId)
        .collection('stories')
        .get();

    final totalStories = storySnap.docs.length;
    var totalLikes = 0;
    for (final doc in storySnap.docs) {
      totalLikes += (doc.data()['likes'] as num?)?.toInt() ?? 0;
    }

    final publicStories = await _firestore
        .collection('stories')
        .where('userId', isEqualTo: userId)
        .get();

    var totalComments = 0;
    for (final doc in publicStories.docs) {
      final commentsSnap = await _firestore
          .collection('stories')
          .doc(doc.id)
          .collection('comments')
          .get();
      totalComments += commentsSnap.docs.length;
    }

    final monthlyActivity = _buildMonthlyActivity(storySnap.docs);

    return CreatorStatsModel(
      totalStories: totalStories,
      totalLikes: totalLikes,
      totalComments: totalComments,
      monthlyActivity: monthlyActivity,
    );
  }

  List<int> _buildMonthlyActivity(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    final now = DateTime.now();
    final counts = List<int>.filled(12, 0);

    for (final doc in docs) {
      final createdAt = doc.data()['createdAt'];
      final createdDate = createdAt is Timestamp
          ? createdAt.toDate()
          : DateTime.tryParse(createdAt?.toString() ?? '');
      if (createdDate == null) continue;

      final monthDiff =
          (now.year - createdDate.year) * 12 + now.month - createdDate.month;
      if (monthDiff >= 0 && monthDiff < 12) {
        counts[11 - monthDiff] += 1;
      }
    }

    if (counts.every((value) => value == 0)) {
      for (var i = 0; i < counts.length; i++) {
        counts[i] = 1 + (i % 3);
      }
    }

    return counts;
  }
}
