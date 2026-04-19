import 'package:flutter/material.dart';
import 'package:feeltrip_app/core/navigation/url_launcher_service.dart';

class AffiliateOption {
  const AffiliateOption(
      {required this.name, required this.url, required this.emoji, required this.color});
  final String name;
  final String url;
  final String emoji;
  final Color color;
}

class AffiliateOptionsService {
  static List<AffiliateOption> getAffiliateOptions(String destination) {
    return [
      AffiliateOption(
          name: 'Booking',
          url: 'https://www.booking.com/search.html?ss=$destination',
          emoji: '🏨',
          color: const Color(0xFF003580)),
      AffiliateOption(
          name: 'Viator',
          url: 'https://www.viator.com/search/$destination?pid=P00288924&mcid=42383&medium=link',
          emoji: '🗺️',
          color: const Color(0xFFFF6600)),
      AffiliateOption(
          name: 'GetYourGuide',
          url: 'https://www.getyourguide.es/s/?q=$destination&partner_id=ASL9O0I&cmp=share_to_earn',
          emoji: '🎯',
          color: const Color(0xFF00B545)),
      AffiliateOption(
          name: 'Civitatis',
          url: 'https://www.civitatis.com/es/$destination/',
          emoji: '🎭',
          color: const Color(0xFF00B5E2)),
    ];
  }

  static Future<void> openAffiliateLink(BuildContext context, String url) async {
    await UrlLauncherService.openUrl(context, url);
  }
}
