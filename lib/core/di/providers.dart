import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:feeltrip_app/app_router.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';
import 'package:feeltrip_app/core/models/user_preferences.dart';
import 'package:feeltrip_app/models/comment_model.dart';
import 'package:feeltrip_app/models/notification_model.dart';
import 'package:feeltrip_app/models/vision_models.dart';
import 'package:feeltrip_app/services/agency_service.dart';
import 'package:feeltrip_app/services/comment_service.dart';
import 'package:feeltrip_app/services/location_service.dart';
import 'package:feeltrip_app/services/notification_service.dart';
import 'package:feeltrip_app/services/osint_ai_service.dart';
import 'package:feeltrip_app/services/revenuecat_service.dart';
import 'package:feeltrip_app/services/vision_service.dart';

export 'camera_providers.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
GoRouter router(RouterRef ref) {
  return createAppRouter(ref);
}

final userPreferencesProvider = StateProvider<UserPreferences>((ref) {
  return const UserPreferences();
});

final revenueCatServiceProvider = Provider<RevenueCatService>((ref) {
  return RevenueCatService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final notificationProvider =
    FutureProvider.family<List<NotificationModel>, String>((ref, userId) async {
  final service = ref.watch(notificationServiceProvider);
  return service.getNotifications(userId);
});

final osintAiServiceProvider =
    StateNotifierProvider<OsintAiService, OsintState>((ref) {
  return OsintAiService(ref);
});

final commentServiceProvider = Provider<CommentService>((ref) {
  return CommentService();
});

final commentProvider =
    StreamProvider.family<List<Comment>, String>((ref, storyId) {
  final service = ref.watch(commentServiceProvider);
  return service.getCommentsStream(storyId);
});

final agencyServiceProvider = Provider<AgencyService>((ref) {
  return AgencyService();
});

final visionServiceProvider =
    StateNotifierProvider<VisionService, VisionState>((ref) {
  return VisionService();
});

final locationServiceProvider =
    Provider<LocationService>((ref) => LocationService());

final userLocationProvider = StreamProvider<Position?>((ref) {
  final prefs = ref.watch(userPreferencesProvider);
  final isQuiet = NotificationService.isInsideQuietHours(prefs);

  return LocationService.getLocationStream(
    locationSettings: LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: isQuiet ? 1000 : 10,
      timeLimit: const Duration(minutes: 1),
    ),
  ).map((position) {
    if (position.speed > 55.5) {
      AppLogger.i(
        'Vuelo detectado (${(position.speed * 3.6).toStringAsFixed(0)} km/h). Optimizando recursos.',
      );
    }
    return position;
  });
});

final locationProvider = FutureProvider.autoDispose<Position?>((ref) async {
  return LocationService.getPosition();
});
