# Console Problems Fix - Priority 1 (P1) Steps

Status: In Progress (0/6 completed)

## P1: Auth & Payment Critical Fixes

### 1. lib/core/di/providers.dart
- [x] Fix GoogleSignIn provider (fixed with scopes named ctor)

### 2. lib/screens/login_screen.dart
- [x] Add await to auth repository calls in _login()
- [x] Fix exception handling scope (move inside fold or proper try-catch)
- [x] Add const qualifiers to widgets
- [x] Fix navigation routes (use context.go('/path'))

### 3. lib/payment_repository.dart
- [x] Add type guard for dynamic result.data
- [x] Make ServerFailure calls const if possible

### 4. test/features/auth/auth_repository_test.dart
- [x] Handle nullable AuthUser? in expects

### 5. lib/features/auth/data/repositories/auth_repository_impl.dart (if needed)
- [x] Verify GoogleSignIn API compatibility

### 6. Validation
- [ ] Run `dart run build_runner build --delete-conflicting-outputs`
- [ ] Run `flutter analyze` 
- [ ] Update TODO_FIX_CONSOLE.md progress
- [ ] Mark P1 complete if 0 errors

**Next after P1:** Priority 2 (Tests), then screens/services lint cleanup.

**Commands to run after edits:**
```
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```
