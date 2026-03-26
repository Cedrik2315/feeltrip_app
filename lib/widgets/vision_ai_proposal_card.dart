import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:feeltrip_app/core/di/providers.dart';

class VisionAiProposalCard extends ConsumerWidget {
  const VisionAiProposalCard({
    super.key,
    required this.labels,
    this.proposalText,
  });

  final List<String> labels;
  final String? proposalText;

  String get _mockText => proposalText ?? _generateMockText(labels);

  String _generateMockText(List<String> lbls) {
    final top3 = lbls.take(3).join(', ');
    if (lbls.any(
      (label) =>
          label.toLowerCase().contains('montana') ||
          label.toLowerCase().contains('nieve'),
    )) {
      return 'Parece que estas en un lugar natural. Quieres que busque experiencias de trekking cerca?';
    }
    if (lbls.any(
      (label) =>
          label.toLowerCase().contains('playa') ||
          label.toLowerCase().contains('lago'),
    )) {
      return 'Vistas increibles cerca del agua. Explorar actividades acuaticas?';
    }
    return 'Escena interesante detectada: $top3. Quieres experiencias similares cerca?';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topLabels = labels.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.black87,
        border: Border(
          top: BorderSide(color: Colors.white24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: topLabels
                .map(
                  (label) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.deepPurpleAccent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Text(
            _mockText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.explore, size: 20),
                  label: const Text('Explorar experiencias'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    final query = labels.take(3).join(' ');
                    if (context.mounted) {
                      context.go('/search_screen?q=$query');
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextButton.icon(
                  icon: const Icon(Icons.camera_alt_outlined, size: 20),
                  label: const Text('Tomar otra foto'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white70,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    ref.read(visionServiceProvider.notifier).reset();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
