import 'package:flutter_test/flutter_test.dart';
import 'package:feeltrip_app/services/affiliate_service.dart';

void main() {
  group('AffiliateService', () {
    test('getAffiliateOptions retorna 3 opciones', () {
      final options = AffiliateService.getAffiliateOptions('Paris');
      expect(options.length, 3);
    });

    test('opciones tienen nombre, url y emoji', () {
      final options = AffiliateService.getAffiliateOptions('Tokyo');
      for (final option in options) {
        expect(option.name, isNotEmpty);
        expect(option.url, isNotEmpty);
        expect(option.emoji, isNotEmpty);
        expect(option.url, startsWith('https://'));
      }
    });
  });
}
