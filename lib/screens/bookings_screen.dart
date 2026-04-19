import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:feeltrip_app/models/booking_model.dart';
import 'package:feeltrip_app/models/trip_model.dart';
import 'package:feeltrip_app/presentation/providers/trip_provider.dart';

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> {
  Timer? _refreshTimer;

  // Paleta FeelTrip
  static const Color boneWhite = Color(0xFFF5F5DC);
  static const Color carbonBlack = Color(0xFF1A1A1A);
  static const Color mossGreen = Color(0xFF4B5320);
  static const Color rustyEarth = Color(0xFFA52A2A);

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _syncAutoRefresh(String userId, List<BookingModel> bookings) {
    final hasPendingWebhook = bookings.any((booking) =>
        booking.status != 'confirmed' &&
        booking.preferenceId != null &&
        booking.paymentId == null);

    if (!hasPendingWebhook) {
      _refreshTimer?.cancel();
      _refreshTimer = null;
      return;
    }

    _refreshTimer ??= Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) {
        ref.invalidate(bookingsProvider(userId));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        backgroundColor: boneWhite,
        body: Center(
          child: Text('> ERROR: AUTH_REQUIRED', 
            style: GoogleFonts.jetBrainsMono(color: rustyEarth)),
        ),
      );
    }

    final bookingsAsync = ref.watch(bookingsProvider(user.uid));

    return Scaffold(
      backgroundColor: boneWhite,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: carbonBlack,
        title: Text('MIS RESERVAS.log', 
          style: GoogleFonts.jetBrainsMono(color: boneWhite, fontSize: 16)),
        iconTheme: const IconThemeData(color: boneWhite),
      ),
      body: bookingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: mossGreen)),
        error: (error, _) => Center(child: Text('// SYS_ERROR: $error', style: GoogleFonts.jetBrainsMono())),
        data: (bookings) {
          _syncAutoRefresh(user.uid, bookings);

          if (bookings.isEmpty) {
            return _EmptyBookingsView(onAction: () => context.pop());
          }

          final pendingWebhookCount = bookings
              .where((booking) =>
                  booking.status != 'confirmed' &&
                  booking.preferenceId != null &&
                  booking.paymentId == null)
              .length;

          return RefreshIndicator(
            color: mossGreen,
            onRefresh: () async => ref.refresh(bookingsProvider(user.uid).future),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length + (pendingWebhookCount > 0 ? 1 : 0),
              itemBuilder: (context, index) {
                if (pendingWebhookCount > 0 && index == 0) {
                  return _PendingWebhookBanner(count: pendingWebhookCount);
                }

                final bookingIndex = pendingWebhookCount > 0 ? index - 1 : index;
                final booking = bookings[bookingIndex];
                final tripAsync = ref.watch(tripPreviewProvider(booking.destinationId));
                
                return _BookingCard(
                  booking: booking,
                  trip: tripAsync.valueOrNull,
                  onViewDetails: tripAsync.valueOrNull == null
                      ? null
                      : () => context.push('/trip-details/${tripAsync.valueOrNull!.id}'),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _EmptyBookingsView extends StatelessWidget {
  const _EmptyBookingsView({required this.onAction});
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 48, color: Color(0xFF4B5320)),
          const SizedBox(height: 16),
          Text(
            'NINGUNA EXPEDICION ENCONTRADA',
            style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: onAction,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF1A1A1A)),
              shape: const RoundedRectangleBorder(),
            ),
            child: Text('EXPLORAR MAPA', style: GoogleFonts.jetBrainsMono(color: const Color(0xFF1A1A1A))),
          ),
        ],
      ),
    );
  }
}

class _PendingWebhookBanner extends StatelessWidget {
  const _PendingWebhookBanner({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border.all(color: const Color(0xFFA52A2A)),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 16, height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFA52A2A)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'WAITING_FOR_WEBHOOK: $count RESERVA(S) PENDIENTE(S)',
              style: GoogleFonts.jetBrainsMono(color: const Color(0xFFF5F5DC), fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking, required this.trip, required this.onViewDetails});
  final BookingModel booking;
  final Trip? trip;
  final VoidCallback? onViewDetails;

  @override
  Widget build(BuildContext context) {
    final title = trip?.title ?? 'ID_${booking.destinationId}';
    final date = trip?.destination ?? DateFormat('dd/MM').format(booking.createdAt) ?? 'N/A';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5DC),
        border: Border.all(color: const Color(0xFF1A1A1A).withValues(alpha: 0.2)),
      ),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(),
        title: Text(title.toUpperCase(), 
          style: GoogleFonts.ebGaramond(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text('DATE: $date', 
          style: GoogleFonts.jetBrainsMono(fontSize: 11, color: const Color(0xFF4B5320))),
        trailing: _StatusBadge(status: booking.status.name),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            color: const Color(0xFF1A1A1A).withValues(alpha: 0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TechnicalRow(label: 'UUID', value: booking.id),
                _TechnicalRow(label: 'PRICE', value: '\$${booking.priceUsd.toStringAsFixed(0)} ${booking.currency}'),
                _TechnicalRow(label: 'PYMNT_ID', value: booking.paymentId ?? 'PENDING_WEBHOOK'),
                _TechnicalRow(label: 'SYNC_STATUS', value: booking.isSynced ? 'OK' : 'SYNC_REQUIRED'),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: onViewDetails,
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1A1A),
                      shape: const RoundedRectangleBorder(),
                    ),
                    child: Text('>> VER EXPEDICION', style: GoogleFonts.jetBrainsMono(color: const Color(0xFFF5F5DC))),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _TechnicalRow extends StatelessWidget {
  const _TechnicalRow({required this.label, required this.value});
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.jetBrainsMono(color: const Color(0xFF1A1A1A), fontSize: 11),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFA52A2A))),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final color = status == 'confirmed' ? const Color(0xFF4B5320) : const Color(0xFFA52A2A);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(border: Border.all(color: color)),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.jetBrainsMono(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}