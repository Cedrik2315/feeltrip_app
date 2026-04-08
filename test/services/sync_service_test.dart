import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  // Asegura que los bindings de Flutter estén listos para interactuar con servicios del sistema
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SyncService Infrastructure', () {
    late Directory tempDir;

    setUp(() async {
      // Creamos un directorio temporal único para evitar colisiones entre tests
      tempDir = await Directory.systemTemp.createTemp('feeltrip_sync_test');
      Hive.init(tempDir.path);
    });

    tearDown(() async {
      // Cerramos todas las cajas y eliminamos los archivos físicos de la base de datos
      await Hive.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('Hive environment should be ready for sync operations', () async {
      final testBox = await Hive.openBox('sync_test_box');
      expect(testBox.isOpen, isTrue);
      await testBox.close();
    });
  });
}
