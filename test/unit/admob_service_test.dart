import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:feeltrip_app/services/admob_service.dart';

void main() {
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  test('isSupported es false en Windows', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    expect(AdMobService.isSupported, isFalse);
  });

  test('en debug usa IDs de prueba Android', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    expect(AdMobService.isSupported, isTrue);
    expect(AdMobService.bannerAdUnitId, 'ca-app-pub-3940256099942544/6300978111');
    expect(AdMobService.interstitialAdUnitId, 'ca-app-pub-3940256099942544/1033173712');
  });
}
