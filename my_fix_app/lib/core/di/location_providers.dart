import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
class UserPreferences {
  const UserPreferences({
    required this.isQuietModeEnabled,
  });
  static const defaultPreferences = UserPreferences(isQuietModeEnabled: false);
  final bool isQuietModeEnabled;

  UserPreferences copyWith({bool? isQuietModeEnabled}) {
    return UserPreferences(
      isQuietModeEnabled: isQuietModeEnabled ?? this.isQuietModeEnabled,
    );
  }
}

final userLocationProvider = FutureProvider<Position>((ref) async {
  final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('Location services not enabled');
  }
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Location permissions denied');
    }
  }
  return await Geolocator.getCurrentPosition();
});

class UserPreferencesNotifier extends StateNotifier<UserPreferences> {
  UserPreferencesNotifier() : super(UserPreferences.defaultPreferences);

  void update(UserPreferences Function(UserPreferences) updateFn) {
    state = updateFn(state);
  }
}

final userPreferencesProvider = StateNotifierProvider<UserPreferencesNotifier, UserPreferences>((ref) => UserPreferencesNotifier());

