import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/logger/app_logger.dart';

class AdMobService {
  static const String _bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _isBannerLoaded = false;
  bool _isInterstitialLoaded = false;
  int _routesSinceLastAd = 0;

  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
    AppLogger.i('AdMob inicializado');
  }

  void loadBanner({required Function() onLoaded}) {
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _isBannerLoaded = true;
          onLoaded();
          AppLogger.i('Banner AdMob cargado');
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _isBannerLoaded = false;
          AppLogger.e('Banner AdMob falló: $error');
        },
      ),
    );
    _bannerAd!.load();
  }

  Widget? getBannerWidget(bool isUserFree) {
    if (!isUserFree || !_isBannerLoaded || _bannerAd == null) return null;
    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }

  void loadInterstitial() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoaded = true;
          AppLogger.i('Intersticial AdMob cargado');
        },
        onAdFailedToLoad: (error) {
          _isInterstitialLoaded = false;
          AppLogger.e('Intersticial AdMob falló: $error');
        },
      ),
    );
  }

  Future<void> showInterstitial({required bool isUserFree}) async {
    if (!isUserFree) return;
    _routesSinceLastAd++;
    if (_routesSinceLastAd < 3) return;
    if (!_isInterstitialLoaded || _interstitialAd == null) return;
    await _interstitialAd!.show();
    _routesSinceLastAd = 0;
    _isInterstitialLoaded = false;
    loadInterstitial();
  }

  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
  }
}
