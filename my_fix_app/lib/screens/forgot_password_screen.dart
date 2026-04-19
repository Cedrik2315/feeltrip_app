import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:feeltrip_app/core/di/providers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSubmitting = false;

  // Colores FeelTrip eliminados para usar el tema global

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  'ACCESO RECUPERACIÓN',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Restablece tu llave de acceso.',
                  style: GoogleFonts.ebGaramond(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Ingresa tu correo electrónico y te enviaremos las instrucciones para re-encriptar tu cuenta y volver a tus expediciones.',
                  style: GoogleFonts.inter(
                    color: colorScheme.onSurface.withValues(alpha: .6),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),
                _buildEmailField(),
                const SizedBox(height: 40),
                _buildSubmitButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    final colorScheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: GoogleFonts.inter(color: colorScheme.onSurface),
      validator: _validateEmail,
      decoration: InputDecoration(
        labelText: 'CORREO ELECTRÓNICO',
        labelStyle: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold, color: colorScheme.onSurface.withValues(alpha: .4)),
        hintText: 'usuario@feeltrip.sys',
        floatingLabelBehavior: FloatingLabelBehavior.always,
        prefixIcon: Icon(Icons.alternate_email_rounded, color: colorScheme.onSurface, size: 20),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.1))),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorScheme.primary, width: 2)),
        errorStyle: GoogleFonts.jetBrainsMono(fontSize: 10),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: colorScheme.primary.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(
                'ENVIAR ENLACE',
                style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'DATO REQUERIDO';
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value.trim())) {
      return 'FORMATO INVÁLIDO';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    
    try {
      final email = _emailController.text.trim();
      await ref.read(authRepositoryProvider).sendPasswordResetEmail(email);

      if (!mounted) return;
      
      _showCustomSnackBar(
        context, 
        'LOG: Correo de recuperación enviado con éxito.', 
        Theme.of(context).colorScheme.primary
      );
      
      Navigator.of(context).pop();
      
    } catch (error) {
      if (!mounted) return;
      _showCustomSnackBar(
        context, 
        'ERROR: Usuario no identificado en el sistema.', 
        const Color(0xFF8B0000)
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showCustomSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.white),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}