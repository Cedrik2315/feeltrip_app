import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:feeltrip_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:feeltrip_app/presentation/providers/profile_provider.dart';
import 'package:feeltrip_app/features/auth/domain/entities/auth_user.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditing = false;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authUserAsync = ref.watch(authNotifierProvider);

    return authUserAsync.when(
      loading: () => Scaffold(
        backgroundColor: colorScheme.surface,
        body: Center(child: CircularProgressIndicator(color: colorScheme.primary)),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: colorScheme.surface,
        body: Center(child: Text('ERROR AUTH: $error', style: GoogleFonts.jetBrainsMono(color: colorScheme.error))),
      ),
      data: (AuthUser? authUser) {
        if (authUser == null) {
          return Scaffold(
            backgroundColor: colorScheme.surface,
            body: const Center(child: Text('SESSION REQUIRED')),
          );
        }

        final currentUid = authUser.id;
        final displayName = authUser.name ?? authUser.email.split('@').first.toUpperCase();
        _syncControllers(displayName, authUser.email);

        final followersAsync = ref.watch(followersProvider(currentUid));
        final followingAsync = ref.watch(followingProvider(currentUid));

        final followers = followersAsync.valueOrNull?.length ?? 0;
        final following = followingAsync.valueOrNull?.length ?? 0;

        return Scaffold(
          backgroundColor: colorScheme.surface,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: colorScheme.surface.withValues(alpha: 0.2),
            elevation: 0,
            title: Text(
              'EXPEDIENTE USUARIO',
              style: GoogleFonts.jetBrainsMono(
                color: colorScheme.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(_isEditing ? Icons.check : Icons.tune, color: colorScheme.onSurface, size: 20),
                onPressed: () => setState(() => _isEditing = !_isEditing),
              ),
            ],
          ),
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/profile_bg.png',
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
                        colorScheme.surface.withValues(alpha: 0.4),
                        colorScheme.surface.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      _buildHeader(context, displayName, authUser.photoUrl),
                      const SizedBox(height: 32),
                      _buildStats(context, followers, following),
                      const SizedBox(height: 40),
                      Text(
                        'INFORMACIÓN BASE',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.tertiary.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTechnicalField('NOMBRE VIAJERO', _nameController, Icons.badge_outlined),
                      const SizedBox(height: 12),
                      _buildTechnicalField('CONTACTO EMAIL', _emailController, Icons.alternate_email),
                      const SizedBox(height: 40),
                      Text(
                        'HERRAMIENTAS UGC',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.tertiary.withValues(alpha: 0.7),
                        ),
                      ),
                      _buildToolTile(context, 'PROGRAMA REFERIDOS', Icons.card_giftcard_outlined, () => context.push('/referral')),
                      _buildToolTile(context, 'ESTADÍSTICAS CREADOR', Icons.analytics_outlined, () => context.push('/creator-stats')),
                      _buildToolTile(context, 'MEMORIAS TIPO STORY', Icons.auto_awesome_mosaic_outlined, () => context.push('/instagram-stories')),
                      _buildToolTile(context, 'TRADUCTOR SISTEMA', Icons.translate_outlined, () => context.push('/translator')),
                      _buildToolTile(context, 'SISTEMA SCOUT AI', Icons.radar, () => context.push('/emotional-prediction')),
                      _buildToolTile(context, 'LECTOR OCR V2', Icons.document_scanner_outlined, () => context.push('/ocr')),
                      _buildToolTile(context, 'WEAR OS COMPANION', Icons.watch_outlined, () => context.push('/wear-companion')),
                      _buildToolTile(context, 'CONFIGURACIÓN', Icons.settings_outlined, () => context.push('/settings')),
                      const SizedBox(height: 40),
                      _buildLogoutButton(),
                      const SizedBox(height: 40),
                      _buildFooter(context),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, String name, String? photoUrl) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.tertiary.withValues(alpha: 0.3), width: 2),
                  boxShadow: [
                    BoxShadow(color: colorScheme.tertiary.withValues(alpha: 0.1), blurRadius: 20)
                  ],
                ),
                child: ClipOval(
                  child: _imageFile != null
                      ? Image.file(_imageFile!, fit: BoxFit.cover)
                      : (photoUrl != null && photoUrl.isNotEmpty
                          ? Image.network(photoUrl, fit: BoxFit.cover)
                          : Container(
                              color: colorScheme.surface,
                              child: Icon(Icons.person_pin_outlined, size: 64, color: colorScheme.onSurface),
                            )),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          name,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'LINK ESTABLE // EXPEDICIONARIO ALPHA',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 9,
            color: colorScheme.tertiary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStats(BuildContext context, int followers, int following) {
    return Row(
      children: [
        _statBox(context, 'SEGUIDORES', followers.toString()),
        const SizedBox(width: 12),
        _statBox(context, 'SIGUIENDO', following.toString()),
      ],
    );
  }

  Widget _statBox(BuildContext context, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.onSurface.withValues(alpha: 0.05),
          border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.jetBrainsMono(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
            ),
            Text(
              label,
              style: GoogleFonts.jetBrainsMono(fontSize: 8, color: colorScheme.onSurface.withValues(alpha: 0.4)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicalField(String label, TextEditingController controller, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      enabled: _isEditing,
      style: GoogleFonts.jetBrainsMono(fontSize: 14, color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.jetBrainsMono(fontSize: 9, color: colorScheme.onSurface.withValues(alpha: 0.5)),
        prefixIcon: Icon(icon, size: 18, color: colorScheme.onSurface),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.2))),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorScheme.primary)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.02),
      ),
    );
  }

  Widget _buildToolTile(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: colorScheme.onSurface.withValues(alpha: 0.8), size: 20),
      title: Text(title, style: GoogleFonts.jetBrainsMono(fontSize: 12, color: colorScheme.onSurface)),
      trailing: Icon(Icons.chevron_right, size: 16, color: colorScheme.onSurface.withValues(alpha: 0.3)),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _showLogoutDialog,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.redAccent, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          'FINALIZAR SESIÓN',
          style: GoogleFonts.jetBrainsMono(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        children: [
          Text(
            'FeelTrip v1.0.0 STABLE',
            style: GoogleFonts.jetBrainsMono(fontSize: 9, color: colorScheme.onSurface.withValues(alpha: 0.3)),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => context.push('/privacy'),
            child: Text(
              'POLÍTICAS DE PRIVACIDAD // TÉRMINOS',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                color: colorScheme.onSurface.withValues(alpha: 0.3),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _syncControllers(String displayName, String email) {
    if (_nameController.text.isEmpty) _nameController.text = displayName;
    if (_emailController.text.isEmpty) _emailController.text = email;
  }

  void _showLogoutDialog() {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outline),
        ),
        title: Text(
          'CERRAR SESIÓN',
          style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
        ),
        content: Text(
          '¿Confirmas la desconexión del sistema?',
          style: GoogleFonts.ebGaramond(fontSize: 18, color: colorScheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CANCELAR',
              style: GoogleFonts.jetBrainsMono(color: colorScheme.onSurface.withValues(alpha: 0.5)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).signOut();
              if (!mounted) return;
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('CONFIRMAR', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}