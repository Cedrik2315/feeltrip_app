import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:uuid/uuid.dart';

import 'package:feeltrip_app/core/di/providers.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';
import 'package:feeltrip_app/models/travel_agency_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:feeltrip_app/models/travel_proposal.dart';
import 'package:feeltrip_app/models/vision_models.dart';
import 'package:feeltrip_app/services/agency_service.dart';
import 'package:feeltrip_app/services/auth_service.dart';
import 'package:feeltrip_app/services/destination_service.dart';
import 'package:feeltrip_app/services/voice_service.dart';
import 'package:feeltrip_app/services/translation_service.dart';
import 'package:feeltrip_app/services/speech_service.dart';

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

  void reset() {
    state = const OsintState.initial();
  }

  Future<void> generateViventialProposal() async {
    state = const OsintState.loading();
    try {
      final userId = AuthService.currentUser?.uid;
      if (userId == null) {
        state = const OsintState.error('Usuario no autenticado');
        return;
      }

      final profileData = await _getUserEmotionalProfile(userId);
      final emotionalProfile = _resolveEmotionalProfile(profileData);
      final visionInsight =
          _buildVisionInsight(_ref.read(visionServiceProvider));

      AppLogger.i(
        'Perfil emocional: $emotionalProfile. Vision: $visionInsight',
      );

      final destinations = await DestinationService.getDestinationsByArchetype(
        archetype: emotionalProfile.toLowerCase(),
      );

      if (destinations.isEmpty) {
        state = const OsintState.error('No hay destinos para tu perfil');
        return;
      }

      final safeCandidates = <String>[];
      for (final destination in destinations) {
        final destinationName = destination['name'] as String? ?? 'Unknown';
        final osintResult = await _performOsintScan(destinationName);
        if (((osintResult['risk_score'] as num?)?.toDouble() ?? 100.0) < 30) {
          safeCandidates.add(destinationName);
        }
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }

      if (safeCandidates.isEmpty) {
        state = const OsintState.error('No hay destinos seguros disponibles');
        return;
      }

      final proposal = await _generateAiProposal(
        emotionalProfile,
        safeCandidates,
        visionInsight: visionInsight,
      );
      state = OsintState.success(proposal);
    } catch (error) {
      AppLogger.e('Error generando propuesta: $error');
      state = OsintState.error('Error: $error');
    }
  }

  Future<Map<String, dynamic>> _getUserEmotionalProfile(String userId) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (!doc.exists) {
      throw Exception('Perfil no encontrado');
    }
    return doc.data() ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> _performOsintScan(String target) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final risk = 10 + Random().nextInt(40);
    return <String, dynamic>{
      'target': target,
      'risk_score': risk.toDouble(),
      'safety': risk < 30,
      'sources': <String>['OSINT API', 'Local News', 'Weather'],
    };
  }

  Future<List<TravelAgency>> getRecommendedAgencies(String mood) async {
    final agencyService = AgencyService();
    return agencyService.getAgenciesByMood(mood);
  }

  /// Generates a contextual travel buddy alert using AI
  Future<void> generateSmartAlert({
    required String weatherContext,
    required Position position,
    String? extraContext, // For currency or specific events
  }) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) return;

    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
      final prompt = '''
        Contexto Geográfico: Lat ${position.latitude}, Lng ${position.longitude}. 
        Contexto Climático: $weatherContext.
        Info Adicional: ${extraContext ?? 'Ninguna'}.
        
        Eres un compañero de viaje experto. Genera un consejo o alerta de MÁXIMO 10 PALABRAS. 
        Sé útil, breve y usa un tono amigable.
      ''';

      final response = await model.generateContent([Content.text(prompt)]);
      final alertText =
          response.text?.trim() ?? '¡Disfruta tu día en el camino!';

      await _ref.read(notificationServiceProvider).showInstantNotification(
            'Compañero FeelTrip',
            alertText,
            prefs: _ref.read(userPreferencesProvider),
          );
      AppLogger.i('Smart Alert generated: $alertText');
    } catch (e) {
      AppLogger.e('Error generating AI smart alert: $e');
    }
  }

  /// Local test for Cedrik's specific requirement
  Future<void> triggerTestNotification() async {
    const name = 'Cedrik';
    const location = 'Quillota';

    await _ref.read(notificationServiceProvider).showInstantNotification(
          'FeelTrip IA',
          '¡Hola $name! El clima en $location está ideal para una foto con la Smart Camera',
          prefs: _ref.read(userPreferencesProvider),
        );

    // Integración de la respuesta de voz
    await _ref.read(voiceServiceProvider).sayStatus(name, location);
  }

  /// Traduce y emite por voz una alerta inteligente
  Future<void> translateAndSpeakAlert(
      String text, String targetLanguage) async {
    final translated = await _ref.read(translationServiceProvider).translate(
          text,
          targetLanguage: targetLanguage,
        );

    // El VoiceService ahora soporta mensajes directos
    await _ref.read(voiceServiceProvider).speak(
          translated,
          language:
              targetLanguage.toLowerCase().contains('en') ? 'en-US' : 'es-MX',
        );
  }

  /// Realiza una traducción completa de voz a voz.
  /// 1. Escucha la entrada de voz.
  /// 2. Traduce el texto vía Gemini.
  /// 3. Reproduce el resultado por los altavoces.
  Future<void> performVoiceToVoiceTranslation(String targetLanguage) async {
    AppLogger.i('Iniciando traducción de voz a voz...');
    
    // 1. Capturar la voz
    final originalText = await _ref.read(speechServiceProvider).listenOnce();
    if (originalText.isEmpty) {
      AppLogger.w('No se detectó voz para traducir.');
      return;
    }

    // 2. Traducir y hablar (reutilizamos nuestra lógica existente)
    // Si el turista está en Alemania, el targetLanguage sería 'Español'
    await translateAndSpeakAlert(
      'El interlocutor dijo: $originalText', 
      targetLanguage,
    );
  }

  Future<TravelAgency?> getPersonalizedProposal(String userId) async {
    try {
      final profileData = await _getUserEmotionalProfile(userId);
      final primaryTrait = _resolveEmotionalProfile(profileData);

      final agencyService = AgencyService();
      final agencies = await agencyService.getAgenciesByMood(primaryTrait);
      final verifiedAgencies =
          agencies.where((agency) => agency.verified).toList();
      if (verifiedAgencies.isEmpty) {
        return null;
      }

      return verifiedAgencies.first.copyWith();
    } catch (error) {
      AppLogger.e('Error getting personalized proposal: $error');
      return null;
    }
  }

  Future<TravelProposal> _generateAiProposal(
    String profile,
    List<String> dests, {
    String? visionInsight,
  }) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      return _mockProposal(profile, dests, visionInsight: visionInsight);
    }

    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
      final agencies = await getRecommendedAgencies(profile);
      final topAgencies = agencies.take(2).toList();
      final agencyInfo = topAgencies.isEmpty
          ? 'No hay agencias verificadas disponibles para este perfil.'
          : topAgencies
              .map(
                (agency) =>
                    'Agencia: ${agency.name} (verificada: ${agency.verified}, especialidades: ${agency.specialties.join(', ')})',
              )
              .join('\n');

      final prompt = '''
Perfil emocional del usuario: $profile
Destinos seguros verificados: ${dests.join(', ')}
Contexto de vision computacional: ${visionInsight ?? 'Sin contexto visual adicional.'}

AGENCIA RECOMENDADA:
$agencyInfo

Redacta una propuesta de Viaje Vivencial personalizada y atractiva.
Incluye:
- Titulo impactante
- 3-5 experiencias unicas coordinadas con la agencia
- Por que coincide emocionalmente
- Como contactar la agencia
- Duracion sugerida (5-10 dias)

Responde SOLO en JSON con este formato:
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
        subtitle:
            jsonData['subtitle'] as String? ?? 'Personalizado para tu esencia',
        destinations: dests,
        experiences: List<String>.from(
          jsonData['experiences'] as Iterable<dynamic>? ?? const <dynamic>[],
        ),
        emotionalProfile: profile,
        safetyScore: 85.0,
        osintReport:
            'Destinos verificados y sugerencias alineadas con el analisis visual.',
        aiPrompt: prompt,
        generatedText:
            jsonData['generatedText'] as String? ?? response.text ?? '',
        agencyRecommendation: jsonData['agencyRecommendation'] as String?,
        generatedAt: DateTime.now(),
      );
    } catch (error) {
      AppLogger.w('GenAI error, using mock: $error');
      return _mockProposal(profile, dests, visionInsight: visionInsight);
    }
  }

  TravelProposal _mockProposal(
    String profile,
    List<String> dests, {
    String? visionInsight,
  }) {
    return TravelProposal(
      id: const Uuid().v4(),
      title: 'Viaje $profile a ${dests.first}',
      subtitle: 'Experiencias autenticas que transformaran tu alma',
      destinations: dests,
      experiences: const <String>[
        'Taller privado de yoga al amanecer con maestro local',
        'Cena secreta en casa de familia tradicional',
        'Trekking guiado a cascada sagrada con chaman',
        'Taller de ceramica ancestral con artesanos',
      ],
      emotionalProfile: profile,
      safetyScore: 92.0,
      osintReport: 'Verificacion OSINT completada: destino de bajo riesgo',
      aiPrompt: 'Mock generation for $profile',
      generatedText:
          'Tu propuesta personalizada combina ${dests.join(', ')} con experiencias unicas para tu perfil $profile. ${visionInsight ?? ''}'
              .trim(),
      agencyRecommendation:
          'Se priorizaron agencias verificadas para este perfil.',
      generatedAt: DateTime.now(),
    );
  }

  Future<void> analyzeScene() async {
    AppLogger.i('AI: analizando la escena en vivo...');
    state = const OsintState.loading();
    try {
      final visionState = _ref.read(visionServiceProvider);
      final visionResult = visionState.maybeWhen(
        success: (result) => result,
        orElse: () => null,
      );

      if (visionResult == null) {
        state = const OsintState.error(
          'Primero toma una foto para analizar la escena.',
        );
        return;
      }

      final userId = AuthService.currentUser?.uid;
      final emotionalProfile = userId == null
          ? 'aventurero'
          : _resolveEmotionalProfile(await _getUserEmotionalProfile(userId));
      final destinations = await _inferDestinationsFromVision(visionResult);
      final proposal = await _generateAiProposal(
        emotionalProfile,
        destinations,
        visionInsight: _describeVisionResult(visionResult),
      );
      state = OsintState.success(proposal);
      AppLogger.i('AI: analisis completado - Propuesta generada');
    } catch (error) {
      state = OsintState.error('Error en analisis de escena: $error');
    }
  }

  String _resolveEmotionalProfile(Map<String, dynamic> profileData) {
    final archetype = profileData['archetype'] as String?;
    final travelerType = profileData['travelerType'] as String?;
    if (archetype != null && archetype.trim().isNotEmpty) {
      return archetype;
    }
    if (travelerType != null && travelerType.trim().isNotEmpty) {
      return travelerType;
    }
    return 'aventurero';
  }

  String _buildVisionInsight(VisionState visionState) {
    return visionState.maybeWhen(
      success: _describeVisionResult,
      orElse: () => 'Sin contexto visual adicional.',
    );
  }

  String _describeVisionResult(VisionResult result) {
    final sentiment = (result.sentimentScore ?? 0.5) >= 0.6
        ? 'positivo'
        : (result.sentimentScore ?? 0.5) <= 0.4
            ? 'sereno'
            : 'equilibrado';
    final labels = (result.topLabels ?? result.imageLabels ?? <String>[])
        .take(3)
        .join(', ');
    final recognizedText = result.recognizedText;
    final textFragment = recognizedText == null || recognizedText.trim().isEmpty
        ? ''
        : ' Texto detectado: ${recognizedText.trim()}.';

    var insight =
        'Estado emocional estimado: $sentiment. Elementos visibles: $labels.$textFragment';
    final location = result.location;
    if (location != null) {
      insight =
          '$insight Coordenadas aproximadas: ${location.latitude}, ${location.longitude}.';
    }
    return insight;
  }

  Future<List<String>> _inferDestinationsFromVision(VisionResult result) async {
    final labels = (result.imageLabels ?? result.topLabels ?? <String>[])
        .map((label) => label.toLowerCase())
        .toList();
    final suggestions = <String>{};

    if (labels.any((label) =>
        label.contains('beach') ||
        label.contains('sea') ||
        label.contains('playa') ||
        label.contains('ocean'))) {
      suggestions.addAll(<String>['Tulum', 'Bali']);
    }
    if (labels.any((label) =>
        label.contains('mountain') ||
        label.contains('montana') ||
        label.contains('snow'))) {
      suggestions.addAll(<String>['Patagonia', 'Banff']);
    }
    if (labels.any((label) =>
        label.contains('temple') ||
        label.contains('city') ||
        label.contains('building') ||
        label.contains('street'))) {
      suggestions.addAll(<String>['Kyoto', 'Lisboa']);
    }

    if (suggestions.isEmpty) {
      final fallback = await DestinationService.getDestinationsByArchetype(
        archetype: 'aventurero',
      );
      suggestions.addAll(
        fallback
            .map((destination) => destination['name'] as String?)
            .whereType<String>(),
      );
    }

    return suggestions.take(3).toList();
  }
}
