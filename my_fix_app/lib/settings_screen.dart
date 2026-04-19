import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:feeltrip_app/user_preferences.dart';
import 'package:feeltrip_app/features/profile/presentation/profile_controller.dart';
import 'package:image_picker/image_picker.dart';
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
          _buildProfileHeader(context, ref, prefs.darkMode),
          const SizedBox(height: 16),
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
              // Se invoca el método del notifier para actualizar el estado global
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

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Divider(thickness: 0.5),
          ),

          _buildSectionHeader('MOTOR_COGNITIVO_IA', brandTeal),
          SwitchListTile(
            activeThumbColor: accentOrange,
            title: Text(
              'Análisis Emocional (IA)',
              style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: prefs.darkMode ? Colors.white : Colors.black87,
              ),
            ),
            subtitle: Text(
              'Habilita el procesamiento de lenguaje natural y visión artificial para personalizar tus rutas.',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
            value: prefs.emotionalAnalytics,
            onChanged: (bool value) {
              notifier.toggleEmotionalEngine();
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

  Widget _buildProfileHeader(BuildContext context, WidgetRef ref, bool isDarkMode) {
    final profileAsync = ref.watch(profileControllerProvider);
    final theme = Theme.of(context);
    
    return profileAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (profile) {
        final String name = profile?.username ?? 'Explorador';
        final String rank = profile?.rank ?? 'RECLUIT';
        final String? photoUrl = profile?.profileImageUrl;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                    backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                    child: photoUrl == null 
                      ? Icon(Icons.person, size: 40, color: theme.colorScheme.primary)
                      : null,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name.toUpperCase(),
                          style: GoogleFonts.ebGaramond(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'ESTATUS: $rank',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.tertiary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _pickAndUploadImage(context, ref),
                  icon: const Icon(Icons.camera_alt_outlined, size: 20),
                  label: Text(
                    'CAMBIAR FOTOGRAFÍA DE PERFIL',
                    style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.colorScheme.primary),
                    foregroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadImage(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      // Aquí iría la lógica de subida a Firebase Storage
      // Por ahora, simulamos éxito o mostramos un mensaje
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'LOG: Procesando imagen ${image.name}... Próximamente integración con Storage.',
            style: GoogleFonts.jetBrainsMono(fontSize: 10),
          ),
          backgroundColor: const Color(0xFF00695C),
        ),
      );
    }
  }
}