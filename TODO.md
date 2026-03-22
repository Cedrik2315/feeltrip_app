# Build Fix TODO

1. [ ] Update pubspec.yaml (add analyzer: ^12.0.0)
2. [ ] Edit lib/models/booking_model.dart (add @ignore to isarId and createdAt)
3. [ ] Edit lib/features/diario/presentation/providers/momento_provider.dart (add part 'momento_provider.g.dart';)
4. [ ] Run `flutter pub get`
5. [ ] Run `dart run build_runner clean`
6. [ ] Run `dart run build_runner build --delete-conflicting-outputs`
7. [ ] Verify no SEVERE errors
