import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:feeltrip_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:feeltrip_app/presentation/providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditing = false;
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  static const Color boneWhite = Color(0xFFF5F5DC);
  static const Color carbon = Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController(text: '+56 9 XXXX XXXX');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authUserAsync = ref.watch(authNotifierProvider);

    return authUserAsync.when(
      loading: () => const Scaffold(backgroundColor: boneWhite, body: Center(child: CircularProgressIndicator(color: carbon))),
      error: (error, _) => Scaffold(body: Center(child: Text('ERROR_AUTH: $error'))),
      data: (authUser) {
        if (authUser == null) return const Scaffold(body: Center(child: Text('SESSION_REQUIRED')));

        final currentUid = authUser.id;
        final displayName = authUser.name ?? authUser.email.split('@').first.toUpperCase();
        _syncControllers(displayName, authUser.email);

        final followersAsync = ref.watch(followersProvider(currentUid));
        final followingAsync = ref.watch(followingProvider(currentUid));

        final followers = followersAsync.valueOrNull?.length ?? 0;
        final following = followingAsync.valueOrNull?.length ?? 0;

        return Scaffold(
          backgroundColor: boneWhite,
          appBar: AppBar(
            backgroundColor: boneWhite,
            elevation: 0,
            title: Text('EXPEDIENTE_USUARIO', style: GoogleFonts.jetBrainsMono(color: carbon, fontSize: 14, fontWeight: FontWeight.bold)),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(_isEditing ? Icons.save_outlined : Icons.tune, color: carbon),
                onPressed: () => setState(() => _isEditing = !_isEditing),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(displayName),
                const SizedBox(height: 32),
                _buildStats(followers, following),
                const SizedBox(height: 40),
                _sectionLabel('INFORMACIÓN_BASE'),
                const SizedBox(height: 16),
                _buildTextField('NOMBRE_VIAJERO', _nameController, Icons.badge_outlined),
                const SizedBox(height: 12),
                _buildTextField('CONTACTO_EMAIL', _emailController, Icons.alternate_email),
                const SizedBox(height: 40),
                _sectionLabel('HERRAMIENTAS_UGC'),
                _buildToolTile('ESTADÍSTICAS_CREADOR', Icons.analytics_outlined, () => context.push('/creator-stats')),
                _buildToolTile('MEMORIAS_TIPO_STORY', Icons.auto_awesome_mosaic_outlined, () => context.push('/instagram-stories')),
                _buildToolTile('TRADUCTOR_SISTEMA', Icons.translate_outlined, () => context.push('/translator')),
                _buildToolTile('LECTOR_OCR_V2', Icons.document_scanner_outlined, () => context.push('/ocr')),
                const SizedBox(height: 40),
                _buildLogoutButton(),
                const SizedBox(height: 60),
                _buildFooter(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(border: Border.all(color: carbon, width: 1)),
            child: const Icon(Icons.person_outline, size: 80, color: carbon),
          ),
        ),
        const SizedBox(height: 24),
        Text(name, style: GoogleFonts.jetBrainsMono(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -1)),
        Text('REGISTRO_ACTIVO: DESDE 2024', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: carbon.withValues(alpha: 0.5))),
      ],
    );
  }

  Widget _buildStats(int followers, int following) {
    return Row(
      children: [
        _statBox('SEGUIDORES', followers.toString()),
        const SizedBox(width: 12),
        _statBox('SIGUIENDO', following.toString()),
      ],
    );
  }

  Widget _statBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(border: Border.all(color: carbon.withValues(alpha: 0.1))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: GoogleFonts.jetBrainsMono(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label, style: GoogleFonts.jetBrainsMono(fontSize: 9, color: carbon.withValues(alpha: 0.5))),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text, style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold, color: carbon.withValues(alpha: 0.4)));
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      enabled: _isEditing,
      style: GoogleFonts.jetBrainsMono(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.jetBrainsMono(fontSize: 10, color: carbon.withValues(alpha: 0.5)),
        prefixIcon: Icon(icon, size: 18, color: carbon),
        border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: carbon.withValues(alpha: 0.1))),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: carbon)),
        filled: !_isEditing,
        fillColor: carbon.withValues(alpha: 0.02),
      ),
    );
  }

  Widget _buildToolTile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: carbon, size: 20),
      title: Text(title, style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward, size: 16, color: carbon),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _showLogoutDialog,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.redAccent),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text('FINALIZAR_SESIÓN', style: GoogleFonts.jetBrainsMono(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          Text('FeelTrip v1.0.0_STABLE', style: GoogleFonts.jetBrainsMono(fontSize: 9, color: carbon.withValues(alpha: 0.3))),
          const SizedBox(height: 8),
          Text('POLÍTICAS_DE_PRIVACIDAD // TÉRMINOS', style: GoogleFonts.jetBrainsMono(fontSize: 9, color: carbon.withValues(alpha: 0.3))),
        ],
      ),
    );
  }

  // Lógica de sincronización y diálogo (se mantiene igual pero con estilo adaptado)
  void _syncControllers(String displayName, String email) {
    if (_nameController.text.isEmpty) _nameController.text = displayName;
    if (_emailController.text.isEmpty) _emailController.text = email;
  }

  void _showLogoutDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: boneWhite,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text('CERRAR_SESIÓN', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold)),
        content: Text('¿Confirmas la desconexión del sistema?', style: GoogleFonts.ebGaramond(fontSize: 18)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('CANCELAR', style: GoogleFonts.jetBrainsMono(color: carbon))),
          ElevatedButton(
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).signOut();
              if (!mounted) return;
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: carbon, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
            child: Text('CONFIRMAR', style: GoogleFonts.jetBrainsMono(color: boneWhite)),
          ),
        ],
      ),
    );
  }
}