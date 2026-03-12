import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomMapScreen extends StatefulWidget {
  final String userPersonality;

  const CustomMapScreen({super.key, required this.userPersonality});

  @override
  State<CustomMapScreen> createState() => _CustomMapScreenState();
}

class _CustomMapScreenState extends State<CustomMapScreen> {
  GoogleMapController? _mapController;
  late String _currentStyle;
  String? _mapStyleJson;

  @override
  void initState() {
    super.initState();
    // Inicializa el estilo con la personalidad obtenida del quiz.
    _currentStyle = widget.userPersonality;
    _applyMapStyle(_currentStyle);
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  /// Se llama solo una vez cuando el mapa es creado.
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  /// Carga y aplica un estilo al mapa actualizando el estado.
  void _applyMapStyle(String userPersonality) async {
    String? style;
    String? stylePath;

    if (userPersonality == 'Retro') {
      stylePath = 'assets/maps/retro_style.json';
    } else if (userPersonality == 'Cyberpunk') {
      stylePath = 'assets/maps/cyberpunk_style.json';
    } else {
      // Para el estilo por defecto, el estilo JSON es null.
      style = null;
    }

    if (stylePath != null) {
      // Carga el archivo JSON del estilo desde los assets.
      style = await DefaultAssetBundle.of(context).loadString(stylePath);
    }

    if (!mounted) return;
    setState(() {
      _currentStyle = userPersonality;
      _mapStyleJson = style;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Emociones'),
        actions: [
          // Menú para cambiar el estilo del mapa en tiempo real.
          PopupMenuButton<String>(
            icon: const Icon(Icons.palette_outlined),
            tooltip: 'Cambiar estilo',
            onSelected: (String value) {
              _applyMapStyle(value);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                  value: 'Retro', child: Text('Estilo Retro')),
              const PopupMenuItem<String>(
                  value: 'Cyberpunk', child: Text('Estilo Cyberpunk')),
              const PopupMenuItem<String>(
                  value: 'Default', child: Text('Estilo por Defecto')),
            ],
          ),
        ],
      ),
      body: GoogleMap(
        style: _mapStyleJson,
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target:
              LatLng(-32.8833, -71.25), // Coordenadas de Quillota como ejemplo
          zoom: 12,
        ),
      ),
    );
  }
}
