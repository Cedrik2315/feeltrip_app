import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AffiliateOption {
  final String name;
  final String url;
  final String emoji;
  final Color color;
  AffiliateOption(
      {required this.name,
      required this.url,
      required this.emoji,
      required this.color});
}

class AffiliateService {
  static List<AffiliateOption> getAffiliateOptions(String destination) {
    return [
      AffiliateOption(
          name: 'Booking',
          url: 'https://www.booking.com/search.html?ss=$destination',
          emoji: '🏨',
          color: Colors.blue),
      AffiliateOption(
          name: 'Viator',
          url:
              'https://www.viator.com/search/$destination?pid=P00288924&mcid=42383&medium=link',
          emoji: '🗺️',
          color: Colors.orange),
      AffiliateOption(
          name: 'GetYourGuide',
          url:
              'https://www.getyourguide.es/s/?q=$destination&partner_id=ASL9O0I&cmp=share_to_earn',
          emoji: '🎯',
          color: Colors.green),
      AffiliateOption(
          name: 'Civitatis',
          url: 'https://www.civitatis.com/es/$destination/',
          emoji: '🎭',
          color: const Color(0xFF00B5E2)),
    ];
  }

  static Future<void> openAffiliateLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
