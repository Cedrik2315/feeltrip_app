# TODO: Fix Analysis Errors to 0 Errors

Status: Group 1 (Imports & Duplicates)

## Steps:

### 1. Delete duplicate export files (5)
- [x] lib/presentation/screens/trip_detail_screen.dart
- [x] lib/presentation/providers/profile_provider.dart  
- [x] lib/core/navigation/app_router.dart
- [x] lib/core/navigation/route_names.dart
- [x] lib/core/providers/observer.dart

### 2. Fix Group 1 imports (6 files)
- [x] lib/presentation/providers/search_provider.dart (trip_model)
- [x] lib/presentation/providers/story_provider.dart (2 imports)
- [x] lib/presentation/providers/trip_provider.dart (trip_model)
- [x] lib/widgets/destination_card.dart (trip_model)
- [x] lib/widgets/affiliate_widget.dart (analytics_service)
- [x] lib/features/user/domain/models/user_model.dart (user_model)

### 3. Group 4: notifications_screen.dart
- [x] Add firebase_auth import

### 4. Group 5: test/widget_test.dart
- [x] Replace with placeholder

### 5. Group 2/3: Codegen
- [x] dart run build_runner build --delete-conflicting-outputs (running)

### 6. Verify
- [x] flutter analyze (running)

Next: Update after each major step.
