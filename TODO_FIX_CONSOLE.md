# TODO: Fix VSCode Problems Console (76 analyze errors)

Status: In Progress

## Priority 1: Auth & Payment (Critical API/Constructor Fixes)
- [ ] 1.1 lib/features/auth/data/repositories/auth_repository_impl.dart: Fix AuthFailure positional args (x8), GoogleSignIn API (no unnamed ctor, no signIn(), no accessToken)
- [ ] 1.2 lib/features/auth/domain/usecases/sign_in_email_usecase.dart: Fix AuthFailure, add const
- [ ] 1.3 lib/payment_repository.dart: Fix ServerFailure positional args, safe cast result.data
- [ ] 1.4 lib/core/di/providers.dart: Fix GoogleSignIn provider to standard()

## Priority 2: Tests
- [ ] 2.1 test/features/auth/auth_repository_test.dart: Add mock stubs (signIn*, register*), implements fix
- [ ] 2.2 test/features/premium/data/revenuecat_repository_test.dart: Verify mocks
- [ ] 2.3 test/services/sync_service_test.dart: Fix args/void

## Priority 3: Screens/Services/Widgets
- [ ] 3.1 lib/screens/login_screen.dart: Fix syntax/await/semicolon/else
- [ ] 3.2 lib/screens/smart_camera_screen.dart: VisionServiceProvider notifier, locationProvider, dynamic calls
- [ ] 3.3 lib/services/sync_service.dart: Init _firestore final, remove duplicate retryFailed
- [ ] 3.4 Screens general: EdgeInsets.only(bottom:), withValues(), imports/providers
- [ ] 3.5 lib/widgets/*, lib/screens/*: avoid_dynamic_calls, inference fixes

## Priority 4: Verify
- [ ] 4.1 flutter analyze --no-fatal-infos (0 errors)
- [ ] 4.2 Update this TODO, mark complete items
- [ ] 4.3 Address ERROR_CHECKLIST runtime (configs/perms)

**Progress: 0/20 steps**

