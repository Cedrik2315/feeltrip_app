import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:feeltrip_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:feeltrip_app/services/legacy_capsule_service.dart';

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final _confirmController = TextEditingController();
  bool _isDeleting = false;
  bool _isConfirmed = false;

  static const Color boneWhite = Color(0xFFF5F5DC);
  static const Color terminalGreen = Color(0xFF00FF41);
  static const Color carbon = Color(0xFF0D0D0D);
  static const Color warningRed = Color(0xFFFF4500);

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: carbon,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: boneWhite),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'PROTOCOLO DE ELIMINACIÓN',
          style: GoogleFonts.jetBrainsMono(
            color: boneWhite,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              _buildTerminalHeader(),
              const SizedBox(height: 32),
              Text(
                '¿ESTÁS SEGURO DE\nABANDONAR LA RED?',
                style: GoogleFonts.ebGaramond(
                  fontSize: 32,
                  color: boneWhite,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Esta acción es IRREVERSIBLE. Se purgarán todos tus datos de biometría, crónicas, mapas de calor y archivos históricos de forma permanente.',
                style: GoogleFonts.inter(
                  color: boneWhite.withValues(alpha: 0.6),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              _buildWarningBox(),
              const SizedBox(height: 40),
              Text(
                'ESCRIBE "ELIMINAR" PARA DESBLOQUEAR EL BOTÓN:',
                style: GoogleFonts.jetBrainsMono(
                  color: terminalGreen.withValues(alpha: 0.5),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _confirmController,
                style: GoogleFonts.jetBrainsMono(color: warningRed, fontSize: 16, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: 'TÉCLEA AQUÍ',
                  hintStyle: GoogleFonts.jetBrainsMono(color: boneWhite.withValues(alpha: 0.1)),
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: warningRed)),
                ),
                onChanged: (val) => setState(() => _isConfirmed = val == 'ELIMINAR'),
              ),
              const SizedBox(height: 60),
              _buildActionButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTerminalHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('> INICIANDO SECUENCIA DE PURGA...', 
          style: GoogleFonts.jetBrainsMono(color: terminalGreen, fontSize: 10)),
        Text('> VERIFICANDO INTEGRIDAD DE ARCHIVOS...', 
          style: GoogleFonts.jetBrainsMono(color: terminalGreen, fontSize: 10)),
        Text('> ADVERTENCIA: DAÑO PERMANENTE A LA BITÁCORA', 
          style: GoogleFonts.jetBrainsMono(color: warningRed, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildWarningBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: warningRed.withValues(alpha: 0.3)),
        color: warningRed.withValues(alpha: 0.05),
      ),
      child: Column(
        children: [
          _warningItem('Pérdida de todas tus Crónicas sintetizadas'),
          _warningItem('Eliminación de Momentos y fotos en la nube'),
          _warningItem('Borrado de perfil y arquetipo detectado'),
          _warningItem('Cancelación inmediata de suscripción Pro'),
        ],
      ),
    );
  }

  Widget _warningItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Icon(Icons.close, color: warningRed, size: 14),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: GoogleFonts.jetBrainsMono(color: boneWhite.withValues(alpha: 0.7), fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: (_isConfirmed && !_isDeleting) ? _processDeletion : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isConfirmed ? warningRed : Colors.white10,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.white10,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        child: _isDeleting
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(
                'EJECUTAR ELIMINACIÓN DEFINITIVA',
                style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1),
              ),
      ),
    );
  }

  Future<void> _processDeletion() async {
    final success = await _showReauthDialog();
    if (!success) return;

    // --- LA GUINDA DE LA TORTA: EL TESTAMENTO DEL EXPLORADOR ---
    await _showLegacyCapsuleDialog();
    // Independientemente de si deja legado o no, procedemos con la eliminación.
    // Pero si aceptó, el servicio ya guardó la cápsula.
    
    setState(() => _isDeleting = true);
    HapticFeedback.heavyImpact();

    try {
      await ref.read(authNotifierProvider.notifier).deleteAccount();
      if (!mounted) return;
      context.go('/login');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      _showErrorSnackbar('FALLO CRÍTICO: No se pudo purgar la cuenta. Contacta a soporte.');
    }
  }

  Future<bool> _showReauthDialog() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final providers = user.providerData.map((p) => p.providerId).toList();

    if (providers.contains('google.com')) {
      return await _reauthWithGoogle();
    } else if (providers.contains('facebook.com')) {
      return await _reauthWithFacebook();
    } else {
      return await _reauthWithEmailPassword();
    }
  }

  Future<bool> _reauthWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return false;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      await FirebaseAuth.instance.currentUser?.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      _showErrorSnackbar('Error de validación con Google');
      return false;
    }
  }

  Future<bool> _reauthWithFacebook() async {
    try {
      final result = await FacebookAuth.instance.login();
      if (result.status != LoginStatus.success) return false;
      final credential = FacebookAuthProvider.credential(result.accessToken!.tokenString);
      await FirebaseAuth.instance.currentUser?.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      _showErrorSnackbar('Error de validación con Facebook');
      return false;
    }
  }

  Future<bool> _reauthWithEmailPassword() async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.94),
      builder: (ctx) => AlertDialog(
        backgroundColor: carbon,
        shape: const RoundedRectangleBorder(side: BorderSide(color: boneWhite, width: 0.5)),
        title: Text('RE-AUTENTICACIÓN REQUERIDA', 
          style: GoogleFonts.jetBrainsMono(color: terminalGreen, fontSize: 12, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              style: GoogleFonts.jetBrainsMono(color: boneWhite, fontSize: 14),
              decoration: const InputDecoration(labelText: 'EMAIL', labelStyle: TextStyle(color: Colors.white38)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              style: GoogleFonts.jetBrainsMono(color: boneWhite, fontSize: 14),
              decoration: const InputDecoration(labelText: 'CONTRASEÑA', labelStyle: TextStyle(color: Colors.white38)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('CANCELAR', style: GoogleFonts.jetBrainsMono(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () async {
              try {
                final credential = EmailAuthProvider.credential(
                  email: emailController.text.trim(),
                  password: passwordController.text.trim(),
                );
                await FirebaseAuth.instance.currentUser?.reauthenticateWithCredential(credential);
                if (ctx.mounted) Navigator.pop(ctx, true);
              } catch (e) {
                _showErrorSnackbar('Credenciales inválidas');
              }
            },
            child: Text('VERIFICAR', style: GoogleFonts.jetBrainsMono(color: terminalGreen)),
          ),
        ],
      ),
    );
    
    emailController.dispose();
    passwordController.dispose();
    return result ?? false;
  }

  Future<bool> _showLegacyCapsuleDialog() async {
    final phraseController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.98), // Pantalla casi negra para solemnidad
      builder: (ctx) => AlertDialog(
        backgroundColor: carbon,
        shape: const RoundedRectangleBorder(side: BorderSide(color: terminalGreen, width: 0.5)),
        title: Column(
          children: [
            const Icon(Icons.auto_awesome, color: terminalGreen, size: 30),
            const SizedBox(height: 16),
            Text(
              'EL TESTAMENTO DEL EXPLORADOR',
              textAlign: TextAlign.center,
              style: GoogleFonts.ebGaramond(color: boneWhite, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tu presencia en la red está por desvanecerse. Pero antes de pulsar ELIMINAR, puedes dejar una huella eterna.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: boneWhite.withValues(alpha: 0.7), fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 20),
            Text(
              '"¿Qué queda de ti cuando ya no estás?"',
              textAlign: TextAlign.center,
              style: GoogleFonts.ebGaramond(color: terminalGreen, fontSize: 16, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: phraseController,
              maxLines: 3,
              style: GoogleFonts.jetBrainsMono(color: boneWhite, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Escribe una última frase, una coordenada emocional...',
                hintStyle: GoogleFonts.jetBrainsMono(color: boneWhite.withValues(alpha: 0.2), fontSize: 11),
                enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
                focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: terminalGreen)),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Esta cápsula será anónima e indestructible. Solo visible para exploradores que pasen por este lugar exacto en el futuro.',
              textAlign: TextAlign.center,
              style: GoogleFonts.jetBrainsMono(color: Colors.white24, fontSize: 9),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('NO DEJAR RASTRO', style: GoogleFonts.jetBrainsMono(color: Colors.white24)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (phraseController.text.trim().isNotEmpty) {
                await ref.read(legacyCapsuleServiceProvider).leaveLegacy(
                  phrase: phraseController.text.trim(),
                  emotionalState: 'LEGACY_PURGE',
                );
              }
              if (ctx.mounted) Navigator.pop(ctx, true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: terminalGreen, foregroundColor: carbon),
            child: Text('GRABAR CÁPSULA', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    
    phraseController.dispose();
    return result ?? false;
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.jetBrainsMono(fontSize: 11)),
        backgroundColor: warningRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}