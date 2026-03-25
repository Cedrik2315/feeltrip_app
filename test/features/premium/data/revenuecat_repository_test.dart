import 'package:feeltrip_app/features/premium/domain/repositories/premium_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:feeltrip_app/features/premium/presentation/providers/premium_notifier.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:feeltrip_app/services/revenuecat_service.dart';

import 'package:feeltrip_app/core/di/providers.dart';

class MockRevenueCatService extends Mock implements RevenueCatService {}

class MockCustomerInfo extends Mock implements CustomerInfo {}

class MockPackage extends Mock implements Package {}

void main() {
  group('RevenueCatRepository Tests', () {
    late ProviderContainer container;
    late MockRevenueCatService mockService;
    late PremiumRepository repository;

    setUp(() {
      mockService = MockRevenueCatService();
      container = ProviderContainer(
        overrides: [
          revenueCatServiceProvider.overrideWithValue(mockService),
        ],
      );
      repository = container.read(premiumRepositoryProvider);
    });

    tearDown(() {
      container.dispose();
    });

    test('purchasePackage success', () async {
      when(() => mockService.purchasePackage(any())).thenAnswer((_) async => MockCustomerInfo());

      final result = await repository.purchasePackage(MockPackage());

      expect(result, isNotNull);
    });
  });
}
