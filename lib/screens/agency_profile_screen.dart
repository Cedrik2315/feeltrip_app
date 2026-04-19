import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/travel_agency_model.dart';
import '../services/sharing_service.dart';
import '../core/di/providers.dart';
import '../features/auth/presentation/providers/auth_notifier.dart';
import '../presentation/providers/profile_provider.dart';
import '../presentation/providers/subscription_provider.dart';
class AgencyProfileScreen extends ConsumerStatefulWidget {
  const AgencyProfileScreen({
    super.key,
    required this.agencyId,
  });
  final String agencyId;

  @override
  ConsumerState<AgencyProfileScreen> createState() => _AgencyProfileScreenState();
}

class _AgencyProfileScreenState extends ConsumerState<AgencyProfileScreen> {
  late Future<TravelAgency?> _agencyFuture;

  // Paleta de Colores Oficial FeelTrip
  static const Color boneWhite = Color(0xFFF5F2ED); // Tono papel más natural
  static const Color carbonBlack = Color(0xFF1A1A1A);
  static const Color mossGreen = Color(0xFF4A5D4E);
  static const Color oxidizedEarth = Color(0xFFB35A38);

  @override
  void initState() {
    super.initState();
    _agencyFuture = ref.read(agencyServiceProvider).getAgencyById(widget.agencyId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TravelAgency?>(
      future: _agencyFuture,
      builder: (context, snapshot) {
        final authUser = ref.watch(authNotifierProvider).value;
        // Estado reactivo de "Siguiendo"
        final followingList = authUser != null 
            ? ref.watch(followingProvider(authUser.id)).valueOrNull ?? <String>[] 
            : <String>[];
        final isFollowing = followingList.contains(widget.agencyId);

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: boneWhite,
            body: Center(child: CircularProgressIndicator(color: mossGreen)),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            backgroundColor: boneWhite,
            appBar: AppBar(
              backgroundColor: carbonBlack,
              elevation: 0,
              title: Text('ERR: NULL_PTR_AGENCY', style: GoogleFonts.jetBrainsMono(fontSize: 14)),
            ),
            body: Center(
              child: Text(
                'No se pudo localizar el registro de la agencia.',
                style: GoogleFonts.ebGaramond(fontSize: 18),
              ),
            ),
          );
        }

        final agency = snapshot.data!;

        return Scaffold(
          backgroundColor: boneWhite,
          body: CustomScrollView(
            slivers: [
              // Header Híbrido: Imagen + Terminal UI
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: carbonBlack,
                iconTheme: const IconThemeData(color: boneWhite),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                  title: Row(
                    children: [
                      Text(
                        '> AGENCY_PROFILE',
                        style: GoogleFonts.jetBrainsMono(
                          color: boneWhite,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(width: 4),
                      _BlinkingCursor(),
                    ],
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        agency.logo,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: carbonBlack,
                            child: const Center(child: CircularProgressIndicator(color: mossGreen, strokeWidth: 1)),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.landscape, color: mossGreen, size: 60),
                      ),
                      // Overlay para asegurar legibilidad del texto de terminal
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              carbonBlack.withValues(alpha: 0.3),
                              carbonBlack.withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  if (authUser != null)
                    IconButton(
                      icon: Icon(
                        isFollowing ? Icons.bookmark : Icons.bookmark_border,
                        color: isFollowing ? oxidizedEarth : boneWhite,
                      ),
                      onPressed: () async {
                        await ref.read(agencyServiceProvider).followAgency(widget.agencyId, authUser.id);
                        // Refrescar el provider de seguimiento
                        ref.invalidate(followingProvider(authUser.id));
                      },
                      tooltip: isFollowing ? 'Siguiendo' : 'Seguir Agencia',
                    ),
                  IconButton(
                    icon: const Icon(Icons.share_outlined),
                    onPressed: () => _shareAgency(agency),
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Metadata Técnica
                      Text(
                        'ID: ${agency.id.toUpperCase()} // REG_LOC: ${agency.city.toUpperCase()}',
                        style: GoogleFonts.jetBrainsMono(
                          color: oxidizedEarth,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Nombre Editorial
                      Text(
                        agency.name,
                        style: GoogleFonts.ebGaramond(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: carbonBlack,
                          height: 0.9,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      Divider(color: mossGreen.withValues(alpha: 0.2), thickness: 1),
                      
                      // Bloque de Estadísticas de Instrumentación
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStat(label: 'RATING', value: agency.rating.toStringAsFixed(1)),
                            _buildStat(label: 'FOLLOWERS', value: agency.followers.toString()),
                            _buildStat(label: 'EXPERIENCES', value: agency.experiences.length.toString()),
                          ],
                        ),
                      ),
                      
                      Divider(color: mossGreen.withValues(alpha: 0.2), thickness: 1),
                      const SizedBox(height: 32),

                      // Sección Narrativa con Capitular
                      Text(
                        'CRÓNICA DE LA AGENCIA',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          color: mossGreen,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildEditorialDescription(agency.description),

                      const SizedBox(height: 32),
                      
                      // Botón para agregar reseña
                      OutlinedButton.icon(
                        onPressed: () => _showReviewDialog(context, agency),
                        icon: const Icon(Icons.rate_review_outlined, color: mossGreen),
                        label: Text(
                          'ESCRIBIR_RESEÑA',
                          style: GoogleFonts.jetBrainsMono(color: mossGreen, fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: mossGreen),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Interfaz de Comandos de Contacto
                      _buildTechnicalAction(
                        label: 'CALL_STREAM',
                        value: agency.phoneNumber,
                        onTap: () => _launchPhone(agency.phoneNumber),
                      ),
                      _buildTechnicalAction(
                        label: 'MAIL_PROTOCOL',
                        value: agency.email,
                        onTap: () => _launchEmail(agency.email),
                      ),

                      const SizedBox(height: 48),

                      // Flujo B2B Especial para Hoteles Boutique
                      if (agency.specialties.any((s) => s.toLowerCase() == 'boutique' || s.toLowerCase() == 'hotel')) ...[
                         SizedBox(
                           width: double.infinity,
                           height: 48,
                           child: OutlinedButton(
                             onPressed: () => _activateBoutiqueCourtesy(context, agency),
                             style: OutlinedButton.styleFrom(
                               foregroundColor: oxidizedEarth,
                               side: const BorderSide(color: oxidizedEarth),
                               shape: const RoundedRectangleBorder(),
                             ),
                             child: Text(
                               '>> ACTIVAR: CORTESÍA_BOUTIQUE_PRO',
                               style: GoogleFonts.jetBrainsMono(
                                 fontWeight: FontWeight.bold,
                                 fontSize: 12,
                               ),
                             ),
                           ),
                         ),
                         const SizedBox(height: 16),
                      ],
                      // Botón de Acción Principal (Terminal Style)
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: OutlinedButton(
                          onPressed: () => _showLeadDialog(context, agency),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: carbonBlack,
                            side: const BorderSide(color: carbonBlack),
                            shape: const RoundedRectangleBorder(), // Rectangular para estética técnica
                          ),
                          child: Text(
                            '>> EJECUTAR: SOLICITAR_EXPEDICIÓN',
                            style: GoogleFonts.jetBrainsMono(
                              color: boneWhite,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget para la descripción con capitular editorial
  Widget _buildEditorialDescription(String text) {
    if (text.isEmpty) return const SizedBox.shrink();
    
    return RichText(
      text: TextSpan(
        style: GoogleFonts.ebGaramond(
          fontSize: 19,
          color: carbonBlack,
          height: 1.5,
        ),
        children: [
          TextSpan(
            text: text.substring(0, 1),
            style: GoogleFonts.ebGaramond(
              fontSize: 52,
              fontWeight: FontWeight.bold,
              color: oxidizedEarth,
              height: 0.8,
            ),
          ),
          TextSpan(text: text.substring(1)),
        ],
      ),
    );
  }

  Widget _buildStat({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value.padLeft(2, '0'),
          style: GoogleFonts.jetBrainsMono(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: carbonBlack,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 9,
            color: mossGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTechnicalAction({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Text('$label > ', 
              style: GoogleFonts.jetBrainsMono(color: mossGreen, fontSize: 11, fontWeight: FontWeight.bold)
            ),
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.jetBrainsMono(
                  color: carbonBlack,
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareAgency(TravelAgency agency) => SharingService.shareAgency(agency);
  Future<void> _launchPhone(String n) async => await launchUrl(Uri.parse('tel:$n'));
  Future<void> _launchEmail(String e) async => await launchUrl(Uri.parse('mailto:$e'));

  void _showLeadDialog(BuildContext context, TravelAgency agency) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PROTOCOLO: Debes estar autenticado para contactar.')),
      );
      return;
    }

    final messageController = TextEditingController(
      text: 'Hola ${agency.name}, me interesa coordinar una expedición bajo el arquetipo FeelTrip.'
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: boneWhite,
        shape: const RoundedRectangleBorder(),
        title: Text('CONTACTAR_SOCIO_B2B', style: GoogleFonts.jetBrainsMono(fontSize: 14, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Escribe un mensaje para la agencia:', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: mossGreen)),
            const SizedBox(height: 12),
            TextField(
              controller: messageController,
              maxLines: 4,
              style: GoogleFonts.ebGaramond(fontSize: 16),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: oxidizedEarth)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('CANCELAR', style: GoogleFonts.jetBrainsMono(color: mossGreen))),
          ElevatedButton(
            onPressed: () async {
              await ref.read(agencyServiceProvider).submitLead(
                userId: user.uid,
                agencyId: agency.id,
                message: messageController.text,
              );
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('LEAD_SYNC: Solicitud enviada exitosamente.')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: carbonBlack),
            child: Text('ENVIAR', style: GoogleFonts.jetBrainsMono(color: boneWhite)),
          ),
        ],
      ),
    );
  }

  void _activateBoutiqueCourtesy(BuildContext context, TravelAgency agency) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PROTOCOLO: Debes estar autenticado para activar cortesías.')),
      );
      return;
    }

    final success = await ref.read(referralServiceProvider).grantBoutiquePro(user.uid);
    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('CORTESÍA B2B: Modo Pro desbloqueado por 3 días gracias a ${agency.name}.',
            style: const TextStyle(color: Color(0xFFB35A38))), // oxidizedEarth
          backgroundColor: const Color(0xFF1A1A1A), // carbonBlack
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ERR: NO_SE_PUDO_ACTIVAR. Intenta más tarde.')),
      );
    }
  }

  void _showReviewDialog(BuildContext context, TravelAgency agency) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('LOG: AUTH_REQUIRED para dejar reseña.')),
      );
      return;
    }

    final commentController = TextEditingController();
    double currentRating = 5.0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: boneWhite,
        title: Text('NUEVA_RESEÑA', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RatingBar.builder(
              initialRating: 5,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(Icons.star, color: oxidizedEarth),
              onRatingUpdate: (rating) => currentRating = rating,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Cuéntanos tu experiencia...',
                border: const OutlineInputBorder(),
                focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: mossGreen)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () async {
              await ref.read(agencyServiceProvider).addReview(
                agencyId: agency.id,
                userId: user.uid,
                userName: user.displayName ?? 'Viajero Anónimo',
                userAvatar: user.photoURL ?? '',
                rating: currentRating,
                comment: commentController.text,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reseña enviada.')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: carbonBlack),
            child: const Text('ENVIAR', style: TextStyle(color: boneWhite)),
          ),
        ],
      ),
    );
  }
}

// Pequeño componente para el cursor parpadeante
class _BlinkingCursor extends StatefulWidget {
  @override
  _BlinkingCursorState createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 600), vsync: this)..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(width: 8, height: 14, color: const Color(0xFFF5F2ED)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}