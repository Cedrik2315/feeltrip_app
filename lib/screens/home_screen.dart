import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../user_preferences.dart';
import 'package:feeltrip_app/presentation/providers/subscription_provider.dart';
import 'package:feeltrip_app/core/di/providers.dart';
import 'package:feeltrip_app/widgets/pro_expiry_banner.dart';
import 'package:feeltrip_app/domain/entities/user_subscription.dart';
import 'package:feeltrip_app/services/geofencing_service.dart';

import 'package:feeltrip_app/features/profile/presentation/profile_controller.dart';
import 'package:feeltrip_app/widgets/cyber_widgets.dart';
// Removido import no utilizado

class ExpeditionSuggestion {
  final String title;
  final String rationale;
  final bool isOffline;
  ExpeditionSuggestion({required this.title, required this.rationale, this.isOffline = false});
}

final localExpeditionsProvider = FutureProvider.autoDispose<List<ExpeditionSuggestion>>((ref) async {
  final profile = ref.watch(profileControllerProvider).value;
  final archetype = profile?.archetype?.toLowerCase() ?? 'default';

  // Base de datos de razonamiento por arquetipo
  Map<String, String> getReason(String place) {
    switch (archetype) {
      case 'aventura': 
        return {
          'Torres del Paine': 'Un desafío de resistencia técnica.',
          'Valle de la Luna': 'Territorio hostil por conquistar.',
          'El Morado': 'Ascenso vertical puro.',
          'Bosque Encantado': 'Exploración en selva virgen.'
        };
      case 'reflexion':
        return {
          'Torres del Paine': 'Paz absoluta ante el granito.',
          'Valle de la Luna': 'Silencio profundo en el desierto.',
          'El Morado': 'Contemplación de los glaciares.',
          'Bosque Encantado': 'Meditación entre musgos centenarios.'
        };
      case 'conexion':
        return {
          'Torres del Paine': 'Historias compartidas en el refugio.',
          'Valle de la Luna': 'Atardeceres míticos con viajeros.',
          'El Morado': 'Ruta clásica de camaradería.',
          'Bosque Encantado': 'Leyendas locales de Chiloé.'
        };
      default:
        return {
          'Torres del Paine': 'Sugerido por proximidad GPS.',
          'Valle de la Luna': 'Sugerido por telemetría IA.',
          'El Morado': 'Sugerido por historial de ruta.',
          'Bosque Encantado': 'Sugerido por afinidad visual.'
        };
    }
  }

  return [
    ExpeditionSuggestion(title: 'Torres del Paine', rationale: getReason('Torres del Paine')['Torres del Paine'] ?? 'Destino recomendado.'),
    ExpeditionSuggestion(title: 'Valle de la Luna', rationale: getReason('Valle de la Luna')['Valle de la Luna'] ?? 'Ruta optimizada.', isOffline: true),
    ExpeditionSuggestion(title: 'Senda del Cóndor', rationale: 'Vuelo compartido con la fauna local.'),
    ExpeditionSuggestion(title: 'Bosque Encantado', rationale: getReason('Bosque Encantado')['Bosque Encantado'] ?? 'Inmersión total.')
  ];
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Activa la telemetría de geofencing al iniciar Sesión Principal
    ref.watch(geofencingProvider);
    
    final expeditionsAsync = ref.watch(localExpeditionsProvider);
    final subscription = ref.watch(subscriptionProvider).valueOrNull;
    final connectivity = ref.watch(connectivityProvider).valueOrNull ?? ConnectivityResult.none;
    final prefs = ref.watch(userPreferencesProvider);
    final theme = Theme.of(context);
    final terminalGreen = theme.colorScheme.tertiary;

    // Lógica de Telemetría Real
    final bool isOnline = connectivity != ConnectivityResult.none;
    final Color syncColor = isOnline ? terminalGreen : Colors.redAccent;
    final Color offlineColor = prefs.offlineFirstMode ? terminalGreen : Colors.orange;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.6,
              child: Image.asset('assets/images/forest_mist.png', fit: BoxFit.cover),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.surface.withValues(alpha: 0.8),
                    Colors.transparent,
                    theme.colorScheme.surface.withValues(alpha: 0.9)
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopStatus(context, subscription, syncColor, offlineColor),
                  const SizedBox(height: 20),
                  _buildHeader(context),
                  const SizedBox(height: 40),
                  _buildActionCenter(context, theme),
                  const SizedBox(height: 24),
                  _buildArchetypeCard(context, ref, theme),
                  const SizedBox(height: 48), // Reemplazo del Spacer
                  _buildLowerExpeditions(context, expeditionsAsync),
                  const SizedBox(height: 100), // ESPACIO EXTRA PARA EVITAR EL BANNER
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: theme.colorScheme.surface,
        child: SafeArea(
          child: BottomAppBar(
            height: 85,
            color: theme.colorScheme.surface,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Container(
              decoration: BoxDecoration(border: Border(top: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.15)))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navIcon(context, Icons.analytics_outlined, true, '/home', theme),
                  _navIcon(context, Icons.explore_outlined, false, '/feed', theme),
                  _navIcon(context, Icons.camera_outlined, false, '/ocr', theme),
                  _navIcon(context, Icons.history_edu_outlined, false, '/diary', theme),
                  _navIcon(context, Icons.person_outline, false, '/profile', theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopStatus(BuildContext context, UserSubscription? sub, Color syncColor, Color offlineColor) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _statusDot(context, syncColor == theme.colorScheme.tertiary ? 'ONLINE' : 'OFFLINE', syncColor),
              const SizedBox(width: 12),
              _statusDot(context, 'SOCIAL SYNC', theme.colorScheme.tertiary),
            ],
          ),
          Row(
            children: [
              if (sub != null && sub.isPro) 
                ProExpiryBanner(subscription: sub)
              else
                TextButton(
                  onPressed: () => context.push('/premium'),
                  child: Text('ACTIVATE PRO', style: GoogleFonts.jetBrainsMono(color: theme.colorScheme.secondary, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.settings_outlined, color: theme.colorScheme.onSurface, size: 20),
                onPressed: () => context.push('/settings'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusDot(BuildContext context, String label, Color color) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: color.withValues(alpha: 0.8), blurRadius: 6)],
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.jetBrainsMono(color: theme.colorScheme.onSurface, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('FEELTRIP // COMMAND', style: GoogleFonts.jetBrainsMono(color: theme.colorScheme.primary, fontSize: 12, letterSpacing: 2)),
          const SizedBox(height: 8),
          Text('CENTRO DE\nEXPEDICIÓN', style: GoogleFonts.ebGaramond(color: theme.colorScheme.onSurface, fontSize: 40, height: 0.9, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(height: 1, width: 60, color: theme.colorScheme.primary),
        ],
      ),
    );
  }

  Widget _buildActionCenter(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: CyberButton(label: 'INICIAR IA', icon: Icons.psychology, primary: true, onTap: () => context.push('/suggestions'))),
              const SizedBox(width: 16),
              Expanded(child: CyberButton(label: 'NUEVO DIARIO', icon: Icons.add_a_photo_outlined, primary: false, onTap: () => context.push('/diary/capture'))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: CyberButton(label: 'PREDICCIÓN', icon: Icons.auto_awesome, primary: false, onTap: () => context.push('/emotional-prediction'))),
              const SizedBox(width: 16),
              Expanded(child: CyberButton(label: 'EXPLORAR RED', icon: Icons.public_outlined, primary: false, onTap: () => context.push('/feed'))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: CyberButton(label: 'INSIGNIAS', icon: Icons.military_tech_outlined, primary: false, onTap: () => context.push('/proof-of-expedition'))),
              const SizedBox(width: 16),
              Expanded(child: CyberButton(label: 'MAPA IA', icon: Icons.map_outlined, primary: false, onTap: () => context.push('/map'))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: CyberButton(label: 'RADAR URBANO', icon: Icons.radar, primary: true, onTap: () => context.push('/city-mode'))),
              const SizedBox(width: 8),
              Expanded(child: CyberButton(label: 'LAB', icon: Icons.shopping_bag_outlined, primary: false, onTap: () => context.push('/artifact-lab/123'))),
              const SizedBox(width: 8),
              Expanded(child: CyberButton(label: 'MURO', icon: Icons.album_outlined, primary: false, onTap: () => context.push('/memory-wall'))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLowerExpeditions(BuildContext context, AsyncValue<List<ExpeditionSuggestion>> list) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text('EXPLORACIONES SUGERIDAS', style: GoogleFonts.jetBrainsMono(color: theme.colorScheme.onSurface.withValues(alpha: 0.3), fontSize: 10)),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 190,
          child: list.when(
            data: (items) => ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              itemBuilder: (context, i) => _ExpeditionCard(suggestion: items[i]),
            ),
            error: (_, __) => const Center(child: Text('Error al cargar telemetría')),
            loading: () => Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)),
          ),
        ),
        const SizedBox(height: 100), // ESPACIO EXTRA PARA EVITAR EL BANNER
      ],
    );
  }

  Widget _buildArchetypeCard(BuildContext context, WidgetRef ref, ThemeData theme) {
    final profileAsync = ref.watch(profileControllerProvider);
    
    return profileAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (profile) {
        final archetype = profile?.archetype;
        final bool hasArchetype = archetype != null;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.8),
              border: Border.all(color: hasArchetype ? theme.colorScheme.tertiary : theme.colorScheme.primary, width: 1),
              boxShadow: [
                BoxShadow(color: (hasArchetype ? theme.colorScheme.tertiary : theme.colorScheme.primary).withValues(alpha: 0.1), blurRadius: 15)
              ]
            ),
            child: Row(
              children: [
                Icon(
                  hasArchetype ? Icons.verified_user_outlined : Icons.psychology_outlined, 
                  color: hasArchetype ? theme.colorScheme.tertiary : theme.colorScheme.primary, 
                  size: 32
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasArchetype ? 'ARQUETIPO: ${archetype.toUpperCase()}' : 'ARQUETIPO NO DETECTADO', 
                        style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasArchetype ? 'Tu esencia exploradora está sincronizada.' : 'Define tu perfil para personalizar la IA.', 
                        style: GoogleFonts.inter(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/quiz'),
                  child: Text(
                    hasArchetype ? 'REPETIR' : 'INICIAR', 
                    style: GoogleFonts.jetBrainsMono(color: theme.colorScheme.primary, fontSize: 10, fontWeight: FontWeight.bold)
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _navIcon(BuildContext context, IconData icon, bool active, String route, ThemeData theme) {
    return IconButton(
      icon: Icon(icon, color: active ? theme.colorScheme.primary : theme.colorScheme.onSurface, size: 28),
      onPressed: () { if (!active) context.push(route); },
    );
  }
}

class _ExpeditionCard extends StatelessWidget {
  final ExpeditionSuggestion suggestion;

  const _ExpeditionCard({required this.suggestion});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 200,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: suggestion.isOffline ? Colors.orange : theme.colorScheme.tertiary, width: 4)),
        boxShadow: [
          BoxShadow(color: (suggestion.isOffline ? Colors.orange : theme.colorScheme.tertiary).withValues(alpha: 0.1), blurRadius: 10)
        ]
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          context.push('/map');
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(suggestion.title, style: GoogleFonts.ebGaramond(fontSize: 16, color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, height: 1.1)),
              const SizedBox(height: 8),
              Text(
                suggestion.rationale, 
                style: GoogleFonts.inter(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.6), height: 1.3),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Text(suggestion.isOffline ? '> CACHED // SYNC' : '> READY // DEPLOY', 
                style: GoogleFonts.jetBrainsMono(fontSize: 8, color: suggestion.isOffline ? Colors.orange : theme.colorScheme.tertiary)),
            ],
          ),
        ),
      ),
    );
  }
}