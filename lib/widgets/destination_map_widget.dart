import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DestinationMapWidget extends StatefulWidget {
  final String destination;
  final double latitude;
  final double longitude;

  const DestinationMapWidget({
    super.key,
    required this.destination,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<DestinationMapWidget> createState() => _DestinationMapWidgetState();
}

class _DestinationMapWidgetState extends State<DestinationMapWidget> {
  // ignore: unused_field
  GoogleMapController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 200,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(widget.latitude, widget.longitude),
            zoom: 12,
          ),
          onMapCreated: (controller) => _controller = controller,
          markers: {
            Marker(
              markerId: const MarkerId('destination'),
              position: LatLng(widget.latitude, widget.longitude),
              infoWindow: InfoWindow(title: widget.destination),
            ),
          },
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),
      ),
    );
  }
}
