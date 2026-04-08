import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserStatsGrid extends StatelessWidget {
  const UserStatsGrid({
    super.key,
    required this.totalKm,
    required this.photosAnalyzed,
    required this.daysActive,
  });

  final int totalKm;
  final int photosAnalyzed;
  final int daysActive;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 1, // Espacio mínimo para simular rejilla técnica
      mainAxisSpacing: 1,
      children: [
        _buildStatTile('KM_TRAVEL', totalKm.toString(), isDark),
        _buildStatTile('AI_SCANS', photosAnalyzed.toString(), isDark),
        _buildStatTile('EXP_DAYS', daysActive.toString(), isDark),
      ],
    );
  }

  Widget _buildStatTile(String label, String value, bool isDark) {
    return Container(
        decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111111) : Colors.white,
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(13) : Colors.black.withAlpha(13),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFFF8F00),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9,
              letterSpacing: 1,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white.withAlpha(97) : Colors.black.withAlpha(97),
            ),
          ),
        ],
      ),
    );
  }
}