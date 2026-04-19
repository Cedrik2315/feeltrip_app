import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../domain/user_profile_model.dart'; // Importamos el modelo real
import 'widgets/emotional_radar_chart.dart';
import 'widgets/user_stats_grid.dart';
import 'widgets/badge_item.dart';
import 'profile_controller.dart';
// Si NotificationBadge da error de ruta, asegúrate de que el archivo existe
import 'package:feeltrip_app/shared/widgets/notification_badge.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profileAsync = ref.watch(profileControllerProvider);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'EXPEDITION_PROFILE',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFFF8F00),
          ),
        ),
        actions: [
          IconButton(
            icon: Stack( // QUITAMOS EL CONST AQUÍ
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_none_outlined),
                Positioned(
                  right: -2, 
                  top: -2, 
                  child: const NotificationBadge(count: 0, child: SizedBox()),
                ),
              ],
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF8F00)),
        ),
        error: (err, stack) => Center(
          child: Text('ERROR_SYNC: $err', style: GoogleFonts.jetBrainsMono()),
        ),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('NO_SESSION_ACTIVE'));
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(profileControllerProvider.notifier).refreshProfile(),
            color: const Color(0xFFFF8F00),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserHeader(profile, isDark),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: UserStatsGrid(
                      totalKm: profile.totalKm,
                      photosAnalyzed: profile.photosAnalyzed,
                      daysActive: profile.daysActive,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'COMPÁS EMOCIONAL ACUMULADO',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white30 : Colors.black26,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  EmotionalRadarChart(stats: profile.emotionalStats),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildBadgesSection(profile, isDark),
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

  // Cambiamos dynamic por UserProfile para evitar errores de compilación
  Widget _buildUserHeader(UserProfile profile, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFFF8F00), width: 1),
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: isDark ? Colors.white10 : Colors.black12,
              backgroundImage: profile.profileImageUrl != null 
                  ? NetworkImage(profile.profileImageUrl!) 
                  : null,
              child: profile.profileImageUrl == null 
                  ? const Icon(Icons.person_outline, color: Color(0xFFFF8F00)) 
                  : null,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.username.toUpperCase(),
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  'NIVEL ${profile.photosAnalyzed ~/ 5} • ${profile.rank}',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    color: const Color(0xFFFF8F00),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: profile.experienceProgress,
                  backgroundColor: isDark ? Colors.white10 : Colors.black12,
                  color: const Color(0xFFFF8F00),
                  minHeight: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesSection(UserProfile profile, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HITOS DE EXPEDICIÓN',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white30 : Colors.black26,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: profile.badges.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.7, // Ajustado para evitar overflow de texto
          ),
          itemBuilder: (context, index) {
            final badge = profile.badges[index];
            return BadgeItem(
              label: badge.label,
              icon: badge.icon, // Usamos el getter .icon del modelo
              isUnlocked: badge.isUnlocked,
              description: badge.description,
            );
          },
        ),
      ],
    );
  }
}