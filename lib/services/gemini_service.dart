import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../core/logger/app_logger.dart';

/// Provider para acceder al servicio de Gemini.
final geminiServiceProvider = Provider<GeminiService>((ref) => GeminiService());

/// Servicio encargado de interactuar con Google Gemini para generar
/// propuestas de viajes vivenciales personalizadas basadas en el perfil emocional.
class GeminiService {
  GeminiService() {
    // Se inicializa el modelo. gemini-1.5-flash es ideal para este caso de uso
    // por su balance entre velocidad y razonamiento contextual.
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
    );
  }
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  late final GenerativeModel _model;

  /// Genera un hash único para el prompt para usar como ID de caché.
  String _generateCacheKey(String prompt) { // Método ya existente, pero lo incluyo para contexto
    final bytes = utf8.encode(prompt);
    return sha256.convert(bytes).toString();
  }

  /// Genera una propuesta de viaje basada en el arquetipo, emociones y reflexiones.
  Future<String> generateProposalFromProfile({
    required String archetype,
    required List<String> emotions,
    required String lastReflection,
  }) async {
    if (_apiKey.isEmpty) {
      AppLogger.e('GeminiService: GEMINI_API_KEY no encontrada en .env');
      return 'Configuración de IA no disponible en este momento.';
    }

    final prompt = """
    Actúa como un 'Experience Designer' y experto en psicología del viaje de FeelTrip.
    Crea una propuesta de viaje transformadora para un usuario con este perfil:

    - Arquetipo de viajero: $archetype
    - Emociones predominantes recientemente: ${emotions.join(', ')}
    - Última reflexión profunda en su diario: "$lastReflection"

    ESTRUCTURA DE LA PROPUESTA:
    1. Destino sugerido (Ciudad, País).
    2. El Porqué: Explica la conexión entre su estado emocional actual y el destino.
    3. Itinerario de Transformación: Propón 3 actividades clave, cada una con una "Tarea Emocional" específica (ej. qué observar, con quién hablar, sobre qué reflexionar).
    4. Ritual de Cierre: Una acción simbólica para realizar el último día que selle su aprendizaje.
    5. El "Despertar": Describe quién será esta persona al regresar.

    Responde de forma inspiradora y estructurada en español, usando emojis y un lenguaje que invite a la introspección.
    """;

    final cacheKey = _generateCacheKey(prompt);

    try {
            // 1. Intentar obtener del caché de Firestore
      final cacheDoc = await FirebaseFirestore.instance
          .collection('ai_responses_cache')
          .doc(cacheKey)
          .get();

      if (cacheDoc.exists) {
        AppLogger.i('GeminiService: Respuesta servida desde caché');
        final data = cacheDoc.data();
        if (data != null && data['response'] != null) {
          return data['response'].toString();
        }
      }

      // 2. Si no hay caché, llamar a Gemini
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text == null || response.text!.isEmpty) {
        return 'No pudimos visualizar tu próximo destino. Intenta reflexionar un poco más en tu diario.';
      }

      // 3. Guardar en caché para futuras consultas
      await FirebaseFirestore.instance
          .collection('ai_responses_cache')
          .doc(cacheKey)
          .set({
        'response': response.text,
        'createdAt': FieldValue.serverTimestamp(),
        'type': 'proposal',
      });

      AppLogger.i(
          'Propuesta Gemini generada exitosamente para arquetipo: $archetype');
      return response.text!.toString();
    } catch (e) {
      AppLogger.e('Error en GeminiService: $e');
      return 'Nuestras brújulas de IA están recalculando. Por favor, intenta de nuevo en unos momentos.';
    }
  }

  /// Genera un resumen de impacto tras completar un itinerario.
  Future<String> generateImpactSummary({
    required String itineraryContent,
    required List<String> diaryReflections,
  }) async {
    if (_apiKey.isEmpty) return 'Configuración de IA no disponible.';

    final prompt = """
    Actúa como un psicólogo existencialista y mentor de viajes de FeelTrip.
    El viajero ha completado el siguiente itinerario vivencial:
    "$itineraryContent"

    Durante el viaje, el usuario registró estas reflexiones en su diario:
    ${diaryReflections.map((r) => "- $r").join('\n')}

    BASÁNDOTE EN LO ANTERIOR, REDACTA UN "RESUMEN DE IMPACTO" QUE:
    1. Valide el crecimiento observado a través de sus palabras.
    2. Identifique el "Momento de Quiebre" o transformación más evidente.
    3. Proponga un mantra o propósito para integrar este aprendizaje en su vida cotidiana.

    Usa un tono profundo, poético y alentador. Máximo 200 palabras. Responde en español.
    """;

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ??
          'Tu viaje ha terminado, pero tu transformación apenas comienza.';
    } catch (e) {
      AppLogger.e('Error en generateImpactSummary: $e');
      return 'No pudimos procesar tu transformación digitalmente, pero lo que viviste es real.';
    }
  }

  /// Sugiere el próximo arquetipo de viajero basado en el historial de viajes completados.
  Future<String> suggestNextArchetype({
    required String currentArchetype,
    required List<String> impactSummaries,
  }) async {
    if (_apiKey.isEmpty) return 'Configuración de IA no disponible.';

    final prompt = """
    Actúa como un mentor de evolución personal y experto en psicología del viaje de FeelTrip.
    
    El usuario es actualmente un viajero de arquetipo: $currentArchetype.
    
    A lo largo de sus viajes, ha logrado las siguientes transformaciones (resúmenes de impacto):
    ${impactSummaries.map((s) => "- $s").join('\n')}
    
    Los 5 arquetipos de FeelTrip son:
    1. Conector (💕): Busca conexiones humanas y pertenencia.
    2. Transformado (🦋): Busca crecimiento personal y autoconocimiento.
    3. Aventurero (⚡): Busca adrenalina y superar límites.
    4. Contemplativo (🌅): Busca paz, silencio y belleza natural.
    5. Aprendiz (📚): Busca conocimiento y comprensión cultural.

    BASÁNDOTE EN SU EVOLUCIÓN:
    1. Identifica qué faceta de su personalidad se ha fortalecido.
    2. Sugiere cuál de los 5 arquetipos debería explorar ahora para equilibrar su crecimiento o profundizar en su camino.
    3. Justifica la elección con un tono inspirador y místico.

    Responde de forma breve y profunda en español. Usa emojis.
    """;

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? 'Sigue explorando tu interior en cada paso.';
    } catch (e) {
      AppLogger.e('Error en suggestNextArchetype: $e');
      return 'Tu camino es único; sigue escuchando a tu corazón.';
    }
  }
}
