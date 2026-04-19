import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:feeltrip_app/core/di/providers.dart';
import 'package:feeltrip_app/features/diario/presentation/providers/momento_provider.dart';
import 'package:feeltrip_app/features/diario/domain/models/momento_model.dart';
import 'package:feeltrip_app/presentation/providers/story_provider.dart';
import 'package:feeltrip_app/models/experience_model.dart';

class MapCuriosityScreen extends ConsumerStatefulWidget {
  const MapCuriosityScreen({super.key});

  @override
  ConsumerState<MapCuriosityScreen> createState() => _MapCuriosityScreenState();
}

class _MapCuriosityScreenState extends ConsumerState<MapCuriosityScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
  
  // El radio de visión que otorga cada historia (en metros)
  static const double _visionRadius = 2000; 

  void _handleMapTap(LatLng point, List<Momento> momentos, List<TravelerStory> stories) async {
    HapticFeedback.lightImpact();
    
    // Determinamos si el punto está en la "Niebla" o ya fue explorado
    final isExplored = _checkIfExplored(point, momentos);
    final historyService = ref.read(historicalContextServiceProvider);

    String message;
    bool isAnomaly = !isExplored;

    if (isExplored) {
      // Si está explorado, buscamos tendencias de la comunidad en la zona
      final localStories = stories.where((s) => 
        _calculateDistance(point, LatLng(s.latitude ?? 0, s.longitude ?? 0)) < _visionRadius
      ).toList();

      if (localStories.isNotEmpty) {
        final archetypes = localStories.map((s) => s.emotionalHighlights.firstOrNull ?? 'Explorador').toList();
        message = await historyService.getArchetypalTrendAnalysis(archetypes, 'esta zona revelada');
      } else {
        message = 'ZONA CONOCIDA: Has despejado la niebla aquí, pero la red aún no registra ecos ajenos. Sé el primero en dejar una marca.';
      }
    } else {
      message = await historyService.getMysteryForLocation(point.latitude, point.longitude);
    }

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _MysteryTerminal(
        future: Future.value(message),
        isAnomaly: isAnomaly,
      ),
    );
  }

  void _showStoryExperience(TravelerStory story) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Text(story.story, style: GoogleFonts.ebGaramond(color: Colors.white, fontSize: 16)),
      )
    );
  }

  bool _checkIfExplored(LatLng point, List<Momento> momentos) {
    const Distance distance = Distance();
    return momentos.any((m) {
      if (m.latitude == null || m.longitude == null) return false;
      final dist = distance.as(LengthUnit.Meter, point, LatLng(m.latitude!, m.longitude!));
      return dist < _visionRadius;
    });
  }

  double _calculateDistance(LatLng p1, LatLng p2) {
    return const Distance().as(LengthUnit.Meter, p1, p2);
  }

  @override
  Widget build(BuildContext context) {
    final momentosAsync = ref.watch(momentoProvider);
    final storiesAsync = ref.watch(allStoriesProvider);
    const carbon = Color(0xFF0D0D0D);

    return Scaffold(
      backgroundColor: carbon,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(-33.4489, -70.6693), // Coordenada base
              initialZoom: 13,
              onTap: (tapPosition, point) {
                final momentos = momentosAsync.value ?? [];
                final stories = storiesAsync.value ?? [];
                _handleMapTap(point, momentos, stories);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
              ),
              // Capa de Niebla de Guerra (AoE II Style)
              momentosAsync.when(
                data: (m) => _buildFogLayer(m),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              // Marcadores Combinados (Míos + Comunidad Revelada)
              storiesAsync.when(
                data: (communityStories) => momentosAsync.when(
                  data: (myMomentos) {
                    final visibleCommunity = communityStories.where((s) => _checkIfExplored(LatLng(s.latitude ?? 0, s.longitude ?? 0), myMomentos));
                    
                    return MarkerLayer(
                      markers: [
                        ...myMomentos.map((m) => _buildArchetypeMarker(m)),
                        ...visibleCommunity.map((s) => _buildCommunityMarker(s)),
                      ],
                    );
                  },
                  loading: () => const MarkerLayer(markers: []),
                  error: (_, __) => const MarkerLayer(markers: []),
                ),
                loading: () => const MarkerLayer(markers: []),
                error: (_, __) => const MarkerLayer(markers: []),
              ),
            ],
          ),
          _buildOverlayUI(),
        ],
      ),
    );
  }

  Widget _buildFogLayer(List<Momento> momentos) {
    // Definimos el marco del mundo (un polígono que cubre todo)
    final worldBounds = [
      const LatLng(-90, -180),
      const LatLng(90, -180),
      const LatLng(90, 180),
      const LatLng(-90, 180),
    ];

    // Calculamos los "agujeros" en la niebla basándonos en los Momentos
    final holes = momentos
        .where((m) => m.latitude != null && m.longitude != null)
        .map((m) => _generateCirclePoints(LatLng(m.latitude!, m.longitude!), _visionRadius))
        .toList();

    return PolygonLayer(
      polygons: [
        Polygon(
          points: worldBounds,
          holePointsList: holes,
          color: Colors.black.withValues(alpha: 0.85), // Opacidad de la niebla
        ),
      ],
    );
  }

  List<LatLng> _generateCirclePoints(LatLng center, double radiusInMeters) {
    const int pointsCount = 20; // Puntos para formar el círculo del "agujero"
    final List<LatLng> points = [];
    for (int i = 0; i < pointsCount; i++) {
      final double angle = (i * 360 / pointsCount) * (pi / 180);
      // Aproximación de desplazamiento por radio
      final double lat = center.latitude + (radiusInMeters / 111320) * cos(angle);
      final double lng = center.longitude + (radiusInMeters / (111320 * cos(center.latitude * pi / 180))) * sin(angle);
      points.add(LatLng(lat, lng));
    }
    return points;
  }

  Marker _buildCommunityMarker(TravelerStory story) {
    final color = _getArchetypeColor(story.emotionalHighlights.firstOrNull ?? 'Explorador');
    
    return Marker(
      point: LatLng(story.latitude ?? 0, story.longitude ?? 0),
      width: 40,
      height: 40,
      child: GestureDetector(
        onTap: () => _showStoryExperience(story),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.2),
            border: Border.all(color: color, width: 1, style: BorderStyle.solid),
          ),
          child: Center(
            child: Icon(Icons.sensors_rounded, size: 16, color: color),
          ),
        ),
      ),
    );
  }

  Marker _buildArchetypeMarker(Momento momento) {
    final isCapsule = momento.title.contains('CÁPSULA HISTÓRICA');
    final color = isCapsule ? Colors.amber : _getArchetypeColor(momento.title);
    
    return Marker(
      point: LatLng(momento.latitude ?? 0, momento.longitude ?? 0),
      width: 100,
      height: 100,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              if (isCapsule)
                Icon(Icons.history_edu, color: color.withValues(alpha: 0.6), size: 30),
              // Efecto de onda expansiva
              if (!isCapsule)
                Container(
                  width: 20 + (80 * _pulseController.value),
                  height: 20 + (80 * _pulseController.value),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 1 - _pulseController.value),
                  ),
                ),
              // Núcleo del marcador
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  boxShadow: [BoxShadow(color: color, blurRadius: 10, spreadRadius: 2)],
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverlayUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CARTOGRAFÍA EMOCIONAL v1.0', 
              style: GoogleFonts.jetBrainsMono(color: Colors.white, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Toca cualquier zona para detectar ecos de campo.', 
              style: GoogleFonts.inter(color: Colors.white54, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Color _getArchetypeColor(String title) {
    final t = title.toUpperCase();
    if (t.contains('ALQUIMISTA')) return Colors.purpleAccent;
    if (t.contains('EXPLORADOR')) return Colors.orangeAccent;
    if (t.contains('ERMITAÑO')) return Colors.cyanAccent;
    if (t.contains('CONECTOR')) return Colors.redAccent;
    if (t.contains('CÁPSULA')) return Colors.amber;
    return Colors.white;
  }
}

class _MysteryTerminal extends StatelessWidget {
  final Future<String> future;
  final bool isAnomaly;
  const _MysteryTerminal({required this.future, this.isAnomaly = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        color: Color(0xFF0A0A0A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: FutureBuilder<String>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(height: 150, child: Center(child: CircularProgressIndicator(color: Colors.cyanAccent)));
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAnomaly ? 'SCANNER_LOG // ANOMALÍA DETECTADA' : 'SCANNER_LOG // ARCHIVO CONOCIDO', 
                style: GoogleFonts.jetBrainsMono(
                  color: isAnomaly ? Colors.orangeAccent : Colors.cyanAccent, 
                  fontSize: 10, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Text(snapshot.data ?? 'Señal interrumpida.', 
                style: GoogleFonts.ebGaramond(color: Colors.white, fontSize: 18, height: 1.4, fontStyle: FontStyle.italic)),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('CERRAR FRECUENCIA', style: GoogleFonts.jetBrainsMono(color: Colors.white24, fontSize: 10)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}