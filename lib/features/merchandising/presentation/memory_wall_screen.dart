import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:feeltrip_app/features/city_mode/data/drift_database.dart';
import 'package:feeltrip_app/features/city_mode/data/city_mode_repository.dart';

class MemoryWallScreen extends ConsumerWidget {
  const MemoryWallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const Color carbonBlack = Color(0xFF1A1A1A);
    const Color neonPurple = Color(0xFFBC13FE);
    const Color boneWhite = Color(0xFFF5F5DC);

    return Scaffold(
      backgroundColor: carbonBlack,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: carbonBlack,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('MURO DE LA MEMORIA', 
                style: GoogleFonts.jetBrainsMono(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2, color: boneWhite)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [neonPurple.withValues(alpha: 0.2), carbonBlack],
                  ),
                ),
                child: Center(
                  child: Icon(Icons.album_outlined, size: 80, color: neonPurple.withValues(alpha: 0.3)),
                ),
              ),
            ),
          ),
          
          // LISTA DE ARTEFACTOS / VINILOS
          StreamBuilder<List<Viaje>>(
            stream: ref.watch(appDatabaseProvider).select(ref.watch(appDatabaseProvider).viajes).watch(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: neonPurple)));
              }
              
              final viajes = snapshot.data ?? [];
              
              if (viajes.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_edu_outlined, color: boneWhite.withValues(alpha: 0.2), size: 64),
                        const SizedBox(height: 16),
                        Text('AÚN NO HAY ARTEFACTOS MATERIALIZADOS', 
                          style: GoogleFonts.jetBrainsMono(color: boneWhite.withValues(alpha: 0.3), fontSize: 10)),
                        const SizedBox(height: 32),
                        OutlinedButton.icon(
                          onPressed: () => ref.read(cityModeRepositoryProvider).insertSeedViajes(),
                          icon: const Icon(Icons.auto_awesome, color: neonPurple),
                          label: Text('GENERAR DATA DE PRUEBA (QUILLOTA)', style: GoogleFonts.jetBrainsMono(color: boneWhite)),
                          style: OutlinedButton.styleFrom(side: BorderSide(color: neonPurple.withValues(alpha: 0.3))),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 24,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _ArtifactVinylCard(viaje: viajes[index]),
                    childCount: viajes.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ArtifactVinylCard extends StatelessWidget {
  final Viaje viaje;
  const _ArtifactVinylCard({required this.viaje});

  @override
  Widget build(BuildContext context) {
    const Color boneWhite = Color(0xFFF5F5DC);
    const Color neonPurple = Color(0xFFBC13FE);
    const Color terminalGreen = Color(0xFF00FF41);

    return GestureDetector(
      onTap: () => context.push('/artifact-summary/${viaje.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PORTADA DEL VINILO (DISEÑO IA)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(color: (viaje.hasPurchasedArtifact) ? neonPurple.withValues(alpha: 0.3) : Colors.transparent, blurRadius: 15),
                ],
                border: Border.all(color: boneWhite.withValues(alpha: 0.1)),
              ),
              child: Stack(
                children: [
                  // Imagen generativa o placeholder técnico
                  Center(
                    child: Icon(Icons.blur_on, color: boneWhite.withValues(alpha: 0.2), size: 48),
                  ),
                  
                  // BADGE DE "ADQUIRIDO"
                  if (viaje.hasPurchasedArtifact)
                    Positioned(
                      top: 8, right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: terminalGreen, borderRadius: BorderRadius.circular(4)),
                        child: Text('TÓTEM', style: GoogleFonts.jetBrainsMono(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(viaje.nombre.toUpperCase(), 
            style: GoogleFonts.jetBrainsMono(color: boneWhite, fontSize: 11, fontWeight: FontWeight.bold),
            maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(viaje.fechaViaje.toString().split(' ')[0], 
            style: GoogleFonts.jetBrainsMono(color: boneWhite.withValues(alpha: 0.4), fontSize: 9)),
        ],
      ),
    );
  }
}
