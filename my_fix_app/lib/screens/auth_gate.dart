import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:feeltrip_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:feeltrip_app/features/profile/presentation/profile_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';
import 'onboarding_screen.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  bool _timeoutReached = false;

  // Paleta FeelTrip Oficial
  static const Color boneWhite = Color(0xFFF5F2ED);
  static const Color carbonBlack = Color(0xFF1A1A1A);
  static const Color mossGreen = Color(0xFF4A5D4E);
  static const Color oxidizedEarth = Color(0xFFB35A38);

  @override
  void initState() {
    super.initState();
    // Temporizador para detectar latencia alta (ej. zonas rurales/offline)
    Future<void>.delayed(const Duration(seconds: 20), () {
      if (mounted) {
        setState(() {
          _timeoutReached = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final profileAsync = ref.watch(profileControllerProvider);

    return authState.when(
      loading: () => _buildLoadingView(withTimeoutMessage: _timeoutReached),
      error: (error, _) => _buildErrorView(
        'AUTH_CORE_ERROR: No se pudo validar el protocolo de seguridad. $error',
      ),
      data: (user) {
        if (user != null) {
          return profileAsync.when(
            loading: () => _buildLoadingView(withTimeoutMessage: _timeoutReached),
            error: (err, st) {
              AppLogger.e('AuthGate: Error sincronizando perfil', err, st);
              // Si falla por red, mostramos una vista de carga con mensaje de error suave
              return _buildLoadingView(
                withTimeoutMessage: true, 
                errorDetail: err.toString()
              );
            },
            data: (profile) {
              // Redirección post-frame para evitar colisiones en el árbol de widgets
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  if (profile?.archetype == null) {
                    context.go('/quiz');
                  } else {
                    context.go('/home');
                  }
                }
              });
              return _buildLoadingView();
            },
          );
        }
        return const OnboardingScreen();
      },
    );
  }

  // Vista de Carga Estilo "System Boot" (Consola de Inicio)
  Widget _buildLoadingView({bool withTimeoutMessage = false, String? errorDetail}) {
    return Scaffold(
      backgroundColor: carbonBlack, 
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barra de progreso minimalista
            const LinearProgressIndicator(
              backgroundColor: Color(0xFF2A2A2A),
              color: mossGreen,
              minHeight: 2,
            ),
            const SizedBox(height: 32),
            
            // Logs de sistema
            Text(
              '> INICIALIZANDO_FEELTRIP_OS...',
              style: GoogleFonts.jetBrainsMono(
                color: mossGreen, 
                fontSize: 13,
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 8),
            Text(
              withTimeoutMessage 
                ? '> ALERTA: Respuesta lenta del satélite...'
                : '> VERIFICANDO_CREDENCIALES_LOCALES...',
              style: GoogleFonts.jetBrainsMono(
                color: withTimeoutMessage ? oxidizedEarth : boneWhite.withValues(alpha: 0.4), 
                fontSize: 11
              ),
            ),
            
            if (withTimeoutMessage) ...[
              const SizedBox(height: 48),
              // Alerta de latencia (estética explorador)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: oxidizedEarth.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '// DIAGNÓSTICO: Cobertura intermitente.',
                      style: GoogleFonts.jetBrainsMono(
                        color: oxidizedEarth, 
                        fontSize: 11,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      errorDetail != null 
                        ? 'LOG: $errorDetail'
                        : 'La señal es débil. Intentaremos sincronizar de forma asíncrona mientras exploras.',
                      style: GoogleFonts.ebGaramond(
                        color: boneWhite.withValues(alpha: 0.7),
                        fontSize: 14,
                        fontStyle: FontStyle.italic
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() => _timeoutReached = false);
                      ref.invalidate(authNotifierProvider);
                      ref.invalidate(profileControllerProvider);
                    },
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: Text(
                      '>> REINTENTAR_COMMS',
                      style: GoogleFonts.jetBrainsMono(
                        color: mossGreen,
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: Text(
                      'FORZAR_LOGIN',
                      style: GoogleFonts.jetBrainsMono(
                        color: boneWhite.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }

  // Vista de Error Crítico (Kernel Panic Style)
  Widget _buildErrorView(String errorMessage) {
    return Scaffold(
      backgroundColor: boneWhite,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '[ FATAL_SYSTEM_ERROR ]',
                style: GoogleFonts.jetBrainsMono(
                  color: oxidizedEarth,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                color: carbonBlack,
                width: double.infinity,
                child: Text(
                  'STATUS: SESSION_V_FAILED\nTRACE: $errorMessage\n\nSugerencia: Verifique su conexión satelital o regrese a una zona con cobertura.',
                  style: GoogleFonts.jetBrainsMono(
                    color: boneWhite.withValues(alpha: 0.9), 
                    fontSize: 11,
                    height: 1.5
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  onPressed: () async {
                    try {
                      // LIMPIEZA ATÓMICA DE PROTOCOLOS
                      await FirebaseFirestore.instance.terminate();
                      await FirebaseFirestore.instance.clearPersistence();
                    } catch (e) {
                      // Ignorar si ya estaba cerrado
                    } finally {
                      if (mounted) {
                        context.go('/login');
                      }
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: carbonBlack, width: 1.5),
                    shape: const RoundedRectangleBorder(),
                    backgroundColor: carbonBlack,
                  ),
                  child: Text(
                    '>> REINICIAR PROTOCOLO AUTH',
                    style: GoogleFonts.jetBrainsMono(
                      color: boneWhite,
                      fontSize: 12,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}