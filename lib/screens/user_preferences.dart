import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para HapticFeedback
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:feeltrip_app/user_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:feeltrip_app/features/profile/presentation/profile_controller.dart';
import 'package:feeltrip_app/features/profile/domain/user_profile_model.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  // Centralizamos los colores de la marca
  static const brandTeal = Color(0xFF00695C);
  static const accentAmber = Color(0xFFFF8F00);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(userPreferencesProvider);
    final notifier = ref.read(userPreferencesProvider.notifier);
    final profile = ref.watch(profileControllerProvider).value;
    final user = FirebaseAuth.instance.currentUser;

    final isDark = prefs.darkMode;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'CONFIGURACIÓN DEL SISTEMA',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 14, 
            letterSpacing: 2, 
            color: Colors.white
          ),
        ),
        elevation: 0,
        backgroundColor: isDark ? Colors.black : brandTeal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          _buildHeader(isDark, user, profile, ref),
          
          _SectionTitle(title: 'EXPERIENCIA VISUAL', darkMode: isDark),
          _CustomSwitchTile(
            title: 'Modo Oscuro (Carbon)',
            subtitle: 'Optimiza el consumo y reduce la fatiga visual',
            value: prefs.darkMode,
            onChanged: (val) {
              HapticFeedback.lightImpact();
              notifier.toggleDarkMode();
            },
            icon: Icons.dark_mode_outlined,
            darkMode: isDark,
          ),

          _SectionTitle(title: 'NÚCLEO FEELTRIP', darkMode: isDark),
          _CustomSwitchTile(
            title: 'Modo Offline-First',
            subtitle: 'Prioriza datos locales en zonas sin señal',
            value: prefs.offlineFirstMode,
            onChanged: (val) {
              HapticFeedback.mediumImpact();
              notifier.toggleOfflineMode();
            },
            icon: Icons.cloud_off_outlined,
            darkMode: isDark,
          ),
          _CustomSwitchTile(
            title: 'Motor Emocional (IA)',
            subtitle: 'Analiza el tono de tus diarios para sugerencias',
            value: prefs.emotionalAnalytics,
            onChanged: (val) {
              HapticFeedback.lightImpact();
              notifier.toggleEmotionalEngine();
            },
            icon: Icons.psychology_outlined,
            darkMode: isDark,
          ),

          _SectionTitle(title: 'SISTEMA', darkMode: isDark),
          ListTile(
            leading: const Icon(Icons.translate, color: brandTeal),
            title: Text(
              'Idioma de la interfaz',
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            ),
            subtitle: Text(
              prefs.language == 'es' ? 'Español (Chile)' : 'English',
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () => _showLanguagePicker(context, ref),
          ),

          const Divider(height: 60, indent: 40, endIndent: 40, thickness: 0.5),
          
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark, User? user, UserProfile? profile, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? Colors.black : brandTeal,
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: accentAmber,
                backgroundImage: (profile?.profileImageUrl != null && profile!.profileImageUrl!.isNotEmpty)
                    ? NetworkImage(profile.profileImageUrl!)
                    : null,
                child: (profile?.profileImageUrl == null || profile!.profileImageUrl!.isEmpty)
                    ? const Icon(Icons.person_outline, size: 40, color: Colors.white)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final image = await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      // Simulación de subida o integrar con Storage
                      ScaffoldMessenger.of(ref.context).showSnackBar(
                        const SnackBar(content: Text('Subiendo fotografía...')),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: accentAmber, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            profile?.username ?? user?.email?.split('@')[0].toUpperCase() ?? 'Explorador FeelTrip',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22, 
              color: Colors.white, 
              fontWeight: FontWeight.bold
            ),
          ),
          Text(
            'ID: ${user?.uid.substring(0, 8).toUpperCase() ?? 'FT-2026-XQ'}',
            style: const TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        children: [
          Text(
            'FEELTRIP v1.0.4-beta',
            style: GoogleFonts.jetBrainsMono(fontSize: 10, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Diseñado en Quillota, Chile',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10, 
              color: accentAmber.withValues(alpha: .5)
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref) {
    final isDark = ref.read(userPreferencesProvider).darkMode;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'SELECCIONAR IDIOMA',
                style: GoogleFonts.jetBrainsMono(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
            ListTile(
              title: Text('Español (Chile)', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
              leading: const Text('🇨🇱'),
              onTap: () {
                ref.read(userPreferencesProvider.notifier).setLanguage('es');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('English (Global)', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
              leading: const Text('🇺🇸'),
              onTap: () {
                ref.read(userPreferencesProvider.notifier).setLanguage('en');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Português (Brasil)', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
              leading: const Text('🇧🇷'),
              onTap: () {
                ref.read(userPreferencesProvider.notifier).setLanguage('pt');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
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
      child: Text(
        title,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: darkMode ? Colors.white30 : Colors.black26,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _CustomSwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
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
    return ListTile(
      leading: Icon(icon, color: SettingsScreen.brandTeal),
      title: Text(
        title,
        style: TextStyle(
          color: darkMode ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 11,
          color: Colors.grey[600],
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: SettingsScreen.accentAmber,
      ),
    );
  }
}