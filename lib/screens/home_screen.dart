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

import 'package:app_links/app_links.dart';
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
import 'custom_map_screen.dart';

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
  DateTimeRange? _travelDates;
  int _travelers = 2;
  final _imagePicker = ImagePicker();
  late final VisionService _visionService;
  StreamSubscription<Uri>? _linkSubscription;

  late final HomeController _homeController;

  @override
  void initState() {
    super.initState();
    _homeController = context.read<HomeController>();
    _visionService = VisionService();
    _loadFeaturedTrips();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _transformSearchController.dispose();
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initDeepLinks() async {
    final appLinks = AppLinks();

    // Handle initial link when app is opened from a terminated state
    final initialUri = await appLinks.getInitialLink();
    if (initialUri != null) {
      if (!mounted) return;
      _handleDeepLink(initialUri);
    }

    // Listen for new links when app is already running
    _linkSubscription = appLinks.uriLinkStream.listen((uri) {
      if (!mounted) return;
      _handleDeepLink(uri);
    });
  }

  void _handleDeepLink(Uri uri) {
    debugPrint('Deep link received: $uri');
    if (uri.scheme == 'feeltrip' && uri.host == 'pago-exitoso') {
      _celebrarPagoExitoso();
    }
    // You can also handle other hosts like 'pago-fallido' here.
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
              Text(
                '$local',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, local),
            child: const Text('Aceptar'),
          ),
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
          content: Text('Escribe cómo te quieres sentir al viajar.'),
        ),
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
                Text(
                  'Destino sugerido: ${result.destino}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(result.explicacion),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  children: result.emociones
                      .map(
                        (e) => Chip(
                          label: Text(e),
                          visualDensity: VisualDensity.compact,
                        ),
                      )
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
    final poeticMessage = await _visionService.getPoeticMessageFromImage(
      File(imageFile.path),
    );

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

  Widget _buildAppBarAction({
    required String tooltip,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.20),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          icon: Icon(icon),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logo.png', // Asegúrate de que esta ruta sea correcta
          height: 35, // Ajusta la altura según necesites
          fit: BoxFit.contain,
        ),
        elevation: 0,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        flexibleSpace: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.deepPurple,
                Colors.purple[700]!,
              ],
            ),
          ),
        ),
        actions: [
          _buildAppBarAction(
            tooltip: 'Buscar',
            icon: Icons.search,
            onPressed: () => Navigator.pushNamed(context, '/search'),
          ),
          _buildAppBarAction(
            tooltip: 'Carrito',
            icon: Icons.shopping_cart_outlined,
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
          _buildAppBarAction(
            tooltip: 'Reservas',
            icon: Icons.calendar_today_outlined,
            onPressed: () => Navigator.pushNamed(context, '/bookings'),
          ),
          _buildAppBarAction(
            tooltip: 'Perfil',
            icon: Icons.person_outline,
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
          const SizedBox(width: 8),
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
            SizedBox(
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage('assets/images/tromso_aurora.png'),
                          fit: BoxFit.cover,
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.deepPurple,
                            Colors.purple[900]!,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.40),
                            Colors.black.withValues(alpha: 0.55),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          AppStrings.homeHeroTitle,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          AppStrings.homeHeroSubtitle,
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _transformSearchController,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (_) => _openAiDestinationChat(),
                          decoration: InputDecoration(
                            hintText: 'Busca un destino transformador',
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.96),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
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
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.96),
                                  foregroundColor: Colors.deepPurple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
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
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.96),
                                  foregroundColor: Colors.deepPurple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          // Navegamos al quiz y esperamos un resultado (la personalidad).
                          final navigator = Navigator.of(context);
                          final personality =
                              await navigator.pushNamed('/quiz');

                          // Verificamos que el widget siga montado antes de usar el BuildContext.
                          if (!mounted) return;

                          // Si obtenemos una personalidad, navegamos a la pantalla del mapa.
                          if (personality is String) {
                            navigator.push(
                              MaterialPageRoute(
                                builder: (_) => CustomMapScreen(
                                    userPersonality: personality),
                              ),
                            );
                          }
                        },
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
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red[300],
                            ),
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
                  Obx(() {
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
                  }),
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
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                                context,
                                homeQuickAccessItems[i].route,
                              );
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
    String emoji,
    String title,
    String description,
    Color color,
  ) {
    return Container(
      width: 140,
      height: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.24),
            color.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  void _showStoryDetails(TravelerStory story) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(story.title),
        content: SingleChildScrollView(
          child: Text(story.story),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cerrar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pushNamed(context, '/comments', arguments: story.id);
            },
            child: const Text('Comentarios'),
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
            if (story.imageUrl.trim().isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: story.imageUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, _) => Container(
                    height: 160,
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, _, __) => Container(
                    height: 160,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.image_not_supported_outlined),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
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
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                      backgroundColor: Colors.purple[100],
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
                Text('${story.likes}', style: const TextStyle(fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _showStoryDetails(story),
                child: const Text('Ver más'),
              ),
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
    final accent = switch (title.trim().toLowerCase()) {
      'mi diario' => Colors.deepPurple,
      'mi impacto' => Colors.teal,
      'comunidad' => Colors.purple,
      _ => Colors.deepPurple,
    };

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                accent.withValues(alpha: 0.08),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                ),
              ],
            ),
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
    final formattedPrice = NumberFormat.currency(
      locale: 'es_CL',
      symbol: '\$',
      decimalDigits: 0,
    ).format(trip.price).replaceAll('\u00A0', '');

    return Card(
      margin: const EdgeInsets.all(8),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () =>
            Navigator.pushNamed(context, '/trip-details', arguments: trip.id),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                trip.images.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: trip.images.first,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 180,
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 180,
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                    : Container(
                        height: 180,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: Center(
                          child: Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                if (trip.isTransformative)
                  Positioned(
                    left: 12,
                    top: 12,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.purple[100],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('✨ ', style: TextStyle(fontSize: 12)),
                            Text(
                              AppStrings.homeTransformativeExperience,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.purple[900],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
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
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formattedPrice,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.amber[300],
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.black87,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${trip.rating}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
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
