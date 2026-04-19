import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:feeltrip_app/models/travel_agency_model.dart';


class AiProposalCard extends StatefulWidget {
  const AiProposalCard({
    super.key,
    required this.agency,
    required this.moodEmoji,
    required this.moodBadge,
    this.userCurrency = 'CLP', // Ajustado a tu contexto local
    this.onAdditionalTap,
  });

  final TravelAgency agency;
  final String moodEmoji;
  final String moodBadge;
  final String userCurrency;
  final VoidCallback? onAdditionalTap;

  @override
  State<AiProposalCard> createState() => _AiProposalCardState();
}

class _AiProposalCardState extends State<AiProposalCard> {
  String? _backgroundImage;
  Map<String, dynamic>? weather;
  Map<String, dynamic>? countryInfo;

  Widget _buildLoader() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildSpecialties(List<String> specialties) {
    return Wrap(
      spacing: 8,
      children: specialties.map((s) => Chip(label: Text(s))).toList(),
    );
  }
  // ... (Mantenemos tu lógica de carga de datos intacta)
  // Nota: Asegúrate de que DestinationService maneje bien los nulos

  bool _showLogistica = false;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Altura dinámica con feedback visual
    final double cardHeight = _showLogistica ? 350 : 260;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Hero(
        tag: 'ai-proposal-${widget.agency.id}',
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          height: cardHeight,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: colorScheme.tertiary.withValues(alpha: 0.05),
                blurRadius: 20,
              )
            ],
          ),
          child: _isLoading 
            ? _buildLoader() 
            : _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background con filtro oscuro para legibilidad
        ShaderMask(
          shaderCallback: (rect) => LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colorScheme.surface.withValues(alpha: 0.2), colorScheme.surface],
          ).createShader(rect),
          blendMode: BlendMode.darken,
          child: Image.network(
            _backgroundImage ?? '',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: Colors.grey[900]),
          ),
        ),

        // Mood Badge (Top Left) - Estilo Etiqueta Técnica
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: colorScheme.tertiary,
            child: Text(
              '${widget.moodEmoji} ${widget.moodBadge.toUpperCase()}',
              style: GoogleFonts.jetBrainsMono(
                color: colorScheme.onTertiary,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        ),

        // Info Principal
        Positioned(
          bottom: _showLogistica ? 120 : 20,
          left: 15,
          right: 15,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
Text(
              (widget.agency.name ?? '').toUpperCase(),
              style: GoogleFonts.playfairDisplay(
                color: colorScheme.onSurface,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
              const SizedBox(height: 5),
_buildSpecialties(widget.agency.specialties ?? []),
            ],
          ),
        ),

        // Botón de expansión (Logística)
        Positioned(
          right: 10,
          bottom: _showLogistica ? 125 : 15,
          child: IconButton(
            icon: Icon(
              _showLogistica ? Icons.keyboard_arrow_down : Icons.analytics_outlined,
              color: colorScheme.onSurface,
            ),
            onPressed: () {
              HapticFeedback.mediumImpact();
              setState(() => _showLogistica = !_showLogistica);
            },
          ),
        ),

        // Panel de Logística Expandido
        if (_showLogistica) _buildLogisticsPanel(context),
      ],
    );
  }

  Widget _buildLogisticsPanel(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: 110,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.95),
          border: Border(top: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.1))),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _logisticsItem(context, 'CLIMA', weather?['temp']?.toString() ?? '?', Icons.thermostat),
                _logisticsItem(context, 'MONEDA', (countryInfo?['currencies'] as Map?)?.keys.firstOrNull?.toString() ?? '?', Icons.payments),
                _logisticsItem(context, 'CAPITAL', (countryInfo?['capital'] as List?)?.firstOrNull?.toString() ?? '?', Icons.location_city),
              ],
            ),
            const Spacer(),
            // Acción final
            SizedBox(
              width: double.infinity,
              height: 35,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colorScheme.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: widget.onAdditionalTap,
                child: Text('VER RUTA COMPLETA', 
                  style: GoogleFonts.jetBrainsMono(color: colorScheme.primary, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _logisticsItem(BuildContext context, String label, String value, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.jetBrainsMono(fontSize: 8, color: Colors.white38)),
        Row(
          children: [
            Icon(icon, size: 12, color: colorScheme.tertiary),
            const SizedBox(width: 4),
            Text(value, style: GoogleFonts.jetBrainsMono(fontSize: 12, color: Colors.white)),
          ],
        ),
      ],
    );
  }
  
  // ... (buildLoader y buildSpecialties simplificados)
}