import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class UserPreferencesNotifier extends Notifier<UserPreferences> {
  @override
  UserPreferences build() => const UserPreferences();

  void toggleDarkMode() => state = state.copyWith(darkMode: !state.darkMode);
  void toggleOfflineMode() => state = state.copyWith(offlineFirstMode: !state.offlineFirstMode);
  void toggleEmotionalEngine() => state = state.copyWith(emotionalAnalytics: !state.emotionalAnalytics);
  void toggleNotifications() => state = state.copyWith(notificationsEnabled: !state.notificationsEnabled);
  void setLanguage(String lang) => state = state.copyWith(language: lang);
  void toggleAdventureFilter(bool value) => state = state.copyWith(showAdventure: value);
  void toggleCulturalFilter(bool value) => state = state.copyWith(showCultural: value);
  void toggleNatureFilter(bool value) => state = state.copyWith(showNature: value);
  void toggleGastronomyFilter(bool value) => state = state.copyWith(showGastronomy: value);
  void toggleUrbanFilter(bool value) => state = state.copyWith(showUrban: value);
  void toggleBeachesFilter(bool value) => state = state.copyWith(showBeaches: value);
  void toggleMountainsFilter(bool value) => state = state.copyWith(showMountains: value);
}

final userPreferencesProvider = NotifierProvider<UserPreferencesNotifier, UserPreferences>(UserPreferencesNotifier.new);
