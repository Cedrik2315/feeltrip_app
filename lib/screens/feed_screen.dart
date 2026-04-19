import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:geolocator/geolocator.dart';

import 'package:feeltrip_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:feeltrip_app/presentation/providers/story_provider.dart';
import 'package:feeltrip_app/models/experience_model.dart';
import 'package:feeltrip_app/services/story_service.dart';
import 'package:feeltrip_app/features/profile/presentation/profile_controller.dart';

// Paleta FeelTrip
const boneWhite = Color(0xFFF5F5DC);
const mossGreen = Color(0xFF4B5320);
const carbon = Color(0xFF1A1A1A);

final storyServiceProvider = Provider((ref) => StoryService());

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  Future<Position?> _getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 2),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storiesAsync = ref.watch(allStoriesProvider);

    return Scaffold(
      backgroundColor: boneWhite,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: carbon,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'EXPLORAR EXPERIENCIAS',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 12, 
            color: boneWhite, 
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.slow_motion_video_outlined, color: boneWhite, size: 22),
            onPressed: () => context.push('/reels'),
            tooltip: 'Ver Reels',
          ),
          IconButton(
            icon: const Icon(Icons.map_outlined, color: boneWhite, size: 20),
            onPressed: () => context.push('/map'),
            tooltip: 'Cartografía IA',
          ),
          IconButton(
            icon: const Icon(Icons.insights_rounded, color: boneWhite, size: 20),
            onPressed: () => context.push('/metrics'),
            tooltip: 'Ver mi impacto',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: mossGreen,
        backgroundColor: boneWhite,
        onRefresh: () async => ref.refresh(allStoriesProvider.future),
        child: storiesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: mossGreen, strokeWidth: 2)),
          error: (error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                const SizedBox(height: 16),
                Text('Error loading feed: $error', 
                  style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.red.shade900),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(allStoriesProvider.future),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (stories) {
            if (stories.isEmpty) {
              return const _EmptyFeedView();
            }

            return FutureBuilder<Position?>(
              future: _getCurrentPosition(),
              builder: (context, snapshot) {
                final position = snapshot.data;
                
                // Clonar y ordenar historias por cercanía si la posición está disponible
                final sortedStories = List<TravelerStory>.from(stories);
                if (position != null) {
                  sortedStories.sort((a, b) {
                    // Se asume que TravelerStory tendrá campos latitude y longitude (double?)
                    final distA = (a.latitude != null && a.longitude != null)
                        ? Geolocator.distanceBetween(position.latitude, position.longitude, a.latitude!, a.longitude!)
                        : double.maxFinite;
                    final distB = (b.latitude != null && b.longitude != null)
                        ? Geolocator.distanceBetween(position.latitude, position.longitude, b.latitude!, b.longitude!)
                        : double.maxFinite;
                    return distA.compareTo(distB);
                  });
                }

                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: sortedStories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) return const _ShadowChallengeBanner();
                    final story = sortedStories[index - 1];
                    return _StoryCard(story: story, currentPosition: position);
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/stories'),
        backgroundColor: carbon,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        icon: const Icon(Icons.add, color: boneWhite),
        label: Text(
          'NUEVA HISTORIA', 
          style: GoogleFonts.jetBrainsMono(
            color: boneWhite, 
            fontWeight: FontWeight.bold, 
            fontSize: 12
          ),
        ),
      ),
    );
  }
}

class _StoryCard extends ConsumerWidget {
  const _StoryCard({required this.story, this.currentPosition});

