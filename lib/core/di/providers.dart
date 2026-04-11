import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:feeltrip_app/core/router/app_router.dart';
import 'package:feeltrip_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:feeltrip_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:feeltrip_app/features/home/data/repositories/home_repository.dart';
import 'package:feeltrip_app/models/comment_model.dart';
import 'package:feeltrip_app/payment_repository.dart';
import 'package:feeltrip_app/services/agency_service.dart';
import 'package:feeltrip_app/services/comment_service.dart';
import 'package:feeltrip_app/services/connectivity_service.dart';
import 'package:feeltrip_app/services/metrics_service.dart';
import 'package:feeltrip_app/services/notification_service.dart';
import 'package:feeltrip_app/services/revenuecat_service.dart';
import 'package:feeltrip_app/services/restaurant_service.dart';
import 'package:feeltrip_app/services/sync_service.dart';
import 'package:feeltrip_app/services/isar_service.dart';
import 'package:feeltrip_app/services/emotional_engine_service.dart';
import 'package:feeltrip_app/services/location_suggestions_repository.dart';

final routerProvider = Provider<GoRouter>((ref) => createAppRouter(ref));

final notificationServiceProvider = Provider((ref) => NotificationService());

final connectivityProvider = StreamProvider<ConnectivityResult>((ref) {
  return Connectivity().onConnectivityChanged.map((event) {
    final dynamic connectivityEvent = event;
    if (connectivityEvent is List<ConnectivityResult>) {
      return connectivityEvent.isNotEmpty
          ? connectivityEvent.first
          : ConnectivityResult.none;
    }
    return connectivityEvent as ConnectivityResult;
  });
});

final connectivityServiceProvider = Provider((ref) => ConnectivityService(ref));
final revenueCatServiceProvider = Provider((ref) => RevenueCatService());

final commentServiceProvider = Provider((ref) => CommentService());
final commentProvider =
    FutureProvider.family<List<Comment>, String>((ref, storyId) async {
  return ref.watch(commentServiceProvider).getComments(storyId);
});

final agencyServiceProvider = Provider((ref) => AgencyService());

final firebaseAuthProvider = Provider((ref) => FirebaseAuth.instance);
final googleSignInProvider =
    Provider<GoogleSignIn>((ref) => GoogleSignIn.instance);
final facebookAuthProvider = Provider((ref) => FacebookAuth.instance);

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(firebaseAuthProvider),
    ref.watch(googleSignInProvider),
    ref.watch(facebookAuthProvider),
  );
});

final metricsServiceProvider = Provider((ref) => MetricsService());


final restaurantServiceProvider = Provider((ref) => RestaurantService());
final paymentRepositoryProvider =
    Provider<IPaymentRepository>((ref) => PaymentRepository());

final homeRepositoryProvider = Provider((ref) => HomeRepository());

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService();
});

final emotionalEngineProvider = Provider((ref) => EmotionalEngineService());

final locationSuggestionsRepositoryProvider =
    Provider((ref) => LocationSuggestionsRepository());

/// Provider para acceder directamente a Isar
final isarProvider = Provider<Isar>((ref) => ref.watch(isarServiceProvider).isar);
