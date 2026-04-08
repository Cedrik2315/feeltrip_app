import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class DestinationMapWidget extends StatefulWidget {
  const DestinationMapWidget({
    required this.destination,
    required this.latitude,
    required this.longitude,
    super.key,
  });
  
  final String destination;
  final double latitude;
  final double longitude;

  @override
  State<DestinationMapWidget> createState() => _DestinationMapWidgetState();
}

class _DestinationMapWidgetState extends State<DestinationMapWidget> {
  GoogleMapController? _controller;

  // Estilo Dark/Retro para el mapa (JSON simplificado)
  final String _darkMapStyle = '''
  [
    {"elementType": "geometry", "stylers": [{"color": "#212121"}]},
    {"elementType": "labels.text.fill", "stylers": [{"color": "#757575"}]},
    {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#000000"}]},
    {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#424242"}]}
  ]
  ''';

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header del Radar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'COORDENADAS DE DESTINO',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFF8F00),
                ),
              ),
              Text(
                '${widget.latitude.toStringAsFixed(4)} , ${widget.longitude.toStringAsFixed(4)}',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  color: isDark ? Colors.white30 : Colors.black26,
                ),
              ),
            ],
          ),
        ),
        
        Container(
          height: 200,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
          ),
          child: Stack(
            children: [
              GoogleMap(
                style: isDark ? _darkMapStyle : null,
                initialCameraPosition: CameraPosition(
                  target: LatLng(widget.latitude, widget.longitude),
                  zoom: 12,
                ),
                onMapCreated: (controller) {
                  _controller = controller;
                },
                markers: {
                  Marker(
                    markerId: const MarkerId('destination'),
                    position: LatLng(widget.latitude, widget.longitude),
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
                  ),
                },
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                myLocationButtonEnabled: false,
              ),
              
              // Overlay de "Scan" visual sutil
              IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.1),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}