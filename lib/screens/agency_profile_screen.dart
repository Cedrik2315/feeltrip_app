import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/travel_agency_model.dart';
import '../services/agency_service.dart';
import '../services/sharing_service.dart';

class AgencyProfileScreen extends StatefulWidget {
  const AgencyProfileScreen({
    super.key,
    required this.agencyId,
  });
  final String agencyId;

  @override
  State<AgencyProfileScreen> createState() => _AgencyProfileScreenState();
}

class _AgencyProfileScreenState extends State<AgencyProfileScreen> {
  final AgencyService _agencyService = AgencyService();
  late Future<TravelAgency?> _agencyFuture;

  // Paleta de Colores Oficial FeelTrip
  static const Color boneWhite = Color(0xFFF5F2ED); // Tono papel más natural
  static const Color carbonBlack = Color(0xFF1A1A1A);
  static const Color mossGreen = Color(0xFF4A5D4E);
  static const Color oxidizedEarth = Color(0xFFB35A38);

  @override
  void initState() {
    super.initState();
    _agencyFuture = _agencyService.getAgencyById(widget.agencyId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TravelAgency?>(
      future: _agencyFuture,
      builder: (context, snapshot) {
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

                      // Botón de Acción Principal (Terminal Style)
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: OutlinedButton(
                          onPressed: () => _agencyService.followAgency(agency.id),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: carbonBlack,
                            side: const BorderSide(color: carbonBlack),
                            shape: const RoundedRectangleBorder(), // Rectangular para estética técnica
                          ),
                          child: Text(
                            '>> EJECUTAR: SEGUIR_AGENCIA',
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