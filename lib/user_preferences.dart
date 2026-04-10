import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- 1. MODELO DE DATOS ---
class UserPreferences {
  final bool showAdventure;
  final bool showCultural;
  final bool showNature;
  final bool showGastronomy;
  final bool showUrban;
  final bool showBeaches;
  final bool showMountains;
  final bool notificationsEnabled;
  final bool offlineFirstMode;
  final bool darkMode;
  final bool emotionalAnalytics;
  final String language;

  const UserPreferences({
    this.showAdventure = true,
    this.showCultural = true,
    this.showNature = true,
    this.showGastronomy = true,
    this.showUrban = true,
    this.showBeaches = true,
    this.showMountains = true,
    this.notificationsEnabled = true,
    this.offlineFirstMode = false,
    this.darkMode = false,
    this.emotionalAnalytics = false,
    this.language = 'es',
  });

  // Convertimos a Map para persistencia
  Map<String, dynamic> toMap() => {
    'showAdventure': showAdventure,
    'showCultural': showCultural,
    'showNature': showNature,
    'showGastronomy': showGastronomy,
    'showUrban': showUrban,
    'showBeaches': showBeaches,
    'showMountains': showMountains,
    'notificationsEnabled': notificationsEnabled,
    'offlineFirstMode': offlineFirstMode,
    'darkMode': darkMode,
    'emotionalAnalytics': emotionalAnalytics,
    'language': language,
  };

  // Creamos desde Map para carga inicial
  factory UserPreferences.fromMap(Map<String, dynamic> map) => UserPreferences(
    showAdventure: map['showAdventure'] as bool? ?? true,
    showCultural: map['showCultural'] as bool? ?? true,
    showNature: map['showNature'] as bool? ?? true,
    showGastronomy: map['showGastronomy'] as bool? ?? true,
    showUrban: map['showUrban'] as bool? ?? true,
    showBeaches: map['showBeaches'] as bool? ?? true,
    showMountains: map['showMountains'] as bool? ?? true,
    notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
    offlineFirstMode: map['offlineFirstMode'] as bool? ?? false,
    darkMode: map['darkMode'] as bool? ?? false,
    emotionalAnalytics: map['emotionalAnalytics'] as bool? ?? false,
    language: map['language'] as String? ?? 'es',
  );

  UserPreferences copyWith({
    bool? showAdventure,
    bool? showCultural,
    bool? showNature,
    bool? showGastronomy,
    bool? showUrban,
    bool? showBeaches,
    bool? showMountains,
    bool? notificationsEnabled,
    bool? offlineFirstMode,
    bool? darkMode,
    bool? emotionalAnalytics,
    String? language,
  }) => UserPreferences(
    showAdventure: showAdventure ?? this.showAdventure,
    showCultural: showCultural ?? this.showCultural,
    showNature: showNature ?? this.showNature,
    showGastronomy: showGastronomy ?? this.showGastronomy,
    showUrban: showUrban ?? this.showUrban,
    showBeaches: showBeaches ?? this.showBeaches,
    showMountains: showMountains ?? this.showMountains,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    offlineFirstMode: offlineFirstMode ?? this.offlineFirstMode,
    darkMode: darkMode ?? this.darkMode,
    emotionalAnalytics: emotionalAnalytics ?? this.emotionalAnalytics,
    language: language ?? this.language,
  );
}

// --- 2. NOTIFIER CON PERSISTENCIA ---
class UserPreferencesNotifier extends Notifier<UserPreferences> {
  static const _key = 'user_preferences_key';

  @override
  UserPreferences build() {
    // Intentamos cargar datos al inicializar
    _init();
    return const UserPreferences();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data != null) {
      state = UserPreferences.fromMap(jsonDecode(data) as Map<String, dynamic>);
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state.toMap()));
  }

  // Métodos de actualización
  void toggleDarkMode() {
    state = state.copyWith(darkMode: !state.darkMode);
    _save();
  }

  void toggleOfflineMode() {
    state = state.copyWith(offlineFirstMode: !state.offlineFirstMode);
    _save();
  }

  void toggleEmotionalEngine() {
    state = state.copyWith(emotionalAnalytics: !state.emotionalAnalytics);
    _save();
  }

  void toggleNotifications() {
    state = state.copyWith(notificationsEnabled: !state.notificationsEnabled);
    _save();
  }

  void setLanguage(String lang) {
    state = state.copyWith(language: lang);
    _save();
  }

  // Filtros de categoría
  void toggleAdventureFilter(bool v) { state = state.copyWith(showAdventure: v); _save(); }
  void toggleCulturalFilter(bool v) { state = state.copyWith(showCultural: v); _save(); }
  void toggleNatureFilter(bool v) { state = state.copyWith(showNature: v); _save(); }
  void toggleGastronomyFilter(bool v) { state = state.copyWith(showGastronomy: v); _save(); }
  void toggleUrbanFilter(bool v) { state = state.copyWith(showUrban: v); _save(); }
  void toggleBeachesFilter(bool v) { state = state.copyWith(showBeaches: v); _save(); }
  void toggleMountainsFilter(bool v) { state = state.copyWith(showMountains: v); _save(); }
}

// --- 3. PROVIDER ---
final userPreferencesProvider = NotifierProvider<UserPreferencesNotifier, UserPreferences>(
  UserPreferencesNotifier.new,
);