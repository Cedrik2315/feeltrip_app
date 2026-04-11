import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:feeltrip_app/services/user_service.dart';

final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

final followersProvider =
    StreamProvider.family<List<String>, String>((ref, userId) {
  return ref.watch(userServiceProvider).getFollowers(userId);
});

final followingProvider =
    StreamProvider.family<List<String>, String>((ref, userId) {
  return ref.watch(userServiceProvider).getFollowing(userId);
});

typedef FollowStatusArgs = ({String currentUserId, String targetUserId});

final isFollowingProvider =
    FutureProvider.family<bool, FollowStatusArgs>((ref, args) async {
  return ref.watch(userServiceProvider).isFollowing(
        args.currentUserId,
        args.targetUserId,
      );
});
