# Firebase Duplicate Class Fix - TODO

## Status: [ ] In Progress

### Steps:
- [✅] 1. Move Firebase BOM to `android/app/build.gradle.kts` (Fixed: was incorrectly in root build.gradle.kts)
- [✅] 2. Add firebase-iid exclusion to `android/app/build.gradle.kts`
- [✅] 3. Clean build caches (`flutter clean && cd android && ./gradlew clean`)
- [✅] 4. Run `flutter pub get`
- [ ] 5. Test `flutter run` or `flutter build apk --debug`
- [ ] 6. Verify no duplicate error

**After complete:** Delete this file or mark ✅
