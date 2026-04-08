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

  // Colores FeelTrip
  static const Color boneWhite = Color(0xFFF5F5DC);
  static const Color mossGreen = Color(0xFF4B5320);
  static const Color carbon = Color(0xFF1A1A1A);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: boneWhite,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: carbon, size: 20),
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
                  'ACCESO_RECUPERACIÓN',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: mossGreen,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Restablece tu llave de acceso.',
                  style: GoogleFonts.ebGaramond(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: carbon,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Ingresa tu correo electrónico y te enviaremos las instrucciones para re-encriptar tu cuenta y volver a tus expediciones.',
                  style: GoogleFonts.inter(
                    color: carbon.withValues(alpha: .6),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),
                _buildEmailField(),
                const SizedBox(height: 40),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: GoogleFonts.inter(color: carbon),
      validator: _validateEmail,
      decoration: InputDecoration(
        labelText: 'CORREO_ELECTRÓNICO',
        labelStyle: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold, color: carbon.withValues(alpha: .4)),
        hintText: 'usuario@feeltrip.sys',
        floatingLabelBehavior: FloatingLabelBehavior.always,
        prefixIcon: const Icon(Icons.alternate_email_rounded, color: carbon, size: 20),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: mossGreen, width: 2)),
        errorStyle: GoogleFonts.jetBrainsMono(fontSize: 10),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: carbon,
          foregroundColor: boneWhite,
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: boneWhite, strokeWidth: 2),
              )
            : Text(
                'ENVIAR_ENLACE',
                style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'DATO_REQUERIDO';
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value.trim())) {
      return 'FORMATO_INVÁLIDO';
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
        mossGreen
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
          style: GoogleFonts.jetBrainsMono(fontSize: 11, color: boneWhite),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}