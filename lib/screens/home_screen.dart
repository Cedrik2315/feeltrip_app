import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import 'package:feeltrip_app/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:feeltrip_app/core/di/providers.dart';
import '../models/trip_model.dart';
import '../models/experience_model.dart';
import '../widgets/ai_proposal_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/travel_agency_model.dart';
import 'translator_screen.dart';
import 'ocr_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<Trip> trips = [];
  int _carouselIndex = 0;
  List<Trip> _featuredTrips = [];
  List<TravelerStory> _stories = [];
  late Future<TravelAgency?> _proposalFuture;

  @override
  void initState() {
    super.initState();
    final userId = AuthService.currentUser?.uid;
    if (userId != null) {
      final notifier = ref.read(osintAiServiceProvider.notifier);
      _proposalFuture = notifier.getPersonalizedProposal(userId);
    } else {
      _proposalFuture = Future<TravelAgency?>(() async => null);
    }

    FirebaseFirestore.instance
        .collection('trips')
        .limit(10)
        .get()
        .then((snapshot) {
      if (mounted) {
        setState(() {
          trips = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Trip.fromJson(data);
          }).toList();
          _featuredTrips =
              trips.where((trip) => trip.isFeatured).toList().take(5).toList();
        });
      }
    });
    _loadStories();
  }

  void _loadStories() {
    setState(() {
      _stories = [
        TravelerStory(
          id: '1',
          author: 'Maria Garcia',
          title: 'Bajo la aurora boreal',
          story:
              'En Tromso, vimos las luces del norte y algo cambio dentro de mi. Llore de alegria viendo la naturaleza en su maxima expresion.',
          emotionalHighlights: ['Asombro', 'Gratitud', 'Transformacion'],
          likes: 347,
          rating: 5.0,
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
        ),
        TravelerStory(
          id: '2',
          author: 'Juan Lopez',
          title: 'Conexion en Peru',
          story:
              'Conoci a una familia quechua en el valle sagrado. Compartimos comida, risas y historias. Aprendi que la verdadera riqueza esta en las conexiones humanas.',
          emotionalHighlights: ['Conexion', 'Paz', 'Esperanza'],
          likes: 512,
          rating: 5.0,
          createdAt: DateTime.now().subtract(const Duration(days: 14)),
        ),
        TravelerStory(
          id: '3',
          author: 'Isabella Romano',
          title: 'El legado de mi nonna',
          story:
              'Volvimos a Italia despues de 40 anos. Encontramos la casa de mis abuelos y conocimos primos que no sabia que existian. Mi identidad cobro nuevo sentido.',
          emotionalHighlights: ['Nostalgia', 'Reflexion', 'Pertenencia'],
          likes: 289,
          rating: 4.8,
          createdAt: DateTime.now().subtract(const Duration(days: 21)),
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FeelTrip - Viajes Transformadores'),
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Consumer(
            builder: (context, ref, child) {
              return ref.watch(userLocationProvider).when(
                    data: (position) {
                      if (position == null) return const SizedBox.shrink();
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4.0,
                        ),
                        child: Text(
                          'Explorando cerca de: ${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (error, stack) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Habilita GPS y permisos para ubicaciÃƒÆ’Ã‚Â³n'),
                            backgroundColor: Colors.orange,
                            duration: Duration(seconds: 3),
                          ),
                        );
                      });
                      return const SizedBox.shrink();
                    },
                  );
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.deepPurple,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Viajes que Transforman',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'No solo viajes, sino experiencias que cambian tu perspectiva de vida',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar destino transformador...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.location_on),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.calendar_today),
                          label: const Text('Fechas'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.deepPurple,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.people),
                          label: const Text('Viajeros'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.deepPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            FutureBuilder<TravelAgency?>(
              future: _proposalFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(height: 220),
                      ),
                    ),
                  );
                }
                final agency = snapshot.data;
                if (agency == null) {
                  return const SizedBox.shrink();
                }
                return Column(
                  children: [
                    AiProposalCard(
                      agency: agency,
                      moodEmoji: 'ÃƒÂ°Ã…Â¸Ã…â€™Ã…Â ',
                      moodBadge: 'Buscando Calma',
                      onAdditionalTap: () => context.go('/agency/${agency.id}'),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple[300]!, Colors.deepPurple],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Descubre Tu Tipo de Viajero',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Responde nuestro quiz para recibir recomendaciones personalizadas basadas en tus valores y emociones',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/quiz');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.deepPurple,
                        ),
                        child: const Text('Empezar Quiz'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tipos de Experiencias',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildArchetypeCard(
                          'ÃƒÂ°Ã…Â¸Ã¢â‚¬â„¢Ã¢â‚¬Â¢',
                          'Conector',
                          'Conexiones humanas\ny culturales',
                          Colors.red,
                        ),
                        _buildArchetypeCard(
                          'ÃƒÂ°Ã…Â¸Ã‚Â¦Ã¢â‚¬Â¹',
                          'Transformado',
                          'Crecimiento personal\ny reflexion',
                          Colors.deepPurple,
                        ),
                        _buildArchetypeCard(
                          'ÃƒÂ¢Ã…Â¡Ã‚Â¡',
                          'Aventurero',
                          'Adrenalina y\nnuevas emociones',
                          Colors.orange,
                        ),
                        _buildArchetypeCard(
                          'ÃƒÂ°Ã…Â¸Ã…â€™Ã¢â‚¬Å¾',
                          'Contemplativo',
                          'Paz interior y\nconexion con la naturaleza',
                          Colors.cyan,
                        ),
                        _buildArchetypeCard(
                          'ÃƒÂ°Ã…Â¸Ã¢â‚¬Å“Ã…Â¡',
                          'Aprendiz',
                          'Conocimiento y\ndescubrimiento',
                          Colors.green,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Viajes Destacados',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_featuredTrips.isNotEmpty)
                    Column(
                      children: [
                        CarouselSlider.builder(
                          itemCount: _featuredTrips.length,
                          options: CarouselOptions(
                            height: 250,
                            autoPlay: true,
                            enlargeCenterPage: true,
                            onPageChanged: (index, reason) {
                              setState(() {
                                _carouselIndex = index;
                              });
                            },
                          ),
                          itemBuilder: (context, index, realIndex) {
                            final trip = _featuredTrips[index];
                            return TripCard(trip: trip);
                          },
                        ),
                        const SizedBox(height: 12),
                        AnimatedSmoothIndicator(
                          activeIndex: _carouselIndex,
                          count: _featuredTrips.length,
                          effect: const ExpandingDotsEffect(),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Historias de Transformacion',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed('/stories');
                        },
                        child: const Text(
                          'Ver todas',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._stories
                      .take(2)
                      .map((story) => _buildStoryPreviewCard(story)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mi Experiencia',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickAccessCard(
                          'ÃƒÂ°Ã…Â¸Ã¢â‚¬Å“Ã¢â‚¬Â',
                          'Mi Diario',
                          'Registra tus emociones',
                          () {
                            Navigator.of(context).pushNamed('/diary');
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickAccessCard(
                          'ÃƒÂ°Ã…Â¸Ã¢â‚¬Å“Ã…Â ',
                          'Mi Impacto',
                          'Mide tu transformacion',
                          () {
                            Navigator.of(context)
                                .pushNamed('/impact-dashboard');
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Herramientas UGC',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: const Icon(Icons.dynamic_feed),
                    title: const Text('Feed'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => Navigator.of(context).pushNamed('/feed'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.translate),
                    title: const Text('Traductor'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const TranslatorScreen(),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('Lector OCR'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const OCRScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ConfiguraciÃƒÆ’Ã‚Â³n',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Consumer(
                      builder: (context, ref, child) {
                        final prefs = ref.watch(userPreferencesProvider);
                        return SwitchListTile(
                          title: const Text('Modo Descanso'),
                          subtitle:
                              const Text('Silencia alertas de 22:00 a 08:00'),
                          secondary: const Icon(Icons.nightlight_round),
                          value: prefs.isQuietModeEnabled,
                          onChanged: (value) {
                            ref.read(userPreferencesProvider.notifier).update(
                                  (state) => state.copyWith(
                                    isQuietModeEnabled: value,
                                  ),
                                );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildArchetypeCard(
    String emoji,
    String title,
    String description,
    Color color,
  ) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryPreviewCard(TravelerStory story) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.deepPurple[200],
                  child: Text(story.author[0]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        story.author,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        story.title,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    Text(
                      '${story.rating}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              story.story,
              style: const TextStyle(fontSize: 13),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              children: story.emotionalHighlights
                  .map(
                    (emotion) => Chip(
                      label: Text(emotion),
                      backgroundColor: Colors.purple[50],
                      labelStyle: const TextStyle(fontSize: 11),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.favorite, size: 16, color: Colors.red),
                const SizedBox(width: 4),
                Text(
                  '${story.likes}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessCard(
    String emoji,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TripCard extends StatelessWidget {
  const TripCard({super.key, required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/trip-details', arguments: trip.id);
      },
      child: Card(
        margin: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              width: double.infinity,
              color: Colors.grey[300],
              child: Center(
                child: Icon(Icons.image, size: 50, color: Colors.grey[600]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.destination,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (trip.isTransformative)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Experiencia Transformadora',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.purple[800],
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${trip.price}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text('${trip.rating}'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
