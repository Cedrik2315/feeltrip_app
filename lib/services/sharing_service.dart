import 'package:share_plus/share_plus.dart';

import '../core/app_logger.dart';
import 'deep_link_service.dart';

class SharingService {
  /// Compartir historia a WhatsApp
  static Future<void> shareToWhatsApp({
    required String storyTitle,
    required String storyDescription,
    required String storyId,
  }) async {
    try {
      // Generate dynamic deep link with preview
      final deepLink = await DeepLinkService().createStoryLink(storyId);

      final message =
          '📸 $storyTitle\n\n$storyDescription\n\n✨ Descubre más historias en FeelTrip:\n$deepLink';

      await Share.share(
        message,
        subject: '¡Mira esta historia en FeelTrip!',
      );

      AppLogger.debug('Compartido a WhatsApp exitosamente: $deepLink');
    } catch (e) {
      AppLogger.debug('Error compartiendo: $e');
      rethrow;
    }
  }

  /// Compartir historia a Facebook
  static Future<void> shareToFacebook({
    required String storyTitle,
    required String storyDescription,
    required String storyId,
  }) async {
    try {
      // Generate dynamic deep link with preview
      final deepLink = await DeepLinkService().createStoryLink(storyId);

      final message =
          '🌍 $storyTitle\n\n$storyDescription\n\n🎒 FeelTrip: Conecta con viajeros\n$deepLink';

      await Share.share(
        message,
        subject: '¡Comparte esta aventura!',
      );

      AppLogger.debug('Compartido a Facebook exitosamente: $deepLink');
    } catch (e) {
      AppLogger.debug('Error compartiendo: $e');
      rethrow;
    }
  }

  /// Compartir historia a TikTok (mediante link)
  static Future<void> shareToTikTok({
    required String storyTitle,
    required String storyId,
  }) async {
    try {
      // Generate dynamic deep link with preview
      final deepLink = await DeepLinkService().createStoryLink(storyId);

      final message = '🎬 $storyTitle\n\nMira esto en FeelTrip:\n$deepLink';

      await Share.share(message, subject: '¡Mira en FeelTrip!');

      AppLogger.debug('Compartido a TikTok exitosamente: $deepLink');
    } catch (e) {
      AppLogger.debug('Error compartiendo: $e');
      rethrow;
    }
  }

  /// Compartir generalmente con cualquier app
  static Future<void> shareGeneral({
    required String title,
    required String description,
    required String deepLink,
  }) async {
    try {
      final fullMessage = '$title\n\n$description\n\n$deepLink';

      await Share.share(
        fullMessage,
        subject: 'Comparte desde FeelTrip',
      );

      AppLogger.debug('Compartido exitosamente');
    } catch (e) {
      AppLogger.debug('Error compartiendo: $e');
      rethrow;
    }
  }

  static Future<void> shareDiaryEntry({
    required String title,
    required String content,
  }) async {
    final message = '📝 $title\n\n$content\n\nFeelTrip: https://feeltrip.app';
    await Share.share(message, subject: 'Mi diario en FeelTrip');
  }

  /// Generar deep link a una historia
  static Future<String> generateStoryDeepLink(String storyId) async {
    return DeepLinkService().createStoryLink(storyId);
  }

  /// Generar deep link a un perfil de agencia
  static Future<String> generateAgencyDeepLink(String agencyId) async {
    return DeepLinkService().createAgencyLink(agencyId);
  }

  /// Generar link de referido
  static Future<String> generateReferralLink(String referralCode) async {
    return DeepLinkService().createReferralLink(referralCode);
  }
}
