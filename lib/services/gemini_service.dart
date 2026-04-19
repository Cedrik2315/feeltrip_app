import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../core/logger/app_logger.dart';
import '../core/security/rate_limiter.dart';
import '../core/security/security_utils.dart';
import 'isar_service.dart';

/// Servicio encargado de interactuar con Google Gemini para generar
/// propuestas de viajes vivenciales personalizadas basadas en el perfil emocional.
class GeminiService {
  final String _apiKey;
  GeminiService({required String apiKey}) : _apiKey = apiKey;

  // Inicialización perezosa para evitar errores si la API Key aún no carga
  GenerativeModel? _modelInstance;
  GenerativeModel get _model {
    _modelInstance ??= GenerativeModel(
      model: 'gemini-1.5-flash-latest', // Cambiado para asegurar compatibilidad con v1beta
      apiKey: _apiKey,
    );
    return _modelInstance!;
  }

  final RateLimiter _rateLimiter =
      RateLimiter(maxRequests: 3, windowSeconds: 60);
  final IsarService _isarService = IsarService();

  String _generateCacheKey(String prompt) {
    final bytes = utf8.encode(prompt);
    return sha256.convert(bytes).toString();
  }

  Future<String?> _readLocalCache(String cacheKey) async {
    try {
      return await _isarService.getAiResponse(cacheKey);
    } catch (e) {
      AppLogger.w('GeminiService: local cache read skipped: $e');
      return null;
    }
  }

  Future<void> _writeLocalCache(String cacheKey, String responseText) async {
    try {
      await _isarService.putAiResponse(cacheKey, responseText);
    } catch (e) {
      AppLogger.w('GeminiService: local cache write skipped: $e');
    }
  }

  Future<String?> _readRemoteCache(String cacheKey) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      final cacheDoc = await FirebaseFirestore.instance
          .collection('ai_responses_cache')
          .doc(cacheKey)
          .get();

