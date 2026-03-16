import 'package:flutter_test/flutter_test.dart';
import 'package:feeltrip_app/services/storage_service.dart';

void main() {
  group('StorageService', () {
    test('métodos estáticos existen', () {
      expect(StorageService.uploadProfilePhoto, isNotNull);
      expect(StorageService.uploadDiaryPhoto, isNotNull);
      expect(StorageService.uploadStoryPhoto, isNotNull);
      expect(StorageService.deleteFile, isNotNull);
    });
  });
}
