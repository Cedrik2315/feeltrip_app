import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:feeltrip_app/services/affiliate_service.dart';

void main() {
  group('AffiliateOption', () {
    test('se crea correctamente', () {
      final option = AffiliateOption(
        name: 'Booking',
        url: 'https://booking.com',
        emoji: '🏨',
        color: Colors.blue,
      );
      expect(option.name, 'Booking');
      expect(option.url, 'https://booking.com');
    });
  });
}
