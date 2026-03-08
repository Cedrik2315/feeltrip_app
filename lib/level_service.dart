class LevelService {
  /// Calculates the user level based on total XP
  /// Each level requires 500 XP more than the previous one
  static int calcularNivel(int totalXP) {
    if (totalXP < 0) return 1;

    int nivel = 1;
    int xpRequerida = 500;
    int xpAcumulada = 0;

    while (xpAcumulada + xpRequerida <= totalXP) {
      xpAcumulada += xpRequerida;
      nivel++;
      xpRequerida = 500 * nivel; // Each level requires more XP
    }

    return nivel;
  }

  /// Returns the title based on the user level
  static String obtenerTitulo(int nivel) {
    switch (nivel) {
      case 1:
        return 'Explorador Inicial';
      case 2:
        return 'Viajero Curioso';
      case 3:
        return 'Aventurero Experto';
      case 4:
        return 'Viajero Senior';
      case 5:
        return 'Maestro Viajero';
      case 6:
        return 'Leyenda Viajera';
      case 7:
        return 'Guardián del Mundo';
      case 8:
        return 'Embajador Cultural';
      case 9:
        return 'Viajero Ilustre';
      case 10:
        return 'Leyenda Viva';
      default:
        if (nivel >= 50) return 'Maestro Supremo';
        if (nivel >= 25) return 'Gran Embajador';
        if (nivel >= 15) return 'Explorador Legendario';
        if (nivel >= 10) return 'Viajero Élite';
        return 'Explorador nivel $nivel';
    }
  }

  /// Calculates XP needed for next level
  static int xpParaSiguienteNivel(int totalXP) {
    int nivelActual = calcularNivel(totalXP);
    int xpRequerida = 500 * nivelActual;
    int xpActualNivel = 0;

    for (int i = 1; i < nivelActual; i++) {
      xpActualNivel += 500 * i;
    }

    return xpRequerida - (totalXP - xpActualNivel);
  }

  /// Returns progress percentage to next level (0.0 to 1.0)
  static double progresoNivel(int totalXP) {
    int nivelActual = calcularNivel(totalXP);
    int xpRequeridaNivel = 500 * nivelActual;
    int xpBaseNivel = 0;

    for (int i = 1; i < nivelActual; i++) {
      xpBaseNivel += 500 * i;
    }

    int xpEnNivelActual = totalXP - xpBaseNivel;
    return (xpEnNivelActual / xpRequeridaNivel).clamp(0.0, 1.0);
  }
}
