import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:feeltrip_app/core/providers/connectivity_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final connectivity = ref.watch(connectivityProvider);
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Requiere login')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              return FutureBuilder<int>(
                future: Future.value(0),
                // future: NotificationService().getUnreadCount(userId),
                builder: (context, snapshot) {
                  final count = snapshot.data ?? 0;
                  if (count == 0) return const SizedBox();
                  return Badge(
                    label: Text('$count'),
                    child: const Icon(Icons.notifications),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: connectivity.when(
        data: (status) => StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('users')
              .doc(userId)
              .collection('notifications')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Error cargando notificaciones'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final notifications = snapshot.data?.docs ?? [];
            if (notifications.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No hay notificaciones',
                        style: TextStyle(fontSize: 18)),
                  ],
                ),
              );
            }
            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final data =
                    notifications[index].data() as Map<String, dynamic>;
                final notification = NotificationModel.fromJson({
                  ...data,
                  'id': notifications[index].id,
                });
                final bool isRead = data['isRead'] == true;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: notification.imageUrl != null
                        ? NetworkImage(notification.imageUrl!)
                        : null,
                    child: notification.imageUrl == null
                        ? const Icon(Icons.notifications)
                        : null,
                  ),
                  title: Text(notification.title),
                  subtitle: Text(notification.body),
                  trailing: isRead
                      ? null
                      : const Icon(Icons.circle, color: Colors.blue, size: 12),
                  onTap: () {
                    _firestore
                        .collection('users')
                        .doc(userId)
                        .collection('notifications')
                        .doc(notification.id)
                        .update({'isRead': true});
                    if (notification.actionId != null) {
                      switch (notification.actionType) {
                        case 'story':
                          break;
                        case 'booking':
                          break;
                      }
                    }
                  },
                );
              },
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error de conectividad')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        // ref.read(notificationServiceProvider).subscribeToTopics();
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
