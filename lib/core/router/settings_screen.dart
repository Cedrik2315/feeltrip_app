import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:feeltrip_app/user_preferences.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(userPreferencesProvider);
    final notifier = ref.read(userPreferencesProvider.notifier);

    // Paleta de colores basada en la identidad visual de FeelTrip
    final Color brandTeal = const Color(0xFF00695C);
    final Color accentOrange = const Color(0xFFFF8F00);

    return Scaffold(
      backgroundColor: prefs.darkMode ? const Color(0xFF0A0A0A) : const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: Text(
          'SISTEMA // AJUSTES',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        backgroundColor: prefs.darkMode ? Colors.black : brandTeal,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: [
          _buildSectionHeader('PREFERENCIAS_VISUALES', brandTeal),
          SwitchListTile(
            activeThumbColor: accentOrange,
            title: Text(
              'Modo Oscuro',
              style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: prefs.darkMode ? Colors.white : Colors.black87,
              ),
            ),
            subtitle: Text(
              'Optimiza la interfaz para entornos de baja luz y reduce el consumo de batería.',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
            value: prefs.darkMode,
            onChanged: (bool value) {
              notifier.toggleDarkMode();
            },
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Divider(thickness: 0.5),
          ),

          _buildSectionHeader('CONECTIVIDAD_Y_DATOS', brandTeal),
          SwitchListTile(
            activeThumbColor: accentOrange,
            title: Text(
              'Modo Offline',
              style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: prefs.darkMode ? Colors.white : Colors.black87,
              ),
            ),
            subtitle: Text(
              'Prioriza el uso de la base de datos local y sincroniza los cambios al detectar conexión.',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
            value: prefs.offlineFirstMode,
            onChanged: (bool value) {
              notifier.toggleOfflineMode();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        '> $title',
        style: GoogleFonts.jetBrainsMono(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}