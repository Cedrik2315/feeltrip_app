// home_screen.dart
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uni_links/uni_links.dart' as uni_links;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/home_content.dart';
import '../constants/strings.dart';
import '../controllers/auth_controller.dart';
import '../controllers/experience_controller.dart';
import '../controllers/home_controller.dart';
import '../models/experience_model.dart';
import '../models/trip_model.dart';
import '../services/emotion_service.dart';
import '../services/vision_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _carouselIndex = 0;
  List<Trip> _featuredTrips = [];
  bool _isLoadingTrips = true;
  String? _errorMessage;
  final TextEditingController _transformSearchController =
      TextEditingController();
  StreamSubscription? _sub;
  DateTimeRange? _travelDates;
  int _travelers = 2;
  final _imagePicker = ImagePicker();
  late final VisionService _visionService;

  late final HomeController _homeController;

  @override
  void initState() {
    super.initState();
    _homeController = context.read<HomeController>();
    _visionService = VisionService();
    _loadFeaturedTrips();
    _initDeepLinkListener();
  }

  @override
  void dispose() {
    _transformSearchController.dispose();
    super.dispose();
    _sub?.cancel();
  }

  Future<void> _pickDates() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
      initialDateRange: _travelDates,
    );
    if (picked == null || !mounted) return;
    setState(() => _travelDates = picked);
  }

  Future<void> _pickTravelers() async {
    int local = _travelers;
    final picked = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cantidad de viajeros'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed:
                    local > 1 ? () => setDialogState(() => local--) : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text('$local',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(
                onPressed:
                    local < 12 ? () => setDialogState(() => local++) : null,
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, local),
              child: const Text('Aceptar')),
        ],
      ),
    );
    if (picked == null || !mounted) return;
    setState(() => _travelers = picked);
  }

  Future<void> _openAiDestinationChat() async {
    final raw = _transformSearchController.text.trim();
    if (raw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Escribe cómo te quieres sentir al viajar.')),
      );
      return;
    }

    final emotionService = context.read<EmotionService>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Asistente de destinos'),
        content: FutureBuilder(
          future: emotionService.analizarTexto(raw),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final result = snapshot.data;
            if (result == null) {
              return const Text(
                'No pude generar una sugerencia ahora. Intenta con más contexto emocional.',
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Destino sugerido: ${result.destino}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(result.explicacion),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  children: result.emociones
                      .map((e) => Chip(
                          label: Text(e), visualDensity: VisualDensity.compact))
                      .toList(),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamed(context, '/search');
            },
            child: const Text('Buscar viajes'),
          ),
        ],
      ),
    );
  }

  String get _dateButtonLabel {
    if (_travelDates == null) return AppStrings.homeDates;
    final f = DateFormat('dd/MM');
    return '${f.format(_travelDates!.start)} - ${f.format(_travelDates!.end)}';
  }

  Future<void> _initDeepLinkListener() async {
    _sub = uni_links.uriLinkStream.listen((Uri? uri) {
      if (!mounted) return;
      if (uri != null && uri.scheme == 'feeltrip') {
        if (uri.host == 'pago-exitoso' || uri.host == 'success') {
          _celebrarPagoExitoso();
        } else if (uri.host == 'pago-fallido' || uri.host == 'failure') {
          Get.snackbar(
            'Pago Fallido',
            'Tu pago no pudo ser procesado. Por favor, inténtalo de nuevo.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        } else if (uri.host == 'pago-pendiente' || uri.host == 'pending') {
          Get.snackbar(
            'Pago Pendiente',
            'Tu pago está siendo procesado. Te avisaremos cuando se complete.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }
      }
    }, onError: (err) {
      if (!mounted) return;
      debugPrint("Error en Deep Link: $err");
    });
  }

  void _celebrarPagoExitoso() {
    final userId = Get.find<AuthController>().user?.uid;
    if (userId == null) {
      debugPrint("Error: Usuario no autenticado para celebrar el pago.");
      return;
    }

    Get.snackbar(
      '¡Pago Exitoso!',
      '¡Gracias! Ahora eres un Mecenas de Rutas y ganaste 500 XP.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    FirebaseFirestore.instance.collection('users').doc(userId).update({
      'isPremium': true,
      'totalXP': FieldValue.increment(500),
    });
  }

  Future<void> _escanearMundo(BuildContext context) async {
    // 1. Pick image from camera
    final XFile? imageFile = await _imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024, // Reduce image size for faster upload
      imageQuality: 70,
    );

    if (imageFile == null || !context.mounted) return;

    // 2. Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text("Descifrando el asombro..."),
          ],
        ),
      ),
    );

    // 3. Call AI service
    final poeticMessage =
        await _visionService.getPoeticMessageFromImage(File(imageFile.path));

    if (!context.mounted) return;
    Navigator.of(context).pop(); // Close loading dialog

    // 4. Show result dialog
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.amber),
            SizedBox(width: 10),
            Text("Voz del Viaje"),
          ],
        ),
        content: Text(
          poeticMessage ?? "No se pudo obtener una respuesta.",
          style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }

  String get _travelersButtonLabel => '$_travelers viajeros';

  Future<void> _loadFeaturedTrips() async {
    // Si ya está cargando o montado, actualizamos estado local
    if (mounted) setState(() => _isLoadingTrips = true);

    try {
      final result = await _homeController.loadFeaturedTrips();
      final trips = result.getOrElse(<Trip>[]);
      // Verificación crítica antes de usar setState después de un await
      if (!mounted) return;
      setState(() {
        _featuredTrips = trips;
        _isLoadingTrips = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingTrips = false;
        _errorMessage = 'No se pudieron cargar los viajes en este momento.';
      });
    }
  }

  void _retryLoadTrips() {
    _loadFeaturedTrips();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.homeTitle),
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            tooltip: 'Buscar',
            onPressed: () => Navigator.pushNamed(context, '/search'),
            icon: const Icon(Icons.search),
          ),
          IconButton(
            tooltip: 'Carrito',
            onPressed: () => Navigator.pushNamed(context, '/cart'),
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
          IconButton(
            tooltip: 'Reservas',
            onPressed: () => Navigator.pushNamed(context, '/bookings'),
            icon: const Icon(Icons.calendar_today_outlined),
          ),
          IconButton(
            tooltip: 'Perfil',
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _escanearMundo(context),
        label: const Text("ESCANEAR ASOMBRO"),
        icon: const Icon(Icons.auto_awesome),
        backgroundColor: Colors.amber,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Banner - Experiencias Vivenciales
            Container(
              color: Colors.deepPurple,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AppStrings.homeHeroTitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    AppStrings.homeHeroSubtitle,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _transformSearchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _openAiDestinationChat(),
                    decoration: InputDecoration(
                      hintText: 'Busca un destino transformador',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.location_on),
                      suffixIcon: IconButton(
                        tooltip: 'Consultar IA',
                        onPressed: _openAiDestinationChat,
                        icon: const Icon(Icons.auto_awesome),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _pickDates,
                          icon: const Icon(Icons.calendar_today),
                          label: Text(_dateButtonLabel),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.deepPurple,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _pickTravelers,
                          icon: const Icon(Icons.people),
                          label: Text(_travelersButtonLabel),
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
            const SizedBox(height: 24),

            // CTA: Descubre tu tipo de viajero
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
                      AppStrings.homeQuizTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      AppStrings.homeQuizSubtitle,
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
                        onPressed: () => Navigator.pushNamed(context, '/quiz'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.deepPurple,
                        ),
                        child: const Text(AppStrings.homeStartQuiz),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Traveler Archetypes
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AppStrings.homeExperienceTypes,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: homeArchetypes
                          .map(
                            (item) => _buildArchetypeCard(
                              item.emoji,
                              item.title,
                              item.description,
                              item.color,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Featured Transformative Trips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AppStrings.homeFeaturedTrips,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_isLoadingTrips)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_errorMessage != null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(Icons.error_outline,
                                size: 48, color: Colors.red[300]),
                            const SizedBox(height: 8),
                            Text(
                              'Error al cargar los viajes',
                              style: TextStyle(color: Colors.red[700]),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _retryLoadTrips,
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (_featuredTrips.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('No hay viajes disponibles'),
                      ),
                    )
                  else
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

            // Historias de Viajeros Transformados
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        AppStrings.homeStories,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/stories'),
                        child: const Text(
                          AppStrings.homeViewAll,
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
                  Obx(
                    () {
                      final controller = Get.find<ExperienceController>();
                      if (controller.stories.isEmpty) {
                        return const SizedBox(); // O un loading/empty state
                      }
                      return Column(
                        children: controller.stories
                            .take(2)
                            .map((story) => _buildStoryPreviewCard(story))
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick Access Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AppStrings.homeMyExperience,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      for (int i = 0; i < homeQuickAccessItems.length; i++) ...[
                        if (i > 0) const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickAccessCard(
                            homeQuickAccessItems[i].emoji,
                            homeQuickAccessItems[i].title,
                            homeQuickAccessItems[i].subtitle,
                            () {
                              Navigator.pushNamed(
                                  context, homeQuickAccessItems[i].route);
                            },
                          ),
                        ),
                      ],
                    ],
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
      String emoji, String title, String description, Color color) {
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
        mainAxisAlignment: MainAxisAlignment.start,
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
                  child: Text(
                    story.author.isNotEmpty
                        ? story.author[0].toUpperCase()
                        : '?',
                  ),
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
      String emoji, String title, String subtitle, VoidCallback onTap) {
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
  final Trip trip;

  const TripCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, '/trip-details', arguments: trip.id),
      child: Card(
        margin: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            trip.images.isNotEmpty
                ? ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: trip.images.first,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 150,
                        color: Colors.grey[300],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 150,
                        color: Colors.grey[300],
                        child: Icon(Icons.image,
                            size: 50, color: Colors.grey[600]),
                      ),
                    ),
                  )
                : Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: Center(
                      child:
                          Icon(Icons.image, size: 50, color: Colors.grey[600]),
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
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.purple[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        AppStrings.homeTransformativeExperience,
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
