import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../core/logger/app_logger.dart';

/// [Sello FeelTrip]: Servicio singleton que gestiona las notificaciones push
/// nativas del dispositivo usando `flutter_local_notifications`.
///
/// Responsable de:
/// - Inicializar el plugin con canales Android e iOS.
/// - Mostrar notificaciones instantáneas (heads-up).
/// - Proveer un punto de extensión para notificaciones programadas.
class LocalNotificationService {
  LocalNotificationService._();
  static final LocalNotificationService instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  /// Canal principal de notificaciones — coincide con el `default_notification_channel_id`
  /// definido en AndroidManifest.xml.
  static const String _channelId = 'high_importance_channel';
  static const String _channelName = 'FeelTrip Alertas';
  static const String _channelDescription =
      'Notificaciones de crónicas, cápsulas y expediciones';

  /// Inicializa el plugin. Debe llamarse una sola vez, idealmente durante
  /// el arranque de la app o tras el login.
  Future<void> initialize({
    void Function(NotificationResponse)? onNotificationTap,
  }) async {
    if (_initialized) return;

    // ── Android ───────────────────────────────────────────────────────────
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ft_launcher',
    );

    // ── iOS / macOS ──────────────────────────────────────────────────────
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: onNotificationTap ?? _defaultTapHandler,
    );

    // Crear canal Android explícitamente (Android 8+)
    if (Platform.isAndroid) {
      final androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDescription,
            importance: Importance.high,
            playSound: true,
            enableVibration: true,
            showBadge: true,
          ),
        );
      }
    }

    _initialized = true;
    AppLogger.i('LocalNotificationService: Inicializado correctamente.');
  }

  /// Muestra una notificación push nativa inmediata.
  ///
  /// [id] — Identificador numérico único de la notificación.
  /// [title] — Título visible en la barra de estado.
  /// [body] — Cuerpo del mensaje.
  /// [payload] — Datos opcionales para manejar el tap.
  Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) {
      AppLogger.w('LocalNotificationService: No inicializado. Llamando initialize()...');
      await initialize();
    }

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ft_launcher',
      styleInformation: BigTextStyleInformation(''),
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await _plugin.show(id: id, title: title, body: body, notificationDetails: details, payload: payload);
    AppLogger.i('LocalNotificationService: Push mostrado — "$title"');
  }

  /// Genera un ID de notificación basado en timestamp (evita colisiones simples).
  static int generateId() =>
      DateTime.now().millisecondsSinceEpoch.remainder(100000);

  void _defaultTapHandler(NotificationResponse response) {
    AppLogger.i(
      'LocalNotificationService: Tap en notificación — payload: ${response.payload}',
    );
  }
}
