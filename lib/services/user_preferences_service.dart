import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'isar_service.dart';

/// [Sello FeelTrip]: Las preferencias son "Parámetros del Sistema"
class UserPreferences { // El "corazón": ¿Registrar emociones en el diario?

  UserPreferences({
    this.darkMode = true, // Default Carbon Black
    this.language = 'es',
    this.pushNotifications = true,
    this.showAiSuggestions = true,
    this.offlineMode = true, 
    this.emotionalLogging = true,
  });
  final bool darkMode;
  final String language;
  final bool pushNotifications;
  final bool showAiSuggestions;
  // Nuevos campos del sello FeelTrip
  final bool offlineMode;      // Arquitectura FeelTrip: Viajes remotos sin señal
  final bool emotionalLogging;

  UserPreferences copyWith({
    bool? darkMode,
    String? language,
    bool? pushNotifications,
    bool? showAiSuggestions,
    bool? offlineMode,
    bool? emotionalLogging,
  }) {
    return UserPreferences(
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      showAiSuggestions: showAiSuggestions ?? this.showAiSuggestions,
      offlineMode: offlineMode ?? this.offlineMode,
      emotionalLogging: emotionalLogging ?? this.emotionalLogging,
    );
  }
}

class UserPreferencesNotifier extends Notifier<UserPreferences> {
  late final IsarService _isar;

  @override
  UserPreferences build() {
    _isar = ref.watch(isarServiceProvider);
    return _loadFromSystemParams();
  }

  /// [Sello FeelTrip]: Carga de parámetros con valores por defecto de la marca
  UserPreferences _loadFromSystemParams() {
    final box = _isar.prefsBox;
    return UserPreferences(
      darkMode: box.get('darkMode', defaultValue: true) as bool,
      language: box.get('language', defaultValue: 'es') as String,
      pushNotifications: box.get('pushNotifications', defaultValue: true) as bool,
      showAiSuggestions: box.get('showAiSuggestions', defaultValue: true) as bool,
      offlineMode: box.get('offlineMode', defaultValue: true) as bool,
      emotionalLogging: box.get('emotionalLogging', defaultValue: true) as bool,
    );
  }

  // --- MÉTODOS DE CALIBRACIÓN DEL SISTEMA ---

  Future<void> toggleParam(String key, dynamic value) async {
    await _isar.prefsBox.put(key, value);
    state = _loadFromSystemParams();
  }

  // Específicos para el Diario y la IA de FeelTrip
  Future<void> toggleOfflineCapability() async {
    final newValue = !state.offlineMode;
    await toggleParam('offlineMode', newValue);
  }

  Future<void> toggleEmotionalEngine() async {
    final newValue = !state.emotionalLogging;
    await toggleParam('emotionalLogging', newValue);
  }
}

final userPreferencesProvider =
    NotifierProvider<UserPreferencesNotifier, UserPreferences>(
        UserPreferencesNotifier.new);