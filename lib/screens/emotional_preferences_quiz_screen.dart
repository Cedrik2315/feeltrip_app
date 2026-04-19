import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';

import 'package:feeltrip_app/features/profile/presentation/profile_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Modelos ---

class QuizAnswer {
  const QuizAnswer({required this.text, required this.category});
  final String text;
  final String category;
}

class QuizQuestion {
  const QuizQuestion({required this.question, required this.answers});
  final String question;
  final List<QuizAnswer> answers;
}

// --- Pantalla de Resultados ---

class QuizResultsScreen extends ConsumerStatefulWidget {
  const QuizResultsScreen({
    super.key,
    required this.category,
    required this.resultData,
  });
  final String category;
  final Map<String, dynamic> resultData;

  @override
  ConsumerState<QuizResultsScreen> createState() => _QuizResultsScreenState();
}

class _QuizResultsScreenState extends ConsumerState<QuizResultsScreen> {
  bool _isSaving = false;

  static const Color boneWhite = Color(0xFFF5F5DC);
  static const Color mossGreen = Color(0xFF4B5320);
  static const Color carbon = Color(0xFF1A1A1A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: boneWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('ARQUETIPO DETECTADO', 
                style: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 2, color: mossGreen, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Text(
                ((widget.resultData['title'] as String?) ?? 'UNKNOWN').toUpperCase(),
                textAlign: TextAlign.center,
                style: GoogleFonts.ebGaramond(
                  fontSize: 42, 
                  fontWeight: FontWeight.bold, 
                  height: 1,
                  color: carbon,
                ),
              ),
              const SizedBox(height: 24),
              Container(height: 1, width: 60, color: carbon.withValues(alpha: .1)),
              const SizedBox(height: 24),
              Text(
                (widget.resultData['description'] as String?) ?? '',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 16, color: Colors.black87, height: 1.5),
              ),
              const SizedBox(height: 60),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: carbon,
                    padding: const EdgeInsets.all(20),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  onPressed: _isSaving ? null : _onContinue,
                  child: _isSaving 
                    ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(color: boneWhite, strokeWidth: 2))
                    : Text('CONTINUAR EXPEDICIÓN', 
                        style: GoogleFonts.jetBrainsMono(color: boneWhite, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onContinue() async {
    AppLogger.i('Iniciando secuencia de cierre de quiz...');
    setState(() => _isSaving = true);
    
    try {
      final profile = ref.read(profileControllerProvider).value;
      if (profile != null) {
        AppLogger.d('Guardando arquetipo detectado: ${widget.category}');
        
        // IMPORTANTE: Esperar el guardado. Si falla por permisos, saltará al catch.
        await ref.read(profileControllerProvider.notifier).updateProfile(
          profile.copyWith(archetype: widget.category),
        );
        AppLogger.i('Arquetipo sincronizado con éxito.');
      }
      
      if (mounted) {
        AppLogger.i('Redirigiendo a zona de operaciones (Home)...');
        context.go('/home');
      }
    } catch (e) {
      AppLogger.e('Error crítico en salida de Quiz: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de persistencia: No tienes permisos para guardar tu arquetipo.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        setState(() => _isSaving = false);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

// --- Datos del Quiz ---

const List<QuizQuestion> questions = [
  QuizQuestion(
    question: '¿Qué te motiva más al iniciar un viaje?',
    answers: [
      QuizAnswer(text: 'Conectar con personas y culturas locales', category: 'conexion'),
      QuizAnswer(text: 'Transformar mi perspectiva interna', category: 'transformacion'),
      QuizAnswer(text: 'La adrenalina de lo desconocido', category: 'aventura'),
      QuizAnswer(text: 'Momentos de absoluto silencio y paz', category: 'reflexion'),
      QuizAnswer(text: 'Aprender técnicas o saberes nuevos', category: 'aprendizaje'),
    ],
  ),
  QuizQuestion(
    question: 'Encuentras un sendero sin marcar, tú...',
    answers: [
      QuizAnswer(text: 'Buscas a alguien para ir acompañado', category: 'conexion'),
      QuizAnswer(text: 'Lo tomas para probar tu propia fortaleza', category: 'transformacion'),
      QuizAnswer(text: 'Corres por él sin dudarlo', category: 'aventura'),
      QuizAnswer(text: 'Caminas despacio, observando cada detalle', category: 'reflexion'),
      QuizAnswer(text: 'Analizas el entorno y su ecosistema', category: 'aprendizaje'),
    ],
  ),
  QuizQuestion(
    question: '¿Cómo prefieres documentar tus memorias?',
    answers: [
      QuizAnswer(text: 'Retratos de personas que conocí', category: 'conexion'),
      QuizAnswer(text: 'Escribiendo reflexiones profundas', category: 'transformacion'),
      QuizAnswer(text: 'Videos de acción y movimiento', category: 'aventura'),
      QuizAnswer(text: 'Fotos de paisajes minimalistas', category: 'reflexion'),
      QuizAnswer(text: 'Notas sobre datos históricos y curiosos', category: 'aprendizaje'),
    ],
  ),
  QuizQuestion(
    question: 'Si el clima arruina tus planes, tú...',
    answers: [
      QuizAnswer(text: 'Buscas refugio y charlas con extraños', category: 'conexion'),
      QuizAnswer(text: 'Meditas sobre la impermanencia', category: 'transformacion'),
      QuizAnswer(text: 'Buscas una actividad extrema bajo la lluvia', category: 'aventura'),
      QuizAnswer(text: 'Disfrutas del sonido de la tormenta a solas', category: 'reflexion'),
      QuizAnswer(text: 'Aprovechas para leer sobre el lugar', category: 'aprendizaje'),
    ],
  ),
  QuizQuestion(
    question: '¿Cuál es tu equipo de viaje esencial?',
    answers: [
      QuizAnswer(text: 'Un regalo para nuevos amigos', category: 'conexion'),
      QuizAnswer(text: 'Mi diario de vida', category: 'transformacion'),
      QuizAnswer(text: 'Equipo técnico de alto rendimiento', category: 'aventura'),
      QuizAnswer(text: 'Unos buenos audífonos canceladores de ruido', category: 'reflexion'),
      QuizAnswer(text: 'Mi cámara profesional', category: 'aprendizaje'),
    ],
  ),
  QuizQuestion(
    question: '¿Qué buscas en un alojamiento?',
    answers: [
      QuizAnswer(text: 'Espacios comunes para socializar', category: 'conexion'),
      QuizAnswer(text: 'Un lugar que inspire cambio espiritual', category: 'transformacion'),
      QuizAnswer(text: 'Una carpa en medio de la nada', category: 'aventura'),
      QuizAnswer(text: 'Una cabaña aislada y silenciosa', category: 'reflexion'),
      QuizAnswer(text: 'Cercanía a museos o centros culturales', category: 'aprendizaje'),
    ],
  ),
  QuizQuestion(
    question: 'Al probar comida local, lo haces por...',
    answers: [
      QuizAnswer(text: 'Compartir la mesa con locales', category: 'conexion'),
      QuizAnswer(text: 'Entender el espíritu del territorio', category: 'transformacion'),
      QuizAnswer(text: 'El reto de probar algo extraño', category: 'aventura'),
      QuizAnswer(text: 'Saborear en soledad y calma', category: 'reflexion'),
      QuizAnswer(text: 'Conocer la tradición culinaria', category: 'aprendizaje'),
    ],
  ),
  QuizQuestion(
    question: 'Tu viaje ideal termina cuando...',
    answers: [
      QuizAnswer(text: 'He hecho amigos para toda la vida', category: 'conexion'),
      QuizAnswer(text: 'Siento que soy alguien mejor', category: 'transformacion'),
      QuizAnswer(text: 'He agotado mis energías explorando', category: 'aventura'),
      QuizAnswer(text: 'He encontrado la paz que buscaba', category: 'reflexion'),
      QuizAnswer(text: 'He comprendido algo nuevo del mundo', category: 'aprendizaje'),
    ],
  ),
];

const Map<String, Map<String, dynamic>> resultsDataMap = {
  'conexion': {
    'title': 'El Conector',
    'description': 'Tú viajas para unirte a otros y crear recuerdos compartidos. Las historias humanas son tu brújula.',
  },
  'transformacion': {
    'title': 'El Alquimista',
    'description': 'Buscas viajes que actúen como catalizadores. No vuelves siendo la misma persona que se fue.',
  },
  'aventura': {
    'title': 'El Explorador',
    'description': 'La zona de confort no existe en tu mapa. Buscas la intensidad de lo salvaje.',
  },
  'reflexion': {
    'title': 'El Ermitaño',
    'description': 'El viaje es un santuario. Prefieres la contemplación del paisaje al ruido de la ciudad.',
  },
  'aprendizaje': {
    'title': 'El Académico',
    'description': 'El mundo es tu aula. Cada destino es un libro abierto sobre historia, arte o naturaleza.',
  },
};

// --- Pantalla Principal del Quiz ---

class EmotionalPreferencesQuizScreen extends StatefulWidget {
  const EmotionalPreferencesQuizScreen({super.key});
  @override
  State<EmotionalPreferencesQuizScreen> createState() => _EmotionalPreferencesQuizScreenState();
}

class _EmotionalPreferencesQuizScreenState extends State<EmotionalPreferencesQuizScreen> {
  final PageController _pageController = PageController();
  int _currentQuestion = 0;
  
  static const Color boneWhite = Color(0xFFF5F5DC);
  static const Color mossGreen = Color(0xFF4B5320);
  static const Color carbon = Color(0xFF1A1A1A);

  final Map<String, int> _scores = {
    'conexion': 0,
    'transformacion': 0,
    'aventura': 0,
    'reflexion': 0,
    'aprendizaje': 0,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: boneWhite,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: boneWhite,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Color(0xFF1A1A1A), size: 24),
          onPressed: () {
            HapticFeedback.lightImpact();
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text('ARQUETIPO QUIZ.sys', 
          style: GoogleFonts.jetBrainsMono(fontSize: 11, color: carbon, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
      body: Column(
        children: [
          _buildProgressBar(),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => setState(() => _currentQuestion = index),
              itemCount: questions.length,
              itemBuilder: (context, index) => _QuestionCard(
                question: questions[index],
                onAnswerSelected: _handleAnswer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: LinearProgressIndicator(
              value: (_currentQuestion + 1) / questions.length,
              minHeight: 2,
              backgroundColor: carbon.withValues(alpha: .05),
              valueColor: const AlwaysStoppedAnimation<Color>(mossGreen),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'LOG_PROGRESS: ${(_currentQuestion + 1).toString().padLeft(2, '0')} / ${questions.length.toString().padLeft(2, '0')}',
            style: GoogleFonts.jetBrainsMono(fontSize: 9, color: carbon.withValues(alpha: .4), fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _handleAnswer(String category) {
    setState(() {
      _scores[category] = (_scores[category] ?? 0) + 1;
    });

    if (_currentQuestion < questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutQuart,
      );
    } else {
      _showResults();
    }
  }

  void _showResults() {
    final topCategory = _scores.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResultsScreen(
          category: topCategory,
          resultData: resultsDataMap[topCategory]!,
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.question, required this.onAnswerSelected});
  final QuizQuestion question;
  final Function(String) onAnswerSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.question,
            style: GoogleFonts.ebGaramond(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.1,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 48),
          ...question.answers.map((answer) => _AnswerTile(
            text: answer.text, 
            onTap: () => onAnswerSelected(answer.category),
          )),
        ],
      ),
    );
  }
}

class _AnswerTile extends StatelessWidget {
  const _AnswerTile({required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black.withValues(alpha: .08)),
            borderRadius: BorderRadius.zero,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: GoogleFonts.inter(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500),
                ),
              ),
              Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.black.withValues(alpha: .2)),
            ],
          ),
        ),
      ),
    );
  }
}