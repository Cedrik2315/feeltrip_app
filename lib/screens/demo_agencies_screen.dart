import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Importaciones corregidas a rutas de paquete
import 'package:feeltrip_app/models/travel_agency_model.dart';
import 'package:feeltrip_app/widgets/ai_proposal_card.dart';

class DemoAgenciesScreen extends StatelessWidget {
  const DemoAgenciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Definición de agencias de demostración
    final demoAgencies = [
      TravelAgency(
        id: '1',
        name: 'Bali Yoga Retreats',
        description: 'Retiros de yoga transformacionales en Ubud',
        logo: 'https://images.unsplash.com/photo-1545389336-cf09bd8c9b56?q=80&w=200&auto=format&fit=crop',
        phoneNumber: '+62 123 456 789',
        email: 'info@baliretreats.com',
        website: 'https://baliretreats.com',
        address: 'Jl. Monkey Forest, Ubud, Bali',
        city: 'Ubud',
        country: 'Indonesia',
        latitude: -8.4897,
        longitude: 115.2658,
        specialties: ['Yoga', 'Wellness', 'Spiritual'],
        rating: 4.8,
        reviewCount: 234,
        experiences: [
          'Yoga al amanecer',
          'Meditación en arrozales',
          'Taller de ayurveda'
        ],
        followers: 1250,
        verified: true,
        socialMedia: ['instagram.com/baliyoga'],
        createdAt: DateTime.now(),
      ),
      TravelAgency(
        id: '2',
        name: 'Toscana Adventures',
        description: 'Experiencias auténticas en el corazón de Italia',
        logo: 'https://images.unsplash.com/photo-1531233076261-16cabd0158d1?q=80&w=200&auto=format&fit=crop',
        phoneNumber: '+39 055 123 456',
        email: 'hello@toscanaadventures.it',
        website: 'https://toscanaadventures.it',
        address: 'Piazza del Duomo, Florence',
        city: 'Florence',
        country: 'Italy',
        latitude: 43.7696,
        longitude: 11.2558,
        specialties: ['Food', 'Culture', 'Wine'],
        rating: 4.9,
        reviewCount: 156,
        experiences: ['Cocina con Nonna', 'Cata de vinos', 'Tour en Vespa'],
        followers: 890,
        verified: true,
        socialMedia: ['instagram.com/toscanaadv'],
        createdAt: DateTime.now(),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC), // FeelTrip BoneWhite
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A), // FeelTrip Charcoal
        elevation: 0,
        title: Text(
          'PROPOSAL_LAB.sys',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 14, 
            color: const Color(0xFFF5F5DC),
            letterSpacing: 1
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFF5F5DC)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 24),
        itemCount: demoAgencies.length,
        separatorBuilder: (_, __) => const SizedBox(height: 20),
        itemBuilder: (context, index) {
          final agency = demoAgencies[index];
          
          // Lógica simple para variar el badge según la especialidad
          final bool isWellness = agency.specialties.contains('Wellness');
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AiProposalCard(
              agency: agency,
              moodEmoji: isWellness ? '🧘' : '🍷',
              moodBadge: isWellness ? 'Wellness' : 'Adventure',
            ),
          );
        },
      ),
    );
  }
}