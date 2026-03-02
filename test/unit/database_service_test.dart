import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:feeltrip_app/services/database_service.dart';

class MockDiaryService extends Mock implements DatabaseService {}

void main() {
  // Inicializar el binding de Flutter para tests
  TestWidgetsFlutterBinding.ensureInitialized();

  test('DiarySaveStrategy enum has correct values', () {
    expect(DiarySaveStrategy.values.length, 3);
    expect(DiarySaveStrategy.cloudOnly, isNotNull);
    expect(DiarySaveStrategy.localOnly, isNotNull);
    expect(DiarySaveStrategy.cloudWithLocalFallback, isNotNull);
  });

  test('DiarioRegistro can be created from JSON', () {
    final json = {
      'id': 'test-id',
      'texto': 'Test entry',
      'emociones': ['Joy', 'Excitement'],
      'fecha': '2024-01-01T00:00:00.000',
      'destino': 'Paris',
    };

    final registro = DiarioRegistro.fromJson(json);

    expect(registro.id, 'test-id');
    expect(registro.texto, 'Test entry');
    expect(registro.emociones, ['Joy', 'Excitement']);
    expect(registro.destino, 'Paris');
  });

  test('DiarioRegistro can convert to JSON', () {
    final registro = DiarioRegistro(
      id: 'test-id',
      texto: 'Test entry',
      emociones: ['Joy'],
      fecha: DateTime(2024, 1, 1),
      destino: 'Bali',
    );

    final json = registro.toJson();

    expect(json['id'], 'test-id');
    expect(json['texto'], 'Test entry');
    expect(json['emociones'], ['Joy']);
    expect(json['destino'], 'Bali');
  });
}
