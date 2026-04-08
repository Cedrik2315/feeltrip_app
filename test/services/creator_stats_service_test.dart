import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:feeltrip_app/services/creator_stats_service.dart';

void main() {
  group('CreatorStatsService', () {
    late FakeFirebaseFirestore firestore;
    late CreatorStatsService service;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      service = CreatorStatsService(firestore: firestore);
    });

    test('aggregates stories, likes and comments for a creator', () async {
      final now = DateTime.now();

      await firestore
          .collection('users')
          .doc('creator_1')
          .collection('stories')
          .doc('story_1')
          .set({
        'likes': 3,
        'createdAt': Timestamp.fromDate(now),
      });
      await firestore
          .collection('users')
          .doc('creator_1')
          .collection('stories')
          .doc('story_2')
          .set({
        'likes': 5,
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 40))),
      });

      await firestore.collection('stories').doc('story_1').set({
        'userId': 'creator_1',
      });
      await firestore.collection('stories').doc('story_2').set({
        'userId': 'creator_1',
      });
      await firestore
          .collection('stories')
          .doc('story_1')
          .collection('comments')
          .add({'text': 'uno'});
      await firestore
          .collection('stories')
          .doc('story_1')
          .collection('comments')
          .add({'text': 'dos'});
      await firestore
          .collection('stories')
          .doc('story_2')
          .collection('comments')
          .add({'text': 'tres'});

      final stats = await service.getStats('creator_1');

      expect(stats.totalStories, 2);
      expect(stats.totalLikes, 8);
      expect(stats.totalComments, 3);
      expect(stats.monthlyActivity.length, 12);
      expect(stats.monthlyActivity.reduce((a, b) => a + b) >= 2, true);
    });
  });
}
