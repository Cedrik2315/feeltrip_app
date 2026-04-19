import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:feeltrip_app/models/expedition_data.dart';
import 'package:feeltrip_app/models/gps_models.dart';
import 'package:feeltrip_app/services/chronicle_repository_impl.dart';
import 'package:feeltrip_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:feeltrip_app/models/chronicle_model.dart';
import 'package:feeltrip_app/core/di/providers.dart';

/// Estado de la generación de la crónica
final finishChronicleProvider = StateNotifierProvider<ChronicleGeneratorNotifier, AsyncValue<ChronicleModel?>>((ref) {
  return ChronicleGeneratorNotifier(ref);
});

class ChronicleGeneratorNotifier extends StateNotifier<AsyncValue<ChronicleModel?>> {
  final Ref ref;

  ChronicleGeneratorNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<ChronicleModel?> generate({
    required RouteModel route,
    required String userDetail,
    required String explorerName,
    required NarrativeTone tone,
  }) async {
    state = const AsyncValue.loading();

    try {
      // 1. OBTENCIÓN DE IDENTIDAD Y CONTEXTO DEL USUARIO
      final authState = ref.read(authNotifierProvider);
      final userId = authState.value?.id ?? 'guest_user';

      // 2. PREPARACIÓN DE DATOS PARA FEELTRIP_OS
      final data = ExpeditionData(
        placeName: route.placeName,
        region: route.region,
        arrivalTime: _formatDate(DateTime.now()),
        temperature: '${route.weatherSnapshot?.temperatureCelsius.toStringAsFixed(1) ?? "N/A"}°C',
        uniqueDetail: userDetail,
        explorerName: explorerName,
        tone: tone,
        distanceKm: route.totalDistanceKm,
        durationMinutes: route.durationMinutes,
        elevationGainM: route.elevationGainMeters,
      );

      // 3. LLAMADA AL REPOSITORIO (Generación vía Gemini y Persistencia Local)
      final chronicle = await ref.read(chronicleRepositoryProvider).generateAndSave(
        data: data,
        userId: userId,
      );

      // 4. PUSH NATIVO: Crónica lista
      unawaited(
        ref.read(notificationServiceProvider).notifyChronicleReady(
          userId: userId,
          chronicleTitle: chronicle.title,
          chronicleId: chronicle.id,
        ),
      );

      state = AsyncValue.data(chronicle);
      return chronicle;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day} de ${_getMonthName(date.month)}, ${date.year}';
  }

  String _getMonthName(int month) {
    const months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return months[month - 1];
  }
}