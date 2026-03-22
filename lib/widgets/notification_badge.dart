import 'package:flutter/material.dart';
import 'package:feeltrip_app/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationBadge extends StatefulWidget {
  const NotificationBadge({super.key});

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge> {
  int unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _updateCount();
  }

  Future<void> _updateCount() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final count = await NotificationService().getUnreadCount(userId);
      if (mounted) setState(() => unreadCount = count);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (unreadCount == 0) return const SizedBox();
    return Positioned(
      right: 0,
      top: 0,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        constraints: const BoxConstraints(
          minWidth: 16,
          minHeight: 16,
        ),
        child: Text(
          unreadCount > 99 ? '99+' : '$unreadCount',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
