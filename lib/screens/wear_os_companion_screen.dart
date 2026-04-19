import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:feeltrip_app/services/wear_sync_service.dart';

// ── Provider del servicio Wear ───────────────────────────────────
final wearSyncServiceProvider = Provider((_) => WearSyncService());

final watchConnectionProvider = FutureProvider.autoDispose<bool>((ref) {
  return ref.watch(wearSyncServiceProvider).isWatchConnected();
});

class WearOSCompanionScreen extends ConsumerStatefulWidget {
  const WearOSCompanionScreen({super.key});

  @override
  ConsumerState<WearOSCompanionScreen> createState() => _WearOSCompanionScreenState();
}

class _WearOSCompanionScreenState extends ConsumerState<WearOSCompanionScreen>
    with SingleTickerProviderStateMixin {
  static const Color boneWhite = Color(0xFFF5F5DC);
  static const Color terminalGreen = Color(0xFF00FF41);
  static const Color carbon = Color(0xFF1A1A1A);

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool _activeRoute = false;
  String _currentDestination = 'Sin destino activo';
  double _distanceKm = 0.0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _syncToWatch() async {
    HapticFeedback.mediumImpact();
    final service = ref.read(wearSyncServiceProvider);
    await service.syncExpeditionStatus(
      destination: _currentDestination,
      distanceKm: _distanceKm,
      heartRate: 72,
      isActive: _activeRoute,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: carbon,
          content: Text('SYNC // Datos enviados al reloj.', style: GoogleFonts.jetBrainsMono(color: terminalGreen, fontSize: 11)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectionAsync = ref.watch(watchConnectionProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: boneWhite),
          onPressed: () => context.pop(),
        ),
        title: Text('WEAR OS // COMPANION',
            style: GoogleFonts.jetBrainsMono(color: boneWhite, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Estado de conexión ────────────────────────────
            _buildLabel('ESTADO DE CONEXIÓN'),
            const SizedBox(height: 16),
            connectionAsync.when(
              loading: () => _buildConnectionCard('ESCANEANDO...', Colors.orange, null),
              error: (_, __) => _buildConnectionCard('ERROR DE PROTOCOLO', Colors.red, Icons.error_outline),
              data: (connected) => connected
                  ? _buildConnectionCard('RELOJ VINCULADO', terminalGreen, Icons.watch_outlined)
                  : _buildConnectionCard('SIN RELOJ DETECTADO', Colors.orange, Icons.watch_off_outlined),
            ),

            const SizedBox(height: 40),

            // ── Vista previa del reloj ────────────────────────
            _buildLabel('PREVISUALIZACIÓN WATCH FACE'),
            const SizedBox(height: 16),
            Center(child: _buildWatchFace()),

            const SizedBox(height: 40),

            // ── Expedición activa ─────────────────────────────
            _buildLabel('EXPEDICIÓN A SINCRONIZAR'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                border: Border.all(color: terminalGreen.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('RUTA ACTIVA', style: GoogleFonts.jetBrainsMono(color: boneWhite.withValues(alpha: 0.4), fontSize: 9)),
                      Switch(
                        value: _activeRoute,
                        onChanged: (v) => setState(() => _activeRoute = v),
                        activeThumbColor: terminalGreen,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    style: GoogleFonts.jetBrainsMono(color: boneWhite, fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'DESTINO',
                      labelStyle: GoogleFonts.jetBrainsMono(color: boneWhite.withValues(alpha: 0.3), fontSize: 9),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: boneWhite.withValues(alpha: 0.2))),
                      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: terminalGreen)),
                    ),
                    onChanged: (v) => setState(() => _currentDestination = v.isEmpty ? 'Sin destino' : v),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // ── Funciones del reloj ───────────────────────────
            _buildLabel('FUNCIONES ACTIVADAS'),
            const SizedBox(height: 12),
            ..._watchFeatures.map((f) => _buildFeatureTile(f['icon'] as IconData, f['title'] as String, f['desc'] as String)),

            const SizedBox(height: 40),

            // ── Botón de sincronización ───────────────────────
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _syncToWatch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: terminalGreen,
                  foregroundColor: carbon,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
                icon: const Icon(Icons.sync_rounded),
                label: Text('SINCRONIZAR CON RELOJ', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(label, style: GoogleFonts.jetBrainsMono(color: terminalGreen, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5));
  }

  Widget _buildConnectionCard(String status, Color color, IconData? icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (_, __) => Opacity(
              opacity: _pulseAnimation.value,
              child: Container(
                width: 10, height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6)]),
              ),
            ),
          ),
          const SizedBox(width: 16),
          if (icon != null) Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Text(status, style: GoogleFonts.jetBrainsMono(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildWatchFace() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: carbon,
        border: Border.all(color: terminalGreen.withValues(alpha: 0.5), width: 2),
        boxShadow: [BoxShadow(color: terminalGreen.withValues(alpha: 0.2), blurRadius: 20, spreadRadius: 2)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('FEELTRIP', style: GoogleFonts.jetBrainsMono(color: terminalGreen, fontSize: 9, letterSpacing: 2, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_currentDestination.toUpperCase(),
                style: GoogleFonts.ebGaramond(color: boneWhite, fontSize: 14, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.favorite, color: Colors.redAccent, size: 10),
                const SizedBox(width: 4),
                Text('72 BPM', style: GoogleFonts.jetBrainsMono(color: boneWhite.withValues(alpha: 0.5), fontSize: 8)),
              ],
            ),
            const SizedBox(height: 4),
            if (_activeRoute)
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (_, __) => Opacity(
                  opacity: _pulseAnimation.value,
                  child: Text('● EN RUTA', style: GoogleFonts.jetBrainsMono(color: terminalGreen, fontSize: 8, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: terminalGreen, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.jetBrainsMono(color: boneWhite, fontSize: 11, fontWeight: FontWeight.bold)),
                Text(desc, style: GoogleFonts.inter(color: boneWhite.withValues(alpha: 0.4), fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.check_circle_outline, color: terminalGreen, size: 16),
        ],
      ),
    );
  }

  static const _watchFeatures = [
    {'icon': Icons.route_outlined, 'title': 'RUTA ACTIVA', 'desc': 'Muestra el destino y progreso en tiempo real'},
    {'icon': Icons.favorite_border, 'title': 'BIOMETRÍA', 'desc': 'Ritmo cardíaco durante la expedición'},
    {'icon': Icons.notifications_outlined, 'title': 'ALERTAS POI', 'desc': 'Notifica puntos de interés cercanos'},
    {'icon': Icons.book_outlined, 'title': 'DIARIO RÁPIDO', 'desc': 'Dicta notas de voz desde el reloj'},
  ];
}
