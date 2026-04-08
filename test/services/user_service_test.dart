import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:feeltrip_app/services/user_service.dart';

void main() {
  group('UserService', () {
    late FakeFirebaseFirestore firestore;
    late UserService service;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      service = UserService(firestore: firestore);
    });

    test('followUser creates following and follower documents', () async {
      await service.followUser('user_a', 'user_b');

      final following = await firestore
          .collection('users')
          .doc('user_a')
          .collection('following')
          .doc('user_b')
          .get();
      final follower = await firestore
          .collection('users')
          .doc('user_b')
          .collection('followers')
          .doc('user_a')
          .get();

      expect(following.exists, true);
      expect(follower.exists, true);
      expect(await service.isFollowing('user_a', 'user_b'), true);
    });

    test('unfollowUser removes following and follower documents', () async {
      await service.followUser('user_a', 'user_b');
      await service.unfollowUser('user_a', 'user_b');

      final following = await firestore
          .collection('users')
          .doc('user_a')
          .collection('following')
          .doc('user_b')
          .get();
      final follower = await firestore
          .collection('users')
          .doc('user_b')
          .collection('followers')
          .doc('user_a')
          .get();

      expect(following.exists, false);
      expect(follower.exists, false);
      expect(await service.isFollowing('user_a', 'user_b'), false);
    });
  });
}
