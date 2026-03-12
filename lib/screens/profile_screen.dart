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
  // Controlador para capturar el widget como imagen
  final _screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();
    final user = authController.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          if (user != null)
            Screenshot(
              controller: _screenshotController,
              child: UserAccountsDrawerHeader(
                accountName: Text(
                  user.displayName ?? 'Viajero Anónimo',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                accountEmail: Text(user.email ?? 'Sin email'),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: user.photoURL != null
                      ? NetworkImage(user.photoURL!)
                      : null,
                  child: user.photoURL == null
                      ? Text(
                          user.displayName?.isNotEmpty == true
                              ? user.displayName![0].toUpperCase()
                              : 'V',
                          style: const TextStyle(
                              fontSize: 40.0, color: Colors.deepPurple),
                        )
                      : null,
                ),
                decoration: const BoxDecoration(
                  color: Colors.deepPurple,
                ),
              ),
            ),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Editar Perfil'),
            onTap: () {
              Get.snackbar('Próximamente',
                  'La edición de perfil estará disponible pronto.');
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart_outlined),
            title: const Text('Mis Estadísticas'),
            onTap: () => Navigator.pushNamed(context, '/stats'),
          ),
          ListTile(
            leading: const Icon(Icons.share_outlined, color: Colors.blue),
            title: const Text('Compartir Perfil'),
            onTap: () async {
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
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar Sesión',
                style: TextStyle(color: Colors.red)),
            onTap: () async {
              await authController.signOut();
              Get.offAll(() => const AuthGate());
            },
          ),
        ],
      ),
    );
  }
}
