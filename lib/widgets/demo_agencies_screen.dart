import 'package:flutter/material.dart';
import '../models/travel_agency_model.dart';
import '../widgets/ai_proposal_card.dart';

class DemoAgenciesScreen extends StatelessWidget {
  const DemoAgenciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final demoAgencies = [
      TravelAgency(
        id: '1',
        name: 'Bali Yoga Retreats',
        description: 'Retiros de yoga transformacionales en Ubud',
        logo: '',
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
        socialMedia: ['instagram.com/baliyoga', 'facebook.com/baliyoga'],
        createdAt: DateTime.now(),
      ),
      TravelAgency(
        id: '2',
        name: 'Toscana Adventures',
        description: 'Experiencias auténticas en el corazón de Italia',
        logo: '',
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
        socialMedia: ['instagram.com/toscanaadv', 'facebook.com/toscanaadv'],
        createdAt: DateTime.now(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('AI Proposal Cards Demo')),
      body: ListView.builder(
        itemCount: demoAgencies.length,
        itemBuilder: (context, index) {
          final agency = demoAgencies[index];
          return AiProposalCard(
            agency: agency,
            moodEmoji: '🧘',
            moodBadge: 'Wellness',
          );
        },
      ),
    );
  }
}
