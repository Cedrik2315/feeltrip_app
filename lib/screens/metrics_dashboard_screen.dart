import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:feeltrip_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:feeltrip_app/presentation/providers/engagement_provider.dart';

class MetricsDashboardScreen extends ConsumerWidget {
  const MetricsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const Color boneWhite = Color(0xFFF5F5DC);
    const Color terminalGreen = Color(0xFF00FF41);
    final authUserAsync = ref.watch(authNotifierProvider);
    final userId = authUserAsync.whenOrNull(data: (user) => user?.id);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('TELEMETRÍA // MÉTRICAS', 
          style: GoogleFonts.jetBrainsMono(color: boneWhite, fontSize: 13, letterSpacing: 1.5)),
        backgroundColor: Colors.black.withValues(alpha: 0.2),
        elevation: 0,
        iconTheme: const IconThemeData(color: boneWhite),
      ),
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/metrics_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
          ),

          userId == null 
            ? _buildUnauthenticatedView()
            : _buildDashboard(context, ref, userId, boneWhite, terminalGreen),
        ],
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, WidgetRef ref, String userId, Color boneWhite, Color terminalGreen) {
    final statsAsync = ref.watch(creatorStatsProvider(userId));

    return statsAsync.when(
      loading: () => Center(child: CircularProgressIndicator(color: terminalGreen)),
      error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
      data: (stats) => SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTerminalHeader('ESTADO DEL SISTEMA: EN LÍNEA', terminalGreen, boneWhite),
              const SizedBox(height: 24),
              
              // Grid de Métricas con Estilo Glass
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard('HISTORIAS', stats.totalStories.toString(), Icons.history_edu, terminalGreen, boneWhite),
                  _buildStatCard('REACCIONES', stats.totalLikes.toString(), Icons.favorite_border, terminalGreen, boneWhite),
                  _buildStatCard('ECOS', stats.totalComments.toString(), Icons.chat_bubble_outline, terminalGreen, boneWhite),
                  _buildStatCard('IMPACTO RUTA', '${(stats.totalLikes * 1.5).toInt()}%', Icons.auto_awesome, terminalGreen, boneWhite),
                ],
              ),
              
              const SizedBox(height: 32),
              _buildTerminalHeader('ACTIVIDAD RECIENTE', terminalGreen, boneWhite),
              const SizedBox(height: 16),
              
              ...stats.monthlyActivity.reversed.take(5).map((val) => _buildActivityRow(val, terminalGreen, boneWhite)),
              
              const SizedBox(height: 40),
              _buildInfoBox('Los datos de telemetría se sincronizan cada 15 minutos con el clúster central de FeelTrip.', boneWhite),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color terminalGreen, Color boneWhite) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: boneWhite.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: terminalGreen),
              const SizedBox(width: 8),
              Text(label, style: GoogleFonts.jetBrainsMono(fontSize: 10, color: boneWhite.withValues(alpha: 0.4))),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.jetBrainsMono(fontSize: 24, color: boneWhite, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActivityRow(int value, Color terminalGreen, Color boneWhite) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(width: 4, height: 20, color: terminalGreen),
          const SizedBox(width: 12),
          Text('> PULSO DETECTADO: ', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: boneWhite.withValues(alpha: 0.5))),
          Text('$value pts', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: terminalGreen, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTerminalHeader(String title, Color terminalGreen, Color boneWhite) {
    return Row(
      children: [
        Text(title, style: GoogleFonts.jetBrainsMono(fontSize: 12, color: terminalGreen, fontWeight: FontWeight.bold)),
        const SizedBox(width: 16),
        Expanded(child: Divider(color: boneWhite.withValues(alpha: 0.1), thickness: 1)),
      ],
    );
  }

  Widget _buildInfoBox(String text, Color boneWhite) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        border: Border.all(color: boneWhite.withValues(alpha: 0.1)),
      ),
      child: Text(
        '// NOTA: $text',
        style: GoogleFonts.jetBrainsMono(fontSize: 10, color: boneWhite.withValues(alpha: 0.4), height: 1.5),
      ),
    );
  }

  Widget _buildUnauthenticatedView() {
    return Center(
      child: Text('INICIA SESIÓN PARA VER TELEMETRÍA', 
        style: GoogleFonts.jetBrainsMono(color: Colors.white38, fontSize: 12)),
    );
  }
}
