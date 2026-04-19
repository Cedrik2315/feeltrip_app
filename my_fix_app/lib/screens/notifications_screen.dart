import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';
import 'package:feeltrip_app/core/di/providers.dart' as di_providers;
import 'package:feeltrip_app/core/providers/connectivity_provider.dart';
import 'package:feeltrip_app/models/notification_model.dart';
import 'package:feeltrip_app/presentation/providers/engagement_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  // Identidad FeelTrip
  static const Color boneWhite = Color(0xFFF5F5DC);
  static const Color carbon = Color(0xFF1A1A1A);
  static const Color deepPurple = Colors.deepPurple;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityProvider);
    final userId = ref.read(di_providers.firebaseAuthProvider).currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        backgroundColor: boneWhite,
        body: Center(
          child: Text('LOG: AUTH_REQUIRED',
              style: GoogleFonts.jetBrainsMono(
                  color: carbon.withValues(alpha: 0.5))),
        ),
      );
    }

    final notificationService =
        ref.watch(di_providers.notificationServiceProvider);
    final unreadCountAsync =
        ref.watch(unreadNotificationsCountProvider(userId));
    final notificationsAsync = ref.watch(notificationsProvider(userId));

    return Scaffold(
      backgroundColor: boneWhite,
      appBar: AppBar(
        title: Text('CENTRO DE NOTIFICACIONES',
            style: GoogleFonts.jetBrainsMono(
                fontSize: 14, fontWeight: FontWeight.bold)),
        backgroundColor: carbon,
        foregroundColor: boneWhite,
        elevation: 0,
        actions: [
          unreadCountAsync.when(
            data: (count) => count > 0
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Badge(
                        label: Text('$count'),
                        backgroundColor: Colors.redAccent,
                        child: const Icon(Icons.notifications_none_rounded,
                            size: 22),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: connectivity.when(
        data: (isConnected) {
          // ConnectivityResult is an enum, not a bool
          final isOffline = isConnected == ConnectivityResult.none;
          if (isOffline) return _buildOfflineView();

          return notificationsAsync.when(
            loading: () => const Center(
                child:
                    CircularProgressIndicator(color: carbon, strokeWidth: 1)),
            error: (error, _) => Center(
                child: Text('// ERROR_SYNC: $error',
                    style: GoogleFonts.jetBrainsMono(
                        fontSize: 11, color: Colors.red))),
            data: (notifications) {
              if (notifications.isEmpty) return _buildEmptyView();

              return RefreshIndicator(
                color: carbon,
                onRefresh: () async {
                  ref.invalidate(notificationsProvider(userId));
                  ref.invalidate(unreadNotificationsCountProvider(userId));
                },
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) => Divider(
                      height: 1,
                      indent: 84,
                      color: carbon.withValues(alpha: 0.05)),
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return _NotificationTile(
                      notification: notification,
                      onTap: () async {
                        await notificationService.markAsRead(notification.id,
                            userId: userId);
                        if (context.mounted) {
                          _navigateFromNotification(context, notification);
                          ref.invalidate(
                              unreadNotificationsCountProvider(userId));
                        }
                      },
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator(color: carbon)),
        error: (_, __) => const Center(child: Text('CONN FAILURE')),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 64, color: carbon.withValues(alpha: 0.1)),
          const SizedBox(height: 24),
          Text('HISTORIAL VACÍO',
              style: GoogleFonts.jetBrainsMono(
                  fontSize: 12, fontWeight: FontWeight.bold, color: carbon)),
          const SizedBox(height: 8),
          Text('No hay nuevos reportes de viaje.',
              style: GoogleFonts.inter(
                  fontSize: 13, color: carbon.withValues(alpha: 0.5))),
        ],
      ),
    );
  }

  Widget _buildOfflineView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.orange),
          const SizedBox(height: 16),
          Text('MODO OFFLINE ACTIVO',
              style: GoogleFonts.jetBrainsMono(
                  fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          Text('Reconéctate para sincronizar alertas.',
              style: GoogleFonts.inter(
                  fontSize: 12, color: carbon.withValues(alpha: 0.5))),
        ],
      ),
    );
  }

  void _navigateFromNotification(
      BuildContext context, NotificationModel notification) {
    final actionId = notification.actionId;
    if (actionId == null || actionId.isEmpty) return;

    final type = notification.actionType ?? notification.type;

    switch (type) {
      case 'story':
      case 'story_comments':
        context.push('/comments/$actionId');
        break;
      case 'booking':
      case 'booking_confirm':
        context.pushNamed('bookings');
        break;
      default:
        AppLogger.w('Notificación: Acción de tipo desconocido ($type) para ID: $actionId');
    }
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});
  final NotificationModel notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isRead = notification.isRead ?? false; // isRead may be nullable from model
    final Color carbon = const Color(0xFF1A1A1A);

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      tileColor: isRead ? null : carbon.withValues(alpha: 0.03),
      leading: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: carbon.withValues(alpha: 0.05),
          image: notification.imageUrl != null
              ? DecorationImage(
                  image: NetworkImage(notification.imageUrl!),
                  fit: BoxFit.cover)
              : null,
          borderRadius:
              BorderRadius.circular(4), // EstÃ©tica cuadrada industrial
        ),
        child: notification.imageUrl == null
            ? Icon(Icons.sensors_rounded,
                color: carbon.withValues(alpha: 0.4), size: 20)
            : null,
      ),
      title: Text(
        notification.title.toUpperCase(),
        style: GoogleFonts.jetBrainsMono(
          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
          fontSize: 12,
          color: carbon,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(notification.body,
              maxLines: 2,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color: carbon.withValues(alpha: isRead ? 0.5 : 0.8),
                  height: 1.3)),
          const SizedBox(height: 6),
          Text(
            notification.createdAt != null
                ? 'LOG_TS: ${DateFormat('dd/MM/yyyy HH:mm').format(notification.createdAt!)}'
                : 'LOG_TS: --/--/---- 00:00',
            style: GoogleFonts.jetBrainsMono(
                fontSize: 9, color: carbon.withValues(alpha: 0.3)),
          ),
        ],
      ),
      trailing: !isRead
          ? Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                  color: Colors.blueAccent, shape: BoxShape.circle),
            )
          : null,
    );
  }
}
