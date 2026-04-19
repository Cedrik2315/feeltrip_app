import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:feeltrip_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:feeltrip_app/features/auth/domain/entities/auth_user.dart';
import 'package:feeltrip_app/core/error/failures.dart';
import 'package:feeltrip_app/core/di/providers.dart';
import 'package:feeltrip_app/services/storage_service.dart';


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

  Future<void> _handleAuthResult(Future<Either<Failure, AuthUser?>> authCall) async {
    state = const AsyncValue.loading();
    final result = await authCall;
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _handleAuthResult(_authRepository.signInWithEmailAndPassword(email, password));
  }

  Future<void> signInWithGoogle() async {
    await _handleAuthResult(_authRepository.signInWithGoogle());
  }

  Future<void> signInWithFacebook() async {
    await _handleAuthResult(_authRepository.signInWithFacebook());
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    await StorageService.clearAllData();
    // Stream will handle state = null
  }

  Future<void> deleteAccount() async {
    state = const AsyncValue.loading();
    final result = await _authRepository.deleteAccount();
    await result.fold(
      (failure) async {
        state = AsyncValue.error(failure, StackTrace.current);
        throw failure;
      },
      (_) async {
        await StorageService.clearAllData();
        state = const AsyncValue.data(null);
      },
    );
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<AuthUser?>>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});
