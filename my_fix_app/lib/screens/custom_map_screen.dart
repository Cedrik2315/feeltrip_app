import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:feeltrip_app/services/location_service.dart';

class CustomMapScreen extends ConsumerStatefulWidget {
  const CustomMapScreen({super.key});

  @override
  ConsumerState<CustomMapScreen> createState() => _CustomMapScreenState();
}

class _CustomMapScreenState extends ConsumerState<CustomMapScreen> {
  static const Color boneWhite = Color(0xFFF5F5DC);
  static const Color carbonBlack = Color(0xFF1A1A1A);
  static const Color terminalGreen = Color(0xFF00FF41);

  final MapController _mapController = MapController();
  LatLng _center = const LatLng(-33.4489, -70.6693); // Santiago por defecto
  bool _isLoadingLocation = false;
  bool _isOfflineMode = false;

  // Puntos de expedición sugeridos y Cápsulas del Tiempo
  final List<_ExpeditionPoint> _points = [
    _ExpeditionPoint(label: 'Torres del Paine', latlng: const LatLng(-51.0, -73.0), archetype: 'EXPLORADOR'),
    _ExpeditionPoint(label: 'Valle de la Luna', latlng: const LatLng(-22.9, -68.2), archetype: 'ERMITAÑO'),
    _ExpeditionPoint(label: 'Cajón del Maipo', latlng: const LatLng(-33.8, -70.1), archetype: 'AVENTURERO'),
    _ExpeditionPoint(label: 'Mercado de Pisac', latlng: const LatLng(-13.4, -71.8), archetype: 'CONECTOR'),
    _ExpeditionPoint(label: 'Cápsula de Esperanza', latlng: const LatLng(-33.45, -70.66), archetype: 'RELIQUIA', isCapsule: true),
    _ExpeditionPoint(label: 'Reliquia de Silencio', latlng: const LatLng(-23.5, -68.4), archetype: 'RELIQUIA', isCapsule: true),
  ];

