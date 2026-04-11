import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/logger/app_logger.dart';
import '../models/notification_model.dart';

final notificationServiceProvider = Provider((ref) => NotificationService());

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _navigationStreamController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get navigationStream =>
      _navigationStreamController.stream;

  CollectionReference<Map<String, dynamic>> _notificationsRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('notifications');
  }

  Future<void> initialize(String userId) async {
    final NotificationSettings settings = await _fcm.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      AppLogger.i('Notificaciones autorizadas');

      final String? token = await _fcm.getToken();
      if (token != null) {
        await _firestore.collection('users').doc(userId).update({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
      }

      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

      final RemoteMessage? initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) _handleMessage(initialMessage);
    }
  }

  void _handleMessage(RemoteMessage message) {
    final data = message.data;
    final type = data['type'];
    final id = data['bookingId'] ?? data['id'];

    AppLogger.i('Notificación recibida: $type - $id');
    _navigationStreamController.add({'type': type, 'id': id});
  }

  Future<void> subscribeToTopic(String topic) async {
    await _fcm.subscribeToTopic(topic);
  }

  Future<List<NotificationModel>> getNotifications({String? userId}) async {
    final resolvedUserId = userId ?? FirebaseAuth.instance.currentUser?.uid;
    if (resolvedUserId == null) return [];

    final snap = await _notificationsRef(resolvedUserId)
        .orderBy('createdAt', descending: true)
        .get();

    return snap.docs
        .map((d) => NotificationModel.fromFirestore(d.id, d.data()))
        .toList();
  }

  Future<int> getUnreadCount({String? userId}) async {
    final resolvedUserId = userId ?? FirebaseAuth.instance.currentUser?.uid;
    if (resolvedUserId == null) return 0;

    final snap = await _notificationsRef(resolvedUserId)
        .where('isRead', isEqualTo: false)
        .get();
    return snap.docs.length;
  }

  Future<void> markAsRead(String id, {String? userId}) async {
    final resolvedUserId = userId ?? FirebaseAuth.instance.currentUser?.uid;
    if (resolvedUserId == null) return;

    await _notificationsRef(resolvedUserId).doc(id).update({'isRead': true});
  }
}
