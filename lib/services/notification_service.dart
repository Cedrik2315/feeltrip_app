import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';
import 'package:feeltrip_app/models/notification_model.dart';
import 'package:uuid/uuid.dart';

class NotificationService {
  factory NotificationService() => _instance;
  NotificationService._internal();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static final NotificationService _instance = NotificationService._internal();
  // ignore: unused_field
  final _uuid = const Uuid();

  // Stream controller for navigation events
  final _navigationController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get navigationStream =>
      _navigationController.stream;

  /// Initialize FCM (enhanced for startup)
  Future<void> initialize() async {
    try {
      // Request permission
      final settings = await _messaging.requestPermission();
      AppLogger.i('FCM Permission: ${settings.authorizationStatus}');

      // Initialize local notifications
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings();
      const initSettings =
          InitializationSettings(android: androidSettings, iOS: iosSettings);
      await _localNotifications.initialize(initSettings);

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(const AndroidNotificationChannel(
            'high_importance_channel', // id
            'High Importance Notifications', // title
            description:
                'This channel is used for important notifications.', // description
            importance: Importance.max,
          ));

      // Get FCM token
      final token = await _messaging.getToken();
      if (token != null && FirebaseAuth.instance.currentUser != null) {
        await _firestore
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .set({'fcmToken': token}, SetOptions(merge: true));
      }

      // Foreground messages - show snackbar/local notif
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        AppLogger.i('Foreground message: ${message.notification?.title}');
        _showLocalNotification(message, data: message.data);
      });

      // Background message tap
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

      // Terminated state - handle deep link
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        AppLogger.i('Initial message: ${initialMessage.messageId}');
        final data = initialMessage.data;
        if (data['type'] != null && data['id'] != null) {
          _handleMessage(initialMessage);
        }
      }

      // Background/quit state
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // Subscribe to viral/growth topics
      await subscribeToTopics();

      AppLogger.i('✅ Growth FCM initialized + topics');
    } catch (e) {
      AppLogger.e('❌ FCM init error: $e');
    }
  }

  void _handleMessage(RemoteMessage message) {
    final data = message.data;
    if (data['type'] != null && data['id'] != null) {
      AppLogger.i('Navigation event: ${data['type']}/${data['id']}');
      _navigationController.add(data);
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message,
      {Map<String, dynamic>? data}) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: data != null ? '${data['type']}/${data['id']}' : null,
      );
    }
  }

  /// Subscribe to growth topics
  Future<void> subscribeToTopics() async {
    await _messaging.subscribeToTopic('daily_reminders');
    await _messaging.subscribeToTopic('feeltrip_growth');
    await _messaging.subscribeToTopic('agency_updates');
    AppLogger.i('Subscribed to growth topics');
  }

  /// Send like notification (Cloud Function ready)
  Future<void> sendLikeNotification(
    String targetUserId,
    String storyTitle,
  ) async {
    try {
      final doc = await _firestore.collection('users').doc(targetUserId).get();
      final token = doc.data()?['fcmToken'] as String?;

      if (token == null) return;

      AppLogger.i('Sending like notif to $targetUserId for "$storyTitle"');

      // Production: Call Cloud Function https://firebase.google.com/docs/cloud-messaging/send-message
      // Demo: Log
    } catch (e) {
      AppLogger.e('Send notif error: $e');
    }
  }

  /// Get unread count
  Future<int> getUnreadCount(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  /// Get notifications list (placeholder for provider usage)
  Future<List<NotificationModel>> getNotifications(String userId) async {
    // Implementation would go here, usually handled by Stream in UI
    return [];
  }
}

// Background message handler (top-level required)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  AppLogger.i('Background message: ${message.messageId}');
}
