import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../widgets/premium_banner.dart';
import '../widgets/achievement_grid.dart';
import '../controllers/auth_controller.dart';
import '../level_service.dart';
import '../xp_bar_widget.dart';
import '../widgets/achievement_dialog.dart';
import 'login_screen.dart';
import '../widgets/streak_badge.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  int? _previousLevel;

  @override
  Widget build(BuildContext context) {
    // Handle case where user is not logged in
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("No se ha iniciado sesión.")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text(
                    "Error al cargar el perfil: ${snapshot.error.toString()}"));
          }
          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return _buildProfileContent(context, 0, 0, 0, 0, false);
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final totalXP = data['totalXP'] as int? ?? 0;
          final diaryCount = data['diaryEntriesCount'] as int? ?? 0;
          final photoCount = data['photosCount'] as int? ?? 0;
          final currentStreak = data['currentStreak'] as int? ?? 0;
          final isPremium = data['isPremium'] as bool? ?? false;

          // Detectar subida de nivel
          final currentLevel = LevelService.calcularNivel(totalXP);
          if (_previousLevel != null && currentLevel > _previousLevel!) {
            // Disparar celebración después del renderizado
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showLevelUpDialog(currentLevel);
            });
          }
          // Actualizar referencia para la próxima comparación
          if (_previousLevel != currentLevel) {
            _previousLevel = currentLevel;
          }

          return _buildProfileContent(context, totalXP, diaryCount, photoCount,
              currentStreak, isPremium);
        },
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, int totalXP, int diaryCount,
      int photoCount, int currentStreak, bool isPremium) {
    final level = LevelService.calcularNivel(totalXP);
    final title = LevelService.obtenerTitulo(level);

    return SingleChildScrollView(
      child: Column(
        children: [
          // 1. ENCABEZADO CON PERFIL Y BARRA DE XP
          _buildHeader(context, totalXP, currentStreak, isPremium),

          // 2. BANNER PREMIUM O BARRA DE NIVEL ESTÁNDAR
          if (isPremium)
            PremiumBanner(nivel: level, titulo: title)
          else
            Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: XpBarWidget(totalXP: totalXP)),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. TARJETA DE ESTADÍSTICAS RÁPIDAS
                _buildQuickStats(diaryCount, photoCount, level),
                const SizedBox(height: 30),

                // 3. LA VITRINA DE LOGROS (El Widget que hicimos antes)
                const Text(
                  "Mi Legado de Viajero",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                AchievementGrid(isUserPremium: isPremium),

                const SizedBox(height: 30),

                // 4. BOTÓN DE CERRAR SESIÓN
                _buildLogoutButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, int totalXP, int currentStreak, bool isPremium) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF673AB7), Color(0xFF512DA8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(50)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            backgroundImage: NetworkImage(
                user?.photoURL ?? 'https://via.placeholder.com/150'),
          ),
          const SizedBox(height: 15),
          Text(
            user?.displayName ?? "Explorador Anónimo",
            style: const TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            user?.email ?? "",
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 10),
          // RACHA DE FUEGO
          StreakBadge(streak: currentStreak),
        ],
      ),
    );
  }

  Widget _buildQuickStats(int diaryCount, int photoCount, int level) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statItem("Viajes", diaryCount.toString()),
            _statItem("Fotos", photoCount.toString()),
            _statItem("Nivel", level.toString()),
          ],
        ),
      ),
    );
  }

  void _showLevelUpDialog(int newLevel) {
    HapticFeedback.vibrate();
    final title = LevelService.obtenerTitulo(newLevel);
    showDialog(
      context: context,
      builder: (_) => AchievementDialog(
        title: "¡Nivel $newLevel!",
        icon: Icons.keyboard_double_arrow_up,
        description: "¡Felicidades! Has ascendido a $title",
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: () async {
          await Get.find<AuthController>().signOut();
          if (!context.mounted) return;
          Get.offAll(() => const LoginScreen());
        },
        icon: const Icon(Icons.logout, color: Colors.redAccent),
        label: const Text("Cerrar Sesión",
            style: TextStyle(color: Colors.redAccent)),
      ),
    );
  }
}
