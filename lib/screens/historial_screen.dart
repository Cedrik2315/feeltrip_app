// historial_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../constants/strings.dart';
import '../models/experience_model.dart';
import '../services/database_service.dart';

class HistorialScreen extends StatelessWidget {
  const HistorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.read<DatabaseService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.historyTitle),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: StreamBuilder<List<DiaryEntry>>(
        stream: db.obtenerEntradas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text(AppStrings.historyLoadError));
          }

          final registros = snapshot.data ?? <DiaryEntry>[];
          if (registros.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_stories, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text(
                    AppStrings.historyEmpty,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: registros.length,
            itemBuilder: (context, index) {
              final item = registros[index];
              final fechaFormateada =
                  DateFormat('dd MMMM yyyy - HH:mm').format(item.createdAt);

              // Mostrar siempre la tarjeta simple (con texto y emociones)
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            fechaFormateada,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(Icons.auto_awesome,
                              size: 16, color: Colors.deepPurple),
                        ],
                      ),
                      const Divider(height: 24),
                      Text(
                        item.content,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.4,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: item.emotions
                            .map(
                              (e) => Chip(
                                label: Text(
                                  e,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600),
                                ),
                                backgroundColor:
                                    Colors.deepPurple.withValues(alpha: 0.08),
                                side: BorderSide.none,
                                shape: const StadiumBorder(),
                                visualDensity: VisualDensity.compact,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
