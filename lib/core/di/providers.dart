import 'package:feeltrip_app/core/router/app_router.dart';
import 'package:feeltrip_app/models/notification_model.dart';
import 'package:feeltrip_app/services/notification_service.dart';
import 'package:feeltrip_app/services/revenuecat_service.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
GoRouter router(RouterRef ref) {
  return createAppRouter(ref);
}

final revenueCatServiceProvider = Provider<RevenueCatService>((ref) {
  return RevenueCatService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// Notifications provider for screen
final notificationProvider =
    FutureProvider.family<List<NotificationModel>, String>((ref, userId) async {
  final service = ref.watch(notificationServiceProvider);
  return service.getNotifications(userId);
});

// OSINT service commented out - pending proper implementation
// final osintAiServiceProvider = Provider<OsintAiService>((ref) {
//   return OsintAiService();
// });

// SharingService is static, no provider needed
