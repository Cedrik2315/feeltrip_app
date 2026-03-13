import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AffiliateOption {
  final String emoji;
  final String name;
  final Color color;
  final String url;

  const AffiliateOption({
    required this.emoji,
    required this.name,
    required this.color,
    required this.url,
  });
}

class AffiliateService {
  static List<AffiliateOption> getAffiliateOptions(String destination) {
    return [
      const AffiliateOption(
        emoji: '🏨',
        name: 'Hotel',
        color: Colors.blue,
        url:
            'https://www.booking.com/searchresults.html?dest_id=-2118678&aid=your_affiliate_id', // Bali example
      ),
      AffiliateOption(
        emoji: '✈️',
        name: 'Vuelos',
        color: Colors.orange,
        url:
            'https://www.skyscanner.net/transport/flights/$destination/240101/240131/?adultsv2=1&preferdirects=false',
      ),
      const AffiliateOption(
        emoji: '🚗',
        name: 'Auto',
        color: Colors.green,
        url: 'https://www.rentalcars.com/',
      ),
    ];
  }

  static Future<void> openAffiliateLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
