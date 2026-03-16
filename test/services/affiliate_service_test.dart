import 'package:flutter_test/flutter_test.dart';
import 'package:feeltrip_app/services/affiliate_service.dart';

void main() {
  group('AffiliateService', () {
    test('retorna 4 opciones', () {
      final options = AffiliateService.getAffiliateOptions('París');
      expect(options.length, 4);
    });

    test('Viator tiene pid correcto', () {
      final options = AffiliateService.getAffiliateOptions('París');
      final viator = options.firstWhere((o) => o.name == 'Viator');
      expect(viator.url, contains('P00288924'));
    });

    test('GetYourGuide tiene partner_id correcto', () {
      final options = AffiliateService.getAffiliateOptions('París');
      final gyg = options.firstWhere((o) => o.name == 'GetYourGuide');
      expect(gyg.url, contains('ASL9O0I'));
    });

    test('todas las URLs empiezan con https://', () {
      final options = AffiliateService.getAffiliateOptions('París');
      for (final option in options) {
        expect(option.url, startsWith('https://'));
      }
    });
  });
}
