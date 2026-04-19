import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../core/logger/app_logger.dart';
import '../models/notification_model.dart';
import 'local_notification_service.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalNotificationService _local = LocalNotificationService.instance;

  final _navigationStreamController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get navigationStream =>
      _navigationStreamController.stream;

  CollectionReference<Map<String, dynamic>> _notificationsRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('notifications');
  }

  Future<void> initialize(String userId) async {
    // ── 1. Inicializar plugin de notificaciones locales ────────────────
    await _local.initialize(
      onNotificationTap: (response) {
        AppLogger.i('Notificación tap — payload: ${response.payload}');
        if (response.payload != null) {
          _navigationStreamController.add({
            'type': response.payload,
            'id': null,
          });
        }
      },
    );

    // ── 2. Permisos FCM ──────────────────────────────────────────────
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

      // ── 3. FCM: Mensaje con app en primer plano ──────────────────
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        AppLogger.i('FCM foreground: ${message.notification?.title}');
        final notification = message.notification;
        if (notification != null) {
          _local.show(
            id: LocalNotificationService.generateId(),
            title: notification.title ?? 'FeelTrip',
            body: notification.body ?? '',
            payload: message.data['type'] as String?,
          );
        }
      });

      // ── 4. FCM: Mensaje abre la app desde background ─────────────
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

      // ── 5. FCM: Mensaje inicial (app abierta desde notificación) ──
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

  /// Guarda una notificación en Firestore Y emite un push nativo en el dispositivo.
  Future<void> sendLocalNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      // 1. Persistir en Firestore (in-app notifications)
      await _notificationsRef(userId).add({
        'title': title,
        'body': body,
        'type': type,
        'data': data ?? {},
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. Push nativo en el dispositivo
      await _local.show(
        id: LocalNotificationService.generateId(),
        title: title,
        body: body,
        payload: type,
      );

      AppLogger.i('Notificación guardada + push nativo: $type');
    } catch (e) {
      AppLogger.e('Error guardando notificación: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  //  NOTIFICACIONES DE CRÓNICA IA
  // ══════════════════════════════════════════════════════════════════════

  /// Notifica al usuario que su crónica IA terminó de generarse.
  ///
  /// Se dispara tanto en generación inmediata (DiaryScreen) como en
  /// generación diferida por reconexión (PendingChronicleService).
  Future<void> notifyChronicleReady({
    required String userId,
    required String chronicleTitle,
    String? chronicleId,
  }) async {
    await sendLocalNotification(
      userId: userId,
      title: '📜 Tu crónica está lista',
      body: '"$chronicleTitle" ha sido generada por la IA. Toca para leerla.',
      type: 'chronicle_ready',
      data: {
        if (chronicleId != null) 'chronicleId': chronicleId,
        'chronicleTitle': chronicleTitle,
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  SECUENCIA DE CONVERSIÓN (TRIAL → PRO)
  // ══════════════════════════════════════════════════════════════════════

  Future<void> scheduleTrialConversionSequence({
    required String userId,
    required DateTime trialExpiresAt,
    required String? referralDiscount,
  }) async {
    final ahora = DateTime.now();
    final notificaciones = [
      {
        'offsetDias': trialExpiresAt.difference(ahora).inDays - 10,
        'title': 'Tu experiencia Pro vence en 10 días',
        'body': 'Sigues explorando con crónicas IA completas y tu arquetipo activo. No pierdas el ritmo.',
        'type': 'trial_reminder_10',
      },
      {
        'offsetDias': trialExpiresAt.difference(ahora).inDays - 5,
        'title': referralDiscount != null
            ? 'Tienes un descuento esperándote — 5 días restantes'
            : 'Solo 5 días de Pro restantes',
        'body': referralDiscount != null
            ? 'Por llegar con invitación, tu primer mes tiene precio especial. Actívalo antes de que venza.'
            : 'Tus crónicas IA, arquetipo y exportaciones siguen activas. Suscríbete para no perderlos.',
        'type': 'trial_reminder_5',
    'data': referralDiscount != null ? <String, dynamic>{'offerCode': referralDiscount} : <String, dynamic>{},
      },
      {
        'offsetDias': trialExpiresAt.difference(ahora).inDays - 2,
        'title': 'Quedan 2 días — tu arquetipo está completo',
        'body': 'Has construido tu perfil de explorador. Suscríbete hoy para seguir desarrollándolo.',
        'type': 'trial_reminder_2',
      },
      {
        'offsetDias': trialExpiresAt.difference(ahora).inDays,
        'title': 'Tu acceso Pro terminó hoy',
        'body': 'Volviste al nivel básico. Tus datos están seguros, pero las crónicas IA completas y tu arquetipo esperan que vuelvas.',
        'type': 'trial_expired',
      },
    ];

    for (final n in notificaciones) {
      final offsetDias = n['offsetDias'] as int;
      if (offsetDias <= 0) continue;
      final fechaEnvio = ahora.add(Duration(days: offsetDias));
      await _notificationsRef(userId).add({
        'title': n['title'],
        'body': n['body'],
        'type': n['type'],
        'data': n['data'] ?? {},
        'isRead': false,
        'scheduledFor': Timestamp.fromDate(fechaEnvio),
        'sent': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    AppLogger.i('Secuencia de conversión programada para $userId');
  }

  // ══════════════════════════════════════════════════════════════════════
  //  REFERRAL & BONUS
  // ══════════════════════════════════════════════════════════════════════

  Future<void> notifyReferralAccepted({
    required String userId,
    required int bonusDaysEarned,
    required int totalBonusDays,
  }) async {
    await sendLocalNotification(
      userId: userId,
      title: '¡Alguien exploró con tu código!',
      body: 'Ganaste $bonusDaysEarned días Pro extra. Llevas $totalBonusDays días acumulados.',
      type: 'referral_accepted',
      data: {'bonusDays': bonusDaysEarned, 'totalDays': totalBonusDays},
    );
  }

  Future<void> notifyBonusExpiringSoon({
    required String userId,
    required int daysRemaining,
  }) async {
    await sendLocalNotification(
      userId: userId,
      title: 'Tu acceso Pro vence en $daysRemaining días',
      body: 'Invita a otro explorador para ganar 15 días más, o suscríbete para no perder tu progreso.',
      type: 'bonus_expiring',
      data: {'daysRemaining': daysRemaining},
    );
  }
}
