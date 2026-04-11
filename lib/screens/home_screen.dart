import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../user_preferences.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(userPreferencesProvider);
    final Color brandTeal = const Color(0xFF00695C);

    return Scaffold(
      backgroundColor: prefs.darkMode ? const Color(0xFF0A0A0A) : const Color(0xFFF2F2F2),
      body: CustomScrollView(
        slivers: [
          // AppBar Dinámico con Estilo Playfair
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            backgroundColor: prefs.darkMode ? Colors.black : brandTeal,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              title: Text('FeelTrip', 
                style: GoogleFonts.playfairDisplay(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 24
                )),
              background: Container(color: prefs.darkMode ? Colors.black : brandTeal),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => context.push('/settings'),
              )
            ],
          ),

          // Sección de Estado del Sistema
          SliverToBoxAdapter(
            child: _SystemStatusBar(prefs: prefs),
          ),

          // Título de Sección
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text('EXPEDICIONES RECIENTES', 
                style: GoogleFonts.jetBrainsMono(fontSize: 12, letterSpacing: 1.5, color: Colors.grey)),
            ),
          ),

          // Lista de Expediciones (Ejemplo)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _ExpeditionCard(
                title: index == 0 ? 'Reserva Nacional El Yali' : 'Cerro La Campana',
                date: '07 ABR 2026',
                isOffline: prefs.offlineFirstMode,
              ),
              childCount: 2,
            ),
          ),
          
          // Botón Flotante de Nueva Ruta (IA)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: ElevatedButton.icon(
                onPressed: () {}, // Aquí dispararíamos el generador Gemini
                icon: const Icon(Icons.auto_awesome),
                label: const Text('GENERAR NUEVA RUTA CON IA'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8F00),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _SystemStatusBar extends StatelessWidget {
  final UserPreferences prefs;
  const _SystemStatusBar({required this.prefs});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: prefs.darkMode ? const Color(0xFF1A1A1A) : Colors.white,
        border: Border.all(color: Colors.grey.withValues(alpha: .2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatusItem(label: 'OFFLINE', isActive: prefs.offlineFirstMode),
          _StatusItem(label: 'AI_ENGINE', isActive: prefs.emotionalAnalytics),
          _StatusItem(label: 'SYNC', isActive: true),
        ],
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  final String label;
  final bool isActive;
  const _StatusItem({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.jetBrainsMono(fontSize: 9, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.greenAccent : Colors.redAccent,
            boxShadow: isActive ? [BoxShadow(color: Colors.greenAccent.withValues(alpha: .5), blurRadius: 4)] : null,
          ),
        )
      ],
    );
  }
}

class _ExpeditionCard extends StatelessWidget {
  final String title;
  final String date;
  final bool isOffline;
  const _ExpeditionCard({
    required this.title,
    required this.date,
    required this.isOffline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: .1),
        border: const Border(left: BorderSide(color: Color(0xFFFF8F00), width: 4)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        title: Text(title, style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
        subtitle: Text(date, style: GoogleFonts.jetBrainsMono(fontSize: 10)),
        trailing: isOffline ? const Icon(Icons.cloud_off, size: 16) : null,
        onTap: () {},
      ),
    );
  }
}