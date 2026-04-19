import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:feeltrip_app/features/city_mode/data/city_mode_repository.dart';
import 'package:feeltrip_app/features/city_mode/data/drift_database.dart';
import 'package:feeltrip_app/services/location_service.dart';
import 'package:feeltrip_app/core/localization/dynamic_translator.dart';
import 'package:feeltrip_app/features/city_mode/domain/city_proximity_engine.dart';
import 'package:feeltrip_app/features/city_mode/data/hive_mode_service.dart';

class CityModeScreen extends ConsumerStatefulWidget {
  const CityModeScreen({super.key});

  @override
  ConsumerState<CityModeScreen> createState() => _CityModeScreenState();
}

class _CityModeScreenState extends ConsumerState<CityModeScreen> with SingleTickerProviderStateMixin {
  static const Color carbonBlack = Color(0xFF1A1A1A);
  static const Color terminalGreen = Color(0xFF00FF41);
  static const Color boneWhite = Color(0xFFF5F5DC);

  final MapController _mapController = MapController();
  LatLng _center = const LatLng(-33.4372, -70.6506); // Centro Santiago default
  bool _isLoadingLocation = false;

  late HiveModeService _hiveService;
  StreamSubscription<Position>? _positionStream;
  List<Hito> _cachedHitos = [];
  final Set<String> _notifiedHitos = {};

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void dispose() {
    _pulseController.dispose();
    _positionStream?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.4).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    _hiveService = HiveModeService(ref.read(appDatabaseProvider));
    _hiveService.startHiveMonitoring();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initLocation());
  }

  Future<void> _initLocation() async {
    setState(() => _isLoadingLocation = true);
    final granted = await LocationService.requestPermissionWithDisclosure(context);
    if (granted) {
      final pos = await LocationService.getPosition();
      if (pos != null) {
        final latLng = LatLng(pos.latitude, pos.longitude);
        _mapController.move(latLng, 14.0);
        setState(() => _center = latLng);
      }
    }
    setState(() => _isLoadingLocation = false);

    // Motor de Escaneo Continuo (Background Tracker)
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 3, // Actualiza cada 3 metros caminados
      ),
    ).listen((Position position) {
      if (mounted) {
        _checkUrbanProximity(position.latitude, position.longitude);
      }
    });

    // Simulación: A los 2 segundos de ubicar al usuario, detectar si está en una ciudad nueva
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _showNewCityPrompt();
      }
    });
  }

  void _checkUrbanProximity(double userLat, double userLng) {
    if (_cachedHitos.isEmpty) return;
    
    for (var hito in _cachedHitos) {
      if (hito.descubierto) continue; // Solo nos interesan los no descubiertos

      final isInside = CityProximityEngine.hasInvadedPerimeter(
        userLat: userLat,
        userLng: userLng,
        hitoLat: hito.lat,
        hitoLng: hito.lng,
        radiusInMeters: hito.radio,
      );

      if (isInside && !_notifiedHitos.contains(hito.id)) {
        _notifiedHitos.add(hito.id);
        
        // ¡El celular reacciona físicamente!
        HapticFeedback.heavyImpact();
        Future.delayed(const Duration(milliseconds: 250), () => HapticFeedback.heavyImpact());

        // Mostrar Interfaz Inmersiva al colisionar
        Color categoryColor = hito.categoria == 'historia' ? const Color(0xFFD4AF37) :
                              hito.categoria == 'tecnico' ? Colors.redAccent : Colors.cyanAccent;
                              
        _showHitoDetails(hito, categoryColor, Icons.warning_amber);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: carbonBlack,
      body: Stack(
        children: [
          // MAPA OFFLINE (TileLayer)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://cartodb-basemaps-{s}.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'app.feeltrip.citymode',
              ),
              ref.watch(cityModeHitosProvider).when(
                data: (hitos) {
                  _cachedHitos = hitos;
                  return MarkerLayer(
                    markers: hitos.map((hito) => _buildMarker(hito)).toList(),
                  );
                },
                loading: () => const MarkerLayer(markers: []),
                error: (_, __) => const MarkerLayer(markers: []),
              ),
              // CAPA COLMENA: Anomalías Emocionales
              ref.watch(cityModeAnomaliasProvider).when(
                data: (anomalias) => MarkerLayer(
                  markers: anomalias.map((a) => _buildAnomalyMarker(a)).toList(),
                ),
                loading: () => const MarkerLayer(markers: []),
                error: (_, __) => const MarkerLayer(markers: []),
              ),
            ],
          ),

          // HEADER MODO CIUDAD
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, left: 16, right: 16, bottom: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [carbonBlack.withValues(alpha: 0.95), Colors.transparent],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: boneWhite),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('MODO CIUDAD // VISIBILIZANDO', 
                        style: GoogleFonts.jetBrainsMono(color: terminalGreen, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
                      Text('PROTOCOLO OFFLINE ACTIVO', 
                        style: GoogleFonts.jetBrainsMono(color: boneWhite.withValues(alpha: 0.5), fontSize: 8)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // CONTROLES DE RADAR
          Positioned(
            right: 16, bottom: 40,
            child: Column(
              children: [
                _buildMapBtn(Icons.my_location, _initLocation, isLoading: _isLoadingLocation),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapBtn(IconData icon, VoidCallback onTap, {bool isLoading = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: carbonBlack,
          border: Border.all(color: terminalGreen.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: isLoading 
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: terminalGreen, strokeWidth: 2))
            : Icon(icon, color: terminalGreen, size: 18),
      ),
    );
  }

  Marker _buildMarker(Hito hito) {
    Color markerColor;
    IconData iconData;

    switch (hito.categoria) {
      case 'historia': // Capas de Tiempo
        markerColor = const Color(0xFFD4AF37); // Dorado historia
        iconData = Icons.auto_awesome;
        break;
      case 'tecnico': // Silencio Digital
        markerColor = Colors.redAccent;
        iconData = Icons.wifi_off;
        break;
      case 'diseno': // Belleza Funcional
        markerColor = Colors.cyanAccent;
        iconData = Icons.architecture;
        break;
      default:
        markerColor = terminalGreen;
        iconData = Icons.location_on;
    }

    return Marker(
      point: LatLng(hito.lat, hito.lng),
      width: 48,
      height: 48,
      child: GestureDetector(
        onTap: () => _showHitoDetails(hito, markerColor, iconData),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: carbonBlack.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                border: Border.all(color: markerColor, width: 2),
                boxShadow: [
                  BoxShadow(color: markerColor.withValues(alpha: 0.4), blurRadius: 12, spreadRadius: 2),
                ],
              ),
              child: Icon(iconData, color: markerColor, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  void _showHitoDetails(Hito hito, Color color, IconData iconData) {
    HapticFeedback.heavyImpact();
    // Marcar como descubierto al abrirlo
    if (!hito.descubierto) {
      ref.read(cityModeRepositoryProvider).desbloquearHito(hito.id);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: carbonBlack,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: color.withValues(alpha: 0.5), width: 1)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: boneWhite.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(iconData, color: color, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(DynamicTranslator.translate(hito.titulo).toUpperCase(), 
                    style: GoogleFonts.ebGaramond(color: boneWhite, fontSize: 24, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
              child: Text(DynamicTranslator.translate('category_${hito.categoria}').toUpperCase(), 
                style: GoogleFonts.jetBrainsMono(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
            const SizedBox(height: 24),
            Text(DynamicTranslator.translate(hito.descripcionCorta), 
              style: GoogleFonts.inter(color: boneWhite.withValues(alpha: 0.8), fontSize: 16, height: 1.5)),
            
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.heavyImpact();
                  // TODO: Abrir pantalla inmersiva o cámara AR
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: carbonBlack,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.remove_red_eye),
                label: Text(DynamicTranslator.translate('btn_reveal'), style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Dejar aporte en Muro de la Memoria
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: boneWhite,
                  side: BorderSide(color: boneWhite.withValues(alpha: 0.2)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.edit_note),
                label: Text(DynamicTranslator.translate('btn_wall'), style: GoogleFonts.jetBrainsMono()),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showNewCityPrompt() {
    bool isDownloadingPack = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateModal) {
          return Dialog(
            backgroundColor: carbonBlack,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: terminalGreen, width: 0.5)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.radar, color: terminalGreen, size: 48),
                  const SizedBox(height: 16),
                  Text('NUEVA ZONA DETECTADA', 
                    style: GoogleFonts.jetBrainsMono(color: terminalGreen, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 16),
                  Text(
                    'Tu señal indica proximidad a Valparaíso. Existen 12 hitos invisibles cifrados en esta topografía.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(color: boneWhite, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 24),
                  if (isDownloadingPack)
                    Column(
                      children: [
                        const CircularProgressIndicator(color: terminalGreen),
                        const SizedBox(height: 16),
                        Text('Sincronizando Over-The-Air a base local...', 
                          style: GoogleFonts.jetBrainsMono(color: terminalGreen, fontSize: 10)),
                      ],
                    )
                  else
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.cloud_download_outlined, size: 16),
                            onPressed: () async {
                              setStateModal(() => isDownloadingPack = true);
                              HapticFeedback.lightImpact();
                              
                              // Simulamos la latencia de la descarga del JSON de Firebase
                              await Future.delayed(const Duration(seconds: 2));
                              
                              // Aquí llamaríamos a:
                              // await ref.read(cityModeRepositoryProvider).insertHitosBatch(valparaisoHitos);
                              
                              if (context.mounted) {
                                Navigator.pop(ctx);
                                HapticFeedback.heavyImpact();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('PAQUETE INSTALADO OFFLINE EXITOSAMENTE', 
                                      style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, color: carbonBlack)),
                                    backgroundColor: terminalGreen,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: terminalGreen,
                              foregroundColor: carbonBlack,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            label: Text('DESCARGAR PAQUETE (1.4 MB)', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text('IGNORAR POR AHORA', style: GoogleFonts.jetBrainsMono(color: boneWhite.withValues(alpha: 0.4), fontSize: 10)),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  Marker _buildAnomalyMarker(AnomaliasEmocionale anomalia) {
    return Marker(
      point: LatLng(anomalia.lat, anomalia.lng),
      width: 100,
      height: 100,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          final value = _pulseAnimation.value;
          return GestureDetector(
            onTap: () => _showAnomalyDialog(anomalia),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Aura pulsante exterior (Inversa para efecto de respiración)
                Container(
                  width: 70 * value,
                  height: 70 * value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.purpleAccent.withValues(alpha: 0.3 * (1.5 - value)),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // Aura interior secundaria
                Container(
                  width: 45 * value,
                  height: 45 * value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purpleAccent.withValues(alpha: 0.4 * value),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                // Núcleo fijo de la anomalía
                Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: carbonBlack,
                    border: Border.all(
                      color: Colors.purpleAccent,
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.blur_on, color: Colors.purpleAccent, size: 16),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAnomalyDialog(AnomaliasEmocionale anomalia) {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: carbonBlack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.purpleAccent),
        ),
        title: Text('ANOMALÍA EMOCIONAL DETECTADA', 
          style: GoogleFonts.jetBrainsMono(color: Colors.purpleAccent, fontSize: 14)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('En este rincón exacto, la comunidad ha experimentado un pico de asombro.',
              style: GoogleFonts.inter(color: boneWhite, fontSize: 13)),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.monitor_heart, color: Colors.purpleAccent, size: 16),
                const SizedBox(width: 8),
                Text('Intensidad HRV: ${anomalia.intensidadHrv}%', 
                  style: GoogleFonts.jetBrainsMono(color: boneWhite.withValues(alpha: 0.6), fontSize: 10)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CERRAR', style: GoogleFonts.jetBrainsMono(color: boneWhite)),
          ),
        ],
      ),
    );
  }
}

// Provider adicional para escuchar la lista de hitos desde el repositorio
final cityModeHitosProvider = StreamProvider((ref) {
  final repo = ref.watch(cityModeRepositoryProvider);
  return repo.watchTodosLosHitos();
});

// Provider para anomalías emocionales (Modo Colmena)
final cityModeAnomaliasProvider = StreamProvider((ref) {
  final repo = ref.watch(cityModeRepositoryProvider);
  return repo.watchAnomaliasEmocionales();
});
