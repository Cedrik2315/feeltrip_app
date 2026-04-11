import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:feeltrip_app/payment_repository.dart';

class MockFirebaseFunctions extends Mock implements FirebaseFunctions {}
class MockHttpsCallable extends Mock implements HttpsCallable {}

class FakeHttpsCallableResult extends Fake
    implements HttpsCallableResult<Map<String, dynamic>> {
  FakeHttpsCallableResult(this._data);

  final Map<String, dynamic> _data;

  @override
  Map<String, dynamic> get data => _data;
}

void main() {
  group('PaymentRepository', () {
    late MockFirebaseFunctions functions;
    late MockHttpsCallable callable;
    late PaymentRepository repository;

    setUp(() {
      functions = MockFirebaseFunctions();
      callable = MockHttpsCallable();
      repository = PaymentRepository(functions: functions);

      when(() => functions.httpsCallable('createMercadoPagoPreference'))
          .thenReturn(callable);
    });

    test('returns structured payment session on success', () async {
      when(() => callable.call<Map<String, dynamic>>(any<Map<String, dynamic>>())).thenAnswer(
        (_) async => FakeHttpsCallableResult({
          'preferenceId': 'pref_123',
          'initPoint': 'https://mp.test/checkout',
          'externalReference': 'booking_123',
          'provider': 'mercadopago',
          'status': 'pending',
          'bookingId': 'booking_123',
        }),
      );

      final result = await repository.createCheckoutSession(
        const PaymentRequest(
          amount: 1000,
          title: 'FeelTrip Booking',
          purpose: 'booking',
          bookingId: 'booking_123',
        ),
      );

      expect(result.isRight(), true);
      final session = result.getOrElse(
        () => throw StateError('Expected payment session'),
      );
      expect(session.preferenceId, 'pref_123');
      expect(session.externalReference, 'booking_123');
      expect(session.bookingId, 'booking_123');
    });

    test('accepts legacy mercado pago field names', () async {
      when(() => callable.call<Map<String, dynamic>>(any<Map<String, dynamic>>())).thenAnswer(
        (_) async => FakeHttpsCallableResult({
          'id': 'pref_legacy',
          'init_point': 'https://mp.test/legacy',
          'external_reference': 'booking_legacy',
          'status': 'pending',
        }),
      );

      final result = await repository.createCheckoutSession(
        const PaymentRequest(
          amount: 2000,
          title: 'Legacy Booking',
          purpose: 'booking',
          bookingId: 'booking_legacy',
        ),
      );

      expect(result.isRight(), true);
      final session = result.getOrElse(
        () => throw StateError('Expected payment session'),
      );
      expect(session.preferenceId, 'pref_legacy');
      expect(session.initPoint, 'https://mp.test/legacy');
      expect(session.externalReference, 'booking_legacy');
    });

    test('returns failure when payment session is incomplete', () async {
      when(() => callable.call<Map<String, dynamic>>(any<Map<String, dynamic>>())).thenAnswer(
        (_) async => FakeHttpsCallableResult({
          'preferenceId': 'pref_broken',
        }),
      );

      final result = await repository.createCheckoutSession(
        const PaymentRequest(
          amount: 500,
          title: 'Broken Booking',
          purpose: 'booking',
          bookingId: 'booking_broken',
        ),
      );

      expect(result.isLeft(), true);
    });
  });
}
