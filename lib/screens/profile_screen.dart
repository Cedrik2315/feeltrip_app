import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import 'creator_stats_screen.dart';
import 'instagram_stories_screen.dart';
import 'translator_screen.dart';
import 'ocr_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  bool _isFollowing = false;
  String? currentUid;
  final String targetUserId = 'demo_traveler';
  final UserService userService = UserService();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final user = AuthService.currentUser;
    currentUid = user?.uid;
    _nameController = TextEditingController(
        text: user?.displayName ??
            user?.email?.split('@')[0].replaceAll('.', ' ') ??
            'Usuario');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: '+34 612 345 678'); // Mock
    _loadFollowingStatus();
  }

  Future<void> _loadFollowingStatus() async {
    if (currentUid == null) return;
    final isFollowing =
        await userService.isFollowing(currentUid!, targetUserId);
    if (mounted) {
      setState(() {
        _isFollowing = isFollowing;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Avatar
            Container(
              color: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(vertical: 24),
              width: double.infinity,
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.deepPurple,
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AuthService.currentUser?.displayName ??
                        AuthService.currentUser?.email
                            ?.split('@')[0]
                            .replaceAll('.', ' ') ??
                        'Usuario',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Miembro desde 2024',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Información personal
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información Personal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Nombre',
                    _nameController,
                    Icons.person,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    'Email',
                    _emailController,
                    Icons.email,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    'Teléfono',
                    _phoneController,
                    Icons.phone,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Stats and Follow
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Seguidores / Siguiendo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Ver todo'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder<List<String>>(
                    stream: currentUid != null
                        ? userService.getFollowers(currentUid!)
                        : Stream.value([]),
                    builder: (context, followerSnapshot) {
                      final followers = followerSnapshot.data?.length ?? 0;
                      return StreamBuilder<List<String>>(
                        stream: currentUid != null
                            ? userService.getFollowing(currentUid!)
                            : Stream.value([]),
                        builder: (context, followingSnapshot) {
                          final following = followingSnapshot.data?.length ?? 0;
                          return Row(
                            children: [
                              Expanded(
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      children: [
                                        Text(
                                          followers.toString(),
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Text('Seguidores'),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      children: [
                                        Text(
                                          following.toString(),
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Text('Siguiendo'),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Follow button example
            Center(
              child: ElevatedButton.icon(
                onPressed: currentUid == null
                    ? null
                    : () async {
                        try {
                          if (_isFollowing) {
                            await userService.unfollowUser(
                                currentUid!, targetUserId);
                          } else {
                            await userService.followUser(
                                currentUid!, targetUserId);
                          }
                          if (!mounted) return;
                          setState(() {
                            _isFollowing = !_isFollowing;
                          });
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      },
                icon:
                    Icon(_isFollowing ? Icons.person_remove : Icons.person_add),
                label: Text(_isFollowing
                    ? 'Dejar de seguir Demo Traveler'
                    : 'Seguir Demo Traveler'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFollowing ? Colors.grey : Colors.green,
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
                    'Herramientas UGC',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.analytics),
                    title: const Text('Estadísticas del Creador'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => const CreatorStatsScreen(),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.view_module),
                    title: const Text('Stories tipo Instagram'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => const InstagramStoriesScreen(),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.translate),
                    title: const Text('Traductor de texto'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => const TranslatorScreen(),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('Lector OCR'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => const OCRScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Acciones
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showLogoutDialog();
                      },
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text(
                        'Cerrar Sesión',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Información legal
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Términos y Condiciones',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Política de Privacidad',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'FeelTrip v1.0.0',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
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

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      enabled: _isEditing,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: !_isEditing,
        fillColor: !_isEditing ? Colors.grey[100] : null,
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await AuthService.signOut();
              if (!mounted) return;
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sesión cerrada'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}
