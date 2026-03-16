import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/agency_model.dart';
import '../services/sharing_service.dart';

class AgencyProfileScreen extends StatefulWidget {
  final String agencyId;

  const AgencyProfileScreen({
    super.key,
    required this.agencyId,
  });

  @override
  State<AgencyProfileScreen> createState() => _AgencyProfileScreenState();
}

class _AgencyProfileScreenState extends State<AgencyProfileScreen> {
  TravelAgency? _agency;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('agencies')
        .doc(widget.agencyId)
        .snapshots()
        .listen((doc) {
      if (doc.exists && mounted) {
        setState(() {
          _agency = TravelAgency.fromJson(doc.data()!);
        });
      }
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _agency == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_agency == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.business_outlined,
                size: 80,
                color: Colors.grey[300]!,
              ),
              const SizedBox(height: 16),
              const Text(
                'Agencia no encontrada',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF757575),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final agency = _agency!;
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue[400]!,
                    Colors.blue[800]!,
                  ],
                ),
              ),
              child: Center(
                child: Image.network(
                  agency.logo,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.business,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => _shareAgency(agency),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            agency.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${agency.city}, ${agency.country}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600]!,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (agency.verified)
                      const Tooltip(
                        message: 'Verificado',
                        child: Icon(
                          Icons.verified,
                          color: Colors.blue,
                          size: 24,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStat(
                      icon: Icons.star,
                      value: agency.rating.toStringAsFixed(1),
                      label: 'Rating',
                    ),
                    const SizedBox(width: 24),
                    _buildStat(
                      icon: Icons.people,
                      value: agency.followers.toString(),
                      label: 'Followers',
                    ),
                    const SizedBox(width: 24),
                    _buildStat(
                      icon: Icons.tour,
                      value: agency.experiences.length.toString(),
                      label: 'Experiencias',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Sobre nosotros',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  agency.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                if (agency.specialties.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Especialidades',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: agency.specialties
                            .map((specialty) => Chip(
                                  label: Text(specialty),
                                  backgroundColor: Colors.blue[100],
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                Text(
                  'Contacto',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),
                _buildContactButton(
                  icon: Icons.phone,
                  label: agency.phoneNumber,
                  onTap: () => _launchPhone(agency.phoneNumber),
                ),
                const SizedBox(height: 8),
                _buildContactButton(
                  icon: Icons.email,
                  label: agency.email,
                  onTap: () => _launchEmail(agency.email),
                ),
                const SizedBox(height: 8),
                _buildContactButton(
                  icon: Icons.language,
                  label: agency.website,
                  onTap: () => _launchWebsite(agency.website),
                ),
                const SizedBox(height: 24),
                if (agency.socialMedia.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Redes Sociales',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        children: agency.socialMedia
                            .map((social) => _buildSocialIcon(social))
                            .toList(),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.person_add),
                    label: const Text('Seguir'),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('¡Siguiendo a esta agencia!'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600]!,
          ),
        ),
      ],
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const Icon(Icons.arrow_forward, size: 16, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon(String social) {
    IconData icon;
    if (social.toLowerCase().contains('instagram')) {
      icon = Icons.camera_alt;
    } else if (social.toLowerCase().contains('facebook')) {
      icon = Icons.group;
    } else if (social.toLowerCase().contains('whatsapp')) {
      icon = Icons.chat;
    } else {
      icon = Icons.link;
    }

    return CircleAvatar(
      backgroundColor: Colors.blue[100],
      child: Icon(icon, color: Colors.blue),
    );
  }

  void _shareAgency(TravelAgency agency) {
    final deepLink = SharingService.generateAgencyDeepLink(agency.id);
    SharingService.shareGeneral(
      title: agency.name,
      description: agency.description,
      deepLink: deepLink,
    );
  }

  Future<void> _launchPhone(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchWebsite(String website) async {
    final uri =
        Uri.parse(website.startsWith('http') ? website : 'https://$website');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
