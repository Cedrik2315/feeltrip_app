import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/agency_model.dart';
import '../services/agency_service.dart';
import '../services/auth_service.dart';

class AgencyProfileScreen extends StatefulWidget {
  final String agencyId;

  const AgencyProfileScreen({super.key, required this.agencyId});

  @override
  State<AgencyProfileScreen> createState() => _AgencyProfileScreenState();
}

class _AgencyProfileScreenState extends State<AgencyProfileScreen> {
  final AgencyService _agencyService = AgencyService();
  final AuthService _authService = AuthService();

  bool _isFollowing = false;
  bool _isLoadingFollow = true;
  late Future<TravelAgency?> _agencyFuture;

  static const _appBarGradient = LinearGradient(
    colors: [Colors.deepPurple, Color(0xFF7B1FA2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const _followGradient = LinearGradient(
    colors: [Colors.deepPurple, Color(0xFF7B1FA2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const _specialtyPalette = <Color>[
    Color(0xFF7C4DFF), // Deep purple accent
    Color(0xFF00BFA5), // Teal accent
    Color(0xFFFF5252), // Red accent
    Color(0xFFFFAB40), // Orange accent
    Color(0xFF40C4FF), // Light blue accent
    Color(0xFF69F0AE), // Green accent
    Color(0xFFFF4081), // Pink accent
  ];

  @override
  void initState() {
    super.initState();
    _agencyFuture = _agencyService.getAgencyById(widget.agencyId);
    _checkFollowStatus();
  }

  Future<void> _checkFollowStatus() async {
    final user = _authService.user;
    if (user != null) {
      final isFollowing = await _agencyService.isFollowingAgency(
        userId: user.uid,
        agencyId: widget.agencyId,
      );
      if (mounted) {
        setState(() {
          _isFollowing = isFollowing;
          _isLoadingFollow = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoadingFollow = false;
        });
      }
    }
  }

  Future<void> _toggleFollow() async {
    final user = _authService.user;
    if (user == null) {
      // Usuario no logueado - mostrar mensaje o redirigir a login
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Inicia sesión para seguir a esta agencia'),
            action: SnackBarAction(
              label: 'Login',
              onPressed: () => Navigator.pushNamed(context, '/login'),
            ),
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoadingFollow = true;
    });

    try {
      if (_isFollowing) {
        await _agencyService.unfollowAgencyWithUser(
          userId: user.uid,
          agencyId: widget.agencyId,
        );
      } else {
        await _agencyService.followAgencyWithUser(
          userId: user.uid,
          agencyId: widget.agencyId,
        );
      }

      // Recargar datos de la agencia para actualizar el contador de seguidores
      _agencyFuture = _agencyService.getAgencyById(widget.agencyId);

      setState(() {
        _isFollowing = !_isFollowing;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingFollow = false;
        });
      }
    }
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      elevation: 1.5,
      shadowColor: Colors.black.withValues(alpha: 0.10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.deepPurple.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.deepPurple, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
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

  Widget _contactButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  Widget _specialtyChip(String specialty) {
    final idx = specialty.hashCode.abs() % _specialtyPalette.length;
    final color = _specialtyPalette[idx];
    return Chip(
      label: Text(
        specialty,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
      backgroundColor: color.withValues(alpha: 0.16),
      side: BorderSide(color: color.withValues(alpha: 0.35)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildHeader(TravelAgency agency) {
    final ImageProvider headerImage = agency.logo.isNotEmpty
        ? NetworkImage(agency.logo) as ImageProvider<Object>
        : const AssetImage('assets/images/tromso_aurora.png');

    return SizedBox(
      height: 250,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image(
            image: headerImage,
            fit: BoxFit.cover,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x33000000),
                  Color(0xCC000000),
                ],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: agency.logo.isNotEmpty
                              ? NetworkImage(agency.logo)
                              : null,
                          backgroundColor: Colors.white,
                          child: agency.logo.isEmpty
                              ? const Icon(Icons.business,
                                  size: 44, color: Colors.deepPurple)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              agency.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (agency.verified)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.90),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.verified,
                                        color: Colors.white, size: 18),
                                    SizedBox(width: 6),
                                    Text(
                                      'Verificada',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowButton() {
    if (_isLoadingFollow) {
      return const ElevatedButton(
        onPressed: null,
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_isFollowing) {
      return ElevatedButton.icon(
        onPressed: _toggleFollow,
        icon: const Icon(Icons.check),
        label: const Text('Siguiendo'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: _followGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D7E57C2),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _toggleFollow,
          borderRadius: BorderRadius.circular(30),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Center(
              child: Text(
                'Seguir',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Perfil de Agencia'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        flexibleSpace: const DecoratedBox(
          decoration: BoxDecoration(gradient: _appBarGradient),
        ),
      ),
      body: FutureBuilder<TravelAgency?>(
        future: _agencyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Agencia no encontrada'));
          }

          final agency = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(agency),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _statCard(
                              icon: Icons.star,
                              label: 'Rating',
                              value:
                                  '${agency.rating.toStringAsFixed(1)} (${agency.reviewCount} reseñas)',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _statCard(
                              icon: Icons.people_outline,
                              label: 'Seguidores',
                              value: agency.followers.toString(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _statCard(
                              icon: Icons.location_on_outlined,
                              label: 'Ciudad',
                              value: agency.city,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Sobre nosotros',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          agency.description,
                          style: const TextStyle(height: 1.4),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Especialidades',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children:
                            agency.specialties.map(_specialtyChip).toList(),
                      ),
                      const SizedBox(height: 22),
                      if (agency.phoneNumber.isNotEmpty)
                        _contactButton(
                          icon: Icons.phone,
                          label: 'Llamar',
                          color: Colors.green,
                          onPressed: () =>
                              _launchUrl('tel:${agency.phoneNumber}'),
                        ),
                      if (agency.phoneNumber.isNotEmpty)
                        const SizedBox(height: 10),
                      if (agency.email.isNotEmpty)
                        _contactButton(
                          icon: Icons.email,
                          label: 'Email',
                          color: Colors.blue,
                          onPressed: () => _launchUrl('mailto:${agency.email}'),
                        ),
                      if (agency.email.isNotEmpty) const SizedBox(height: 10),
                      if (agency.website.isNotEmpty)
                        _contactButton(
                          icon: Icons.language,
                          label: 'Web',
                          color: Colors.orange,
                          onPressed: () =>
                              _launchUrl('https://${agency.website}'),
                        ),
                      const SizedBox(height: 16),
                      _buildFollowButton(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