  final TravelerStory story;
  final Position? currentPosition;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => context.push('/comments/${story.id}'),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with author and date
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: mossGreen,
                    child: Text(
                      story.author.isNotEmpty ? story.author[0].toUpperCase() : '?',
                      style: const TextStyle(color: boneWhite, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          story.title.toUpperCase(),
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _formatDate(story.createdAt),
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _LikeButton(
                    likes: story.likes,
                    onTap: () {
                      final userId = authState.valueOrNull?.id;
                      if (userId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('LOG: AUTH_REQUIRED_FOR_INTERACTION')),
                        );
                        return;
                      }
                      
                      ref.read(storyServiceProvider).toggleLike(story.id, userId).then((_) {
                        // Refrescamos el feed para ver el cambio en el contador
                        ref.invalidate(allStoriesProvider);
                      }).catchError((Object e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('ERR: LIKE_SYNC_FAILED > $e')),
                        );
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Image
              if (story.imageUrl.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: story.imageUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 180,
                        color: Colors.grey.shade200,
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 180,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_not_supported_outlined, size: 48, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              // Content
              Text(
                story.story,
                maxLines: story.imageUrl.isEmpty ? 4 : 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.ebGaramond(
                  fontSize: 17, 
                  color: Colors.black87, 
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              // Divider
              Container(
                height: 1,
                width: double.infinity,
                color: Colors.black.withValues(alpha: 0.1),
              ),
              // Highlights
              if (story.emotionalHighlights.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: story.emotionalHighlights.take(3).map((highlight) => Chip(
                    label: Text(highlight, style: GoogleFonts.jetBrainsMono(fontSize: 10)),
                    backgroundColor: mossGreen.withValues(alpha: 0.1),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  )).toList(),
                ),
              ],
              const SizedBox(height: 16),
              // Recomendación Dinámica por Arquetipo
              Consumer(
                builder: (context, ref, child) {
                  final profile = ref.watch(profileControllerProvider).value;
                  final userArchetype = profile?.archetype?.toLowerCase() ?? 'explorador';
                  
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: mossGreen.withValues(alpha: 0.05),
                      border: Border(left: BorderSide(color: mossGreen.withValues(alpha: 0.3), width: 2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RECOMENDADO PARA TU PERFIL ${userArchetype.toUpperCase()}',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9, 
                            fontWeight: FontWeight.bold,
                            color: mossGreen,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _buildRationaleWithDistance(userArchetype, story),
                          style: GoogleFonts.inter(
                            fontSize: 11, 
                            color: carbon.withValues(alpha: 0.7),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildRationaleWithDistance(String userArchetype, TravelerStory story) {
    String rationale = _getArchetypeRationale(userArchetype, story.story);
    
    if (currentPosition != null && story.latitude != null && story.longitude != null) {
      final distance = Geolocator.distanceBetween(
        currentPosition!.latitude,
        currentPosition!.longitude,
        story.latitude!,
        story.longitude!,
      );
      rationale += ' | A ${(distance / 1000).toStringAsFixed(1)} km de ti';
    }
    return rationale;
  }

  String _getArchetypeRationale(String archetype, String text) {
    switch (archetype.toLowerCase()) {
      case 'aventura':
      case 'explorador':
        return 'Esta ruta desafía tus límites físicos y técnicos con terrenos de alta intensidad.';
      case 'reflexion':
      case 'ermitaño':
        return 'El aislamiento de este destino garantiza el silencio necesario para tu introspección.';
      case 'conexion':
      case 'conector':
        return 'La calidez de su gente y las historias compartidas nutren tu necesidad de pertenencia.';
      case 'transformacion':
      case 'alquimista':
        return 'La mística del lugar actúa como catalizador para el cambio interno que estás buscando.';
      case 'aprendizaje':
      case 'académico':
        return 'Su riqueza histórica y biodiversidad ofrecen un aula viva para tu curiosidad intelectual.';
      default:
        return 'Sugerido por telemetría IA basándonos en tu historial de exploración emocional.';
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}

class _LikeButton extends StatelessWidget {
  const _LikeButton({
    required this.likes,
    required this.onTap,
  });

  final int likes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            Icons.favorite_border_rounded,
            color: mossGreen,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            '$likes',
            style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _EmptyFeedView extends ConsumerWidget {
  const _EmptyFeedView();

  // Expediciones semilla para inspirar a nuevos usuarios
  // Coordenadas de ejemplo (Lat/Lng)
  static const List<_SeedExpedition> _seeds = [
    _SeedExpedition(
      title: 'Torres del Paine en Silencio',
      author: 'Exploradora_M',
      archetype: 'ERMITAÑO',
      preview: 'El viento no pregunta si estás listo. Simplemente empieza a empujarte hacia donde debes ir. Tres días sin señal cambiaron algo en mí que no sé cómo nombrar todavía.',
      highlights: ['soledad', 'viento patagónico', 'transformación'],
      lat: -51.0, 
      lng: -73.0,
    ),
    _SeedExpedition(
      title: 'Mercado de Pisac al amanecer',
      author: 'Conector_J',
      archetype: 'CONECTOR',
      preview: 'Una señora me ofreció chicha de jora antes de que dijera hola. Así empezó la mejor conversación de mi vida sobre tejidos y memoria colectiva.',
      highlights: ['cultura', 'gastronomía', 'conexión humana'],
      lat: -13.4, 
      lng: -71.8,
    ),
    _SeedExpedition(
      title: 'Ruta del Cóndor: 4.800 msnm',
      author: 'Explorador_K',
      archetype: 'EXPLORADOR',
      preview: 'El altímetro decía imposible. Mi cuerpo decía lo mismo. Llegamos igual. La línea entre límite y frontera es más delgada de lo que crees.',
      highlights: ['altitud', 'resistencia', 'cóndores'],
      lat: -33.4, 
      lng: -70.6,
    ),
  ];

  Future<Position?> _getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 2),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileControllerProvider).value;
    final userArchetype = profile?.archetype?.toUpperCase() ?? 'EXPLORADOR';

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 16),
        const _ShadowChallengeBanner(),
        
        // Header motivador
        Text(
          'TRANSMISIONES\nDE CAMPO',
          style: GoogleFonts.ebGaramond(
            fontSize: 36,
            color: carbon,
            fontWeight: FontWeight.bold,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '> CARGANDO PRIMERAS SEÑALES DE LA RED...',
          style: GoogleFonts.jetBrainsMono(
            color: mossGreen,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 32),

        // CTA principal
        GestureDetector(
          onTap: () => context.push('/stories'),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: carbon,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Row(
              children: [
                const Icon(Icons.add_photo_alternate_outlined, color: boneWhite, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SÉ EL PRIMERO', style: GoogleFonts.jetBrainsMono(color: boneWhite, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      const SizedBox(height: 4),
                      Text('Publica tu expedición y arranca la conversación.', style: GoogleFonts.ebGaramond(color: boneWhite.withValues(alpha: 0.7), fontSize: 14)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_rounded, color: boneWhite, size: 18),
              ],
            ),
          ),
        ),

        const SizedBox(height: 48),
        
        FutureBuilder<Position?>(
          future: _getCurrentPosition(),
          builder: (context, snapshot) {
            final position = snapshot.data;
            
            // 1. Filtrar por Arquetipo (Afinidad Directa)
            final archetypeSeeds = _seeds.where((s) => s.archetype == userArchetype).toList();
            
            // 2. Ordenar por Proximidad si hay GPS
            List<_SeedExpedition> nearSeeds = List.from(_seeds);
            if (position != null) {
              nearSeeds.sort((a, b) {
                double distA = Geolocator.distanceBetween(position.latitude, position.longitude, a.lat, a.lng);
                double distB = Geolocator.distanceBetween(position.latitude, position.longitude, b.lat, b.lng);
                return distA.compareTo(distB);
              });
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (archetypeSeeds.isNotEmpty) ...[
                  _buildSectionHeader('MATCH POR ARQUETIPO: $userArchetype'),
                  const SizedBox(height: 16),
                  ...archetypeSeeds.map((seed) => _SeedCard(seed: seed)),
                  const SizedBox(height: 32),
                ],
                
                _buildSectionHeader(position != null ? 'CERCA DE TU UBICACIÓN' : 'RECOMENDADOS PARA TI'),
                const SizedBox(height: 16),
                ...nearSeeds.take(3).map((seed) => _SeedCard(seed: seed, currentPosition: position)),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.jetBrainsMono(fontSize: 9, color: carbon.withValues(alpha: 0.4), letterSpacing: 1, fontWeight: FontWeight.bold),
    );
  }
}

class _SeedExpedition {
  final String title;
  final String author;
  final String archetype;
  final String preview;
  final List<String> highlights;
  final double lat;
  final double lng;

  const _SeedExpedition({
    required this.title, 
    required this.author, 
    required this.archetype, 
    required this.preview, 
    required this.highlights,
    required this.lat,
    required this.lng,
  });
}

class _SeedCard extends StatelessWidget {
  final _SeedExpedition seed;
  final Position? currentPosition;
  const _SeedCard({required this.seed, this.currentPosition});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: mossGreen, width: 3)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: mossGreen,
                child: Text(seed.author[0], style: const TextStyle(color: boneWhite, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(seed.author, style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold, color: carbon)),
                  Text('ARQUETIPO: ${seed.archetype}', style: GoogleFonts.jetBrainsMono(fontSize: 8, color: mossGreen)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(seed.title.toUpperCase(), style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.w800, color: carbon)),
          const SizedBox(height: 8),
          Text(seed.preview, style: GoogleFonts.ebGaramond(fontSize: 15, color: Colors.black87, height: 1.4), maxLines: 3, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            children: seed.highlights.map((h) => Chip(
              label: Text(h, style: GoogleFonts.jetBrainsMono(fontSize: 9)),
              backgroundColor: mossGreen.withValues(alpha: 0.08),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            )).toList(),
          ),
          const SizedBox(height: 12),
          // Rationale para Seed Card
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, size: 12, color: mossGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ideal para ${seed.archetype} por su balance de ${seed.highlights.join(" y ")}.',
                    style: GoogleFonts.inter(fontSize: 10, color: carbon.withValues(alpha: 0.6), fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShadowChallengeBanner extends StatelessWidget {
  const _ShadowChallengeBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 24, top: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: carbon,
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: const AssetImage('assets/images/diary_bg.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(carbon.withValues(alpha: 0.8), BlendMode.dstATop),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_alt_outlined, color: Color(0xFFD4AF37), size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'PROTOCOLO SOMBRA',
                  style: GoogleFonts.jetBrainsMono(
                    color: const Color(0xFFD4AF37),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Consumer(
            builder: (context, ref, child) {
              final profile = ref.watch(profileControllerProvider).value;
              final archetype = profile?.archetype?.toLowerCase() ?? 'contemplativo';
              
              String challenge;
              String reason;
              
              switch (archetype) {
                case 'aventura':
                  reason = 'Tu pulso siempre busca la cima.';
                  challenge = 'Hoy el desafío es la INMOVILIDAD. Encuentra un banco, siéntate 15 minutos sin mirar el mapa y describe solo los olores del entorno.';
                  break;
                case 'reflexion':
                case 'ermitaño':
                  reason = 'El silencio es tu refugio habitual.';
                  challenge = 'Protocolo de EXTROVERSIÓN activado. Pide una recomendación a un extraño sobre un lugar oculto y anota su nombre en tu bitácora.';
                  break;
                case 'conexion':
                case 'conector':
                  reason = 'Eres un imán de historias ajenas.';
                  challenge = 'Protocolo de INTROSPECCIÓN. Busca un rincón donde nadie te vea y escribe una carta a tu "yo" de hace 5 años sobre este viaje.';
                  break;
                case 'academico':
                  reason = 'Buscas entender todo con datos.';
                  challenge = 'Protocolo SENSORIAL. No busques la historia del lugar. Solo toca la textura de 3 plantas distintas y descríbelas por su tacto.';
                  break;
                default:
                  reason = 'Llevas varios días en tu zona de confort.';
                  challenge = 'Tu desafío hoy: Entabla una conversación de 5 minutos con un local y escribe lo aprendido en la bitácora.';
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reason,
                    style: GoogleFonts.jetBrainsMono(color: boneWhite.withValues(alpha: 0.5), fontSize: 9),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    challenge,
                    style: GoogleFonts.ebGaramond(
                      color: boneWhite,
                      fontSize: 16,
                      height: 1.3,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('DESAFÍO ACEPTADO. Dirígete al Diario de Campo.', style: TextStyle(color: Color(0xFFD4AF37))),
                    backgroundColor: carbon,
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: boneWhite,
                backgroundColor: mossGreen.withValues(alpha: 0.8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
              ),
              child: Text(
                'ACEPTAR MISIÓN',
                style: GoogleFonts.jetBrainsMono(
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
