class DynamicTranslator {
  /// Diccionario dinámico local. Podría también sincronizarse con Firebase Remote Config.
  static final Map<String, Map<String, String>> _dictionary = {
    'es': {
      // Hitos de Quillota
      'hito_consistorial_title': 'Edificio Consistorial',
      'hito_consistorial_desc': 'El centro político colonial. Secretos palpitan bajo sus cimientos de piedra.',
      'hito_museo_title': 'Museo Arqueológico',
      'hito_museo_desc': 'Restos de la civilización Bato aguardan en estas sombras centenarias.',
      'hito_plaza_title': 'Plaza de Armas',
      'hito_plaza_desc': 'El corazón del valle. Aquí la vida transcurre bajo la sombra protectora de pinos ancestrales.',
      'hito_estacion_title': 'Ex Estación Bio-Tren',
      'hito_estacion_desc': 'Diseño puramente funcional donde el acero conectó el valle.',
      'hito_mercado_title': 'El Mercado del Silencio',
      'hito_mercado_desc': 'Zona sin radar. Solo la gente local conoce las reliquias que esconde este laberinto.',

      // Ui Elements
      'btn_reveal': 'REVELAR LO INVISIBLE',
      'btn_wall': 'DEJAR MEMORIA EN ESTE MURO',
      'status_new_zone': 'NUEVA ZONA DETECTADA',
      'status_downloading': 'Sincronizando Over-The-Air...',
      'category_history': 'HISTORIA',
      'category_social': 'SOCIAL',
      'category_technic': 'TÉCNICO',
      'category_design': 'DISEÑO',
    },
    'en': {
      // Hitos de Quillota
      'hito_consistorial_title': 'Consistorial Building',
      'hito_consistorial_desc': 'The colonial political center. Secrets pulse beneath its stone foundations.',
      'hito_museo_title': 'Archaeological Museum',
      'hito_museo_desc': 'Remains of the Bato civilization await in these centuries-old shadows.',
      'hito_plaza_title': 'Main Square',
      'hito_plaza_desc': 'The heart of the valley. Life goes on here under the protective shadow of ancient pines.',
      'hito_estacion_title': 'Former Train Station',
      'hito_estacion_desc': 'Purely functional design where steel connected the valley.',
      'hito_mercado_title': 'The Silent Market',
      'hito_mercado_desc': 'Off-grid zone. Only locals know the relics hidden in this maze.',

      // Ui Elements
      'btn_reveal': 'REVEAL THE INVISIBLE',
      'btn_wall': 'LEAVE A MEMORY ON THIS WALL',
      'status_new_zone': 'NEW ZONE DETECTED',
      'status_downloading': 'Syncing Over-The-Air...',
      'category_history': 'HISTORY',
      'category_social': 'SOCIAL',
      'category_technic': 'TECHNICAL',
      'category_design': 'DESIGN',
    }
  };

  /// Devuelve la traducción de una [key] basándose en el [localeCode] (ej: 'en', 'es').
  /// Si no existe el locale o la key, hace un fallback a inglés y luego devuelve la misma key.
  static String translate(String key, {String localeCode = 'es'}) {
    final dict = _dictionary[localeCode] ?? _dictionary['en'];
    if (dict != null && dict.containsKey(key)) {
      return dict[key]!;
    }
    // Fallback dictionary (Inglés) si la clave no existe en español
    final fallbackDict = _dictionary['en'];
    return fallbackDict?[key] ?? key; 
  }
}
