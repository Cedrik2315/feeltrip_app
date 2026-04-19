import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/agency_service.dart';
// Unused import removed
import 'package:go_router/go_router.dart';

class AgenciesMapScreen extends StatefulWidget {
  const AgenciesMapScreen({super.key});

  @override
  State<AgenciesMapScreen> createState() => _AgenciesMapScreenState();
}

class _AgenciesMapScreenState extends State<AgenciesMapScreen> {
  final AgencyService _agencyService = AgencyService();
  Set<Marker> _markers = {};
  String _selectedArchetype = 'TODOS';
  
  // Arquetipos FeelTrip (vínculo con specialties de agencia)
  final List<String> _archetypes = ['TODOS', 'CONECTOR', 'TRANSFORMADO', 'AVENTURERO', 'CONTEMPLATIVO', 'APRENDIZ'];

  @override
  void initState() {
    super.initState();
    _loadAgencies();
  }

  void _loadAgencies() {
    _agencyService.getAgenciesByArchetype(_selectedArchetype).listen((agencies) {
      if (!mounted) return;
      final newMarkers = agencies.map((agency) {
        return Marker(
          markerId: MarkerId(agency.id),
          position: LatLng(agency.latitude, agency.longitude),
          infoWindow: InfoWindow(
            title: agency.name,
            snippet: '${agency.rating} ⭐ | ${agency.city}',
            onTap: () => context.push('/agency/${agency.id}'),
          ),
        );
      }).toSet();

      setState(() {
        _markers = newMarkers;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text('MAP_FILTER_v1.0', style: GoogleFonts.jetBrainsMono(fontSize: 14, color: Colors.white)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _buildFilterBar(),
        ),
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(-33.4489, -70.6693), // Coordenada base
          zoom: 11,
        ),
        markers: _markers,
        myLocationEnabled: true,
        mapToolbarEnabled: false,
        style: _darkMapStyle,
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 60,
      color: const Color(0xFF1A1A1A),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: _archetypes.length,
        itemBuilder: (context, index) {
          final archetype = _archetypes[index];
          final isSelected = _selectedArchetype == archetype;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(archetype, style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedArchetype = archetype;
                    _loadAgencies();
                  });
                }
              },
              selectedColor: const Color(0xFFB35A38),
              backgroundColor: const Color(0xFF4A5D4E).withValues(alpha: 0.3),
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70),
            ),
          );
        },
      ),
    );
  }

  // Estilo visual del mapa para mantener la coherencia mística/tecnológica
  static const String _darkMapStyle = '''
  [
    { "elementType": "geometry", "stylers": [ { "color": "#212121" } ] },
    { "elementType": "labels.text.fill", "stylers": [ { "color": "#757575" } ] }
  ]
  ''';
}