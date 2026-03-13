import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../controllers/auth_controller.dart';
import '../widgets/social_share_sheet.dart';
import 'auth_gate.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _screenshotController = ScreenshotController();

  List<Map<String, dynamic>> get badges => [
        {'emoji': '🌍', 'name': 'Primer viaje', 'unlocked': true},
        {'emoji': '✈️', 'name': 'Nómada', 'unlocked': true},
        {'emoji': '📖', 'name': 'Diario activo', 'unlocked': false},
        {'emoji': '⭐', 'name': '5 estrellas', 'unlocked': true},
        {'emoji': '🏆', 'name': 'Experto XP', 'unlocked': false},
        {'emoji': '💎', 'name': 'Premium', 'unlocked': false},
      ];

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildImprovedListTile(
      IconData icon, String title, VoidCallback? onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.deepPurple, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();
    final user = authController.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Color(0xFF4A148C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          if (user != null)
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              height: 240,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepPurple, Color(0xFF4A148C)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Screenshot(
                controller: _screenshotController,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 46,
                            backgroundColor: Colors.transparent,
                            backgroundImage: user.photoURL != null
                                ? NetworkImage(user.photoURL!)
                                : null,
                            child: user.photoURL == null
                                ? const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        user.displayName ?? 'Viajero Anónimo',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email ?? 'Sin email',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatCard('Historias', '5'),
                          _buildStatCard('Entradas\\ndiario', '12'),
                          _buildStatCard('XP', '150'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mis Logros',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: badges.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final badge = badges[index];
                      final isUnlocked = badge['unlocked'] as bool;
                      return Container(
                        width: 85,
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: isUnlocked
                                    ? Colors.amber[200]
                                    : Colors.grey[300],
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isUnlocked
                                      ? Colors.amber[700]!
                                      : Colors.grey[500]!,
                                  width: 3,
                                ),
                              ),
                              child: Text(
                                badge['emoji'],
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Text(
                                badge['name'],
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isUnlocked
                                      ? Colors.black87
                                      : Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildImprovedListTile(Icons.currency_exchange, 'Convertidor de Monedas', () => Get.toNamed('/currency-converter')),
          _buildImprovedListTile(Icons.bar_chart_outlined, 'Mis Estadísticas',
              () => Navigator.pushNamed(context, '/stats')),
          _buildImprovedListTile(Icons.share_outlined, 'Compartir Perfil',
              () async {
            await showSocialShareSheet(
              context: context,
              title: 'Compartir perfil',
              actions: [
                SocialShareAction(
                  icon: Icons.image_outlined,
                  label: 'Compartir imagen',
                  onTap: () async {
                    final Uint8List? image =
                        await _screenshotController.capture();
                    if (image == null) return;

                    final directory = await getTemporaryDirectory();
                    final imagePath =
                        await File('${directory.path}/feeltrip_profile.png')
                            .writeAsBytes(image);

                    await Share.shareXFiles(
                      [XFile(imagePath.path)],
                      text:
                          '¡Este es mi perfil de viajero en FeelTrip! 🌍 Descubre el tuyo: https://feeltrip.app',
                    );
                  },
                ),
                SocialShareAction(
                  icon: Icons.link,
                  label: 'Compartir texto',
                  onTap: () async {
                    await Share.share(
                      '¡Este es mi perfil de viajero en FeelTrip! 🌍 Descubre el tuyo: https://feeltrip.app',
                      subject: 'Mi perfil en FeelTrip',
                    );
                  },
                ),
              ],
            );
          }),
          Container(
            margin: const EdgeInsets.only(top: 16, bottom: 16),
            height: 1,
            color: Colors.grey[300],
          ),
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.deepPurple, Color(0xFF4A148C)],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () {
                  Get.snackbar('Próximamente',
                      'La edición de perfil estará disponible pronto.');
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit, color: Colors.white, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Editar Perfil',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.red[500],
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () async {
                  final authController = Get.find<AuthController>();
                  await authController.signOut();
                  Get.offAll(() => const AuthGate());
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Colors.white, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Cerrar Sesión',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
