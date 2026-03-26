import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import '../core/logger/app_logger.dart';
import '../core/models/user_preferences.dart';
import '../models/notification_model.dart';

class NotificationService {
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final NotificationService _instance = NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final Set<String> _notifiedGeofences = {};
  final _navigationController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get navigationStream =>
      _navigationController.stream;

  Future<void> initialize() async {
    try {
      tz.initializeTimeZones();

      final settings = await _messaging.requestPermission();
      AppLogger.i('FCM Permission: ${settings.authorizationStatus}');

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
            'high_importance_channel',
            'High Importance Notifications',
            description: 'This channel is used for important notifications.',
            importance: Importance.max,
          ));

      final token = await _messaging.getToken();
      if (token != null && FirebaseAuth.instance.currentUser != null) {
        await _firestore
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .set({'fcmToken': token}, SetOptions(merge: true));

        final uid = FirebaseAuth.instance.currentUser!.uid;
        final agencySnapshot = await _firestore
            .collection('agencies')
            .where('ownerUid', isEqualTo: uid)
            .get();
        for (final doc in agencySnapshot.docs) {
          await doc.reference.set({'fcmToken': token}, SetOptions(merge: true));
        }
      }

      FirebaseMessaging.onMessage.listen((message) {
        AppLogger.i('Foreground message: ${message.notification?.title}');
        _showLocalNotification(message, data: message.data);
      });

      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        AppLogger.i('Initial message: ${initialMessage.messageId}');
        final data = initialMessage.data;
        if (data['type'] != null && data['id'] != null) {
          _handleMessage(initialMessage);
        }
      }

      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);
      await subscribeToTopics();

      AppLogger.i('Growth FCM initialized + topics');
    } catch (error) {
      AppLogger.e('FCM init error: $error');
    }
  }

  Future<void> scheduleLocationNotification() async {
    AppLogger.i('Location scheduling logic ready for geofencing');
  }

  Future<void> showInstantNotification(
    String title,
    String body, {
    bool isPriority = false,
    UserPreferences? prefs,
  }) async {
    if (prefs != null && isInsideQuietHours(prefs) && !isPriority) {
      AppLogger.i('Notification suppressed by quiet hours');
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
    );
  }

  static bool isInsideQuietHours(UserPreferences prefs) {
    if (!prefs.isQuietModeEnabled) {
      return false;
    }

    final now = DateTime.now();
    final currentHour = now.hour;
    final startHour = prefs.startHour;
    final endHour = prefs.endHour;

    if (startHour == endHour) {
      return true;
    }
    if (startHour < endHour) {
      return currentHour >= startHour && currentHour < endHour;
    }
    return currentHour >= startHour || currentHour < endHour;
  }

  Future<void> checkProximityAndNotify({
    required Position userPosition,
    required String targetId,
    required String targetName,
    required double targetLat,
    required double targetLng,
    double radiusInMeters = 500,
  }) async {
    final distance = Geolocator.distanceBetween(
      userPosition.latitude,
      userPosition.longitude,
      targetLat,
      targetLng,
    );

    if (distance <= radiusInMeters && !_notifiedGeofences.contains(targetId)) {
      _notifiedGeofences.add(targetId);
      AppLogger.i('Geofence entry: $targetName ($distance m)');
      await showInstantNotification(
        'Destino cercano',
        'Estas muy cerca de $targetName. Abre FeelTrip para ver que hay aqui.',
      );
    } else if (distance > radiusInMeters * 2) {
      _notifiedGeofences.remove(targetId);
    }
  }

  void _handleMessage(RemoteMessage message) {
    final data = message.data;
    if (data['type'] != null && data['id'] != null) {
      AppLogger.i('Navigation event: ${data['type']}/${data['id']}');
      _navigationController.add(data);
    }
  }

  Future<void> _showLocalNotification(
    RemoteMessage message, {
    Map<String, dynamic>? data,
  }) async {
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

  Future<void> subscribeToTopics() async {
    await _messaging.subscribeToTopic('daily_reminders');
    await _messaging.subscribeToTopic('feeltrip_growth');
    await _messaging.subscribeToTopic('agency_updates');
    AppLogger.i('Subscribed to growth topics');
  }

  Future<void> sendLikeNotification(
    String targetUserId,
    String storyTitle,
  ) async {
    try {
      final doc = await _firestore.collection('users').doc(targetUserId).get();
      final token = doc.data()?['fcmToken'] as String?;
      if (token == null) return;

      AppLogger.i('Sending like notif to $targetUserId for "$storyTitle"');
    } catch (error) {
      AppLogger.e('Send notif error: $error');
    }
  }

  Future<void> sendCommentNotification(
    String targetUserId,
    String storyTitle,
    String storyId,
  ) async {
    try {
      final doc = await _firestore.collection('users').doc(targetUserId).get();
      final token = doc.data()?['fcmToken'] as String?;
      if (token == null) return;

      AppLogger.i('Sending comment notif to $targetUserId for story $storyId');

      await _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('notifications')
          .add({
        'title': 'Nuevo comentario',
        'body': 'Alguien esta interesado en tus experiencias.',
        'type': 'story_comments',
        'storyId': storyId,
        'storyTitle': storyTitle,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      AppLogger.e('Send comment notif error: $error');
    }
  }

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

  Future<List<NotificationModel>> getNotifications(String userId) async {
    return [];
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  AppLogger.i('Background message: ${message.messageId}');
}
