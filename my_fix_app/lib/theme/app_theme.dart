import 'package:flutter/material.dart';

const ColorScheme feelTripColorScheme = ColorScheme(
  brightness: Brightness.dark,
  
  // Rojo Eléctrico / Coral (El "latido" y la pasión)
  primary: Color(0xFFFF2D55),
  onPrimary: Colors.white,
  
  // Violeta / Magenta (La transición tecnológica)
  secondary: Color(0xFF8E2DE2),
  onSecondary: Colors.white,
  
  // Azul Cian / Aero (La precisión de los agentes IA)
  tertiary: Color(0xFF00D2FF),
  onTertiary: Color(0xFF0D0D0D),

  // Fondos profundos para estética Cyber-Organic
  surface: Color(0xFF0D0D0D),
  onSurface: Color(0xFFF5F5DC), // Tono crema para lectura descansada
  
  error: Color(0xFFCF6679),
  onError: Colors.black,
  
  outline: Color(0xFF4A5D4E), // Tono bosque para bordes sutiles
);

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: feelTripColorScheme,
      scaffoldBackgroundColor: feelTripColorScheme.surface,
      
      // Tipografía moderna
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: Color(0xFFF5F5DC)),
        bodyMedium: TextStyle(color: Color(0xFFF5F5DC)),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15), 
          borderSide: BorderSide(color: feelTripColorScheme.outline)
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15), 
          borderSide: BorderSide(color: feelTripColorScheme.outline)
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15), 
          borderSide: BorderSide(color: feelTripColorScheme.tertiary, width: 1.5)
        ),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white30),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: feelTripColorScheme.surface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white, 
          fontSize: 20, 
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
        iconTheme: IconThemeData(color: feelTripColorScheme.primary),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: feelTripColorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          elevation: 4,
          shadowColor: feelTripColorScheme.primary.withValues(alpha: 0.5),
        ),
      ),

      cardTheme: CardThemeData(
        color: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
      ),
      
      dividerTheme: DividerThemeData(
        color: feelTripColorScheme.outline.withValues(alpha: 0.3),
        thickness: 1,
      ),
    );
  }
}
