import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class MetricsDashboardScreen extends ConsumerWidget {
  const MetricsDashboardScreen({super.key});

  // Paleta FeelTrip_OS
  static const Color boneWhite = Color(0xFFF5F5DC);
  static const Color carbon = Color(0xFF1A1A1A);
  static const Color amberStatus = Color(0xFFFFBF00);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: boneWhite,
      appBar: AppBar(
        title: Text(
          'TELEMETRÍA_SISTEMA',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 14, 
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2
          ),
        ),
        backgroundColor: carbon,
        foregroundColor: boneWhite,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusHeader(),
              const SizedBox(height: 40),
              
              Text(
                'EVENTOS_FIREBASE_ACTIVOS',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11, 
                  fontWeight: FontWeight.bold, 
                  color: carbon.withValues(alpha: 0.5)
                ),
              ),
              const SizedBox(height: 16),
              
              _buildEventLogList(),
              
              const SizedBox(height: 40),
              _buildFirebaseConsoleLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: carbon,
        borderRadius: BorderRadius.zero, // Estética industrial
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_outlined, color: amberStatus, size: 20),
              const SizedBox(width: 12),
              Text(
                'MODO_PRODUCCIÓN: ON',
                style: GoogleFonts.jetBrainsMono(
                  color: amberStatus, 
                  fontWeight: FontWeight.bold, 
                  fontSize: 13
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'El flujo de datos local ha sido desviado. Todas las interacciones de los exploradores están siendo indexadas en Firebase Analytics Cloud.',
            style: GoogleFonts.inter(
              color: boneWhite.withValues(alpha: 0.7), 
              fontSize: 13,
              height: 1.5
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventLogList() {
    final List<Map<String, dynamic>> activeEvents = [
      {'name': 'SIGNUP_INIT', 'desc': 'Registro de nuevo explorador', 'icon': Icons.person_add_alt},
      {'name': 'DESTINATION_SEARCH', 'desc': 'Consulta de coordenadas/destinos', 'icon': Icons.radar},
      {'name': 'MOMENT_SYNC', 'desc': 'Persistencia de recuerdos visuales', 'icon': Icons.sync},
      {'name': 'PREMIUM_TIER_VIEW', 'desc': 'Acceso a catálogo de expedición Pro', 'icon': Icons.workspace_premium_outlined},
      {'name': 'TX_COMPLETED', 'desc': 'Confirmación de pago exitosa', 'icon': Icons.receipt_long},
      {'name': 'EXPEDITION_SHARED', 'desc': 'Difusión de ruta por el usuario', 'icon': Icons.ios_share},
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: carbon.withValues(alpha: 0.1)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: activeEvents.length,
        separatorBuilder: (_, __) => Divider(
          height: 1, 
          color: carbon.withValues(alpha: 0.05),
          indent: 50,
        ),
        itemBuilder: (context, index) {
          final event = activeEvents[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: carbon.withValues(alpha: 0.05),
                shape: BoxShape.circle
              ),
              child: Icon(event['icon'] as IconData, color: carbon, size: 18),
            ),
            title: Text(
              event['name'] as String,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12, 
                fontWeight: FontWeight.bold,
                color: carbon
              ),
            ),
            subtitle: Text(
              event['desc'] as String,
              style: GoogleFonts.inter(fontSize: 11, color: carbon.withValues(alpha: 0.6)),
            ),
            trailing: const Icon(Icons.check_circle, color: Colors.green, size: 14),
          );
        },
      ),
    );
  }

  Widget _buildFirebaseConsoleLink() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: boneWhite,
        border: Border.all(color: carbon, width: 0.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_queue_rounded, color: carbon, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FIREBASE_CONSOLE_REMOTE',
                  style: GoogleFonts.jetBrainsMono(
                    fontWeight: FontWeight.bold, 
                    fontSize: 11
                  ),
                ),
                Text(
                  'Visualiza el RTDB y el DebugView en tiempo real.',
                  style: GoogleFonts.inter(
                    fontSize: 11, 
                    color: carbon.withValues(alpha: 0.5)
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: carbon),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: Text(
              'CONECTAR',
              style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold, color: carbon),
            ),
          )
        ],
      ),
    );
  }
}