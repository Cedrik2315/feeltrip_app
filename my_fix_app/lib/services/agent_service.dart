import 'dart:convert';
import 'dart:async';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:feeltrip_app/services/flight_service.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';
import '../agent_prompts.dart';
import 'emotional_engine_service.dart';
import 'isar_service.dart';

/// Provider para acceder al servicio de Agentes (Scout Flow).
final agentServiceProvider = Provider<AgentService>((ref) => AgentService());

/// 🤖 AGENT SERVICE (Lightweight Agentic Implementation)
/// 
/// Esta versión utiliza el SDK estándar de Google AI para simular un 
/// Sistema de Agentes (Tool Calling) sin depender de Genkit Dart.
class AgentService {
  final String _apiKey = dotenv.env['GOOGLE_AI_API_KEY'] ?? 
      dotenv.env['GEMINI_API_KEY'] ?? 
      const String.fromEnvironment('GOOGLE_AI_API_KEY');
      
  final _flights = FlightService();
  final _isarService = IsarService();

  String _generateCacheKey(String prompt) {
    final bytes = utf8.encode(prompt);
    return sha256.convert(bytes).toString();
  }

  /// 🛠️ TOOL: Búsqueda de Vuelos (REAL)
  /// Intenta llamar a Amadeus. Si falla o no hay llaves, devuelve un link de búsqueda real.
  Future<String> _searchFlights(String origin, String destination, String date) async {
    AppLogger.i('AgentService: Agente buscando vuelos en Despegar/Google Flights ($origin -> $destination)');

    await _flights.searchFlights(
      origin: origin,
      destination: destination,
      departureDate: date,
    );

    final despegarLink = _flights.generateDespegarLink(origin, destination, date);
    final googleLink = _flights.generateGoogleFlightsLink(origin, destination, date);

    return 'BÚSQUEDA DE VUELOS INICIADA: \n'
           '- Opción Despegar: $despegarLink \n'
           '- Opción Google Flights: $googleLink \n'
           'El usuario puede elegir su plataforma preferida desde la tarjeta de expedición.';
  }

  /// 🛠️ TOOL: Clima (Simulada)
  Future<String> _getWeather(String destination) async {
    AppLogger.i('AgentService: Agente consultando clima: $destination');
    await Future.delayed(const Duration(milliseconds: 800));
    final weathers = {
      'JFK': 'Soleado, 22°C. Ideal para caminar.',
      'EZE': 'Nublado, 15°C. Probabilidad de lluvia.',
      'TORRES DEL PAINE': 'Frío extremo, -2°C. Nieve en senderos.',
      'CUSCO': 'Templado, 18°C. Cielo despejado.',
    };
    return weathers[destination.toUpperCase()] ?? 'Templado, 20°C. Clima estable.';
  }

  /// 🛠️ TOOL: Actividades Locales (Simulada)
  Future<String> _searchActivities(String destination, String archetype) async {
    AppLogger.i('AgentService: Agente buscando actividades para $archetype en $destination');
    await Future.delayed(const Duration(milliseconds: 1200));
    if (archetype == 'EXPLORADOR') {
      return 'Trekking glaciar, Kayak nocturno y avistamiento de fauna.';
    } else if (archetype == 'ERMITAÑO') {
      return 'Retiro de silencio, cabaña autosustentable y meditación frente al lago.';
    }
    return 'Tour cultural, gastronomía local y mercados artesanales.';
  }

  /// 🛠️ TOOL: Calendario (Simulada)
  /// Resuelve la fricción de planificación mencionada para Sercotec.
  Future<String> _createCalendarEvent(String title, String date, String location) async {
    AppLogger.i('AgentService: Agente agendando en calendario: $title en $location para el $date');
    
    DateTime startDate = DateTime.now().add(const Duration(days: 7));
    try {
      startDate = DateTime.parse(date);
    } catch (_) {}

    final event = Event(
      title: 'FeelTrip: $title',
      description: 'Expedición recomendada y agendada por tu Scout Agent de IA.',
      location: location,
      startDate: startDate,
      endDate: startDate.add(const Duration(days: 3)), 
    );

    // Llama al calendario nativo. Es síncrono para la app, el resultado de _createCalendarEvent
    // alimenta el log que lee el Agente.
    Add2Calendar.addEvent2Cal(event);
    
    return 'Evento "$title" convertido a intent de calendario nativo para el $date en $location.';
  }

  /// 🛠️ TOOL: Pagos (Fase 6)
  Future<String> _processPayment(double amount, String currency, String description) async {
    AppLogger.i('AgentService: Agente iniciando pago de $amount $currency ($description)');
    // En un entorno productivo aquí se llamaría a Stripe o MercadoPago
    await Future.delayed(const Duration(milliseconds: 2000));
    return 'Pago de $amount $currency por "$description" procesado exitosamente. ID Transacción: FT-${DateTime.now().millisecondsSinceEpoch}';
  }

