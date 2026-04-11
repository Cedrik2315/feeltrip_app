import 'package:cloud_functions/cloud_functions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:feeltrip_app/services/booking_service.dart';

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
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseFunctions functions;
  late MockHttpsCallable callable;
  late BookingService service;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    functions = MockFirebaseFunctions();
    callable = MockHttpsCallable();
    service = BookingService(firestore: fakeFirestore, functions: functions);

    when(() => functions.httpsCallable('createMercadoPagoPreference'))
        .thenReturn(callable);
  });

  group('BookingService', () {
    test('creates pending booking with expected fields', () async {
      final bookingId = await service.createPendingBooking(
        userId: 'user_1',
        experienceId: 'exp_1',
        amount: 99.5,
      );

      final snapshot = await fakeFirestore.collection('bookings').doc(bookingId).get();
      final data = snapshot.data();

      expect(snapshot.exists, isTrue);
      expect(data?['userId'], 'user_1');
      expect(data?['experienceId'], 'exp_1');
      expect(data?['amount'], 99.5);
      expect(data?['status'], 'pending');
    });

    test('returns callable payload when payment response is complete', () async {
      when(() => callable.call<Map<String, dynamic>>(any<Map<String, dynamic>>())).thenAnswer(
        (_) async => FakeHttpsCallableResult({
          'preferenceId': 'pref_123',
          'initPoint': 'https://mp.test/checkout',
          'bookingId': 'booking_123',
        }),
      );

      final payload = await service.initiateServerSidePayment(
        bookingId: 'booking_123',
        amount: 120,
        experienceId: 'exp_123',
      );

      expect(payload['preferenceId'], 'pref_123');
      expect(payload['initPoint'], 'https://mp.test/checkout');
    });

    test('accepts legacy payment response keys from callable', () async {
      when(() => callable.call<Map<String, dynamic>>(any<Map<String, dynamic>>())).thenAnswer(
        (_) async => FakeHttpsCallableResult({
          'id': 'pref_legacy',
          'init_point': 'https://mp.test/legacy',
        }),
      );

      final payload = await service.initiateServerSidePayment(
        bookingId: 'booking_legacy',
        amount: 220,
        experienceId: 'exp_legacy',
      );

      expect(payload['id'], 'pref_legacy');
      expect(payload['init_point'], 'https://mp.test/legacy');
    });

    test('throws when payment response is incomplete', () async {
      when(() => callable.call<Map<String, dynamic>>(any<Map<String, dynamic>>())).thenAnswer(
        (_) async => FakeHttpsCallableResult({
          'preferenceId': 'pref_incomplete',
        }),
      );

      expect(
        () => service.initiateServerSidePayment(
          bookingId: 'booking_bad',
          amount: 220,
          experienceId: 'exp_bad',
        ),
        throwsA(isA<StateError>()),
      );
    });
  });
}
