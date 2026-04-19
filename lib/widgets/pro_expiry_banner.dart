import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:feeltrip_app/domain/entities/user_subscription.dart';

/// Banner que informa al usuario sobre la expiración de su acceso Pro ganado
/// mediante referidos o trial.
///
/// - [ProAlertLevel.safe] → no muestra nada
/// - [ProAlertLevel.warning] → banner amarillo sutil
/// - [ProAlertLevel.urgent] → banner naranja + botón "Extender gratis"
/// - [ProAlertLevel.critical] → banner rojo prominente + botón CTA
/// - [ProAlertLevel.none] / [ProAlertLevel.expired] → no muestra nada
///
/// El banner puede cerrarse y se suprime hasta el día siguiente usando Hive.
class ProExpiryBanner extends StatelessWidget {
  const ProExpiryBanner({super.key, required this.subscription});

  final UserSubscription subscription;

  static const _hiveBox = 'pro_banner_prefs';
  static const _dismissKey = 'banner_dismissed_date';

  // ── Lógica de dismiss persistida en Hive ─────────────────────────────────

  static bool _isDismissedToday() {
    try {
      final box = Hive.box(_hiveBox);
      final stored = box.get(_dismissKey) as String?;
      if (stored == null) return false;
      final storedDate = DateTime.tryParse(stored);
      if (storedDate == null) return false;
      final today = DateTime.now();
      return storedDate.year == today.year &&
          storedDate.month == today.month &&
          storedDate.day == today.day;
    } catch (_) {
      return false;
    }
  }

  static Future<void> _dismissForToday() async {
    try {
      final box = Hive.box(_hiveBox);
      await box.put(_dismissKey, DateTime.now().toIso8601String());
    } catch (_) {}
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final level = subscription.alertLevel;

    // No mostrar en estos casos
    if (level == ProAlertLevel.none ||
        level == ProAlertLevel.safe ||
        level == ProAlertLevel.expired) {
      return const SizedBox.shrink();
    }

    if (_isDismissedToday()) return const SizedBox.shrink();

    return _BannerContent(
      level: level,
      daysLeft: subscription.proExpiresInDays,
      proExpiresAt: subscription.proExpiresAt,
    );
  }
}

// ── Widget interno con estado para el dismiss ─────────────────────────────────

class _BannerContent extends StatefulWidget {
  const _BannerContent({
    required this.level,
    required this.daysLeft,
    this.proExpiresAt,
  });

  final ProAlertLevel level;
  final int daysLeft;
  final DateTime? proExpiresAt;

  @override
  State<_BannerContent> createState() => _BannerContentState();
}

class _BannerContentState extends State<_BannerContent> {
  bool _dismissed = false;

  void _dismiss() {
    ProExpiryBanner._dismissForToday();
    setState(() => _dismissed = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final Color bgColor;
    final Color textColor;
    final Color borderColor;
    final String message;
    final Widget? actionButton;

    final expiryText = widget.proExpiresAt != null
        ? DateFormat('d MMM yyyy', 'es').format(widget.proExpiresAt!)
        : '';

    switch (widget.level) {
      case ProAlertLevel.warning:
        bgColor = const Color(0xFFFFF9C4); // amarillo pálido
        textColor = const Color(0xFF5D4037);
        borderColor = const Color(0xFFF9A825);
        message =
            'Tu acceso Pro vence en ${widget.daysLeft} días${expiryText.isNotEmpty ? ' ($expiryText)' : ''} — invita a alguien para extenderlo.';
        actionButton = null;

      case ProAlertLevel.urgent:
        bgColor = const Color(0xFFFFE0B2); // naranja claro
        textColor = const Color(0xFFE65100);
        borderColor = const Color(0xFFFF6D00);
        message = 'Solo ${widget.daysLeft} días de Pro restantes.';
        actionButton = TextButton(
          onPressed: () => context.push('/referral'),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFE65100),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: const BorderSide(color: Color(0xFFE65100)),
            ),
          ),
          child: const Text(
            'Extender gratis',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        );

      case ProAlertLevel.critical:
        bgColor = const Color(0xFFFFEBEE); // rojo claro
        textColor = colorScheme.error;
        borderColor = colorScheme.error;
        message = 'Tu Pro vence en ${widget.daysLeft} ${widget.daysLeft == 1 ? 'día' : 'días'}.';
        actionButton = ElevatedButton(
          onPressed: () => context.push('/premium'),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.error,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Suscribirse ahora',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        );

      default:
        return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.access_time_rounded, color: textColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
                if (actionButton != null) ...[
                  const SizedBox(height: 6),
                  actionButton,
                ],
              ],
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: _dismiss,
            child: Icon(Icons.close_rounded, color: textColor.withValues(alpha: 0.6), size: 18),
          ),
        ],
      ),
    );
  }
}
