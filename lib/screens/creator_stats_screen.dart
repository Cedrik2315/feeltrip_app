import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:feeltrip_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:feeltrip_app/presentation/providers/engagement_provider.dart';

class CreatorStatsScreen extends ConsumerWidget {
  const CreatorStatsScreen({super.key});

  static const Color boneWhite = Color(0xFFF5F5DC);
  static const Color carbonBlack = Color(0xFF1A1A1A);
  static const Color mossGreen = Color(0xFF4B5320);
  static const Color signalOrange = Color(0xFFFF8C00);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUserAsync = ref.watch(authNotifierProvider);
    final userId = authUserAsync.whenOrNull(data: (user) => user?.id);

    if (userId == null) {
      return _buildTerminalError(
        icon: Icons.sensors_off,
        code: 'AUTH_REQUIRED',
        message: 'Inicia sesión para recibir telemetría de red.',
      );
    }

    final statsAsync = ref.watch(creatorStatsProvider(userId));

    return Scaffold(
      backgroundColor: boneWhite,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: carbonBlack,
        centerTitle: false,
        title: Text('CREATOR METRICS.sys', 
          style: GoogleFonts.jetBrainsMono(color: boneWhite, fontSize: 13, letterSpacing: 1)),
        iconTheme: const IconThemeData(color: boneWhite, size: 20),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: mossGreen, strokeWidth: 2)),
        error: (error, _) => _buildTerminalError(
          icon: Icons.error_outline,
          code: 'DATA_FETCH_ERROR',
          message: error.toString(),
        ),
        data: (stats) {
          return RefreshIndicator(
            color: mossGreen,
            onRefresh: () async => ref.refresh(creatorStatsProvider(userId).future),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionHeader(title: 'DATA OVERVIEW'),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _StatTerminalCard('STRS', stats.totalStories.toString())),
                      const SizedBox(width: 10),
                      Expanded(child: _StatTerminalCard('LKS', stats.totalLikes.toString())),
                      const SizedBox(width: 10),
                      Expanded(child: _StatTerminalCard('CMTS', stats.totalComments.toString())),
                    ],
                  ),
                  const SizedBox(height: 40),
                  const _SectionHeader(title: 'ACTIVITY LOG'),
                  const SizedBox(height: 24),
                  _ActivityLogSummary(monthlyActivity: stats.monthlyActivity),
                  const SizedBox(height: 40),
                  const _TerminalLogs(
                    message: 'La telemetría visual avanzada ha sido migrada al Observatorio de Tendencias externo para optimizar el rendimiento del sistema.',
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTerminalError({required IconData icon, required String code, required String message}) {
    return Scaffold(
      backgroundColor: boneWhite,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: carbonBlack.withValues(alpha: 0.2)),
              const SizedBox(height: 24),
              Text('// ERROR: $code', 
                style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.red.shade900)),
              const SizedBox(height: 8),
              Text(message, 
                textAlign: TextAlign.center,
                style: GoogleFonts.jetBrainsMono(fontSize: 11, color: carbonBlack.withValues(alpha: 0.6))),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.analytics_outlined, size: 14, color: Color(0xFF4B5320)),
        const SizedBox(width: 10),
        Text(title, style: GoogleFonts.jetBrainsMono(
          fontWeight: FontWeight.w800, 
          fontSize: 11,
          letterSpacing: 2,
          color: const Color(0xFF4B5320),
        )),
        const Expanded(child: Divider(indent: 16, color: Color(0x1A000000), thickness: 0.5)),
      ],
    );
  }
}

class _StatTerminalCard extends StatelessWidget {
  const _StatTerminalCard(this.label, this.value);
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.zero,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.jetBrainsMono(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(value.padLeft(2, '0'), style: GoogleFonts.jetBrainsMono(
            color: const Color(0xFFF5F5DC),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          )),
        ],
      ),
    );
  }
}

class _ActivityLogSummary extends StatelessWidget {
  const _ActivityLogSummary({required this.monthlyActivity});
  final List<int> monthlyActivity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'REGISTRO RECIENTE:',
            style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black45),
          ),
          const SizedBox(height: 12),
          ...monthlyActivity.reversed.take(4).map((activity) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, size: 12, color: Color(0xFF4B5320)),
                const SizedBox(width: 12),
                Text(
                  'INTERACCIONES DETECTADAS: ${activity.toString().padLeft(3, '0')}',
                  style: GoogleFonts.jetBrainsMono(fontSize: 10, color: Colors.black87),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _TerminalLogs extends StatelessWidget {
  const _TerminalLogs({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: const Border(left: BorderSide(color: Color(0xFFFF8C00), width: 1.5)),
        color: Colors.black.withValues(alpha: 0.03),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.info_outline, size: 12, color: Color(0xFFFF8C00)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'LOG_NOTE: $message',
              style: GoogleFonts.jetBrainsMono(
                color: Colors.black.withValues(alpha: 0.5),
                fontSize: 10,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}