  /// 🧠 SCOUT AGENT FLOW
  /// Analiza el diario y toma decisiones autónomas usando múltiples herramientas.
  Future<EmotionalPrediction?> scoutAgent(
    String diaryHistory, {
    String locale = 'es',
    Function(String status)? onStatusUpdate,
  }) async {
    if (_apiKey.isEmpty) {
      AppLogger.e('AgentService: GOOGLE_AI_API_KEY no configurada');
      return null;
    }

    final cacheKey = _generateCacheKey(diaryHistory + locale);
    try {
      final cachedResponse = await _isarService.getAiResponse(cacheKey);
      if (cachedResponse != null) {
        AppLogger.i('AgentService: Retornando expedición desde caché local.');
        onStatusUpdate?.call('Recuperando plan de la memoria local...');
        return EmotionalPrediction.fromJson(cachedResponse);
      }
    } catch (e) {
      AppLogger.w('AgentService: Error al leer caché: $e');
    }

    final prompt = '''
      Analiza este historial del diario y genera la expedición final usando tus herramientas:
      $diaryHistory
    ''';

    // 1. Definición de Herramientas
    final flightTool = FunctionDeclaration(
      'searchFlights',
      AgentPrompts.get('flight_tool_desc', locale: locale),
      Schema.object(
        properties: {
          'origin': Schema.string(description: 'Código IATA origen (ej: EZE)'),
          'destination': Schema.string(description: 'Código IATA destino (ej: JFK)'),
          'date': Schema.string(description: 'Fecha YYYY-MM-DD'),
        },
        requiredProperties: ['origin', 'destination', 'date'],
      ),
    );

    final weatherTool = FunctionDeclaration(
      'getWeather',
      AgentPrompts.get('weather_tool_desc', locale: locale),
      Schema.object(
        properties: {
          'destination': Schema.string(description: 'Nombre del destino o código IATA'),
        },
        requiredProperties: ['destination'],
      ),
    );

    final activitiesTool = FunctionDeclaration(
      'searchActivities',
      AgentPrompts.get('activities_tool_desc', locale: locale),
      Schema.object(
        properties: {
          'destination': Schema.string(description: 'Nombre del lugar'),
          'archetype': Schema.string(description: 'Arquetipo (EXPLORADOR, ERMITAÑO, CONECTOR, etc)'),
        },
        requiredProperties: ['destination', 'archetype'],
      ),
    );

    final calendarTool = FunctionDeclaration(
      'addCalendarEvent',
      AgentPrompts.get('calendar_tool_desc', locale: locale),
      Schema.object(
        properties: {
          'title': Schema.string(description: 'Título del evento (ej: Vuelo a NYC)'),
          'date': Schema.string(description: 'Fecha en formato YYYY-MM-DD'),
          'location': Schema.string(description: 'Ubicación del evento'),
        },
        requiredProperties: ['title', 'date', 'location'],
      ),
    );

    final paymentTool = FunctionDeclaration(
      'processPayment',
      AgentPrompts.get('payment_tool_desc', locale: locale),
      Schema.object(
        properties: {
          'amount': Schema.number(description: 'Monto a pagar'),
          'currency': Schema.string(description: 'Moneda (ej: USD, CLP)'),
          'description': Schema.string(description: 'Descripción del servicio a pagar'),
        },
        requiredProperties: ['amount', 'currency', 'description'],
      ),
    );

    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
      tools: [
        Tool(functionDeclarations: [flightTool, weatherTool, activitiesTool, calendarTool, paymentTool])
      ],
      systemInstruction: Content('system', [
        TextPart(AgentPrompts.get('system_instruction', locale: locale))
      ]),
    );

    final chat = model.startChat();
    
    try {
      final content = Content.text(prompt);
      
      final tokenCount = await model.countTokens([content]);
      AppLogger.i('AgentService: Iniciando Scout con ${tokenCount.totalTokens} tokens.');

      onStatusUpdate?.call('Iniciando orquestador de agentes...');
      var response = await chat.sendMessage(content);

      // 🔄 LOOP AGÉNTICO MULTI-TURNO
      int maxIter = 5; 
      while (response.functionCalls.isNotEmpty && maxIter > 0) {
        final List<FunctionResponse> responses = [];
        
        for (final call in response.functionCalls) {
          onStatusUpdate?.call('Agente lanzando: ${call.name}...');
          try {
            dynamic result;
            if (call.name == 'searchFlights') {
              result = await _searchFlights(
                call.args['origin'] as String,
                call.args['destination'] as String,
                call.args['date'] as String,
              );
            } else if (call.name == 'getWeather') {
              result = await _getWeather(call.args['destination'] as String);
            } else if (call.name == 'searchActivities') {
              result = await _searchActivities(
                call.args['destination'] as String,
                call.args['archetype'] as String,
              );
            } else if (call.name == 'addCalendarEvent') {
              result = await _createCalendarEvent(
                call.args['title'] as String,
                call.args['date'] as String,
                call.args['location'] as String,
              );
            } else if (call.name == 'processPayment') {
              result = await _processPayment(
                (call.args['amount'] as num).toDouble(),
                call.args['currency'] as String,
                call.args['description'] as String,
              );
            }
            responses.add(FunctionResponse(call.name, {'result': result}));
          } catch (e) {
            AppLogger.e('AgentService: Error en herramienta ${call.name}: $e');
            responses.add(FunctionResponse(call.name, {'error': e.toString()}));
          }
        }
        
        onStatusUpdate?.call('Razonando con nuevos datos (Iteración: ${6 - maxIter})...');
        response = await chat.sendMessage(Content.functionResponses(responses));
        maxIter--;
      }
      
      onStatusUpdate?.call('Generando expedición final...');

      final rawText = response.text ?? '{}';
      
      // Extracción robusta de JSON usando Regex
      final jsonRegex = RegExp(r'\{[\s\S]*\}');
      final match = jsonRegex.stringMatch(rawText);
      final cleanJson = match ?? '{}';
      
      // Persistir en caché local
      unawaited(_isarService.putAiResponse(cacheKey, cleanJson));

      return EmotionalPrediction.fromJson(cleanJson);

    } catch (e, stack) {
      AppLogger.e('AgentService: Error crítico en Agente Scout', e, stack);
      return EmotionalPrediction(
        moodPattern: 'Error en el orquestador',
        intensity: 0.5,
        recommendedArchetype: 'EXPLORADOR',
        suggestedDestination: 'Desconocido',
        reasoning: 'Ocurrió un error al procesar la expedición con agentes.',
      );
    }
  }
}