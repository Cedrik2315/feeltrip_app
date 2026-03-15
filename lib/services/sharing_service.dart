import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';

class SharingService {
  /// Compartir historia a WhatsApp
  static Future<void> shareToWhatsApp({
    required String storyTitle,
    required String storyDescription,
    required String deepLink,
  }) async {
    try {
      final message =
          '📸 $storyTitle\n\n$storyDescription\n\n✨ Descubre más historias en FeelTrip:\n$deepLink';

      await Share.share(
        message,
        subject: '¡Mira esta historia en FeelTrip!',
      );

      debugPrint('✅ Compartido a WhatsApp exitosamente');
    } catch (e) {
      debugPrint('❌ Error compartiendo: $e');
      rethrow;
    }
  }

  /// Compartir historia a Facebook
  static Future<void> shareToFacebook({
    required String storyTitle,
    required String storyDescription,
    required String deepLink,
  }) async {
    try {
      final message =
          '🌍 $storyTitle\n\n$storyDescription\n\n🎒 FeelTrip: Conecta con viajeros\n$deepLink';

      await Share.share(
        message,
        subject: '¡Comparte esta aventura!',
      );

      debugPrint('✅ Compartido a Facebook exitosamente');
    } catch (e) {
      debugPrint('❌ Error compartiendo: $e');
      rethrow;
    }
  }

  /// Compartir historia a TikTok (mediante link)
  static Future<void> shareToTikTok({
    required String storyTitle,
    required String deepLink,
  }) async {
    try {
      final message = '🎬 $storyTitle\n\nMira esto en FeelTrip:\n$deepLink';

      await Share.share(message, subject: '¡Mira en FeelTrip!');

      debugPrint('✅ Compartido a TikTok exitosamente');
    } catch (e) {
      debugPrint('❌ Error compartiendo: $e');
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

      debugPrint('✅ Compartido exitosamente');
    } catch (e) {
      debugPrint('❌ Error compartiendo: $e');
      rethrow;
    }
  }

  /// Generar deep link a una historia
  static String generateStoryDeepLink(String storyId) {
    return 'https://feeltrip.app/story/$storyId';
  }

  /// Generar deep link a un perfil de agencia
  static String generateAgencyDeepLink(String agencyId) {
    return 'https://feeltrip.app/agency/$agencyId';
  }
}
