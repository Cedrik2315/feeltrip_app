import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:feeltrip_app/services/nfc_service.dart';

class ArtifactLabScreen extends ConsumerStatefulWidget {
  final int viajeId;
  const ArtifactLabScreen({super.key, required this.viajeId});

  @override
  ConsumerState<ArtifactLabScreen> createState() => _ArtifactLabScreenState();
}

class _ArtifactLabScreenState extends ConsumerState<ArtifactLabScreen> {
  static const Color carbonBlack = Color(0xFF1A1A1A);
  static const Color neonPurple = Color(0xFFBC13FE);
  static const Color terminalGreen = Color(0xFF00FF41);
  static const Color boneWhite = Color(0xFFF5F5DC);

  String selectedProduct = 'POLERA SUBLIMADA';
  String selectedSize = 'L';
  Color selectedItemColor = Colors.black;
  bool isGeneratingImage = false;
  String? generatedImageUrl;

  @override
  void initState() {
    super.initState();
    _generateArtifactImage();
  }

  Future<void> _generateArtifactImage() async {
    setState(() => isGeneratingImage = true);
    // Simulación de latencia de GPU para generación de imagen por IA
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() {
        isGeneratingImage = false;
        // En un caso real, aquí obtendríamos la URL de DALL-E o Stable Diffusion
        generatedImageUrl = 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=1000&auto=format&fit=crop';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: carbonBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: boneWhite),
          onPressed: () => context.pop(),
        ),
        title: Text('LABORATORIO DE ARTEFACTOS', 
          style: GoogleFonts.jetBrainsMono(color: neonPurple, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('TRANSFORMA TU EXPEDICIÓN EN MATERIA', 
              style: GoogleFonts.ebGaramond(color: boneWhite, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Diseño algorítmico basado en tus coordenadas y emociones del Viaje #${widget.viajeId}.', 
              style: GoogleFonts.inter(color: boneWhite.withValues(alpha: 0.5), fontSize: 13)),
            
            const SizedBox(height: 32),
            
            // PREVISUALIZACIÓN DEL PRODUCTO
            _buildProductPreview(),
            
            const SizedBox(height: 40),
            
            // CONFIGURACIÓN
            Text('PERSONALIZACIÓN TÉCNICA', 
              style: GoogleFonts.jetBrainsMono(color: neonPurple, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 16),
            
            _buildOptionGroup('PRENDA', ['POLERA SUBLIMADA', 'TOTEBAG ECO', 'PÓSTER DE DATOS'], selectedProduct, (val) {
              setState(() => selectedProduct = val);
            }),
            
            const SizedBox(height: 24),
            
            _buildOptionGroup('TALLA', ['S', 'M', 'L', 'XL'], selectedSize, (val) {
              setState(() => selectedSize = val);
            }),
            
            const SizedBox(height: 48),
            
            // PRECIO Y ACCIÓN
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: neonPurple.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('VALOR TOTAL', style: GoogleFonts.jetBrainsMono(color: boneWhite.withValues(alpha: 0.5), fontSize: 10)),
                      Text('\$24.900 CLP', style: GoogleFonts.jetBrainsMono(color: boneWhite, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: isGeneratingImage ? null : () async {
                      HapticFeedback.heavyImpact();
                      // Simulación de compra exitosa
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('COMPRA EXITOSA: PROCESANDO TÓTEM...'), backgroundColor: Colors.green),
                      );
                      
                      // Mostrar diálogo de vinculación NFC
                      _showNfcLinkingDialog();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: neonPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('ADQUIRIR TÓTEM', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNfcLinkingDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: carbonBlack,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: neonPurple)),
        title: Text('VINCULACIÓN FÍSICA', style: GoogleFonts.jetBrainsMono(color: neonPurple, fontSize: 14)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.nfc, color: boneWhite, size: 48),
            const SizedBox(height: 16),
            Text('Acerca tu sticker NFC o prenda FeelTrip al reverso del dispositivo para grabar tu memoria.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: boneWhite, fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref.read(nfcServiceProvider).writeTripToArtifact(widget.viajeId);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('TÓTEM VINCULADO CORRECTAMENTE'), backgroundColor: Colors.purple),
                );
              }
            },
            child: Text('SIMULAR ACERCAMIENTO', style: GoogleFonts.jetBrainsMono(color: neonPurple)),
          ),
        ],
      ),
    );
  }

  Widget _buildProductPreview() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Mockup de la polera
          if (selectedProduct == 'POLERA SUBLIMADA')
            Icon(Icons.check_box_outline_blank, size: 300, color: boneWhite.withValues(alpha: 0.1)), 
          
          // La imagen generada por IA
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(color: neonPurple.withValues(alpha: 0.3), blurRadius: 40, spreadRadius: 5),
              ],
            ),
            child: isGeneratingImage 
              ? _buildGeneratorPlaceholder()
              : ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(generatedImageUrl!, fit: BoxFit.cover),
                ),
          ),
          
          // Overlay decorativo
          if (!isGeneratingImage)
            Positioned(
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: carbonBlack,
                child: Text('COORD: -32.8803, -71.2475', 
                  style: GoogleFonts.jetBrainsMono(color: terminalGreen, fontSize: 8)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGeneratorPlaceholder() {
    return Container(
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: neonPurple, strokeWidth: 2),
          const SizedBox(height: 16),
          Text('CANALIZANDO\nMEMORIAS...', 
            textAlign: TextAlign.center,
            style: GoogleFonts.jetBrainsMono(color: neonPurple, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildOptionGroup(String label, List<String> options, String selected, Function(String) onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.jetBrainsMono(color: boneWhite.withValues(alpha: 0.3), fontSize: 9)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: options.map((opt) {
            final isSelected = opt == selected;
            return GestureDetector(
              onTap: () => onSelect(opt),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? neonPurple.withValues(alpha: 0.1) : Colors.transparent,
                  border: Border.all(color: isSelected ? neonPurple : boneWhite.withValues(alpha: 0.1)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(opt, style: GoogleFonts.jetBrainsMono(color: isSelected ? neonPurple : boneWhite, fontSize: 10)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
