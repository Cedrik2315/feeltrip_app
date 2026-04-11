// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'premium_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$premiumRepositoryHash() => r'45750990e4f0dc0f37b7b0885cfcc72cce9511a1';

/// See also [premiumRepository].
@ProviderFor(premiumRepository)
final premiumRepositoryProvider =
    AutoDisposeProvider<PremiumRepository>.internal(
  premiumRepository,
  name: r'premiumRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$premiumRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PremiumRepositoryRef = AutoDisposeProviderRef<PremiumRepository>;
String _$premiumNotifierHash() => r'4fe7208cc91a47458efe7bb7d9f49c529b9b49e4';

/// See also [PremiumNotifier].
@ProviderFor(PremiumNotifier)
final premiumNotifierProvider =
    AutoDisposeNotifierProvider<PremiumNotifier, PremiumState>.internal(
  PremiumNotifier.new,
  name: r'premiumNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$premiumNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PremiumNotifier = AutoDisposeNotifier<PremiumState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
