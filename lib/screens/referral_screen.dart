import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:feeltrip_app/domain/entities/user_subscription.dart';
import 'package:feeltrip_app/presentation/providers/subscription_provider.dart';
import 'package:feeltrip_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';
import 'package:intl/intl.dart';

/// Pantalla del sistema de referidos de FeelTrip.
///
/// Secciones:
/// 1. Tu código de invitación (copiar / compartir)
/// 2. Tus días bonus (barra de progreso + fecha de expiración)
/// 3. Tus referidos (contador)
/// 4. Ingresar código de invitación (solo si aún no ha usado uno)
class ReferralScreen extends ConsumerStatefulWidget {
  const ReferralScreen({super.key});

  @override
  ConsumerState<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends ConsumerState<ReferralScreen> {
  final _codeController = TextEditingController();
  bool _applyingCode = false;
  String? _applyError;
  bool _applySuccess = false;

  // ── Paleta FeelTrip ────────────────────────────────────────────────────────
  static const Color _bg = Color(0xFFF5F2ED);
  static const Color _carbon = Color(0xFF1A1A1A);
  static const Color _teal = Color(0xFF00695C);
  static const Color _amber = Color(0xFFFF8F00);

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  // ── Lógica ─────────────────────────────────────────────────────────────────

  Future<void> _applyCode(String userId, UserSubscription sub) async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _applyError = 'Ingresa un código de invitación.');
      return;
    }

    setState(() {
      _applyingCode = true;
      _applyError = null;
      _applySuccess = false;
    });

    try {
      final service = ref.read(referralServiceProvider);
      final ok = await service.applyInviteCode(userId, code);
      if (!mounted) return;
      setState(() {
        _applySuccess = ok;
        _applyError = ok
            ? null
            : 'Código inválido, ya utilizado o no aplicable.';
      });
      if (ok) _codeController.clear();
    } catch (e, st) {
      AppLogger.e('ReferralScreen._applyCode', e, st);
      if (mounted) setState(() => _applyError = 'Error al aplicar el código.');
    } finally {
      if (mounted) setState(() => _applyingCode = false);
    }
  }

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Código $code copiado al portapapeles'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _teal,
      ),
    );
  }

  void _shareCode(String code) {
    Share.share(
      '¡Únete a FeelTrip y viaja para recordar! 🌎\n'
      'Usa mi código de invitación $code al registrarte y recibe 30 días Pro gratis.\n'
      'Descarga la app: https://feeltrip.app',
      subject: 'Mi código FeelTrip: $code',
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authNotifierProvider);
    final subAsync = ref.watch(subscriptionProvider);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _carbon),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'PROGRAMA REFERIDOS',
          style: GoogleFonts.jetBrainsMono(
            color: _carbon,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: authAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Sesión requerida'));
          }
          return subAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (sub) => _buildContent(user.id, sub),
          );
        },
      ),
    );
  }

  Widget _buildContent(String userId, UserSubscription sub) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Código de invitación ──────────────────────────────────────
          _sectionHeader('TU CÓDIGO DE INVITACIÓN', Icons.card_giftcard_outlined),
          const SizedBox(height: 12),
          _buildCodeCard(sub.referralCode.isEmpty ? '—' : sub.referralCode),
          const SizedBox(height: 8),
          Text(
            'Cada amigo que use tu código gana 30 días Pro gratis.\n'
            'Tú ganas 15 días extra (máximo 90 días acumulables).',
            style: GoogleFonts.ebGaramond(
              fontSize: 14,
              color: _carbon.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),

          // ── 2. Días bonus ────────────────────────────────────────────────
          _sectionHeader('TUS DÍAS BONUS', Icons.stars_rounded),
          const SizedBox(height: 12),
          _buildBonusDaysCard(sub),
          const SizedBox(height: 28),

          // ── 3. Referidos ─────────────────────────────────────────────────
          _sectionHeader('TUS REFERIDOS', Icons.people_outline_rounded),
          const SizedBox(height: 12),
          _buildReferralStats(sub),
          const SizedBox(height: 28),

          // ── 4. Ingresar código (solo si no ha usado uno) ─────────────────
          if (sub.referredBy == null) ...[
            _sectionHeader('INGRESAR CÓDIGO DE INVITACIÓN', Icons.qr_code_scanner),
            const SizedBox(height: 12),
            _buildApplyCodeSection(userId, sub),
            const SizedBox(height: 28),
          ],
        ],
      ),
    );
  }

  // ── Sección 1: Tarjeta del código ─────────────────────────────────────────

  Widget _buildCodeCard(String code) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: _carbon,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              code,
              style: GoogleFonts.jetBrainsMono(
                color: _amber,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Copiar código',
            icon: const Icon(Icons.copy_rounded, color: Colors.white70),
            onPressed: code == '—' ? null : () => _copyCode(code),
          ),
          IconButton(
            tooltip: 'Compartir código',
            icon: const Icon(Icons.share_rounded, color: Colors.white70),
            onPressed: code == '—' ? null : () => _shareCode(code),
          ),
        ],
      ),
    );
  }

  // ── Sección 2: Días bonus ─────────────────────────────────────────────────

  Widget _buildBonusDaysCard(UserSubscription sub) {
    const int cap = 90;
    final accumulated = sub.bonusDaysAccumulated.clamp(0, cap);
    final progress = accumulated / cap;
    final expiryStr = sub.proExpiresAt != null
        ? DateFormat('d MMM yyyy', 'es').format(sub.proExpiresAt!)
        : '—';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: _carbon.withValues(alpha: 0.12)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$accumulated días acumulados de $cap máx.',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _carbon,
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  color: _teal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: _carbon.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(
                accumulated >= cap ? _amber : _teal,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14),
              const SizedBox(width: 6),
              Text(
                'Pro activo hasta: $expiryStr',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  color: _carbon.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Sección 3: Estadísticas de referidos ──────────────────────────────────

  Widget _buildReferralStats(UserSubscription sub) {
    return Row(
      children: [
        Expanded(
          child: _statBox(
            label: 'EXPLORADORES\nUNIDOS',
            value: sub.invitesAccepted.toString(),
            icon: Icons.group_add_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statBox(
            label: 'DÍAS BONUS\nGANADOS',
            value: sub.bonusDaysEarned.toString(),
            icon: Icons.star_rounded,
          ),
        ),
      ],
    );
  }

  Widget _statBox({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: _carbon.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _teal, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: _carbon,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9,
              color: _carbon.withValues(alpha: 0.5),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Sección 4: Aplicar código ─────────────────────────────────────────────

  Widget _buildApplyCodeSection(String userId, UserSubscription sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿Alguien te invitó? Ingresa su código y gana 30 días Pro gratis.',
          style: GoogleFonts.ebGaramond(
            fontSize: 14,
            height: 1.5,
            color: _carbon.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
                decoration: InputDecoration(
                  hintText: 'FELT-XXXX',
                  hintStyle: GoogleFonts.jetBrainsMono(
                    color: _carbon.withValues(alpha: 0.3),
                    letterSpacing: 1.5,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: _carbon.withValues(alpha: 0.15),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: _carbon.withValues(alpha: 0.15),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _teal, width: 1.5),
                  ),
                ),
                onFieldSubmitted: (_) => _applyCode(userId, sub),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _applyingCode ? null : () => _applyCode(userId, sub),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                ),
                child: _applyingCode
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Aplicar',
                        style: GoogleFonts.jetBrainsMono(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
              ),
            ),
          ],
        ),
        if (_applyError != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.error_outline, size: 14, color: Colors.redAccent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _applyError!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
        if (_applySuccess) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.check_circle_outline, size: 14, color: Colors.green),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  '¡Código aplicado! Tienes 30 días Pro gratis 🎉',
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // ── Helpers de UI ──────────────────────────────────────────────────────────

  Widget _sectionHeader(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _teal),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: _carbon.withValues(alpha: 0.45),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
