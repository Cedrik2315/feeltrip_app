import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/admob_service.dart';

final adMobProvider = StateNotifierProvider<AdMobNotifier, AdMobService>((ref) {
  final service = AdMobService();
  service.loadBanner(onLoaded: () {});
  service.loadInterstitial();
  return AdMobNotifier(service);
});

class AdMobNotifier extends StateNotifier<AdMobService> {
  AdMobNotifier(super.state);

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }
}
