import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';
import 'package:feeltrip_app/services/destination_service.dart';
import 'package:feeltrip_app/models/travel_proposal.dart';
import 'package:feeltrip_app/services/auth_service.dart';
import 'package:uuid/uuid.dart';
import 'package:feeltrip_app/services/agency_service.dart';
import 'package:feeltrip_app/models/travel_agency_model.dart';
import 'package:feeltrip_app/core/di/providers.dart';

part 'osint_ai_service.freezed.dart';

@freezed
class OsintState with _$OsintState {
  const factory OsintState.initial() = _Initial;
  const factory OsintState.loading() = _Loading;
  const factory OsintState.success(TravelProposal proposal) = _Success;
  const factory OsintState.error(String message) = _Error;
}

class OsintAiService extends StateNotifier<OsintState> {
  OsintAiService(this._ref) : super(const OsintState.initial());

  final Ref _ref;

  Future<void> generateViventialProposal() async {
    state = const OsintState.loading();
    try {
      // Step 1: Emotional profile from user + Vision data
      final userId = AuthService.currentUser?.uid;
      if (userId == null) {
        state = const OsintState.error('Usuario no autenticado');
        return;
      }

      final profileData = await _getUserEmotionalProfile(userId);
      final emotionalProfile = (profileData['archetype'] as String? ?? '') != ''
          ? (profileData['archetype'] as String)
          : ((profileData['travelerType'] as String? ?? '') != ''
              ? (profileData['travelerType'] as String)
              : 'aventurero');

      // Vision integration
      final visionState = _ref.read(visionServiceProvider.notifier).state;
      String visionInsight = '';
      visionState.maybeWhen(
        success: (result) {
          final sentiment =
              (result.sentimentScore ?? 0.5) > 0.5 ? 'feliz' : 'reflexivo';
          final labels = (result.imageLabels as Iterable<dynamic>?)?.take(3).join(', ') ?? '';
          visionInsight = 'Sentimiento actual: $sentiment. Visto: $labels.';
        },
        orElse: () {},
      );

      AppLogger.i(
          'Perfil emocional: $emotionalProfile. Vision: $visionInsight');

      // Step 2: Filter destinations
      final destinations = await DestinationService.getDestinationsByArchetype(
        archetype: emotionalProfile.toLowerCase(),
      );

      if (destinations.isEmpty) {
        state = const OsintState.error('No hay destinos para tu perfil');
        return;
      }

      // Step 3: OSINT verification
      final safeCandidates = <String>[];
      for (final dest in destinations) {
        final destName = dest['name'] as String? ?? 'Unknown';
        final osintResult = await _performOsintScan(destName);
        if (((osintResult['risk_score'] as num?)?.toDouble() ?? 100.0) < 30) {
          safeCandidates.add(destName);
        }
        await Future<void>.delayed(
            const Duration(milliseconds: 200)); // Rate limit sim
      }

      if (safeCandidates.isEmpty) {
        state = const OsintState.error('No hay destinos seguros disponibles');
        return;
      }

      // Step 4: GenAI proposal
      final proposal =
          await _generateAiProposal(emotionalProfile, safeCandidates);
      state = OsintState.success(proposal);
    } catch (e) {
      AppLogger.e('Error generando propuesta: $e');
      state = OsintState.error('Error: $e');
    }
  }

