import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../constants/strings.dart';
import '../controllers/auth_controller.dart';
import '../controllers/diary_controller.dart';
import '../controllers/experience_controller.dart';
import '../models/achievement_model.dart';
import '../services/admob_service.dart';
import '../services/emotion_service.dart';
import '../widgets/achievement_dialog.dart';
import '../widgets/quick_translator_sheet.dart';
import 'historial_screen.dart';
import 'login_screen.dart';

class DiarioScreen extends StatefulWidget {
  const DiarioScreen({super.key, this.enableAds = true});

  final bool enableAds;

  @override
  State<DiarioScreen> createState() => _DiarioScreenState();
}

class _DiarioScreenState extends State<DiarioScreen> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _bannerListo = false;
  int _guardadosExitosos = 0;
  bool _shareAsExperience = true;

  @override
  void initState() {
    super.initState();
    if (widget.enableAds) {
      _cargarBanner();
      _cargarInterstitial();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  Future<void> _cerrarSesion() async {
    await Get.find<AuthController>().signOut();
    // Use GetX for navigation to be consistent across the app.
    Get.offAll(() => const LoginScreen());
  }

  void _cargarBanner() {
    if (!AdMobService.isSupported) return;

    final banner = BannerAd(
      adUnitId: AdMobService.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
            _bannerListo = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (!mounted) return;
          setState(() => _bannerListo = false);
        },
      ),
    );

    banner.load();
  }

  void _cargarInterstitial() {
    if (!AdMobService.isSupported) return;

    InterstitialAd.load(
      adUnitId: AdMobService.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (_) => _interstitialAd = null,
      ),
    );
  }

  void _mostrarInterstitialSiCorresponde() {
    if (!AdMobService.isSupported) return;

    _guardadosExitosos++;
    if (_guardadosExitosos % 3 != 0) return;

    final ad = _interstitialAd;
    if (ad == null) {
      _cargarInterstitial();
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _cargarInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _interstitialAd = null;
        _cargarInterstitial();
      },
    );

    ad.show();
    _interstitialAd = null;
  }

  Future<void> _analizarEmociones() async {
    final controller = context.read<DiaryController>();
    final textoBusqueda = _controller.text.trim();
    if (textoBusqueda.isEmpty) return;

    try {
      await controller.analyzeText(textoBusqueda);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _guardarDiario() async {
    final controller = context.read<DiaryController>();
    final storyText = _controller.text.trim();
    final snapshotEmotions = List<String>.from(controller.detectedEmotions);
    final snapshotResult = controller.aiResult;

    try {
      final unlockedAchievements = await controller.saveDiary(storyText);

      if (_shareAsExperience) {
        await _shareDiaryAsExperience(
          storyText: storyText,
          emotions: snapshotEmotions,
          aiResult: snapshotResult,
        );
      }

      if (!mounted) return;
      _controller.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.diarySaved),
          backgroundColor: Colors.deepPurple,
        ),
      );
      if (widget.enableAds) {
        _mostrarInterstitialSiCorresponde();
      }
      if (unlockedAchievements.isNotEmpty) {
        _showAchievementsDialog(unlockedAchievements);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    }
  }

  void _showAchievementsDialog(List<Achievement> achievements) {
    if (achievements.isEmpty) return;

    final achievement = achievements.first;

    HapticFeedback.vibrate();

    showDialog(
      context: context,
      builder: (context) => AchievementDialog(
        title: achievement.title,
        icon: _iconForAchievement(achievement.iconName),
      ),
    );
  }

  IconData _iconForAchievement(String iconName) {
    switch (iconName) {
      case 'explore':
        return Icons.explore;
      case 'auto_awesome':
        return Icons.auto_awesome;
      case 'camera_alt':
        return Icons.camera_alt;
      default:
        return Icons.emoji_events;
    }
  }

  Future<void> _shareDiaryAsExperience({
    required String storyText,
    required List<String> emotions,
    required AnalisisResultado? aiResult,
  }) async {
    final authController = Get.find<AuthController>();
    final user = authController.user;
    if (user == null || storyText.isEmpty) return;

    final author = (user.displayName?.trim().isNotEmpty == true)
        ? user.displayName!
        : (user.email?.split('@').first ?? 'Viajero FeelTrip');

    final highlights = emotions.isNotEmpty
        ? emotions
        : <String>['Transformación', 'Reflexión'];

    final destination = aiResult?.destino.trim();
    final title = destination != null && destination.isNotEmpty
        ? 'Diario IA: $destination'
        : 'Diario IA: Mi experiencia transformadora';

    // Usar ExperienceController para centralizar la lógica de creación de historias
    final experienceController = Get.find<ExperienceController>();
    await experienceController.createStory(
        author: author,
        title: title,
        story: storyText,
        emotionalHighlights: highlights,
        rating: 5.0);
  }

  Future<void> _tomarFotoParada(int index) async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      if (!mounted) return;
      context.read<DiaryController>().updateStopImage(index, photo.path);
    }
  }

  Future<void> _mostrarBuscadorDeLugares() async {
    String? lugarSeleccionado = await showDialog<String>(
      context: context,
      builder: (context) {
        String query = '';
        return AlertDialog(
          title: const Text('Añadir parada'),
          content: TextField(
            autofocus: true,
            decoration:
                const InputDecoration(hintText: 'Ej: Termas Geométricas'),
            onChanged: (val) => query = val,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, query),
              child: const Text('Buscar'),
            ),
          ],
        );
      },
    );

    if (lugarSeleccionado != null && lugarSeleccionado.isNotEmpty) {
      if (!mounted) return;
      try {
        await context
            .read<DiaryController>()
            .addStopFromSearch(lugarSeleccionado);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontró el lugar')),
        );
      }
    }
  }

  void _mostrarTraductor(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: const QuickTranslatorSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DiaryController>();
    final isLoading = controller.isLoading;
    final detectedEmotions = controller.detectedEmotions;
    final aiResult = controller.aiResult;
    final stops = controller.stops;
    final markers = controller.markers;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.diaryTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.translate),
            tooltip: 'Traductor Rápido',
            onPressed: () => _mostrarTraductor(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: AppStrings.logout,
            onPressed: _cerrarSesion,
          ),
          IconButton(
            icon: const Icon(Icons.history_edu_rounded),
            tooltip: AppStrings.viewHistory,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistorialScreen()),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.auto_awesome_outlined,
                size: 64, color: Colors.deepPurple),
            const SizedBox(height: 16),
            const Text(
              AppStrings.diaryPrompt,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: AppStrings.diaryHint,
                alignLabelWithHint: true,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: Colors.grey.withValues(alpha: 0.05),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : _analizarEmociones,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 2,
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      AppStrings.diaryAnalyze,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 32),
            if (detectedEmotions.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                AppStrings.diaryAnalysisTitle,
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: detectedEmotions
                    .map(
                      (e) => Chip(
                        label: Text(e,
                            style: const TextStyle(color: Colors.deepPurple)),
                        backgroundColor:
                            Colors.deepPurple.withValues(alpha: 0.1),
                        side: const BorderSide(
                            color: Colors.deepPurple, width: 0.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                    )
                    .toList(),
              ),
            ],
            if (aiResult != null) ...[
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 20),
              const Text(
                "Tu Alma Sugiere un Viaje...",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CachedNetworkImage(
                        imageUrl:
                            "https://source.unsplash.com/featured/800x450/?travel,${Uri.encodeComponent(aiResult.destino)}",
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.deepPurple[50],
                          child:
                              const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.landscape,
                              size: 50, color: Colors.grey),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    "?? ${aiResult.destino}",
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(20),
                                    border:
                                        Border.all(color: Colors.green[200]!),
                                  ),
                                  child: Text(
                                    "Match con tu Alma",
                                    style: TextStyle(
                                        color: Colors.green[800],
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              aiResult.explicacion,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[800],
                                height: 1.4,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            if (aiResult.lat != null && aiResult.lng != null)
                              Container(
                                height: 120,
                                width: double.infinity,
                                margin:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: GoogleMap(
                                    initialCameraPosition: CameraPosition(
                                      target: stops.isNotEmpty
                                          ? stops.last.posicion
                                          : LatLng(
                                              aiResult.lat!, aiResult.lng!),
                                      zoom: stops.length > 1 ? 10 : 12,
                                    ),
                                    liteModeEnabled: true,
                                    zoomControlsEnabled: false,
                                    mapToolbarEnabled: false,
                                    polylines: {
                                      if (stops.isNotEmpty)
                                        Polyline(
                                          polylineId: const PolylineId(
                                              "ruta_emocional"),
                                          points: stops
                                              .map((p) => p.posicion)
                                              .toList(),
                                          color: Colors.deepPurple,
                                          width: 5,
                                          geodesic: true,
                                        )
                                    },
                                    markers: markers,
                                  ),
                                ),
                              ),
                            if (aiResult.lat != null && aiResult.lng != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: TextButton.icon(
                                  onPressed: _mostrarBuscadorDeLugares,
                                  icon: const Icon(Icons.add_location_alt,
                                      color: Colors.deepPurple),
                                  label: const Text("Añadir parada a la ruta",
                                      style:
                                          TextStyle(color: Colors.deepPurple)),
                                ),
                              ),
                            if (stops.isNotEmpty) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Text("Tu Itinerario Emocional",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: stops.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    leading: CircleAvatar(
                                      child: Text('${index + 1}'),
                                    ),
                                    title: Text('Parada ${index + 1}'),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.camera_alt),
                                      onPressed: () => _tomarFotoParada(index),
                                    ),
                                  );
                                },
                              ),
                            ],
                            const Divider(height: 32),
                            SwitchListTile(
                              title: const Text(
                                  'Compartir como Experiencia Pública'),
                              subtitle: const Text(
                                  'Tu diario se publicará anónimamente para inspirar a otros.'),
                              value: _shareAsExperience,
                              onChanged: (value) {
                                setState(() {
                                  _shareAsExperience = value;
                                });
                              },
                              activeTrackColor: Colors.deepPurple,
                              secondary: const Icon(Icons.public),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _guardarDiario,
                              icon: const Icon(Icons.save_alt_rounded),
                              label: const Text('Guardar Diario'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 55),
                                backgroundColor: Colors.green.shade700,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: (_bannerListo && _bannerAd != null)
          ? SafeArea(
              child: Container(
                alignment: Alignment.center,
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            )
          : null,
    );
  }
}
