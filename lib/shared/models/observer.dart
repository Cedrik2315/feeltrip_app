import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Observer para debugging de providers en desarrollo
class AppProviderObserver extends ProviderObserver {
  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {
    if (kDebugMode) {
      final providerLabel = provider.name ?? provider.runtimeType;
      debugPrint('Provider added: $providerLabel');
    }
  }

  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {
    if (kDebugMode) {
      final providerLabel = provider.name ?? provider.runtimeType;
      debugPrint('Provider disposed: $providerLabel');
    }
  }

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    if (kDebugMode) {
      final providerLabel = provider.name ?? provider.runtimeType;
      debugPrint('Provider updated: $providerLabel');
    }
  }

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object? error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    if (kDebugMode) {
      final providerLabel = provider.name ?? provider.runtimeType;
      debugPrint('Provider failed: $providerLabel');
      debugPrint('Error: $error');
    }
  }
}
