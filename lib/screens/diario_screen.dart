import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/experience_model.dart';
import '../controllers/experience_controller.dart';
import '../services/auth_service.dart';
import '../services/sharing_service.dart';

class DiarioScreen extends StatefulWidget {
  const DiarioScreen({super.key});

  @override
  State<DiarioScreen> createState() => _DiarioScreenState();
}

class _DiarioScreenState extends State<DiarioScreen> {
  late final ExperienceController _controller;

  @override
  void initState() {
    super.initState();
    // Get the ExperienceController from GetX
    _controller = Get.find<ExperienceController>();

    // Initialize with current user if not already done
    final authService = Get.find<AuthService>();
    if (authService.user != null && _controller.userId == null) {
      _controller.initialize(authService.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildDiaryListWithSlivers(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/smart-camera'),
        backgroundColor: const Color(0xFF1A237E),
        icon: const Icon(Icons.auto_awesome, color: Colors.white),
        label:
            const Text("NUEVO MOMENTO", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildDiaryListWithSlivers() {
    return Obx(() {
      if (_controller.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      return CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF1A237E),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'MI BITÁCORA',
                style: TextStyle(
                  fontFamily: 'Serif', // O una fuente elegante que tengas
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              background: Container(color: const Color(0xFF1A237E)),
            ),
          ),
          if (_controller.diaryEntries.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.note_alt_outlined,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text(
                        'Aún no tienes entradas',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Presiona "NUEVO MOMENTO" para capturar tus pensamientos y emociones.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return DiaryCard(entry: _controller.diaryEntries[index]);
                },
                childCount: _controller.diaryEntries.length,
              ),
            ),
        ],
      );
    });
  }
}

// TARJETA ESTILO "MAGAZINE"
class DiaryCard extends StatelessWidget {
  final DiaryEntry entry;
  const DiaryCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // IMAGEN DE FONDO
            CachedNetworkImage(
              imageUrl: entry.imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey[300]),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.image_not_supported_outlined),
            ),

            // GRADIENTE PARA LEER TEXTO
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),

            // CONTENIDO DEL TEXTO
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('dd MMMM, yyyy', 'es')
                        .format(entry.createdAt)
                        .toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12, letterSpacing: 1),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    entry.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.favorite,
                          color: Colors.redAccent, size: 18),
                      const SizedBox(width: 5),
                      Text(
                        entry.emotions.isNotEmpty
                            ? entry.emotions.first
                            : 'Sin emoción',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14),
                      ),
                      const Spacer(),
                      // BOTÓN COMPARTIR RÁPIDO
                      IconButton(
                        icon: const Icon(Icons.share_outlined,
                            color: Colors.white),
                        onPressed: () async {
                          await SharingService.shareDiaryEntry(
                            title: entry.title,
                            content: entry.content,
                          );
                        },
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