      if (!cacheDoc.exists) return null;
      final data = cacheDoc.data();
      final response = data?['response']?.toString();
      if (response != null && response.isNotEmpty) {
        AppLogger.i('GeminiService: remote cache hit');
      }
      return response;
    } on FirebaseException catch (e) {
      AppLogger.w(
          'GeminiService: remote cache read skipped [${e.code}] ${e.message}');
      return null;
    } catch (e) {
      AppLogger.w('GeminiService: remote cache read skipped: $e');
      return null;
    }
  }

  Future<void> _writeRemoteCache(String cacheKey, String responseText) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('ai_responses_cache')
          .doc(cacheKey)
          .set({
        'response': responseText,
        'createdAt': FieldValue.serverTimestamp(),
        'type': 'proposal',
        'userId': user.uid,
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      AppLogger.w(
          'GeminiService: remote cache write skipped [${e.code}] ${e.message}');
    } catch (e) {
      AppLogger.w('GeminiService: remote cache write skipped: $e');
    }
  }

  Future<String> generateProposalFromProfile({
    required String archetype,
    required List<String> emotions,
    required String lastReflection,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';

    if (_apiKey.isEmpty || _apiKey == 'tu_api_key_aqui') {
      AppLogger.e('GeminiService: API Key inválida o vacía. Revisa tu archivo .env');
      return 'Configuración de IA no disponible. Verifica la API Key en el dispositivo.';
    }

    if (!_rateLimiter.canRequest(userId)) {
      final waitMode = _rateLimiter.secondsToWait(userId);
      AppLogger.w(
        'GeminiService: Rate limit alcanzado para usuario $userId. Esperar $waitMode seg.',
      );
      return 'Has alcanzado el limite de consultas permitidas. Por favor, espera $waitMode segundos.';
    }

    final sArchetype = SecurityUtils.sanitizeInput(archetype);
    final sEmotions = emotions.map(SecurityUtils.sanitizeInput).toList();
    final sReflection =
        SecurityUtils.sanitizeInput(lastReflection, maxLength: 2000);

    final prompt = """
    Actua como un 'Experience Designer' y experto en psicologia del viaje de FeelTrip.
    Crea una propuesta de viaje transformadora para un usuario con este perfil:

    - Arquetipo de viajero: $sArchetype
    - Emociones predominantes recientemente: ${sEmotions.join(', ')}
    - Ultima reflexion profunda en su diario: \"$sReflection\"

    ESTRUCTURA DE LA PROPUESTA:
    1. Destino sugerido (Ciudad, Pais).
    2. Justificacion de Arquetipo: Explica por que, basandote en su diario, has determinado que este es el arquetipo que necesita hoy.
    3. El Porque del Destino: Explica la conexion entre su estado emocional actual y el destino elegido.
    4. Itinerario de Transformacion: Propon 3 actividades clave, cada una con una "Tarea Emocional" especifica.
    5. Ritual de Cierre: Una accion simbolica para realizar el ultimo dia que selle su aprendizaje.
    6. El "Despertar": Describe quien sera esta persona al regresar.

    Responde de forma inspiradora y estructurada en espanol, usando emojis y un lenguaje que invite a la introspeccion.
    """;

    final cacheKey = _generateCacheKey(prompt);

    try {
      final localCache = await _readLocalCache(cacheKey);
      if (localCache != null && localCache.isNotEmpty) {
        AppLogger.i('GeminiService: propuesta servida desde cache local');
        return localCache;
      }

      final remoteCache = await _readRemoteCache(cacheKey);
      if (remoteCache != null && remoteCache.isNotEmpty) {
        await _writeLocalCache(cacheKey, remoteCache);
        return remoteCache;
      }

      final response = await _model.generateContent([Content.text(prompt)])
          .timeout(const Duration(seconds: 20));
      final responseText = response.text;
      if (responseText == null || responseText.isEmpty) {
        return 'No pudimos visualizar tu proximo destino. Intenta reflexionar un poco mas en tu diario.';
      }

      await _writeLocalCache(cacheKey, responseText);
      unawaited(_writeRemoteCache(cacheKey, responseText));

      AppLogger.i(
          'Propuesta Gemini generada exitosamente para arquetipo: $archetype');
      return responseText;
    } on TimeoutException catch (e) {
      AppLogger.e('Timeout en GeminiService: $e');
      return 'El oráculo está tardando demasiado. Revisa tu conexión e intenta de nuevo.';
    } on GenerativeAIException catch (e) {
      AppLogger.e('Error específico de Gemini AI: $e');
      final msg = e.message.toLowerCase();
      if (msg.contains('not found') || msg.contains('supported')) {
        return 'CONFIGURACIÓN DE MODELO: El modelo seleccionado no responde. Revisa si "Generative Language API" está activa en Google Cloud.';
      } else if (msg.contains('location') || msg.contains('region')) {
        return 'RESTRICCIÓN GEOGRÁFICA: Gemini no está disponible en tu ubicación actual. Intenta usar una conexión diferente.';
      }
      return 'La IA ha tenido un desliz místico. Por favor, reintenta.';
    } on FirebaseException catch (e) {
      AppLogger.e('Error de Firebase en GeminiService: [${e.code}] ${e.message}');
      if (e.code == 'unauthenticated' || e.message?.contains('blocked') == true) {
        return 'ERROR DE LLAVE API: El acceso a Firebase está bloqueado en Google Cloud Console. Revisa las restricciones de tu API Key.';
      }
      return 'Error de permisos al sincronizar la propuesta. Revisa tu conexión.';
    } catch (e) {
      AppLogger.e('Error crítico en GeminiService: $e');

      final errorStr = e.toString();
      if (errorStr.contains('GenerativeLanguageApi') || errorStr.contains('403')) {
        return 'CONFIGURACIÓN REQUERIDA: Debes habilitar "Generative Language API" en tu Google Cloud Console para esta API Key.';
      }

      if (e.toString().contains('SocketException') || e.toString().contains('network')) {
        return 'Sin conexión: No se pudo contactar con el oráculo de IA. Revisa tu internet.';
      }
      return 'Nuestras brujulas de IA estan recalculando. Por favor, intenta de nuevo en unos momentos.';
    }
  }

  Future<String> generateImpactSummary({
    required String itineraryContent,
    required List<String> diaryReflections,
  }) async {
    if (_apiKey.isEmpty) return 'Configuracion de IA no disponible.';

    final prompt = """
    Actua como un psicologo existencialista y mentor de viajes de FeelTrip.
    El viajero ha completado el siguiente itinerario vivencial:
    \"$itineraryContent\"

    Durante el viaje, el usuario registro estas reflexiones en su diario:
    ${diaryReflections.map((r) => '- $r').join('\n')}

    BASANDOTE EN LO ANTERIOR, REDACTA UN "RESUMEN DE IMPACTO" QUE:
    1. Valide el crecimiento observado a traves de sus palabras.
    2. Identifique el "Momento de Quiebre" o transformacion mas evidente.
    3. Proponga un mantra o proposito para integrar este aprendizaje en su vida cotidiana.

    Usa un tono profundo, poetico y alentador. Maximo 200 palabras. Responde en espanol.
    """;

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ??
          'Tu viaje ha terminado, pero tu transformacion apenas comienza.';
    } catch (e) {
      AppLogger.e('Error en generateImpactSummary: $e');
      return 'No pudimos procesar tu transformacion digitalmente, pero lo que viviste es real.';
    }
  }

  Future<String> suggestNextArchetype({
    required String currentArchetype,
    required List<String> impactSummaries,
  }) async {
    if (_apiKey.isEmpty) return 'Configuracion de IA no disponible.';

    final prompt = """
    Actua como un mentor de evolucion personal y experto en psicologia del viaje de FeelTrip.

    El usuario es actualmente un viajero de arquetipo: $currentArchetype.

    A lo largo de sus viajes, ha logrado las siguientes transformaciones (resumenes de impacto):
    ${impactSummaries.map((s) => '- $s').join('\n')}

    Los 5 arquetipos de FeelTrip son:
    1. Conector: Busca conexiones humanas y pertenencia.
    2. Transformado: Busca crecimiento personal y autoconocimiento.
    3. Aventurero: Busca adrenalina y superar limites.
    4. Contemplativo: Busca paz, silencio y belleza natural.
    5. Aprendiz: Busca conocimiento y comprension cultural.

    BASANDOTE EN SU EVOLUCION:
    1. Identifica que faceta de su personalidad se ha fortalecido.
    2. Sugiere cual de los 5 arquetipos deberia explorar ahora para equilibrar su crecimiento o profundizar en su camino.
    3. Justifica la eleccion con un tono inspirador y mistico.

    Responde de forma breve y profunda en espanol. Usa emojis.
    """;

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Sigue explorando tu interior en cada paso.';
    } catch (e) {
      AppLogger.e('Error en suggestNextArchetype: $e');
      return 'Tu camino es unico; sigue escuchando a tu corazon.';
    }
  }
}
