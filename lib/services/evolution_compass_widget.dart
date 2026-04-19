import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:feeltrip_app/services/transformation_history_screen.dart';
import 'package:feeltrip_app/core/di/providers.dart';

/// Provider que encapsula la lógica de obtener el siguiente arquetipo sugerido
final suggestedArchetypeProvider =
    FutureProvider.autoDispose<String>((ref) async {
  final history = await ref.watch(transformationHistoryProvider.future);

  // Si no hay viajes completados, devolvemos un mensaje inicial inspirador
  if (history.isEmpty) {
    return 'Tu brújula interna se activará tras completar tu primera aventura transformadora. ¡El camino te espera!';
  }

  final summaries =
      history.map((i) => i.impactSummary).whereType<String>().toList();

  if (summaries.isEmpty) {
    return 'Sigue registrando tus reflexiones en el diario. La IA necesita tus palabras para trazar tu evolución.';
  }

  // NOTA: El arquetipo actual debería venir del perfil del usuario (User Entity).
  // En esta implementación de referencia, usamos 'Aventurero' como punto de partida.
  const currentArchetype = 'Aventurero';

  return ref.read(geminiServiceProvider).suggestNextArchetype(
        currentArchetype: currentArchetype,
        impactSummaries: summaries,
      );
});

class EvolutionCompassWidget extends ConsumerWidget {
  const EvolutionCompassWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionAsync = ref.watch(suggestedArchetypeProvider);

    return Card(
      elevation: 8,
      shadowColor: Colors.deepPurple.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade800, Colors.indigo.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.explore_outlined, color: Colors.amber, size: 28),
                SizedBox(width: 12),
                Text(
                  'Brújula de Evolución',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            suggestionAsync.when<Widget>(
              data: (suggestion) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => ref
                          .read(routerProvider)
                          .push('/transformation-history'),
                      icon: const Icon(Icons.history,
                          color: Colors.amber, size: 18),
                      label: const Text('Ver mi camino',
                          style: TextStyle(color: Colors.amber)),
                    ),
                  ),
                ],
              ),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: CircularProgressIndicator(color: Colors.amber),
                ),
              ),
              error: (err, stack) => const Text(
                'La brújula está recalibrando su energía mística... intenta de nuevo en unos momentos.',
                style: TextStyle(color: Colors.white60),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
