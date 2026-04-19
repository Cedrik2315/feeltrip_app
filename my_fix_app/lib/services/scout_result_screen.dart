import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:feeltrip_app/services/agent_service.dart';
import 'package:feeltrip_app/services/emotional_engine_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:feeltrip_app/services/telemetry_service.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';

/// Provider para el estado del agente durante la ejecución (Thinking Process)
final scoutStatusProvider = StateProvider<String>((ref) => 'Preparando Scout Agent...');

/// Provider que orquesta la llamada al Agente Scout pasándole el historial del diario
final scoutResultProvider = FutureProvider.family<EmotionalPrediction?, String>((ref, history) async {
  final agent = ref.watch(agentServiceProvider);
  final prediction = await agent.scoutAgent(
    history,
    onStatusUpdate: (status) => ref.read(scoutStatusProvider.notifier).state = status,
  );

  if (prediction != null) {
    ref.read(telemetryServiceProvider).logAgentEvent(
      eventName: 'agent_scout_completed',
      metadata: {'destination': prediction.suggestedDestination, 'archetype': prediction.recommendedArchetype},
    );
  }
  return prediction;
});

class ScoutResultScreen extends ConsumerWidget {
  final String diaryHistory;

  const ScoutResultScreen({
    super.key,
    required this.diaryHistory,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scoutAsync = ref.watch(scoutResultProvider(diaryHistory));
    final status = ref.watch(scoutStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expedición Scout'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: scoutAsync.when(
        data: (prediction) => prediction != null 
            ? _ResultView(prediction: prediction)
            : const Center(child: Text('No se pudo generar la expedición.')),
        loading: () => _LoadingView(status: status),
        error: (err, stack) {
          AppLogger.e('ScoutResultScreen: Error', err, stack);
          return _ErrorView(error: err.toString());
        },
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  final String status;
  const _LoadingView({required this.status});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              'El Agente Scout está pensando...',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                status,
                key: ValueKey(status),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final EmotionalPrediction prediction;
  const _ResultView({required this.prediction});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderSection(prediction: prediction),
          const SizedBox(height: 20),
          _ReasoningCard(reasoning: prediction.reasoning),
          const SizedBox(height: 16),
          if (prediction.flightInfo != null) 
            _InfoTile(
              icon: Icons.flight_takeoff,
              title: 'Vuelo Sugerido',
              content: prediction.flightInfo!['result']?.toString() ?? 'Buscando vuelos...',
              color: Colors.blueAccent,
            ),
          if (prediction.weatherInfo != null)
            _InfoTile(
              icon: Icons.cloud,
              title: 'Clima en Destino',
              content: prediction.weatherInfo!,
              color: Colors.orangeAccent,
            ),
          const SizedBox(height: 16),
          const Text(
            'Actividades Recomendadas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...?(prediction.activityInfo?.map((a) => Card(
            child: ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: Text(a),
            ),
          ))),
          const SizedBox(height: 32),
          if (prediction.flightInfo != null && (prediction.flightInfo!['result']?.toString().contains('http') ?? false))
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: ElevatedButton.icon(
                onPressed: () => launchUrl(Uri.parse(prediction.flightInfo!['result'].toString().split(': ').last)),
                icon: const Icon(Icons.shopping_cart),
                label: const Text('Reservar Vuelo (Afiliado)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Conectar con un UseCase para persistir la expedición
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Expedición guardada en tu itinerario')),
              );
            },
            icon: const Icon(Icons.calendar_today),
            label: const Text('Confirmar Itinerario'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final EmotionalPrediction prediction;
  const _HeaderSection({required this.prediction});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          prediction.suggestedDestination.toUpperCase(),
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Chip(
              label: Text(prediction.recommendedArchetype),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            ),
            const SizedBox(width: 8),
            Chip(
              label: Text(prediction.moodPattern),
              avatar: const Icon(Icons.psychology, size: 18),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: prediction.intensity,
          backgroundColor: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        const SizedBox(height: 4),
        Text(
          'Intensidad del patrón: ${(prediction.intensity * 100).toInt()}%',
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}

class _ReasoningCard extends StatelessWidget {
  final String reasoning;
  const _ReasoningCard({required this.reasoning});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Análisis del Scout', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(reasoning, style: const TextStyle(height: 1.5)),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Color color;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.content,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: color.withValues(alpha: 0.2), child: Icon(icon, color: color)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(content),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  const _ErrorView({required this.error});
  @override
  Widget build(BuildContext context) => Center(child: Text('Error: $error'));
}