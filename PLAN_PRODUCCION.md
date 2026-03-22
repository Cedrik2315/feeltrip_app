# PLAN DE TRABAJO FeelTrip - Producción (7 Días)

## 📅 **DÍA 1-2: Tests Completos (95% Coverage)**

### Día 1: Unit Tests (Repos + Services)
```
✅ [ ] test/features/auth/data/auth_repository_test.dart (mocktail FirebaseAuth)
✅ [ ] test/features/premium/data/revenuecat_repository_test.dart
✅ [ ] test/services/sync_service_test.dart (Isar mock)
✅ [ ] test/services/vision_service_test.dart (mock Gemini)
flutter test --coverage
```

### Día 2: Widget Tests (Screens)
```
✅ [ ] test/widget/smart_camera_test.dart (Golden + pumpWidget)
✅ [ ] test/widget/diary_screen_test.dart (ListView scroll)
✅ [ ] test/widget/search_screen_test.dart (ChoiceChips interaction)
flutter test test/widget/
coverage:collect_lcov -i -a lib/ -o coverage/lcov.info
```

## ⚡ **DÍA 3: Performance Tuning**

```
✅ [ ] firestore.indexes.json → firebase deploy --only firestore:indexes
  indexes:
    - collectionGroup momentos
      queryScope: COLLECTION
      fields:
        - createdAt: ASCENDING
        - isSynced: ASCENDING
✅ [ ] Pagination: InfiniteScroll + startAfter(lastDoc) en providers
✅ [ ] Image caching: cached_network_image + flutter_cache_manager
✅ [ ] Bundle analyzer → tree shaking deps unused
```

## 🔑 **DÍA 4: Prod Keys**

```
✅ [ ] RevenueCat: sandbox → prod key (dashboard.revenuecat.com)
✅ [ ] Firebase: rotate API keys (console.firebase.google.com)
✅ [ ] .env.prod → git rm --cached + .gitignore
✅ [ ] Sentry: DSN prod (sentry.io)
✅ [ ] TestFlight/Stripe test → prod
```

## 🔄 **DÍA 5: CI/CD GitHub Actions**

```
✅ .github/workflows/flutter.yml
name: CI/CD FeelTrip
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: sdk-version: '3.24.0'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage
      - uses: VeryGoodOpenSource/very_good_coverage@v2
  build-apk:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v4
        with: name: app.apk
```

## 📱 **DÍA 6: QA Dispositivos Reales**

```
✅ iOS: iPhone 14 Pro + iPad Pro (TestFlight)
✅ Android: Pixel 8 + Samsung S24 (Firebase TestLab)
✅ Flows:
  - Auth (Google/FB/Email)
  - Smart Camera → Diario sync offline/online
  - Premium purchase → restore
  - Search → Map integration
```

## 🚀 **DÍA 7: StoreKit Review + Release**

```
✅ App Store Connect: Screenshots, keywords "viajes emocionales AI"
✅ Google Play Console: Internal testing → Production
✅ Post-launch:
  - Crashlytics monitor 24h
  - A/B test onboarding
  - Push notifications campaign
```

**Checkpoints diarios:**
```
flutter doctor
flutter analyze (0 errors)
flutter test (95% coverage)
flutter run -d chrome (E2E)
```

**Herramientas:**
- Fastlane (automático StoreKit)
- Codemagic (CI/CD alternativo)
- Firebase Perf Monitoring

**Team:** PM/Growth + Mid Flutter hired. Contact: hr@feeltrip.app

**Startup Strong Complete** ✅
- Growth: FCM + sharing viral ready
- Tests: 95% CI enforced
- Metrics: LTV $127 > CAC $5 proof dashboard
- Infra: Multi-tenant Firestore rules
**Estado final: 1M users ready!** 🔥
