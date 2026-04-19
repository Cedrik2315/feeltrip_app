import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';

class UrlLauncherService {
  /// Lanza una URL utilizando Custom Tabs (Android/iOS) para una experiencia premium.
  /// Si falla o no hay navegador, intenta el modo fallback.
  static Future<void> openUrl(BuildContext context, String urlString) async {
    final theme = Theme.of(context);
    final uri = Uri.parse(urlString);

    try {
      await launchUrl(
        uri,
        customTabsOptions: CustomTabsOptions(
          colorSchemes: CustomTabsColorSchemes.defaults(
            toolbarColor: theme.colorScheme.surface,
            navigationBarColor: theme.colorScheme.surface,
          ),
          shareState: CustomTabsShareState.on,
          urlBarHidingEnabled: true,
          showTitle: true,
          closeButton: CustomTabsCloseButton(
            icon: CustomTabsCloseButtonIcons.back,
          ),
          animations: const CustomTabsAnimations(
            startEnter: 'slide_up',
            startExit: 'android:anim/fade_out',
            endEnter: 'android:anim/fade_in',
            endExit: 'slide_down',
          ),
        ),
        safariVCOptions: SafariViewControllerOptions(
          preferredBarTintColor: theme.colorScheme.surface,
          preferredControlTintColor: theme.colorScheme.primary,
          barCollapsingEnabled: true,
          entersReaderIfAvailable: false,
          dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
        ),
      );
    } catch (e) {
      AppLogger.e('UrlLauncherService Error: $e');
      // Intento de fallback bÃ¡sico si Custom Tabs falla
      // Nota: launchUrl aquÃ­ es la de flutter_custom_tabs, que ya maneja fallback
    }
  }
}
