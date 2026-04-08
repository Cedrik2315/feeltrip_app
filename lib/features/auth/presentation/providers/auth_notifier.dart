import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:feeltrip_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:feeltrip_app/features/auth/domain/entities/auth_user.dart';
import 'package:feeltrip_app/core/di/providers.dart';


class AuthNotifier extends StateNotifier<AsyncValue<AuthUser?>> {
  AuthNotifier(this._authRepository) : super(const AsyncValue.loading()) {
    _authStreamSubscription = _authRepository.authStateChanges().listen(
      (user) {
        state = AsyncValue.data(user);
      },
      onError: (Object error, StackTrace stackTrace) {
        state = AsyncValue.error(error, stackTrace);
      },
    );
  }

  late final StreamSubscription<AuthUser?> _authStreamSubscription;
  final IAuthRepository _authRepository;

  @override
  void dispose() {
    _authStreamSubscription.cancel();
    super.dispose();
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    state = const AsyncValue.loading();
    final result = await _authRepository.signInWithEmailAndPassword(email, password);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    final result = await _authRepository.signInWithGoogle();
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }

  Future<void> signInWithFacebook() async {
    state = const AsyncValue.loading();
    final result = await _authRepository.signInWithFacebook();
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    // Stream will handle state = null
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<AuthUser?>>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});
