import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:feeltrip_app/core/di/providers.dart';
import 'package:feeltrip_app/services/isar_service.dart';
import 'package:feeltrip_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:feeltrip_app/models/itinerary_model.dart';


final transformationHistoryProvider =
    FutureProvider.autoDispose<List<ItineraryModel>>((ref) async {
  final authState = ref.watch(authNotifierProvider);
  final userId = authState.value?.id;
  if (userId == null) return [];

  final isar = ref.read(isarServiceProvider);
  return isar.getItineraries(userId: userId, status: 'completed');
});

final evolutionSuggestionProvider =
    FutureProvider.autoDispose<String>((ref) async {
  final history = await ref.watch(transformationHistoryProvider.future);

  final summaries =
      history.map((i) => i.impactSummary).whereType<String>().toList();

  if (summaries.isEmpty) {
    return 'Para trazar tu evolución, primero completa un itinerario y registra tus reflexiones.';
  }

  return ref.read(geminiServiceProvider).suggestNextArchetype(
        currentArchetype: 'Aventurero',
        impactSummaries: summaries,
      );
});

class TransformationHistoryScreen extends ConsumerWidget {
  const TransformationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(transformationHistoryProvider);
    final suggestionAsync = ref.watch(evolutionSuggestionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Transformación'),
        backgroundColor: Colors.deepPurple,
      ),
      body: historyAsync.when<Widget>(
        data: (itineraries) {
          if (itineraries.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'Tu camino apenas comienza. Completa tu primer itinerario para ver tu historial aquí.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
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
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ExpansionTile(
                  leading: const Icon(Icons.auto_awesome, color: Colors.amber),
                  title: Text(
                    'Viaje: ${DateFormat('dd/MM/yyyy').format(itinerary.createdAt)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  childrenPadding: const EdgeInsets.all(16),
                  expandedAlignment: Alignment.topLeft,
                  children: [
                    const Text(
                      'Propuesta aceptada:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      itinerary.content,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const Divider(height: 32),
                    const Text(
                      'Resumen de tu transformación:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      itinerary.impactSummary ??
                          'No se generó resumen para este viaje.',
                      style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Error al cargar historial: $error')),
      ),
      floatingActionButton: suggestionAsync.maybeWhen(
        data: (suggestion) => FloatingActionButton.extended(
          onPressed: () => _showEvolutionModal(context, suggestion, ref),
          label: const Text('Descubrir mi siguiente paso'),
          icon: const Icon(Icons.auto_awesome),
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
        )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .shimmer(
              delay: 2.seconds,
              duration: 1500.ms,
              color: Colors.white.withValues(alpha: 0.5),
            )
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.05, 1.05),
              duration: 1.seconds,
            ),
        orElse: () => null,
      ),
    );
  }

  void _showEvolutionModal(
    BuildContext context,
    String suggestion,
    WidgetRef ref,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.explore, size: 64, color: Colors.amber)
                .animate(onPlay: (controller) => controller.repeat())
                .rotate(duration: 3.seconds),
            const SizedBox(height: 24),
            const Text(
              'Tu Brújula de Evolución',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
            const SizedBox(height: 16),
            Text(
              suggestion,
              style: const TextStyle(fontSize: 16, height: 1.6),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 600.ms).shimmer(
                  duration: 2.seconds,
                  color: Colors.amber.withValues(alpha: 0.3),
                ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(routerProvider).push('/quiz');
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Realizar nuevo Quiz de Arquetipo'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Seguir explorando mi historial'),
            ),
          ],
        ),
      ),
    );
  }
}
