import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
  });

  group('BookingService', () {
    test('Firestore environment is correctly mocked', () async {
      // This setup replaces the need for a real Firebase connection during tests.
      // You can now pass [fakeFirestore] to your service constructor or use it to seed data.
      await fakeFirestore.collection('bookings').add({
        'status': 'confirmed',
        'tripId': 'trip_001',
      });

      final snapshot = await fakeFirestore.collection('bookings').get();
      expect(snapshot.docs.length, 1);
    });
  });
}
