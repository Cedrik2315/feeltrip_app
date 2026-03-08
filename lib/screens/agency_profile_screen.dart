import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/agency_model.dart';
import '../services/agency_service.dart';

class AgencyProfileScreen extends StatelessWidget {
  final String agencyId;
  final AgencyService _agencyService = AgencyService();

  AgencyProfileScreen({super.key, required this.agencyId});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil de Agencia')),
      body: FutureBuilder<TravelAgency?>(
        future: _agencyService.getAgencyById(agencyId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Agencia no encontrada'));
          }

          final agency = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: agency.logo.isNotEmpty
                        ? NetworkImage(agency.logo)
                        : null,
                    child: agency.logo.isEmpty
                        ? const Icon(Icons.business, size: 50)
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    agency.name,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                if (agency.verified)
                  const Center(
                    child: Chip(
                      label: Text('Verificada',
                          style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.blue,
                      avatar: Icon(Icons.check_circle,
                          color: Colors.white, size: 18),
                    ),
                  ),
                const SizedBox(height: 24),
                _buildInfoRow(
                    Icons.location_on, '${agency.city}, ${agency.country}'),
                _buildInfoRow(Icons.star,
                    '${agency.rating} (${agency.reviewCount} reseñas)'),
                _buildInfoRow(Icons.people, '${agency.followers} seguidores'),
                const SizedBox(height: 24),
                const Text('Sobre nosotros',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(agency.description),
                const SizedBox(height: 24),
                const Text('Especialidades',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: agency.specialties
                      .map((s) => Chip(label: Text(s)))
                      .toList(),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (agency.website.isNotEmpty)
                      ElevatedButton.icon(
                        onPressed: () =>
                            _launchUrl('https://${agency.website}'),
                        icon: const Icon(Icons.language),
                        label: const Text('Web'),
                      ),
                    if (agency.email.isNotEmpty)
                      ElevatedButton.icon(
                        onPressed: () => _launchUrl('mailto:${agency.email}'),
                        icon: const Icon(Icons.email),
                        label: const Text('Email'),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _agencyService.followAgency(agencyId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Seguir Agencia'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
