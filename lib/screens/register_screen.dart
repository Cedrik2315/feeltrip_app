import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Nota: Asegúrate de tener estas dependencias en tu pubspec.yaml si vas a usar Firebase:
// firebase_auth: ^latest_version

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Clave global para manejar las validaciones del formulario
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Estados de la UI
  bool _obscurePassword = true;
  bool _agreedToTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    // Es vital liberar los controladores para evitar fugas de memoria
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Validación de Email con Expresión Regular
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'El email es obligatorio';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Ingresa un email válido';
    return null;
  }

  // Lógica principal de registro
  Future<void> _handleRegister() async {
    // 1. Ejecutar validaciones del Form
    if (!_formKey.currentState!.validate()) return;

    // 2. Validar que el Checkbox de términos esté marcado
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes aceptar los términos y condiciones'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // --- INTEGRACIÓN REAL AQUÍ ---
      // Ejemplo con Firebase Auth:
      // await FirebaseAuth.instance.createUserWithEmailAndPassword(
      //   email: _emailController.text.trim(),
      //   password: _passwordController.text.trim(),
      // );
      
      // Simulación de delay de red
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Navegar al Home tras éxito
      context.go('/home');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Bienvenido a FeelTrip! 🌎'),
          backgroundColor: Colors.teal,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error en el registro: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.teal[800]!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Encabezado con diseño curvo (Estilo Travel-Tech)
            _buildHeader(themeColor),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputField(
                      label: 'Nombre Completo',
                      controller: _nameController,
                      hint: 'Ej: Juan Pérez',
                      icon: Icons.person_outline,
                      validator: (v) => v!.isEmpty ? 'Por favor, ingresa tu nombre' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildInputField(
                      label: 'Email',
                      controller: _emailController,
                      hint: 'tu@correo.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildInputField(
                      label: 'Contraseña',
                      controller: _passwordController,
                      hint: 'Mínimo 6 caracteres',
                      icon: Icons.lock_outline,
                      obscure: _obscurePassword,
                      suffix: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (v) => v!.length < 6 ? 'La contraseña es muy corta' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildInputField(
                      label: 'Confirmar Contraseña',
                      controller: _confirmPasswordController,
                      hint: 'Repite tu contraseña',
                      icon: Icons.lock_reset,
                      obscure: true,
                      validator: (v) => v != _passwordController.text ? 'Las contraseñas no coinciden' : null,
                    ),
                    
                    const SizedBox(height: 20),
                    _buildTermsCheckbox(),
                    
                    const SizedBox(height: 30),
                    _buildSubmitButton(themeColor),
                    
                    _buildLoginLink(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS DE SOPORTE ---

  Widget _buildHeader(Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 80, bottom: 50, left: 30, right: 30),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(60),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.map_rounded, color: Colors.white, size: 40),
          SizedBox(height: 16),
          Text(
            'Crea tu cuenta',
            style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Explora Quillota y sus alrededores de forma auténtica.',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.teal, size: 22),
            suffixIcon: suffix,
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.teal, width: 1.5),
            ),
            errorStyle: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: _agreedToTerms,
            activeColor: Colors.teal,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
            child: Text(
              'Acepto los términos y la política de privacidad',
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(Color color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: _isLoading ? null : _handleRegister,
        child: _isLoading 
          ? const SizedBox(
              height: 20, 
              width: 20, 
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
            ) 
          : const Text(
              'REGISTRARME',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1),
            ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Center(
        child: TextButton(
          onPressed: () => context.pop(), // Vuelve a la pantalla de Login
          child: RichText(
            text: const TextSpan(
              text: '¿Ya tienes cuenta? ',
              style: TextStyle(color: Colors.black54, fontSize: 14),
              children: [
                TextSpan(
                  text: 'Inicia sesión',
                  style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}