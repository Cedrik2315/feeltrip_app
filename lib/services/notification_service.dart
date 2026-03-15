import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initialize FCM (task #2)
  Future<void> initialize() async {
    try {
      // Request permission
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // log eliminado: User granted permission: ${settings.authorizationStatus}

      // Get FCM token
      String? token = await _messaging.getToken();
      if (token != null && FirebaseAuth.instance.currentUser != null) {
        await _firestore
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({'fcmToken': token});
      }

      // Foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        // log eliminado: Got foreground message: ${message.notification?.title}
        // Show local notification or snackbar
      });

      // Terminated state
      RemoteMessage? initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        // Handle navigation
      }

      // Background handler (top level function required)
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // log eliminado: ✅ Notification service initialized
    } catch (e) {
      // log eliminado: ❌ Error initializing notifications: $e
    }
  }

  /// Send like notification (task #2)
  Future<void> sendLikeNotification(
      String targetUserId, String storyTitle) async {
    try {
      // Get target FCM token
      final doc = await _firestore.collection('users').doc(targetUserId).get();
      final token = doc.data()?['fcmToken'] as String?;

      if (token == null) return;

      // Send via server or Cloud Function
      // For demo, print
      // log eliminado: 📱 Sending like notification to $targetUserId for "$storyTitle"
      // log eliminado: Token: $token

      // Real impl would use HTTP to FCM server
    } catch (e) {
      // log eliminado: ❌ Error sending notification: $e
    }
  }
}

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // log eliminado: Handling background message: ${message.messageId}
}
