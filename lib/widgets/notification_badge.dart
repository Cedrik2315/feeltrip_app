import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      final count = await NotificationService().getUnreadCount(userId: userId);
      if (mounted) {
        setState(() => unreadCount = count);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (unreadCount == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: const BoxDecoration(
        // Cambiamos el rojo genÃ©rico por el naranja de FeelTrip o un carmesÃ­ tÃ©cnico
        color: Color(0xFFFF8F00), 
        borderRadius: BorderRadius.zero, // Estilo brutalista: bordes rectos
      ),
      constraints: const BoxConstraints(
        minWidth: 14,
        minHeight: 14,
      ),
      child: Center(
        child: Text(
          unreadCount > 9 ? '9+' : '$unreadCount',
          style: GoogleFonts.jetBrainsMono(
            color: Colors.black, // Texto negro sobre fondo naranja para mÃ¡ximo contraste
            fontSize: 9,
            fontWeight: FontWeight.w900,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
