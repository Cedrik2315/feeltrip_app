// historial_screen.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../constants/strings.dart';
import '../services/database_service.dart';
import '../services/travel_service.dart';

class HistorialScreen extends StatelessWidget {
  const HistorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.read<DatabaseService>();
    final travelService = TravelService();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.historyTitle),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: StreamBuilder<List<DiarioRegistro>>(
        stream: db.obtenerEntradas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text(AppStrings.historyLoadError));
          }

          final registros = snapshot.data ?? <DiarioRegistro>[];
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
                  DateFormat('dd MMMM yyyy - HH:mm').format(item.fecha);

              // Mostrar siempre la tarjeta simple (con texto y emociones)
              // Y si tiene destino, mostrar también la versión pequeña
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
                        item.texto,
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
                        children: item.emociones
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
                      // Si tiene destino, mostrar versión pequeña
                      if (item.destino != null && item.destino!.isNotEmpty) ...[
                        const Divider(height: 24),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 16, color: Colors.deepPurple),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Destino sugerido: ${item.destino}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.open_in_new,
                                  color: Colors.deepPurple),
                              tooltip: 'Buscar en Airbnb',
                              onPressed: () =>
                                  travelService.buscarEnAirbnb(item.destino!),
                            )
                          ],
                        ),
                        if (item.lat != null && item.lng != null)
                          Container(
                            height: 120,
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(item.lat!, item.lng!),
                                  zoom: 11,
                                ),
                                liteModeEnabled: true,
                                zoomControlsEnabled: false,
                                mapToolbarEnabled: false,
                                markers: {
                                  Marker(
                                    markerId: MarkerId(item.id),
                                    position: LatLng(item.lat!, item.lng!),
                                  ),
                                },
                              ),
                            ),
                          ),
                      ],
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
