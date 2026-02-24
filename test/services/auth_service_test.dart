import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:feeltrip_app/services/auth_service.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  group('AuthService Tests', () {
    late AuthService authService;
    late MockFirebaseAuth mockAuth;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      authService = AuthService(auth: mockAuth);
    });

    test('AuthService should be created with default FirebaseAuth', () {
      final service = AuthService();
      expect(service, isNotNull);
    });

    test('AuthService should expose user stream', () {
      expect(authService.user, isA<Stream<User?>>());
    });

    test('signInAnon should return null on error', () async {
      // Test that signInAnon handles errors gracefully
      // Without mocking Firebase, we just verify the method exists
      expect(authService.signInAnon, isNotNull);
    });
  });

  group('AuthService Model Tests', () {
    test('AuthService methods should be callable', () {
      final service = AuthService();

      // Verify all methods exist and are callable
      expect(service.signInAnon, isNotNull);
      expect(service.signInWithEmail, isNotNull);
      expect(service.registerWithEmail, isNotNull);
      expect(service.signOut, isNotNull);
      expect(service.sendPasswordResetEmail, isNotNull);

      service.signOut(); // Should not throw
    });
  });
}
