import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// Importamos tu provider de preferencias
import '../user_preferences.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(userPreferencesProvider);
    final prefsNotifier = ref.read(userPreferencesProvider.notifier);

    const brandColor = Color(0xFF00695C); // Teal
    const accentColor = Color(0xFFFF8F00); // Ámbar

    return Scaffold(
      backgroundColor: prefs.darkMode ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('CONFIGURACIÓN DEL SISTEMA', 
          style: GoogleFonts.jetBrainsMono(fontSize: 14, letterSpacing: 2)),
        elevation: 0,
        backgroundColor: prefs.darkMode ? Colors.black : brandColor,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          _buildHeader(prefs.darkMode),
          
          _SectionTitle(title: 'EXPERIENCIA VISUAL', darkMode: prefs.darkMode),
          _CustomSwitchTile(
            title: 'Modo Oscuro (Carbon)',
            subtitle: 'Optimiza el consumo y reduce la fatiga visual',
            value: prefs.darkMode,
            onChanged: (val) => prefsNotifier.toggleDarkMode(),
            icon: Icons.dark_mode_outlined,
            darkMode: prefs.darkMode,
          ),

          _SectionTitle(title: 'NÚCLEO FEELTRIP', darkMode: prefs.darkMode),
          _CustomSwitchTile(
            title: 'Modo Offline-First',
            subtitle: 'Prioriza datos locales en zonas sin señal',
            value: prefs.offlineFirstMode,
            onChanged: (val) => prefsNotifier.toggleOfflineMode(),
            icon: Icons.cloud_off_outlined,
            darkMode: prefs.darkMode,
          ),
          _CustomSwitchTile(
            title: 'Motor Emocional (IA)',
            subtitle: 'Analiza el tono de tus diarios para sugerencias',
            value: prefs.emotionalAnalytics,
            onChanged: (val) => prefsNotifier.toggleEmotionalEngine(),
            icon: Icons.psychology_outlined,
            darkMode: prefs.darkMode,
          ),

          _SectionTitle(title: 'SISTEMA', darkMode: prefs.darkMode),
          ListTile(
            leading: Icon(Icons.translate, color: brandColor),
            title: Text('Idioma de la interfaz', 
              style: TextStyle(color: prefs.darkMode ? Colors.white : Colors.black87)),
            subtitle: Text(prefs.language == 'es' ? 'Español (Chile)' : 'English', 
              style: TextStyle(color: Colors.grey)),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              // Aquí podrías abrir un modal para cambiar el idioma
              prefsNotifier.setLanguage(prefs.language == 'es' ? 'en' : 'es');
            },
          ),

          const Divider(height: 40, indent: 20, endIndent: 20),
          
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text('FEELTRIP v1.0.4-beta', 
                  style: GoogleFonts.jetBrainsMono(fontSize: 10, color: Colors.grey)),
                const SizedBox(height: 8),
                Text('Diseñado en Quillota, Chile', 
                  style: GoogleFonts.jetBrainsMono(fontSize: 10, color: accentColor.withValues(alpha: .7))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? Colors.black : const Color(0xFF00695C),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Color(0xFFFF8F00),
            child: Icon(Icons.person_outline, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text('Explorador FeelTrip', 
            style: GoogleFonts.playfairDisplay(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
          const Text('ID: FT-2026-XQ', 
            style: TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool darkMode;
  const _SectionTitle({required this.title, required this.darkMode});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
      child: Text(title, 
        style: GoogleFonts.jetBrainsMono(
          fontSize: 11, 
          fontWeight: FontWeight.bold, 
          color: darkMode ? Colors.white38 : Colors.black38,
          letterSpacing: 1.2
        )),
    );
  }
}

class _CustomSwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final Function(bool) onChanged;
  final IconData icon;
  final bool darkMode;
  const _CustomSwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.icon,
    required this.darkMode,
  });

  @override
  Widget build(BuildContext context) {
    final brandColor = const Color(0xFF00695C);
    
    return ListTile(
      leading: Icon(icon, color: value ? brandColor : Colors.grey),
      title: Text(title, 
        style: TextStyle(
          color: darkMode ? Colors.white : Colors.black87, 
          fontWeight: FontWeight.w500
        )),
      subtitle: Text(subtitle, 
        style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeTrackColor: brandColor,
      ),
    );
  }
}