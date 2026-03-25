import 'package:share_plus/share_plus.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';
import '../models/travel_agency_model.dart';
import '../models/experience_model.dart';

class SharingService {
  /// Share to WhatsApp with viral CTA
  static Future<void> shareToWhatsApp({
    required String title,
    required String description,
    String? deepLink,
  }) async {
    try {
      const cta = '🌟 Únete a FeelTrip y descubre más aventuras!';
      final message =
          '$title\n\n$description\n\n$cta${deepLink != null ? '\n$deepLink' : ''}';
      await Share.share(message, subject: 'Historia increíble en FeelTrip');
      AppLogger.i('Shared to WhatsApp: $title');
    } catch (e) {
      AppLogger.e('WhatsApp share error: $e');
      rethrow;
    }
  }

  /// Share to Facebook
  static Future<void> shareToFacebook({
    required String title,
    required String description,
    String? deepLink,
  }) async {
    try {
      const cta = 'FeelTrip: Donde los viajes se vuelven historias';
      final message =
          '$title\n\n$description\n\n$cta${deepLink != null ? '\n$deepLink' : ''}';
      await Share.share(message, subject: 'Comparte tu aventura');
      AppLogger.i('Shared to Facebook: $title');
    } catch (e) {
      AppLogger.e('Facebook share error: $e');
      rethrow;
    }
  }

  /// Share to TikTok/general
  static Future<void> shareToTikTok({
    required String title,
    String? deepLink,
  }) async {
    try {
      final message = '$title${deepLink != null ? '\n\n$deepLink' : ''}';
      await Share.share(message, subject: 'FeelTrip TikTok');
      AppLogger.i('Shared to TikTok: $title');
    } catch (e) {
      AppLogger.e('TikTok share error: $e');
      rethrow;
    }
  }

  /// General share
  static Future<void> shareGeneral({
    required String title,
    String? description,
    String? deepLink,
  }) async {
    try {
      final message =
          [title, description, deepLink].where((s) => s != null).join('\n\n');
      await Share.share(message, subject: 'FeelTrip - $title');
      AppLogger.i('General share: $title');
    } catch (e) {
      AppLogger.e('Share error: $e');
      rethrow;
    }
  }

  static String generateAgencyDeepLink(String agencyId) {
    return 'https://feeltrip.app/agency/$agencyId';
  }

  /// Share an agency highlighting if verified
  static Future<void> shareAgency(TravelAgency agency) async {
    final deepLink = generateAgencyDeepLink(agency.id);
    final verifiedBadge = agency.verified ? ' ✅ Verificada' : '';
    final message =
        '${agency.name}${verifiedBadge} en ${agency.city}, ${agency.country}\n\n'
        '${agency.description}\n\n'
        'Descubre experiencias únicas en FeelTrip 🌍✨\n'
        '$deepLink';
    try {
      await Share.share(message, subject: '${agency.name} - FeelTrip');
      AppLogger.i('Shared agency: ${agency.id}');
    } catch (e) {
      AppLogger.e('Share agency error: $e');
    }
  }

  static String generateStoryDeepLink(String storyId) {
    return 'https://feeltrip.app/story/$storyId';
  }

  /// Share a story with travel emojis 🌍 and CTA
  static Future<void> shareStory(TravelerStory story) async {
    final deepLink = generateStoryDeepLink(story.id);
    final message =
        '🌍 ¡Historia increíble de ${story.author} en ${story.title}! '
        'Únete a FeelTrip y vive tu propia aventura transformacional 🌟✨\n\n'
        '$deepLink';
    try {
      await Share.share(message, subject: 'Historia en FeelTrip');
      AppLogger.i('Shared story: ${story.id}');
    } catch (e) {
      AppLogger.e('Share story error: $e');
    }
  }

  static String generateDeepLink(String type, String id) {
    return 'https://feeltrip.app/$type/$id';
  }
}
