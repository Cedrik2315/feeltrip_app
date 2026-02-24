import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:feeltrip_app/services/database_service.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  late _MockFirebaseAuth firebaseAuth;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    firebaseAuth = _MockFirebaseAuth();
    when(() => firebaseAuth.currentUser).thenReturn(null);
  });

  test('localOnly guarda y recupera entradas localmente', () async {
    final service = DatabaseService(
      strategy: DiarySaveStrategy.localOnly,
      auth: firebaseAuth,
    );

    await service.guardarEntrada(texto: 'Entrada test', emociones: ['Calma']);
    final entries = await service.obtenerEntradas().first;

    expect(entries.length, 1);
    expect(entries.first.texto, 'Entrada test');
    expect(entries.first.emociones, ['Calma']);
  });

  test('cloudOnly con usuario null lanza excepción', () async {
    final service = DatabaseService(
      strategy: DiarySaveStrategy.cloudOnly,
      auth: firebaseAuth,
    );

    expect(
      () => service.guardarEntrada(texto: 'x', emociones: const ['y']),
      throwsA(isA<Exception>()),
    );
  });
}