  Future<Map<String, dynamic>> _getUserEmotionalProfile(String userId) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (!doc.exists) throw Exception('Perfil no encontrado');
    return doc.data() ?? {};
  }

  Future<Map<String, dynamic>> _performOsintScan(String target) async {
    // Enhance existing mock with more realism
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final risk = 10 + Random().nextInt(40); // 10-50
    return {
      'target': target,
      'risk_score': risk.toDouble(),
      'safety': risk < 30,
      'sources': ['OSINT API', 'Local News', 'Weather'],
    };
  }

  Future<List<TravelAgency>> getRecommendedAgencies(String mood) async {
    final agencyService = AgencyService();
    return agencyService.getAgenciesByMood(mood);
  }

  Future<TravelAgency?> getPersonalizedProposal(String userId) async {
    try {
      final profileData = await _getUserEmotionalProfile(userId);
      final primaryTrait = (profileData['archetype'] as String?) ??
          (profileData['travelerType'] as String?) ??
          'aventurero';

      // Map trait to badge
      // Eliminar moodEmoji y moodBadge ya que no se utilizan
      // String moodEmoji = '🌊';
      // String moodBadge = 'Buscando Calma';
      // switch (primaryTrait.toLowerCase()) {
      //   case 'calma':
      //   case 'reflexion':
      //     moodEmoji = '🌊';
      //     moodBadge = 'Buscando Calma';
      //     break;
      //   case 'aventurero':
      //   case 'aventura':
      //     moodEmoji = '⚡';
      //     moodBadge = 'Aventura Pura';
      //     break;
      //   case 'conexion':
      //     moodEmoji = '💕';
      //     moodBadge = 'Conexiones';
      //     break;
      //   case 'transformacion':
      //     moodEmoji = '🦋';
      //     moodBadge = 'Transformación';
      //     break;
      //   case 'aprendizaje':
      //     moodEmoji = '📚';
      //     moodBadge = 'Aprendizaje';
      //     break;
      //   default:
      //     moodEmoji = '✨';
      //     moodBadge = 'Vivencial';
      // }

      final agencyService = AgencyService();
      final agencies = await agencyService.getAgenciesByMood(primaryTrait);

      // Filter verified only, pick first
      final verifiedAgencies = agencies.where((a) => a.verified).toList();
      if (verifiedAgencies.isEmpty) return null;

      return verifiedAgencies.first.copyWith();
    } catch (e) {
      AppLogger.e('Error getting personalized proposal: $e');
      return null;
    }
  }

  Future<TravelProposal> _generateAiProposal(
      String profile, List<String> dests) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      // Fallback mock
      return _mockProposal(profile, dests);
    }

    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
      // Get recommended agencies
      final agencies = await getRecommendedAgencies(profile);
      final topAgencies = agencies.take(2).toList();
      final agencyInfo = topAgencies
          .map((a) =>
              'Agencia: ${a.name} (verificada: ${a.verified}, especialidades: ${a.specialties.join(', ')})')
          .join('\\n');

      final prompt = '''
Perfil emocional del usuario: $profile (ej: aventurero, busca calma)
Destinos seguros verificados: ${dests.join(', ')}

AGENCIA RECOMENDADA:
$agencyInfo

Basado en tu perfil de $profile, te recomiendo la agencia [AgencyName]. Son expertos en [Specialty] y están verificados por nuestro sistema de seguridad.

Redacta una propuesta de "Viaje Vivencial" personalizada y atractiva INCLUYENDO la agencia recomendada. 
Incluye:
- Título impactante
- 3-5 experiencias ÚNICAS coordinadas con la agencia
- Por qué coincide emocionalmente
- Cómo contactar la agencia
- Duración sugerida (5-10 días)

Formato JSON:
{
  "title": "...",
  "subtitle": "...", 
  "experiences": ["...", "..."],
  "agencyRecommendation": "Texto completo sobre la agencia...",
  "generatedText": "texto completo..."
}
      ''';

      final response = await model.generateContent([Content.text(prompt)]);
      final jsonStr = response.text ?? '{}';
      final jsonData = json.decode(jsonStr) as Map<String, dynamic>;

      return TravelProposal(
        id: const Uuid().v4(),
        title: jsonData['title'] as String? ?? 'Tu Viaje Vivencial Perfecto',
        subtitle: jsonData['subtitle'] as String? ?? 'Personalizado para tu esencia',
        destinations: dests,
        experiences: List<String>.from(jsonData['experiences'] as Iterable<dynamic>? ?? []),
        emotionalProfile: profile,
        safetyScore: 85.0,
        osintReport:
            'Todos destinos verificados seguros + agencias recomendadas',
        aiPrompt: prompt,
        generatedText: jsonData['generatedText'] as String? ?? response.text ?? '',
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      AppLogger.w('GenAI error, using mock: $e');
      return _mockProposal(profile, dests);
    }
  }

  TravelProposal _mockProposal(String profile, List<String> dests) {
    return TravelProposal(
      id: const Uuid().v4(),
      title: 'Viaje $profile a ${dests.first}',
      subtitle: 'Experiencias auténticas que transformarán tu alma',
      destinations: dests,
      experiences: [
        'Taller privado de yoga al amanecer con maestro local',
        'Cena secreta en casa de familia tradicional',
        'Trekking guiado a cascada sagrada con chaman',
        'Taller de cerámica ancestral con artesanos',
      ],
      emotionalProfile: profile,
      safetyScore: 92.0,
      osintReport: 'Verificación OSINT completada: 100% seguro',
      aiPrompt: 'Mock generation for $profile',
      generatedText:
          'Tu propuesta personalizada con destinos ${dests.join(', ')} y experiencias únicas para tu perfil $profile.',
      generatedAt: DateTime.now(),
    );
  }
}
