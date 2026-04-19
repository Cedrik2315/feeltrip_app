import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:feeltrip_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _analyticsEnabled = true;
  bool _biometricEnabled = false;
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: colorScheme.surface.withValues(alpha: 0.2),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 18, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'CONFIGURACIÓN SISTEMA',
          style: GoogleFonts.jetBrainsMono(
            color: colorScheme.onSurface,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colorScheme.surface,
                    colorScheme.surface.withValues(alpha: 0.95),
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
                  const SizedBox(height: 24),

                  // ── CUENTA ─────────────────────────────────────────
                  _sectionLabel('CUENTA'),
                  _settingsTile(
                    context,
                    icon: Icons.person_outline,
                    title: 'EDITAR PERFIL',
                    subtitle: 'Nombre, foto y datos personales',
                    onTap: () => context.push('/profile'),
                  ),
                  _settingsTile(
                    context,
                    icon: Icons.workspace_premium_outlined,
                    title: 'SUSCRIPCIÓN',
                    subtitle: 'Gestionar plan FeelTrip Pro',
                    onTap: () => context.push('/premium'),
                  ),
                  _settingsTile(
                    context,
                    icon: Icons.card_giftcard_outlined,
                    title: 'PROGRAMA REFERIDOS',
                    subtitle: 'Invita exploradores, gana Pro',
                    onTap: () => context.push('/referral'),
                  ),
                 

                  const SizedBox(height: 32),

                  // ── NOTIFICACIONES ──────────────────────────────────
                  _sectionLabel('NOTIFICACIONES'),
                  _settingsSwitch(
                    context,
                    icon: Icons.notifications_outlined,
                    title: 'NOTIFICACIONES PUSH',
                    subtitle: 'Alertas de crónicas, cápsulas y expediciones',
                    value: _notificationsEnabled,
                    onChanged: (val) => setState(() => _notificationsEnabled = val),
                  ),

                  const SizedBox(height: 32),

                  // ── PRIVACIDAD ──────────────────────────────────────
                  _sectionLabel('PRIVACIDAD Y DATOS'),
                  _settingsSwitch(
                    context,
                    icon: Icons.analytics_outlined,
                    title: 'TELEMETRÍA EMOCIONAL',
                    subtitle: 'Datos anónimos para mejorar el servicio',
                    value: _analyticsEnabled,
                    onChanged: (val) => setState(() => _analyticsEnabled = val),
                  ),
                  _settingsSwitch(
                    context,
                    icon: Icons.monitor_heart_outlined,
                    title: 'SINCRONIZACIÓN BIOMÉTRICA',
                    subtitle: 'HRV y métricas fisiológicas del viaje',
                    value: _biometricEnabled,
                    onChanged: _toggleBiometrics,
                  ),
                  _settingsTile(
                    context,
                    icon: Icons.policy_outlined,
                    title: 'POLÍTICA DE PRIVACIDAD',
                    subtitle: 'Ley N° 19.628 — República de Chile',
                    onTap: () => context.push('/privacy'),
                  ),
                  _settingsTile(
                    context,
                    icon: Icons.gavel_outlined,
                    title: 'TÉRMINOS Y CONDICIONES',
                    subtitle: 'Acuerdo de uso de la plataforma',
                    onTap: () => context.push('/terms'),
                  ),
                  _settingsTile(
                    context,
                    icon: Icons.shield_outlined,
                    title: 'DERECHOS ARCO',
                    subtitle: 'Acceso, Rectificación, Cancelación, Oposición',
                    onTap: () => _showArcoDialog(context),
                  ),

                  const SizedBox(height: 32),

                  // ── FILOSOFÍA ───────────────────────────────────────
                  _sectionLabel('FILOSOFÍA'),
                  _settingsTile(
                    context,
                    icon: Icons.auto_awesome_outlined,
                    title: 'MANIFIESTO DEL VIAJERO',
                    subtitle: 'Nuestra filosofía y visión del mundo',
                    iconShadows: [
                      Shadow(color: const Color(0xFFFFBF00).withValues(alpha: 0.8), blurRadius: 15),
                    ],
                    onTap: () => context.push('/manifesto'),
                  ),

                  const SizedBox(height: 32),

                  // ── SOPORTE ─────────────────────────────────────────
                  _sectionLabel('SOPORTE'),
                  _settingsTile(
                    context,
                    icon: Icons.bug_report_outlined,
                    title: 'REPORTAR PROBLEMA',
                    subtitle: 'soporte@feeltrip.app',
                    onTap: () {},
                  ),
                  _settingsTile(
                    context,
                    icon: Icons.info_outline,
                    title: 'VERSIÓN DEL SISTEMA',
                    subtitle: 'FeelTrip v1.0.0 STABLE',
                    onTap: null,
                  ),

                  const SizedBox(height: 40),

                  // ── ZONA PELIGROSA ──────────────────────────────────
                  _dangerZone(context),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

 



  // ── WIDGETS DE SECCIÓN ──────────────────────────────────────────────

  Widget _sectionLabel(String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        label,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: colorScheme.tertiary.withValues(alpha: 0.7),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _settingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    List<Shadow>? iconShadows,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.03),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.08)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(
          icon,
          color: colorScheme.onSurface.withValues(alpha: 0.7),
          size: 20,
          shadows: iconShadows,
        ),
        title: Text(
          title,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            color: colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
        trailing: onTap != null
            ? Icon(Icons.chevron_right, size: 16, color: colorScheme.onSurface.withValues(alpha: 0.3))
            : null,
        onTap: onTap,
      ),
    );
  }

  Widget _settingsSwitch(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.03),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.08)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(icon, color: colorScheme.onSurface.withValues(alpha: 0.7), size: 20),
        title: Text(
          title,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            color: colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: colorScheme.primary,
        ),
      ),
    );
  }

  Widget _dangerZone(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 40, height: 1, color: colorScheme.error.withValues(alpha: 0.4)),
            const SizedBox(width: 8),
            Text(
              'ZONA DE PELIGRO',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: colorScheme.error.withValues(alpha: 0.7),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: Container(height: 1, color: colorScheme.error.withValues(alpha: 0.4))),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.error.withValues(alpha: 0.3)),
            color: colorScheme.error.withValues(alpha: 0.03),
          ),
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.logout, color: colorScheme.error.withValues(alpha: 0.8), size: 20),
                title: Text(
                  'FINALIZAR SESIÓN',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.error,
                  ),
                ),
                subtitle: Text(
                  'Cierra la sesión actual del dispositivo',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
                trailing: Icon(Icons.chevron_right, size: 16, color: colorScheme.error.withValues(alpha: 0.4)),
                onTap: () => _showLogoutDialog(context),
              ),
              Divider(color: colorScheme.error.withValues(alpha: 0.15), height: 1),
              ListTile(
                leading: Icon(Icons.delete_forever_outlined, color: colorScheme.error, size: 20),
                title: Text(
                  'ELIMINAR CUENTA',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.error,
                  ),
                ),
                subtitle: Text(
                  'Elimina permanentemente todos tus datos',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
                trailing: _isDeleting
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.error),
                      )
                    : Icon(Icons.chevron_right, size: 16, color: colorScheme.error.withValues(alpha: 0.4)),
                onTap: _isDeleting ? null : () => _showDeleteAccountDialog(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '⚠ La eliminación de cuenta es irreversible y purga todos\nlos datos de Firestore asociados a tu UID.',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 9,
            color: colorScheme.error.withValues(alpha: 0.5),
            height: 1.6,
          ),
        ),
      ],
    );
  }

  // ── DIÁLOGOS ────────────────────────────────────────────────────────

  Future<void> _toggleBiometrics(bool val) async {
    if (!val) {
      setState(() => _biometricEnabled = false);
      return;
    }

    final colorScheme = Theme.of(context).colorScheme;
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: colorScheme.outline),
        ),
        title: Row(
          children: [
            Icon(Icons.monitor_heart_outlined, color: colorScheme.primary, size: 24),
            const SizedBox(width: 8),
            Text(
              'CONSENTIMIENTO BIOMÉTRICO',
              style: GoogleFonts.jetBrainsMono(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
                fontSize: 12,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Al activar esta función, FeelTrip procesará métricas como tu Variabilidad de Frecuencia Cardíaca (HRV) para adaptar de forma personalizada tus itinerarios y recomendaciones.',
              style: GoogleFonts.ebGaramond(
                fontSize: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.9),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '> Conforme a la Ley N° 19.628 de Protección de Datos Personales, estos datos se consideran sensibles y no serán compartidos con terceros sin tu consentimiento explícito.',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'RECHAZAR',
              style: GoogleFonts.jetBrainsMono(color: colorScheme.onSurface.withValues(alpha: 0.5)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: Text(
              'ACEPTO',
              style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (accepted == true) {
      setState(() => _biometricEnabled = true);
    }
  }

  void _showLogoutDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
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
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCELAR',
                style: GoogleFonts.jetBrainsMono(color: colorScheme.onSurface.withValues(alpha: 0.5))),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).signOut();
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: Text('CONFIRMAR',
                style: GoogleFonts.jetBrainsMono(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final confirmController = TextEditingController();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(color: colorScheme.error.withValues(alpha: 0.5), width: 1.5),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: colorScheme.error, size: 20),
              const SizedBox(width: 8),
              Text(
                'ELIMINAR CUENTA',
                style: GoogleFonts.jetBrainsMono(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.error,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Esta acción eliminará permanentemente:',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 12),
              ...[
                'Perfil y datos personales',
                'Crónicas e historias',
                'Expediciones y rutas GPS',
                'Momentos y fotografías',
                'Credenciales de acceso',
              ].map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Icon(Icons.remove, size: 12, color: colorScheme.error),
                        const SizedBox(width: 8),
                        Text(
                          item,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 20),
              Text(
                'Escribe ELIMINAR para confirmar:',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: confirmController,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 14,
                  color: colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: 'ELIMINAR',
                  hintStyle: GoogleFonts.jetBrainsMono(
                    fontSize: 14,
                    color: colorScheme.onSurface.withValues(alpha: 0.2),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.error.withValues(alpha: 0.4)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.error),
                  ),
                ),
                onChanged: (_) => setDialogState(() {}),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                confirmController.dispose();
                Navigator.pop(ctx);
              },
              child: Text(
                'CANCELAR',
                style: GoogleFonts.jetBrainsMono(color: colorScheme.onSurface.withValues(alpha: 0.5)),
              ),
            ),
            ElevatedButton(
              onPressed: confirmController.text == 'ELIMINAR'
                  ? () async {
                      Navigator.pop(ctx);
                      await _deleteAccount();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.error,
                disabledBackgroundColor: colorScheme.error.withValues(alpha: 0.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: Text(
                'ELIMINAR CUENTA',
                style: GoogleFonts.jetBrainsMono(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showArcoDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: colorScheme.outline),
        ),
        title: Text(
          'DERECHOS ARCO',
          style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Conforme a la Ley N° 19.628 de Chile, puedes ejercer tus derechos de:',
              style: GoogleFonts.jetBrainsMono(fontSize: 11, color: colorScheme.onSurface.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 16),
            ...[
              ('A', 'Acceso', 'Ver tus datos almacenados'),
              ('R', 'Rectificación', 'Corregir datos inexactos'),
              ('C', 'Cancelación', 'Eliminar tu cuenta y datos'),
              ('O', 'Oposición', 'Denegar uso secundario'),
            ].map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: colorScheme.primary),
                        ),
                        child: Text(
                          item.$1,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.$2,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              item.$3,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                color: colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 8),
            Text(
              'Contacto: soporte@feeltrip.app',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CERRAR',
                style: GoogleFonts.jetBrainsMono(color: colorScheme.onSurface.withValues(alpha: 0.5))),
          ),
        ],
      ),
    );
  }

  // ── LÓGICA DE ELIMINACIÓN ────────────────────────────────────────────

  Future<bool> _showReauthDialog() async {
    // Detectar provider del usuario actual
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

  // ── RE-AUTH GOOGLE ───────────────────────────────────────────────────

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
    } on FirebaseAuthException catch (e) {
      if (mounted) _showErrorSnackbar('Error Google: ${e.code.toUpperCase()}');
      return false;
    } catch (e) {
      if (mounted) _showErrorSnackbar('Error inesperado con Google');
      return false;
    }
  }

  // ── RE-AUTH FACEBOOK ─────────────────────────────────────────────────

  Future<bool> _reauthWithFacebook() async {
    try {
      final result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.cancelled) return false;
      if (result.status != LoginStatus.success) {
        if (mounted) _showErrorSnackbar('Error Facebook: ${result.message}');
        return false;
      }

      final credential = FacebookAuthProvider.credential(
        result.accessToken!.tokenString,
      );

      await FirebaseAuth.instance.currentUser?.reauthenticateWithCredential(credential);
      return true;
    } on FirebaseAuthException catch (e) {
      if (mounted) _showErrorSnackbar('Error Facebook: ${e.code.toUpperCase()}');
      return false;
    } catch (e) {
      if (mounted) _showErrorSnackbar('Error inesperado con Facebook');
      return false;
    }
  }

  // ── RE-AUTH EMAIL/PASSWORD ───────────────────────────────────────────

  Future<bool> _reauthWithEmailPassword() async {
    final colorScheme = Theme.of(context).colorScheme;
    const boneWhite = Color(0xFFF5F5DC);
    const terminalGreen = Color(0xFF00FF41);

    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    bool isLoading = false;
    String? errorMsg;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(color: boneWhite.withValues(alpha: 0.2), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '> VERIFICACIÓN DE IDENTIDAD',
                      style: GoogleFonts.jetBrainsMono(
                        color: terminalGreen,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(color: terminalGreen.withValues(alpha: 0.5), blurRadius: 4)],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '> PROTOCOLO DE SEGURIDAD REQUERIDO',
                      style: GoogleFonts.jetBrainsMono(
                        color: terminalGreen.withValues(alpha: 0.6),
                        fontSize: 10,
                        shadows: [Shadow(color: terminalGreen.withValues(alpha: 0.3), blurRadius: 4)],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Confirma tu identidad\nantes de continuar',
                  style: GoogleFonts.ebGaramond(fontSize: 22, color: boneWhite, height: 1.3),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: emailController,
                  style: GoogleFonts.jetBrainsMono(color: boneWhite, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'AUTENTICACIÓN ID (EMAIL)',
                    labelStyle: GoogleFonts.jetBrainsMono(color: boneWhite.withValues(alpha: 0.4), fontSize: 9),
                    prefixIcon: Icon(Icons.alternate_email, color: boneWhite.withValues(alpha: 0.4), size: 16),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: boneWhite.withValues(alpha: 0.2))),
                    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: boneWhite)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: GoogleFonts.jetBrainsMono(color: boneWhite, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'CÓDIGO DE ACCESO (PASSWORD)',
                    labelStyle: GoogleFonts.jetBrainsMono(color: boneWhite.withValues(alpha: 0.4), fontSize: 9),
                    prefixIcon: Icon(Icons.lock_outline, color: boneWhite.withValues(alpha: 0.4), size: 16),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: boneWhite.withValues(alpha: 0.2))),
                    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: boneWhite)),
                  ),
                ),
                if (errorMsg != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      errorMsg!,
                      style: GoogleFonts.jetBrainsMono(color: Colors.redAccent, fontSize: 10),
                    ),
                  ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: boneWhite.withValues(alpha: 0.3)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          'CANCELAR',
                          style: GoogleFonts.jetBrainsMono(color: boneWhite.withValues(alpha: 0.5), fontSize: 11),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: colorScheme.error, width: 1.5),
                          boxShadow: [BoxShadow(color: colorScheme.error.withValues(alpha: 0.2), blurRadius: 8)],
                        ),
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  setDialogState(() { isLoading = true; errorMsg = null; });
                                  try {
                                    final credential = EmailAuthProvider.credential(
                                      email: emailController.text.trim(),
                                      password: passwordController.text.trim(),
                                    );
                                    await FirebaseAuth.instance.currentUser
                                        ?.reauthenticateWithCredential(credential);
                                    if (ctx.mounted) Navigator.pop(ctx, true);
                                  } on FirebaseAuthException catch (e) {
                                    setDialogState(() {
                                      isLoading = false;
                                      errorMsg = e.code == 'wrong-password'
                                          ? 'Contraseña incorrecta'
                                          : e.code == 'invalid-email'
                                              ? 'Email inválido'
                                              : 'Error: ${e.code.toUpperCase()}';
                                    });
                                  } catch (e) {
                                    setDialogState(() { isLoading = false; errorMsg = 'Error inesperado'; });
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: isLoading
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.error),
                                )
                              : Text(
                                  'CONFIRMAR',
                                  style: GoogleFonts.jetBrainsMono(
                                    color: colorScheme.error,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    emailController.dispose();
    passwordController.dispose();
    return result ?? false;
  }

  Future<void> _deleteAccount() async {
    final success = await _showReauthDialog();
    if (!success) return;

    setState(() => _isDeleting = true);

    try {
      await ref.read(authNotifierProvider.notifier).deleteAccount();
      if (!mounted) return;
      context.go('/login');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      _showErrorSnackbar('Error al eliminar cuenta. Contacta a soporte@feeltrip.app');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.jetBrainsMono(fontSize: 11),
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
