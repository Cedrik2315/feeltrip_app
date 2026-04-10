import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:feeltrip_app/core/di/providers.dart';
import 'package:feeltrip_app/services/isar_service.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';

import 'package:feeltrip_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:feeltrip_app/models/itinerary_model.dart';
import 'package:feeltrip_app/services/gemini_service.dart';
import 'package:feeltrip_app/models/syncable_model.dart';

final myItinerariesProvider =
    FutureProvider.autoDispose<List<ItineraryModel>>((ref) async {
  final isarService = ref.watch(isarServiceProvider);
  final authState = ref.watch(authNotifierProvider);
  final userId = authState.value?.id;
  if (userId == null) return [];

  return isarService.getItineraries(userId: userId, status: 'active');
});

class MyItinerariesScreen extends ConsumerWidget {
  const MyItinerariesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itinerariesAsync = ref.watch(myItinerariesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Itinerarios Activos'),
        backgroundColor: Colors.deepPurple,
      ),
      body: itinerariesAsync.when<Widget>(
        data: (itineraries) {
          if (itineraries.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.map_outlined,
                        size: 80, color: Colors.grey),
                    const SizedBox(height: 24),
                    const Text(
                      'AÃºn no tienes un itinerario activo.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Genera una propuesta personalizada con nuestra IA para comenzar tu aventura transformadora.',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () =>
                          ref.read(routerProvider).push('/suggestions'),
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Generar Propuesta con IA'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () => ref
                          .read(routerProvider)
                          .push('/transformation-history'),
                      icon: const Icon(Icons.history),
                      label: const Text('Ver mi Historial de TransformaciÃ³n'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: itineraries.length,
            itemBuilder: (context, index) {
              final itinerary = itineraries[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withAlpha(38),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'ACTIVO',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          Text(
                            DateFormat('dd/MM/yyyy')
                                .format(itinerary.createdAt),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        itinerary.content,
                        style: const TextStyle(fontSize: 15, height: 1.5),
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () => ref
                                .read(routerProvider)
                                .push('/transformation-history'),
                            icon: const Icon(Icons.history, color: Colors.grey),
                            tooltip: 'Historial',
                          ),
                          TextButton.icon(
                            onPressed: () =>
                                _completeItinerary(context, ref, itinerary),
                            icon:
                                const Icon(Icons.verified, color: Colors.green),
                            label: const Text(
                              'Completar Viaje',
                              style: TextStyle(color: Colors.green),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () =>
                                ref.read(routerProvider).push('/diary'),
                            icon: const Icon(Icons.edit_note),
                            label: const Text('Registrar en el Diario'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Error al cargar itinerarios: $error')),
      ),
    );
  }

  Future<void> _completeItinerary(
    BuildContext context,
    WidgetRef ref,
    ItineraryModel itinerary,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Â¿Finalizar aventura?'),
        content: const Text(
          'Se generarÃ¡ un resumen de tu transformaciÃ³n basado en lo vivido.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('AÃºn no'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Â¡SÃ­, he vuelto!'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    if (!context.mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Gemini estÃ¡ analizando tu transformaciÃ³n...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final isar = ref.read(isarServiceProvider);
      final reflections = await isar.getDiaryReflectionsInDateRange(
        userId: itinerary.userId,
        start: itinerary.createdAt,
        end: DateTime.now(),
      );

      final summary =
          await ref.read(geminiServiceProvider).generateImpactSummary(
                itineraryContent: itinerary.content,
                diaryReflections: reflections,
              );

      itinerary.status = 'completed';
      itinerary.impactSummary = summary;
      itinerary.syncStatus = SyncStatus.pending;
      itinerary.lastAttempt = DateTime.now();

      await isar.putItinerary(itinerary);
      ref.read(syncServiceProvider).performGlobalSync();

      if (context.mounted) {
        Navigator.pop(context);
        _showImpactSummary(context, summary);
        ref.invalidate(myItinerariesProvider);
      }
    } catch (e) {
      AppLogger.e('Error al completar itinerario: $e');
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al procesar el cierre del viaje.'),
          ),
        );
      }
    }
  }

  void _showImpactSummary(BuildContext context, String summary) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, size: 48, color: Colors.deepPurple),
            const SizedBox(height: 16),
            const Text(
              'Tu Resumen de Impacto',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              summary,
              style: const TextStyle(fontSize: 16, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar y Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
