import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SharingService {
  static String generateStoryDeepLink(String storyId) {
    // En una app real, usarías Firebase Dynamic Links o similar.
    // Por ahora, simulamos un link web.
    return 'https://feeltrip.app/story/$storyId';
  }

  static Future<void> shareGeneral({
    required String title,
    required String description,
    required String deepLink,
  }) async {
    await Share.share(
      '$title\n\n$description\n\nVer más en: $deepLink',
      subject: title,
    );
  }

  static Future<void> shareToWhatsApp({
    required String storyTitle,
    required String storyDescription,
    required String deepLink,
  }) async {
    final text = Uri.encodeComponent(
        '¡Mira esta historia en FeelTrip!\n*$storyTitle*\n$storyDescription\n$deepLink');
    final url = Uri.parse('whatsapp://send?text=$text');

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      // Fallback a compartir general si WhatsApp no está instalado
      await shareGeneral(
        title: storyTitle,
        description: storyDescription,
        deepLink: deepLink,
      );
    }
  }
}
