import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:feeltrip_app/core/di/providers.dart' as di_providers;
import 'package:feeltrip_app/models/creator_stats_model.dart';
import 'package:feeltrip_app/models/notification_model.dart';
import 'package:feeltrip_app/services/creator_stats_service.dart';

final creatorStatsServiceProvider = Provider<CreatorStatsService>((ref) {
  return CreatorStatsService();
});

final creatorStatsProvider =
    FutureProvider.family<CreatorStatsModel, String>((ref, userId) async {
  return ref.watch(creatorStatsServiceProvider).getStats(userId);
});

final notificationsProvider =
    FutureProvider.family<List<NotificationModel>, String>((ref, userId) async {
  return ref
      .watch(di_providers.notificationServiceProvider)
      .getNotifications(userId: userId);
});

final unreadNotificationsCountProvider =
    FutureProvider.family<int, String>((ref, userId) async {
  return ref
      .watch(di_providers.notificationServiceProvider)
      .getUnreadCount(userId: userId);
});

