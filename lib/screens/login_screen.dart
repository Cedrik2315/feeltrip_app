import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:feeltrip_app/core/di/providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  static const Color boneWhite = Color(0xFFF5F5DC);
  static const Color terminalGreen = Color(0xFF00FF41);

  Future<void> _signIn() async {
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        context.go('/home');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _mapError(e.code);
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _validateForm() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Completa todos los campos');
      return false;
    }
    return true;
  }

  String _mapError(String code) {
    switch (code) {
      case 'user-not-found': return 'Usuario no encontrado';
      case 'wrong-password': return 'Contraseña incorrecta';
      case 'invalid-email': return 'Email inválido';
      default: return 'Error: ${code.toUpperCase()}';
    }
  }

  Future<void> _handleSocialLoginWithConsent(Future<void> Function() loginMethod) async {
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: boneWhite.withValues(alpha: 0.2)),
        ),
        title: Text(
          '> TÉRMINOS Y PRIVACIDAD',
          style: GoogleFonts.jetBrainsMono(
            fontWeight: FontWeight.bold,
            color: terminalGreen,
            fontSize: 12,
            shadows: [Shadow(color: terminalGreen.withValues(alpha: 0.5), blurRadius: 4)],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Para acceder vía redes sociales, requieres confirmar la aceptación de:',
              style: GoogleFonts.jetBrainsMono(
                color: boneWhite.withValues(alpha: 0.8),
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => context.push('/privacy'),
              child: Text(
                '> Políticas de Privacidad',
                style: GoogleFonts.jetBrainsMono(
                  color: terminalGreen.withValues(alpha: 0.8),
                  fontSize: 11,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => context.push('/terms'), // Assuming '/terms' route exists similar to privacy
              child: Text(
                '> Términos y Condiciones',
                style: GoogleFonts.jetBrainsMono(
                  color: terminalGreen.withValues(alpha: 0.8),
                  fontSize: 11,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'CANCELAR',
              style: GoogleFonts.jetBrainsMono(
                color: boneWhite.withValues(alpha: 0.5),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              side: const BorderSide(color: terminalGreen),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: Text(
              'ACEPTAR',
              style: GoogleFonts.jetBrainsMono(
                color: terminalGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (accepted == true) {
      await loginMethod();
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.signInWithGoogle();
    
    result.fold(
      (failure) {
        if (mounted) setState(() { _errorMessage = 'Error en Google: ${failure.message}'; _isLoading = false; });
      },
      (user) {
        if (mounted) context.go('/home');
      }
    );
  }

  Future<void> _signInWithFacebook() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.signInWithFacebook();
    
    result.fold(
      (failure) {
        if (mounted) setState(() { _errorMessage = 'Error en Facebook: ${failure.message}'; _isLoading = false; });
      },
      (user) {
        if (mounted) context.go('/home');
      }
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Image with Dark Overlay
          Positioned.fill(
            child: Image.asset(
              'assets/images/login_bg.png',
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
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                children: [
                  const Spacer(),
                  
                  // Compass Logo (Mockup Style)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: boneWhite, width: 2),
                    ),
                    child: const Icon(Icons.explore_outlined, color: boneWhite, size: 48),
                  ),
                  const SizedBox(height: 16),
                  
                  // Title
                  Text(
                    'FeelTrip',
                    style: GoogleFonts.ebGaramond(
                      fontSize: 48,
                      color: boneWhite,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Terminal Telemetry Section
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTerminalLine('> INICIANDO PROTOCOLO FEELTRIP...'),
                        _buildTerminalLine('> CARGANDO DATOS DE AVENTURA...'),
                        _buildTerminalLine('> BIENVENIDO EXPLORADOR'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Email Field
                  _buildTechnicalField(
                    controller: _emailController,
                    label: 'AUTENTICACIÓN ID (EMAIL)',
                    icon: Icons.alternate_email,
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  _buildTechnicalField(
                    controller: _passwordController,
                    label: 'CODIGO ACCESO (PASSWORD)',
                    icon: Icons.lock_outline,
                    obscure: true,
                  ),

                  // Error Message
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        _errorMessage!,
                        style: GoogleFonts.jetBrainsMono(color: Colors.redAccent, fontSize: 12),
                      ),
                    ),

                  const SizedBox(height: 40),

                  // Main Login Button (Glow Border Style)
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: boneWhite, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: boneWhite.withValues(alpha: 0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: boneWhite,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: boneWhite)
                          : Text(
                              'INICIAR EXPEDICION',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Social Logins
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(
                        icon: FontAwesomeIcons.google,
                        label: 'GMAIL',
                        onTap: () => _handleSocialLoginWithConsent(_signInWithGoogle),
                      ),
                      const SizedBox(width: 24),
                      _buildSocialButton(
                        icon: FontAwesomeIcons.facebookF,
                        label: 'META',
                        onTap: () => _handleSocialLoginWithConsent(_signInWithFacebook),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Register Link
                    TextButton(
                      onPressed: () => context.go('/register'),
                      child: Text(
                        '¿NUEVO EN LA RED? REGISTRATE',
                        style: GoogleFonts.jetBrainsMono(
                          color: boneWhite.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => context.push('/privacy'),
                      child: Text(
                        'REVISAR PROTOCOLO DE PRIVACIDAD',
                        style: GoogleFonts.jetBrainsMono(
                          color: boneWhite.withValues(alpha: 0.5),
                          fontSize: 10,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTerminalLine(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: GoogleFonts.jetBrainsMono(
          color: terminalGreen,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: terminalGreen.withValues(alpha: 0.5), blurRadius: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicalField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: GoogleFonts.jetBrainsMono(color: boneWhite, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.jetBrainsMono(color: boneWhite.withValues(alpha: 0.5), fontSize: 10),
        prefixIcon: Icon(icon, color: boneWhite.withValues(alpha: 0.5), size: 18),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: boneWhite.withValues(alpha: 0.3)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: boneWhite),
        ),
      ),
    );
  }

  Widget _buildSocialButton({required dynamic icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          FaIcon(icon as FaIconData, color: boneWhite, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(color: boneWhite, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
