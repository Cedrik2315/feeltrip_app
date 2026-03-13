import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/experience_controller.dart';
import '../services/emotion_service.dart';

class ExperienceImpactDashboardScreen extends StatefulWidget {
  const ExperienceImpactDashboardScreen({super.key});

  @override
  State<ExperienceImpactDashboardScreen> createState() =>
      _ExperienceImpactDashboardScreenState();
}

class _ExperienceImpactDashboardScreenState
    extends State<ExperienceImpactDashboardScreen> {
  bool _isGeneratingSuggestion = false;
  String? _suggestedDestination;
  String? _suggestedExplanation;
  List<String> _suggestedEmotions = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureControllerIsInitialized();
    });
  }

  Future<void> _ensureControllerIsInitialized() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final controller = context.read<ExperienceController>();
    if (uid == null) return;
    if (controller.userId != uid) {
      await controller.initialize(uid);
      return;
    }
    if (controller.diaryEntries.isEmpty) {
      await controller.loadDiaryEntries();
      await controller.loadDiaryStats();
    }
  }

  double _calculateImpactScore(ExperienceController controller) {
    final totalEntries = controller.diaryEntries.length;
    if (totalEntries == 0) return 0;

    final avgDepth = controller.getAverageDepth();
    final uniqueEmotionCount = controller.getUniqueEmotions().length;
    final entriesFactor = (totalEntries * 8).clamp(0, 45);
    final depthFactor = (avgDepth * 8).clamp(0, 35);
    final emotionFactor = (uniqueEmotionCount * 4).clamp(0, 20);
    final score = entriesFactor + depthFactor + emotionFactor;
    return score.clamp(0, 100).toDouble();
  }

  List<String> _topEmotions(ExperienceController controller) {
    final frequency = controller.getEmotionFrequency().entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return frequency.take(4).map((e) => e.key).toList();
  }

  Future<void> _generateTransformativeSuggestion(
    ExperienceController controller,
  ) async {
    if (controller.diaryEntries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Escribe en tu diario para obtener sugerencias con IA.'),
        ),
      );
      return;
    }

    setState(() => _isGeneratingSuggestion = true);
    try {
      final topEmotions = _topEmotions(controller);
      final avgDepth = controller.getAverageDepth().toStringAsFixed(1);
      final recentNotes = controller.diaryEntries
          .take(3)
          .map((e) => '${e.title}: ${e.content}')
          .join('\n');

      final prompt = '''
Necesito una recomendación de viaje transformador.
Emociones predominantes: ${topEmotions.join(', ')}.
Profundidad promedio de reflexión: $avgDepth/5.
Notas recientes:
$recentNotes
''';

      final result = await context.read<EmotionService>().analizarTexto(prompt);
      if (!mounted) return;

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No pude generar sugerencia por ahora.')),
        );
      } else {
        setState(() {
          _suggestedDestination = result.destino;
          _suggestedExplanation = result.explicacion;
          _suggestedEmotions = result.emociones;
        });
      }
    } finally {
      if (mounted) setState(() => _isGeneratingSuggestion = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExperienceController>(
      builder: (context, controller, _) {
        final impact = _calculateImpactScore(controller);
        final impactLabel = impact >= 70
            ? 'Alto'
            : impact >= 40
                ? 'Medio'
                : 'Inicial';
        final topEmotions = _topEmotions(controller);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Mi Impacto de Viaje'),
            backgroundColor: Colors.deepPurple,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  color: Colors.deepPurple,
                  padding: const EdgeInsets.all(24),
                  width: double.infinity,
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tu Transformación Personal',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Ahora usa tu actividad real para sugerirte próximos viajes.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                            'Índice de Transformación',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: impact / 100,
                            minHeight: 10,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${impact.toStringAsFixed(0)}% • Nivel $impactLabel',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${controller.diaryEntries.length} entradas • ${topEmotions.length} emociones clave',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isGeneratingSuggestion
                                  ? null
                                  : () => _generateTransformativeSuggestion(
                                      controller),
                              icon: _isGeneratingSuggestion
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Icon(Icons.auto_awesome),
                              label: Text(
                                _isGeneratingSuggestion
                                    ? 'Generando sugerencia...'
                                    : 'Sugerir viaje transformador (IA)',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_suggestedDestination != null) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      color: Colors.deepPurple[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Sugerencia personalizada',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _suggestedDestination!,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(_suggestedExplanation ?? ''),
                            if (_suggestedEmotions.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                children: _suggestedEmotions
                                    .map((e) => Chip(
                                          label: Text(e),
                                          visualDensity: VisualDensity.compact,
                                        ))
                                    .toList(),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pushNamed(context, '/search'),
                                  child: const Text('Ver viajes'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pushNamed(context, '/stories'),
                                  child: const Text('Ir a comunidad'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Comunidad de Viajeros',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Comparte tu experiencia y conecta con otros viajeros transformadores.',
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/stories'),
                              icon: const Icon(Icons.groups),
                              label: const Text('Ir a Comunidad'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}
