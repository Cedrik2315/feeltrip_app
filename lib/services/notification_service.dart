import 'dart:io';
import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

/// Servicio de notificaciones push para FeelTrip
/// Utiliza Firebase Cloud Messaging para enviar notificaciones
class NotificationService {
  NotificationService({
    FirebaseMessaging? messaging,
    FirebaseAuth? auth,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseMessaging _messaging;
  final FirebaseAuth _auth;

  // ignore: unused_field - Para uso futuro con flutter_local_notifications
  // static const String _channelId = 'feeltrip_notifications';
  // static const String _channelName = 'FeelTrip Notifications';
  // static const String _channelDescription = 'Notificaciones de viajes y promociones';

  bool _isInitialized = false;

  /// Inicializa el servicio de notificaciones
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Solicitar permisos en iOS
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      developer.log(
        'Notification permission status: ${settings.authorizationStatus}',
        name: 'NotificationService',
      );

      // Obtener token del dispositivo
      final token = await _getDeviceToken();
      if (token != null) {
        await _saveTokenToUser(token);
      }

      // Configurar handling de mensajes en foreground
      _setupForegroundHandler();

      // Configurar handling de mensajes en background
      _setupBackgroundHandler();

      _isInitialized = true;
    } catch (e, st) {
      developer.log(
        'Error initializing notifications',
        name: 'NotificationService',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Obtiene el token del dispositivo
  Future<String?> _getDeviceToken() async {
    try {
      // En debug, usar vapid key alternativa
      if (kDebugMode) {
        return await _messaging.getToken(
          vapidKey: dotenv.env['VAPID_KEY'],
        );
      }
      return await _messaging.getToken();
    } catch (e) {
      developer.log(
        'Error getting device token',
        name: 'NotificationService',
        error: e,
      );
      return null;
    }
  }

  /// Guarda el token en el perfil del usuario
  Future<void> _saveTokenToUser(String token) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Guardar en Firestore o Preferences
        developer.log(
          'Token saved for user: ${user.uid}',
          name: 'NotificationService',
        );
      }
    } catch (e) {
      developer.log(
        'Error saving token',
        name: 'NotificationService',
        error: e,
      );
    }
  }

  /// Configura el handler para notificaciones en foreground
  void _setupForegroundHandler() {
    FirebaseMessaging.onMessage.listen((message) {
      developer.log(
        'Received foreground message: ${message.notification?.title}',
        name: 'NotificationService',
      );
      _handleNotification(message);
    });
  }

  /// Configura el handler para notificaciones en background
  void _setupBackgroundHandler() {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      developer.log(
        'Opened app from notification: ${message.notification?.title}',
        name: 'NotificationService',
      );
      _handleNotificationTap(message);
    });
  }

  /// Maneja la notificación recibida
  void _handleNotification(RemoteMessage message) {
    final data = message.data;
    final notification = message.notification;

    developer.log(
      'Notification data: $data',
      name: 'NotificationService',
    );

    // Aquí puedes mostrar una alerta in-app o actualizar el UI
    if (notification != null) {
      // Procesar notificación
    }
  }

  /// Maneja el tap en la notificación
  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;

    // Navegar según el tipo de notificación
    final route = data['route'];
    if (route != null) {
      developer.log(
        'Navigate to: $route',
        name: 'NotificationService',
      );
      // Aquí usarías el router para navegar
    }
  }

  /// Suscribe al usuario a un tema
  Future<bool> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      developer.log(
        'Subscribed to topic: $topic',
        name: 'NotificationService',
      );
      return true;
    } catch (e) {
      developer.log(
        'Error subscribing to topic: $topic',
        name: 'NotificationService',
        error: e,
      );
      return false;
    }
  }

  /// Desuscribe al usuario de un tema
  Future<bool> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      developer.log(
        'Unsubscribed from topic: $topic',
        name: 'NotificationService',
      );
      return true;
    } catch (e) {
      developer.log(
        'Error unsubscribing from topic: $topic',
        name: 'NotificationService',
        error: e,
      );
      return false;
    }
  }

  /// Envía una notificación local
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    // Para notificaciones locales, usa flutter_local_notifications
    // Esta es una implementación básica
    developer.log(
      'Local notification: $title - $body',
      name: 'NotificationService',
    );
  }

  /// Obtiene el token actual
  Future<String?> getCurrentToken() async {
    return await _messaging.getToken();
  }

  /// Elimina el token (para logout)
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      developer.log(
        'Token deleted',
        name: 'NotificationService',
      );
    } catch (e) {
      developer.log(
        'Error deleting token',
        name: 'NotificationService',
        error: e,
      );
    }
  }

  /// Verifica si las notificaciones están habilitadas
  Future<bool> isNotificationEnabled() async {
    try {
      final settings = await _messaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      return false;
    }
  }

  /// Abre la configuración de notificaciones del sistema
  Future<void> openNotificationSettings() async {
    if (Platform.isIOS) {
      // Abrir configuración de iOS
      developer.log(
        'Open iOS notification settings',
        name: 'NotificationService',
      );
    } else if (Platform.isAndroid) {
      // Abrir configuración de Android
      developer.log(
        'Open Android notification settings',
        name: 'NotificationService',
      );
    }
  }
}

/// Tipos de notificaciones
enum NotificationType {
  tripReminder,
  bookingConfirmation,
  newMessage,
  promotion,
  diaryReminder,
  reviewRequest,
}

/// Extensión para obtener información de los tipos
extension NotificationTypeExtension on NotificationType {
  String get topic {
    switch (this) {
      case NotificationType.tripReminder:
        return 'trip_reminders';
      case NotificationType.bookingConfirmation:
        return 'bookings';
      case NotificationType.newMessage:
        return 'messages';
      case NotificationType.promotion:
        return 'promotions';
      case NotificationType.diaryReminder:
        return 'diary';
      case NotificationType.reviewRequest:
        return 'reviews';
    }
  }
}
