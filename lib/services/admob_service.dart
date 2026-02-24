import 'package:flutter/foundation.dart';

class AdMobService {
  static const String _androidBannerProd = 'ca-app-pub-9067451109299541/2137990706';
  static const String _androidInterstitialProd = 'ca-app-pub-9067451109299541/4320796335';

  // Configura estos IDs por --dart-define para release iOS.
  static const String _iosBannerProd =
      String.fromEnvironment('ADMOB_IOS_BANNER_ID', defaultValue: '');
  static const String _iosInterstitialProd =
      String.fromEnvironment('ADMOB_IOS_INTERSTITIAL_ID', defaultValue: '');

  // IDs oficiales de prueba de Google AdMob.
  static const String _androidBannerTest = 'ca-app-pub-3940256099942544/6300978111';
  static const String _androidInterstitialTest = 'ca-app-pub-3940256099942544/1033173712';
  static const String _iosBannerTest = 'ca-app-pub-3940256099942544/2934735716';
  static const String _iosInterstitialTest = 'ca-app-pub-3940256099942544/4411468910';

  static bool get isSupported {
    return !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
  }

  static bool get isTestMode => !kReleaseMode;

  static String get bannerAdUnitId {
    if (isTestMode) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        return _androidBannerTest;
      }
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        return _iosBannerTest;
      }
      throw UnsupportedError('Plataforma no soportada para AdMob');
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return _androidBannerProd;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      if (_iosBannerProd.isEmpty) {
        throw StateError(
          'Falta ADMOB_IOS_BANNER_ID para build release de iOS.',
        );
      }
      return _iosBannerProd;
    }
    throw UnsupportedError('Plataforma no soportada para AdMob');
  }

  static String get interstitialAdUnitId {
    if (isTestMode) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        return _androidInterstitialTest;
      }
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        return _iosInterstitialTest;
      }
      throw UnsupportedError('Plataforma no soportada para AdMob');
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return _androidInterstitialProd;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      if (_iosInterstitialProd.isEmpty) {
        throw StateError(
          'Falta ADMOB_IOS_INTERSTITIAL_ID para build release de iOS.',
        );
      }
      return _iosInterstitialProd;
    }
    throw UnsupportedError('Plataforma no soportada para AdMob');
  }
}
