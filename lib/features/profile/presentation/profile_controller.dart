import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user_profile_model.dart';
import '../data/profile_repository_providers.dart';

/// StateNotifier que gestiona el estado del perfil de forma asíncrona.
class ProfileController extends AsyncNotifier<UserProfile?> {
  
  @override
  FutureOr<UserProfile?> build() async {
    // Al iniciar, cargamos el perfil (esto activará el loading en la UI)
    return _fetchProfile();
  }

  /// Método privado para centralizar la llamada al repositorio
  Future<UserProfile?> _fetchProfile() async {
    final repository = ref.read(profileRepositoryProvider);
    return await repository.getUserProfile();
  }

  /// Refresca los datos (utilizado por el RefreshIndicator de la Screen)
  Future<void> refreshProfile() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchProfile());
  }

  /// Actualiza un campo específico y sincroniza con el repositorio
  /// Ejemplo: Incrementar experiencia o cambiar el nombre
  Future<void> updateProfile(UserProfile updatedProfile) async {
    final repository = ref.read(profileRepositoryProvider);
    
    // Optimismo: Actualizamos el estado local de inmediato para una UI fluida
    state = AsyncValue.data(updatedProfile);

    try {
      await repository.saveProfile(updatedProfile);
    } catch (e, stack) {
      // Si falla la red, revertimos o manejamos el error
      state = AsyncValue.error(e, stack);
    }
  }
}

/// Provider global para que la UI pueda observar el estado del perfil
final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, UserProfile?>(() {
  return ProfileController();
});