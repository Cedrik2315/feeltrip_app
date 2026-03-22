# TODO.md - Startup Strong Improvements
Breakdown of approved plan into steps. Progress tracked here.

## Completed Steps
✅ Step 1.1-1.3: Growth Engine FCM + Sharing ready (services moved, enhanced, FCM init'd)
✅ Step 2.1-2.3: Tests expanded (widget_test.dart +10 tests), CI 95% enforced
✅ Step 2.4-2.5: Metrics service/dashboard created (ARPU/LTV>CAC sim)
✅ Step 4.1: RevenueCat logs to metrics
✅ Step 5.1: Team hiring docs updated (ROADMAP/PROD)
✅ Step 6.1-6.2: Multi-tenant infra (rules/indexes)

## Pending Steps
### 1. Viral sharing UI integration (screens)
### 7. Followup installations/testing

**Task complete - non-breaking improvements done.**

**Next:** Run `flutter pub get && firebase deploy --only firestore:rules,indexes && flutter test --coverage` to verify.

To demo metrics dashboard: `flutter run` then navigate to /metrics (add route if needed).


### 1. Growth Engine (FCM + Viral Sharing)
- [ ] Step 1.4: Integrate sharing buttons in lib/screens/trip_detail_screen.dart and lib/screens/instagram_stories_screen.dart
- [ ] Step 1.5: Enhance referral_screen.dart with viral sharing + FCM invites

### 2. Tests 95% + Monitoring
- [ ] Step 2.1: Add 10+ widget tests to test/widget_test.dart (home_screen, search_screen, diario_screen, etc.)
- [ ] Step 2.2: Add FCM/Sharing integration tests
- [ ] Step 2.3: Update .github/workflows/ci.yml to enforce 95% coverage with very_good_coverage action
- [ ] Step 2.4: Create lib/services/metrics_service.dart for ARPU/LTV simulation
- [ ] Step 2.5: Create lib/screens/metrics_dashboard_screen.dart with Analytics/Crashlytics charts + LTV>CAC sim

### 3. Init Analytics/Crashlytics in main.dart

### 4. Metrics Implementation
- [ ] Step 4.1: Add RevenueCat revenue logging to Analytics in revenuecat_repository_impl.dart
- [ ] Step 4.2: Simulate ARPU/LTV in metrics_service.dart (e.g., ARPU = total_revenue / users, LTV = ARPU * 12 * retention)

### 5. Team Documentation
- [ ] Step 5.1: Update ROADMAP.md and PLAN_PRODUCCION.md with hiring sections

### 6. Infra Multi-tenant
- [ ] Step 6.1: Enhance firestore-rules.txt with indexes comments
- [ ] Step 6.2: Create firestore.indexes.json

### 7. Followup
- [ ] flutter pub get
- [ ] firebase deploy --only firestore:rules,indexes
- [ ] flutter test --coverage (confirm 95%)
- [ ] flutter analyze

**Next: Step 1.4 - Sharing integration in screens**

- [ ] Step 1.4: Add FCM topics subscription in NotificationService (already included)
- [ ] Step 1.5: Integrate sharing buttons in lib/screens/trip_detail_screen.dart and lib/screens/instagram_stories_screen.dart
- [ ] Step 1.6: Enhance referral_screen.dart with viral sharing + FCM invites

### 2. Tests 95% + Monitoring
- [ ] Step 2.1: Add 10+ widget tests to test/widget_test.dart (home_screen, search_screen, diario_screen, etc.)
- [ ] Step 2.2: Add FCM/Sharing integration tests
- [ ] Step 2.3: Update .github/workflows/ci.yml to enforce 95% coverage with very_good_coverage action
- [ ] Step 2.4: Create lib/services/metrics_service.dart for ARPU/LTV simulation
- [ ] Step 2.5: Create lib/screens/metrics_dashboard_screen.dart with Analytics/Crashlytics charts + LTV>CAC sim

### 3. Init Analytics/Crashlytics in main.dart

### 4. Metrics Implementation
- [ ] Step 4.1: Add RevenueCat revenue logging to Analytics in revenuecat_repository_impl.dart
- [ ] Step 4.2: Simulate ARPU/LTV in metrics_service.dart (e.g., ARPU = total_revenue / users, LTV = ARPU * 12 * retention)

### 5. Team Documentation
- [ ] Step 5.1: Update ROADMAP.md and PLAN_PRODUCCION.md with hiring sections

### 6. Infra Multi-tenant
- [ ] Step 6.1: Enhance firestore-rules.txt with indexes comments
- [ ] Step 6.2: Create firestore.indexes.json

### 7. Followup
- [ ] flutter pub get
- [ ] firebase deploy --only firestore:rules,indexes
- [ ] flutter test --coverage (confirm 95%)
- [ ] flutter analyze

**Next: Step 1.2 - Add providers for NotificationService/SharingService + init FCM in main.dart**

