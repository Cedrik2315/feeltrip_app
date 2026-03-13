import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static const String _bannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111'; // test
  static const String _interstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712'; // test

  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  static Widget buildBannerAd() {
    final bannerAd = createBannerAd();
    bannerAd.load();
    return SizedBox(
      height: bannerAd.size.height.toDouble(),
      width: bannerAd.size.width.toDouble(),
      child: AdWidget(ad: bannerAd),
    );
  }

  static Future<void> loadBannerAd() async {
    final bannerAd = createBannerAd();
    bannerAd.load();
  }

  static BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    );
  }

  static Future<bool> showInterstitialAd() async {
    bool shown = false;
    await InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.show();
          shown = true;
        },
        onAdFailedToLoad: (error) {},
      ),
    );
    return shown;
  }
}
