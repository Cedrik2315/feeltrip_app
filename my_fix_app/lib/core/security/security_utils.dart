class SecurityUtils {
  /// Sanatiza el input para prevenir XSS y Prompt Injection.
  /// Limpia etiquetas HTML y caracteres de control sospechosos.
  static String sanitizeInput(String input, {int maxLength = 1000}) {
    if (input.isEmpty) return '';
    
    // 1. Limitar longitud para prevenir ataques DoS
    String sanitized = input.length > maxLength ? input.substring(0, maxLength) : input;

    // 2. Remover etiquetas HTML burdamente para prevenir XSS básico
    sanitized = sanitized.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '');

    // 3. Escapar caracteres especiales que podrían interferir con prompts de IA
    sanitized = sanitized
        .replaceAll(RegExp(r'[<{}[\]]'), '') // Remueve corchetes y llaves
        .replaceAll(r'$', r'\$') // Escapa signo de dólar
        .trim();

    return sanitized;
  }

  /// Valida si un email es estructuralmente correcto.
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  /// Limpia strings para ser usados en consultas (PREVENCIÓN DE INJECTION)
  static String escapeString(String text) {
    return text.replaceAll("'", "''").replaceAll('"', '""');
  }
}
