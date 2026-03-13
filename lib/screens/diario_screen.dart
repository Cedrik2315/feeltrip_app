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
        backgroundColor: const Color(0xFF00838F),
        icon: const Icon(Icons.auto_awesome, color: Colors.white),
        label: const Text("NUEVO MOMENTO", style: TextStyle(color: Colors.white)),
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
            backgroundColor: const Color(0xFF00838F),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'MI BITÁCORA',
                style: TextStyle(
                  fontFamily: 'Serif',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF009688), Color(0xFF00796B)],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: const Color(0xFFE0F2F1),
              padding: const EdgeInsets.all(16),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '3 entradas este mes',
                    style: TextStyle(
                      color: Color(0xFF00796B),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
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
                      Icon(Icons.book_outlined,
                          size: 96, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      const Text(
                        'Tu diario está vacío',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '¡Empieza a registrar tus momentos!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Get.toNamed('/smart-camera'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00838F),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'COMENZAR AHORA',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // IMAGEN A LA IZQUIERTA
          if (entry.imageUrl.isNotEmpty)
            Container(
              width: 80,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(entry.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              width: 80,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                color: Colors.grey[300],
              ),
              child: const Icon(Icons.image_not_supported_outlined,
                  color: Colors.grey, size: 32),
            ),

          // CONTENIDO
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CHIP DE EMOCIÓN
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getEmotionColor(entry.emotions.first),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getEmotionIcon(entry.emotions.first),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // BOTÓN COMPARTIR RÁPIDO
                      IconButton(
                        icon: const Icon(Icons.share_outlined,
                            color: Color(0xFF00838F)),
                        onPressed: () async {
                          await SharingService.shareDiaryEntry(
                            title: entry.title,
                            content: entry.content,
                          );
                        },
                      ),
                    ],
                  ),

                  // FECHA
                  Text(
                    _formatDate(entry.createdAt),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  // TÍTULO
                  Text(
                    entry.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // PREVIEW DEL CONTENIDO
                  const SizedBox(height: 4),
                  Text(
                    entry.content,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Hoy';
    } else if (difference == 1) {
      return 'Ayer';
    } else if (difference < 7) {
      return 'Hace $difference días';
    } else {
      return DateFormat('dd MMMM, yyyy', 'es').format(date);
    }
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion) {
      case 'Alegría':
        return const Color(0xFFFFEB3B); // Amarillo
      case 'Tristeza':
        return const Color(0xFF64B5F6); // Azul
      case 'Enojo':
        return const Color(0xFFF44336); // Rojo
      case 'Paz':
        return const Color(0xFF4CAF50); // Verde
      default:
        return const Color(0xFF9E9E9E); // Gris
    }
  }

  String _getEmotionIcon(String emotion) {
    switch (emotion) {
      case 'Alegría':
        return '😊';
      case 'Tristeza':
        return '😢';
      case 'Enojo':
        return '😤';
      case 'Paz':
        return '😌';
      default:
        return '🙂';
    }
  }
}