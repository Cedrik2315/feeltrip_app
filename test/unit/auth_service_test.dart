import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:feeltrip_app/services/auth_service.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockUserCredential extends Mock implements UserCredential {}

class _MockUser extends Mock implements User {}

void main() {
  late _MockFirebaseAuth firebaseAuth;
  late AuthService service;

  setUp(() {
    firebaseAuth = _MockFirebaseAuth();
    service = AuthService(auth: firebaseAuth);
  });

  test('signInWithEmail delega en FirebaseAuth', () async {
    final credential = _MockUserCredential();
    when(() => firebaseAuth.signInWithEmailAndPassword(email: any(named: 'email'), password: any(named: 'password')))
        .thenAnswer((_) async => credential);

    final result = await service.signInWithEmail(email: 'a@b.com', password: '123456');

    expect(result, credential);
    verify(() => firebaseAuth.signInWithEmailAndPassword(email: 'a@b.com', password: '123456')).called(1);
  });

  test('registerWithEmail actualiza displayName cuando viene nombre', () async {
    final credential = _MockUserCredential();
    final user = _MockUser();
    when(() => firebaseAuth.createUserWithEmailAndPassword(email: any(named: 'email'), password: any(named: 'password')))
        .thenAnswer((_) async => credential);
    when(() => credential.user).thenReturn(user);
    when(() => user.updateDisplayName(any())).thenAnswer((_) async {});

    await service.registerWithEmail(name: 'Monch', email: 'x@y.com', password: '123456');

    verify(() => user.updateDisplayName('Monch')).called(1);
  });
}
