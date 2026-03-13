import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/database_service.dart';
import '../utils/emotion_styles.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late Future<Map<String, int>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    setState(() {
      _statsFuture =
          context.read<DatabaseService>().obtenerEstadisticasSemanales();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi Viaje Interior",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: FutureBuilder<Map<String, int>>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.redAccent),
                    const SizedBox(height: 16),
                    Text(
                      "No se pudieron cargar las estadísticas.\n${snapshot.error}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadStats,
                      icon: const Icon(Icons.refresh),
                      label: const Text("Reintentar"),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final data = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async {
              _loadStats();
              await _statsFuture;
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // 1. TARJETA DEL GRÁFICO
                  _buildChartCard(data),
                  const SizedBox(height: 20),

                  // 2. RESUMEN DE "INSIGHT" (El consejo de la IA)
                  _buildInsightCard(data),
                  const SizedBox(height: 20),

                  // 3. LISTA DE FRECUENCIA
                  _buildEmotionList(data),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChartCard(Map<String, int> data) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Balance Emocional Semanal",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 40,
                  sections: data.entries
                      .map((e) => PieChartSectionData(
                            color: EmotionStyle.getColor(e.key),
                            value: e.value.toDouble(),
                            title: '${e.value}',
                            radius: 50,
                            titleStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(Map<String, int> data) {
    if (data.isEmpty) return const SizedBox.shrink();

    // Encontrar la emoción predominante
    final dominantEntry =
        data.entries.reduce((a, b) => a.value > b.value ? a : b);
    final emotion = dominantEntry.key;

    String message;
    // Lógica simple de mensajes basada en la emoción predominante
    switch (emotion.toLowerCase()) {
      case 'felicidad':
      case 'alegría':
      case 'gratitud':
        message =
            "¡Tu energía es contagiosa! Es un momento perfecto para compartir tu luz con otros.";
        break;
      case 'paz':
      case 'calma':
      case 'tranquilidad':
        message =
            "Tu alma ha buscado paz. Considera mantener este estado con actividades relajantes.";
        break;
      case 'aventura':
      case 'emoción':
      case 'entusiasmo':
        message =
            "¡Estás vibrando alto! El mundo está lleno de nuevas experiencias esperando por ti.";
        break;
      case 'nostalgia':
      case 'tristeza':
        message =
            "Abraza tus recuerdos. A veces mirar atrás nos ayuda a caminar hacia adelante con más fuerza.";
        break;
      case 'estrés':
      case 'ansiedad':
      case 'miedo':
        message =
            "Recuerda respirar. Un pequeño descanso o contacto con la naturaleza puede hacer maravillas.";
        break;
      default:
        message =
            "Tus emociones son un viaje único. ¡Sigue explorando tu mundo interior!";
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [Colors.deepPurple[400]!, Colors.deepPurple[700]!]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.amber, size: 30),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionList(Map<String, int> data) {
    // Ordenar por frecuencia descendente
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sortedEntries
          .map((e) => ListTile(
                leading: Icon(EmotionStyle.getIcon(e.key),
                    color: EmotionStyle.getColor(e.key)),
                title: Text(e.key),
                trailing: Text("${e.value} veces",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ))
          .toList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pie_chart_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            "Aún no hay suficientes viajes para mostrar estadísticas.",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            "¡Escribe en tu diario para comenzar!",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