  Future<void> _goToMyLocation() async {
    HapticFeedback.lightImpact();
    setState(() => _isLoadingLocation = true);
    try {
      final granted = await LocationService.requestPermissionWithDisclosure(context);
      if (!granted) {
        setState(() => _isLoadingLocation = false);
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final myPos = LatLng(position.latitude, position.longitude);
      _mapController.move(myPos, 13.0);
      setState(() => _center = myPos);
    } catch (_) {
      // Mantiene la posición por defecto
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: carbonBlack,
      body: Stack(
        children: [
          // ── Mapa Real con flutter_map ──────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 5.0,
              maxZoom: 18.0,
              minZoom: 3.0,
            ),
            children: [
              TileLayer(
                urlTemplate: _isOfflineMode
                    ? '' // En modo offline usa caché
                    : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'app.feeltrip.mobile',
                fallbackUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
              MarkerLayer(
                markers: _points.map((p) => Marker(
                  point: p.latlng,
                  width: 32,
                  height: 32,
                  child: GestureDetector(
                    onTap: () => _showExpeditionSheet(p),
                    child: Container(
                      decoration: BoxDecoration(
                        color: p.isCapsule ? const Color(0xFFD4AF37) : terminalGreen,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: (p.isCapsule ? const Color(0xFFD4AF37) : terminalGreen).withValues(alpha: 0.5), blurRadius: 8)],
                      ),
                      child: Icon(p.isCapsule ? Icons.auto_awesome : Icons.explore, color: Colors.black, size: 16),
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),

          // ── Header ────────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 8, right: 8, bottom: 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [carbonBlack.withValues(alpha: 0.95), Colors.transparent],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: boneWhite),
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('CARTOGRAFÍA IA', style: GoogleFonts.jetBrainsMono(color: boneWhite, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 2)),
                        Text('MODO: ${_isOfflineMode ? "OFFLINE // CACHÉ" : "ONLINE // OSM"}',
                          style: GoogleFonts.jetBrainsMono(color: _isOfflineMode ? Colors.orange : terminalGreen, fontSize: 8)),
                      ],
                    ),
                  ),
                  // Toggle offline
                  GestureDetector(
                    onTap: () { HapticFeedback.lightImpact(); setState(() => _isOfflineMode = !_isOfflineMode); },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _isOfflineMode ? Colors.orange.withValues(alpha: 0.2) : terminalGreen.withValues(alpha: 0.1),
                        border: Border.all(color: _isOfflineMode ? Colors.orange : terminalGreen, width: 1),
                      ),
                      child: Text(
                        _isOfflineMode ? 'OFFLINE' : 'ONLINE',
                        style: GoogleFonts.jetBrainsMono(fontSize: 8, color: _isOfflineMode ? Colors.orange : terminalGreen, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Controles Flotantes ───────────────────────────────
          Positioned(
            right: 16, bottom: 220,
            child: Container(
              decoration: BoxDecoration(color: carbonBlack, border: Border.all(color: boneWhite.withValues(alpha: 0.1))),
              child: Column(
                children: [
                  _mapBtn(Icons.add, () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1)),
                  Container(height: 1, width: 20, color: boneWhite.withValues(alpha: 0.1)),
                  _mapBtn(Icons.remove, () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1)),
                  Container(height: 1, width: 20, color: boneWhite.withValues(alpha: 0.1)),
                  _isLoadingLocation
                    ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 1.5, color: terminalGreen)))
                    : _mapBtn(Icons.gps_fixed, _goToMyLocation),
                ],
              ),
            ),
          ),

          // ── Botón "The Invisible Layer" ───────────────────────
          Positioned(
            left: 16, bottom: 220,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.heavyImpact();
                context.push('/city-mode');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: carbonBlack,
                  border: Border.all(color: terminalGreen, width: 1.5),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: terminalGreen.withValues(alpha: 0.2), blurRadius: 10, spreadRadius: 2),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.remove_red_eye_outlined, color: terminalGreen, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'CAPA INVISIBLE',
                      style: GoogleFonts.jetBrainsMono(
                        color: terminalGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Panel inferior de expediciones ────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildExpeditionPanel(),
          ),
        ],
      ),
    );
  }

  Widget _mapBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(padding: const EdgeInsets.all(12), child: Icon(icon, color: boneWhite, size: 18)),
    );
  }

  Widget _buildExpeditionPanel() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter, end: Alignment.topCenter,
          colors: [carbonBlack, carbonBlack.withValues(alpha: 0.95), Colors.transparent],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text('EXPEDICIONES EN RED', style: GoogleFonts.jetBrainsMono(color: terminalGreen, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _points.length,
              itemBuilder: (context, i) => _buildExpeditionCard(_points[i]),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildExpeditionCard(_ExpeditionPoint point) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _mapController.move(point.latlng, 8.0);
        _showExpeditionSheet(point);
      },
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          border: Border.all(color: terminalGreen.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(point.archetype, style: GoogleFonts.jetBrainsMono(color: terminalGreen, fontSize: 8, fontWeight: FontWeight.bold)),
            Text(point.label, style: GoogleFonts.ebGaramond(color: boneWhite, fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, color: boneWhite, size: 12),
                const SizedBox(width: 4),
                Text('VER EN MAPA →', style: GoogleFonts.jetBrainsMono(color: boneWhite.withValues(alpha: 0.4), fontSize: 8)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showExpeditionSheet(_ExpeditionPoint point) {
    showModalBottomSheet(
      context: context,
      backgroundColor: carbonBlack,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('EXPEDICIÓN DETECTADA', style: GoogleFonts.jetBrainsMono(color: terminalGreen, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(point.label, style: GoogleFonts.ebGaramond(color: boneWhite, fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Arquetipo recomendado: ${point.archetype}', style: GoogleFonts.jetBrainsMono(color: boneWhite.withValues(alpha: 0.5), fontSize: 11)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () { Navigator.pop(context); context.push('/suggestions'); },
                style: ElevatedButton.styleFrom(backgroundColor: terminalGreen, foregroundColor: Colors.black, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
                child: Text('GENERAR RUTA IA', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showRelicDialog(point);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFD4AF37),
                  side: const BorderSide(color: Color(0xFFD4AF37)),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
                icon: const Icon(Icons.change_history, size: 16),
                label: Text('BUSCAR CÁPSULAS DEL TIEMPO', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRelicDialog(_ExpeditionPoint point) {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (ctx) => Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFFD4AF37), Colors.transparent, Color(0xFFD4AF37)]),
          ),
          child: Container(
            color: carbonBlack,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome, color: Color(0xFFD4AF37), size: 48),
                const SizedBox(height: 20),
                Text('RELIQUIA DETECTADA', 
                  style: GoogleFonts.jetBrainsMono(color: const Color(0xFFD4AF37), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 3)),
                const SizedBox(height: 24),
                Text(
                  '"Encontré paz en este silencio absoluto. El tiempo aquí se mueve distinto."',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ebGaramond(color: boneWhite, fontSize: 18, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 16),
                Text('— EXPLORADOR ANÓNIMO', 
                  style: GoogleFonts.jetBrainsMono(color: boneWhite.withValues(alpha: 0.5), fontSize: 9)),
                const SizedBox(height: 32),
                Container(height: 1, width: double.infinity, color: boneWhite.withValues(alpha: 0.1)),
                const SizedBox(height: 16),
                Text('SINCRO: ${point.label.toUpperCase()}', 
                  style: GoogleFonts.jetBrainsMono(color: terminalGreen, fontSize: 8)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.black,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    child: Text('RECOLECTAR MEMORIA', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpeditionPoint {
  final String label;
  final LatLng latlng;
  final String archetype;
  final bool isCapsule;
  const _ExpeditionPoint({
    required this.label,
    required this.latlng,
    required this.archetype,
    this.isCapsule = false,
  });
}