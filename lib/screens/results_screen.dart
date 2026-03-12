import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../constants/strings.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key, required this.answers});

  final List<String> answers;

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isSharing = false;

  Map<String, dynamic> getRecommendedTrip() {
    final emotion = widget.answers[0];
    final season = widget.answers[3];

    if (emotion.contains('Lágrima') && season == 'Invierno') {
      return {
        'tripId': 'trip_1',
        'title': 'Auroras en Tromsø',
        'description':
            '5 días para llorar de emoción bajo las auroras boreales',
        'price': 'EUR 1,290',
        'emotion': 'Lágrima de emoción',
        'includes': ['Vuelos', 'Cabaña de cristal', 'Sauna', 'Guía local']
      };
    } else if (emotion.contains('Abrazo')) {
      return {
        'tripId': 'trip_2',
        'title': 'Cocina con Nonna',
        'description': '7 días de abrazos italianos y pasta casera',
        'price': 'EUR 980',
        'emotion': 'Abrazo cálido',
        'includes': [
          'Vuelos',
          'Casa rural',
          'Clases de cocina',
          'Mercado local'
        ]
      };
    } else if (emotion.contains('Boom')) {
      return {
        'tripId': 'trip_3',
        'title': 'Aventura en Queenstown',
        'description': '6 días de adrenalina pura en Nueva Zelanda',
        'price': 'EUR 1,450',
        'emotion': 'Explosión de adrenalina',
        'includes': ['Vuelos', 'Hotel 4*', 'Paracaídas', 'Bungee', 'Rafting']
      };
    }

    return {
      'tripId': 'trip_4',
      'title': 'Meditación en Bali',
      'description': '8 días de paz profunda y yoga',
      'price': 'EUR 850',
      'emotion': 'Paz interior',
      'includes': ['Vuelos', 'Retiro', 'Yoga diario', 'Meditación', 'Spa']
    };
  }

  String _backgroundAssetForTrip(String tripId) {
    switch (tripId) {
      case 'trip_1':
        return 'assets/images/tromso_aurora.png';
      case 'trip_2':
        return 'assets/images/tuscana_nonna.png';
      case 'trip_3':
        return 'assets/images/queenstown_adventure.png';
      case 'trip_4':
      default:
        return 'assets/images/bali_yoga.png';
    }
  }

  String _profileLabelForTrip(String tripId) {
    switch (tripId) {
      case 'trip_1':
        return 'EMOTIVO';
      case 'trip_2':
        return 'CÁLIDO';
      case 'trip_3':
        return 'AVENTURERO';
      case 'trip_4':
      default:
        return 'CONTEMPLATIVO';
    }
  }

  Widget _buildShareableCard(Map<String, dynamic> trip) {
    final tripId = trip['tripId'] as String? ?? 'trip_4';
    final profile = _profileLabelForTrip(tripId);
    final title = (trip['title'] as String?) ?? 'FeelTrip';
    final recommendation = (trip['description'] as String?) ?? '';
    final backgroundAsset = _backgroundAssetForTrip(tripId);

    return SizedBox(
      width: 1080,
      height: 1920,
      child: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backgroundAsset),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.85),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 150),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/images/logo.png', height: 120),
                  const SizedBox(height: 20),
                  Text(
                    'SOY UN VIAJERO $profile',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 54,
                      fontWeight: FontWeight.bold,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    recommendation,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 32,
                      fontStyle: FontStyle.italic,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 100),
                  const Text(
                    'Descubre tu viaje emocional en FeelTrip App',
                    style: TextStyle(color: Colors.white54, fontSize: 24),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'https://feeltrip.app',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareResult(Map<String, dynamic> trip) async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    try {
      final imageBytes = await _screenshotController.capture();
      if (imageBytes == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo generar la imagen.')),
        );
        return;
      }

      final directory = await getTemporaryDirectory();
      final file = File(
        '${directory.path}/feeltrip_emotional_profile_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(imageBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text:
            '¡Acabo de descubrir mi perfil emocional en FeelTrip! 🌍✈️ #FeelTrip #Travel\nhttps://feeltrip.app',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al compartir: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final trip = getRecommendedTrip();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.resultsTitle),
        backgroundColor: Colors.blue[800],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[800]!, Colors.blue[200]!],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Text(
                  AppStrings.resultsFound,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: AspectRatio(
                    aspectRatio: 9 / 16,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: Screenshot(
                        controller: _screenshotController,
                        child: _buildShareableCard(trip),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  trip['emotion'],
                  style: TextStyle(
                    color: Colors.yellow[100],
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        trip['title'],
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        trip['description'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.blue[600],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        AppStrings.resultsIncludes,
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ...(trip['includes'] as List<String>).map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                item,
                                style: TextStyle(color: Colors.blue[600]),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '${AppStrings.resultsPrice}: ${trip['price']}',
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue[800],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/trip-details',
                        arguments: trip['tripId'],
                      );
                    },
                    child: const Text(
                      AppStrings.resultsBook,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _isSharing ? null : () => _shareResult(trip),
                    icon: _isSharing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.share_outlined),
                    label: Text(
                      _isSharing
                          ? 'Generando...'
                          : 'Compartir mi perfil emocional',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    AppStrings.resultsRedoQuiz,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
