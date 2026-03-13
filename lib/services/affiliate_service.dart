import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class AffiliateOption {
  final String name;
  final String emoji;
  final String url;
  final String description;
  final Color color;

  const AffiliateOption({
    required this.name,
    required this.emoji,
    required this.url,
    required this.description,
    required this.color,
  });
}

class AffiliateService {
  static const String _bookingAid = 'b424845c-f0e1-4ef0-98ed-dd8fc841334e';
  static const String _viatorPid = 'P00084671';
  static const String _partnerId = 'FEELTRIP';

  static String getBookingUrl(String destination) {
    final encoded = Uri.encodeComponent(destination.trim());
    return 'https://www.booking.com/search.html?ss=$encoded&aid=$_bookingAid';
  }

  static String getViatorUrl(String destination) {
    final encoded = destination.trim().toLowerCase().replaceAll(' ', '-');
    return 'https://www.viator.com/search/$encoded?pid=$_viatorPid';
  }

  static String getGetYourGuideUrl(String destination) {
    final encoded = Uri.encodeComponent(destination.trim());
    return 'https://www.getyourguide.com/s/?q=$encoded&partner_id=$_partnerId';
  }

  static Future<void> openAffiliateLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  static List<AffiliateOption> getAffiliateOptions(String destination) {
    return [
      AffiliateOption(
        name: 'Booking.com',
        emoji: '🏨',
        url: getBookingUrl(destination),
        description: 'Hoteles y alojamiento',
        color: const Color(0xFF003580),
      ),
      AffiliateOption(
        name: 'Viator',
        emoji: '🎯',
        url: getViatorUrl(destination),
        description: 'Tours y actividades',
        color: const Color(0xFF00AF87),
      ),
      AffiliateOption(
        name: 'GetYourGuide',
        emoji: '🗺️',
        url: getGetYourGuideUrl(destination),
        description: 'Experiencias únicas',
        color: const Color(0xFFFF5533),
      ),
    ];
  }
}
