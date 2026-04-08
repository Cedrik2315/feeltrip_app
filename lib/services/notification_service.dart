import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/logger/app_logger.dart';
import '../models/notification_model.dart';

final notificationServiceProvider = Provider((ref) => NotificationService());

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream para comunicar eventos de navegación a la UI
  final _navigationStreamController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get navigationStream => _navigationStreamController.stream;

  /// Inicializa las notificaciones y guarda el token del usuario.
  Future<void> initialize(String userId) async {
    // 1. Solicitar permisos (crítico en iOS)
    final NotificationSettings settings = await _fcm.requestPermission(
      
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      AppLogger.i('Notificaciones autorizadas');
      
      // 2. Obtener y guardar token
      final String? token = await _fcm.getToken();
      if (token != null) {
        await _firestore.collection('users').doc(userId).update({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
      }

      // 3. Manejar notificaciones en segundo plano/cerrada
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
      
      // 4. Verificar si la app se abrió desde una notificación
      final RemoteMessage? initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) _handleMessage(initialMessage);
    }
  }

  void _handleMessage(RemoteMessage message) {
    final data = message.data;
    final type = data['type'];
    final id = data['bookingId'] ?? data['id']; // Soporta ambos formatos

    AppLogger.i('Notificación recibida: $type - $id');

    // Enviamos el payload al stream para que main.dart maneje el router
    _navigationStreamController.add({'type': type, 'id': id});
  }

  /// Suscribirse a temas de interés (ej. ofertas de último minuto)
  Future<void> subscribeToTopic(String topic) async {
    await _fcm.subscribeToTopic(topic);
  }

  Future<List<NotificationModel>> getNotifications() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return [];
    final snap = await _firestore.collection('notifications')
      .where('userId', isEqualTo: userId).get();
    return snap.docs
      .map((d) => NotificationModel.fromJson(d.data()))
      .toList();
  }

  Future<int> getUnreadCount() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return 0;
    final snap = await _firestore.collection('notifications')
      .where('userId', isEqualTo: userId)
      .where('read', isEqualTo: false).get();
    return snap.docs.length;
  }

  Future<void> markAsRead(String id) async {
    await _firestore.collection('notifications').doc(id).update({'read': true});
  }
}
