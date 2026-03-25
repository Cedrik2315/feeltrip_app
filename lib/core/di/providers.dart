import 'package:feeltrip_app/app_router.dart';
import 'package:feeltrip_app/services/osint_ai_service.dart';
import 'package:feeltrip_app/models/notification_model.dart';
import 'package:feeltrip_app/services/notification_service.dart';
import 'package:feeltrip_app/services/revenuecat_service.dart';
import 'package:feeltrip_app/services/comment_service.dart';
import 'package:feeltrip_app/services/agency_service.dart';
import 'package:feeltrip_app/models/comment_model.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:feeltrip_app/services/vision_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

final osintAiServiceProvider =
    StateNotifierProvider<OsintAiService, OsintState>((ref) {
  return OsintAiService(ref);
});

// NEW: Comment providers for unified realtime system
final commentServiceProvider = Provider<CommentService>((ref) {
  return CommentService();
});

final commentProvider =
    StreamProvider.family<List<Comment>, String>((ref, storyId) {
  final service = ref.watch(commentServiceProvider);
  return service.getCommentsStream(storyId);
});

// NEW: Agency service for verified badge
final agencyServiceProvider = Provider<AgencyService>((ref) {
  return AgencyService();
});

// SharingService is static, no provider needed
final visionServiceProvider =
    StateNotifierProvider<VisionService, VisionState>((ref) {
  return VisionService();
});
