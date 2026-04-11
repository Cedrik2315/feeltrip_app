# Emergency Post-Modularization Cleanup TODO

## Status: In Progress

### Step 1: [PENDING] Delete lib/shared/models/ folder
- Remove entire lib/shared/models/ directory to unify models.

### Step 2: [PENDING] Update travel_agency_model.dart
- Add `required this.address,` to constructor.
- Safe cast in fromFirestore: `address: data['address'] as String? ?? '',`
- Add copyWith method matching shared version.

### Step 3: [PENDING] Update all TravelAgency imports project-wide
- Change 'shared/models/agency_model.dart' → 'models/travel_agency_model.dart' in home_screen.dart, osint_ai_service.dart, providers.dart, etc.

### Step 4: [PENDING] Fix app_router.dart screen imports
- Add imports like `import '../../screens/splash_screen.dart';` for all undefined screens (SplashScreen, HomeScreen, etc.).

### Step 5: [PENDING] Fix providers.dart Vision import
- Add `import '../services/vision_service.dart';`

### Step 6: [PENDING] Fix vision_service.dart confidence
- Change retainWhere on labels before mapping to strings: `final filteredLabels = labels.where((l) => l.confidence > 0.5).toList(); final imageLabels = filteredLabels.map((l) => l.label).toList();`

### Step 7: [PENDING] Fix destination_service.dart
- Comment out unused imports and static instances for restaurant/unsplash until implemented.

### Step 8: [PENDING] Add explicit casts
- osint_ai_service.dart: `title: (jsonData['title'] as String?) ?? '',`
- unsplash_service.dart: `(data['results'] as List?)?.map((item) => (item['urls'] as Map?)?['regular'] as String?)`

### Step 9: [PENDING] Run flutter analyze and iterate
- Verify 'No issues found!'

Updated after each step.
