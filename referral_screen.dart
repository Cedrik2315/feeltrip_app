import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:feeltrip_app/services/deep_link_service.dart';

class ReferralPassport extends StatefulWidget {
  final String userReferralCode; // This would come from Firebase

  const ReferralPassport({super.key, required this.userReferralCode});

  @override
  State<ReferralPassport> createState() => _ReferralPassportState();
}

class _ReferralPassportState extends State<ReferralPassport> {
  String? _dynamicLink;
  bool _isLoadingLink = true;

  @override
  void initState() {
    super.initState();
    _generateDynamicLink();
  }

  Future<void> _generateDynamicLink() async {
    try {
      final link =
          await DeepLinkService().createReferralLink(widget.userReferralCode);
      setState(() {
        _dynamicLink = link;
        _isLoadingLink = false;
      });
    } catch (e) {
      // Fallback to static link if dynamic link fails
      setState(() {
        _dynamicLink = 'https://feeltrip.app/join/${widget.userReferralCode}';
        _isLoadingLink = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pasaporte de Invitación")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "CRECE TU TRIBU",
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
            const SizedBox(height: 10),
            const Text("Muestra este código para ganar un Escudo de Racha"),

            const SizedBox(height: 30),
            // QR with dynamic link
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber, width: 4),
              ),
              child: _isLoadingLink
                  ? const SizedBox(
                      width: 200,
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : QrImageView(
                      data: _dynamicLink ?? 'https://feeltrip.app',
                      version: QrVersions.auto,
                      size: 200.0,
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Color(0xFF0F0F1A),
                      ),
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Color(0xFF0F0F1A),
                      ),
                    ),
            ),

            const SizedBox(height: 20),
            // Copy code
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: widget.userReferralCode));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Código copiado al portapapeles')),
                );
              },
              child: Text(
                "Código: ${widget.userReferralCode} 📋",
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.amber),
              ),
            ),

            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _isLoadingLink
                  ? null
                  : () async {
                      final message = _dynamicLink != null
                          ? "¡Únete a mi expedición en FeelTrip! $_dynamicLink"
                          : "¡Únete a mi expedición! Usa mi código ${widget.userReferralCode}";
                      await Share.share(message);
                    },
              icon: const Icon(Icons.share),
              label: const Text("Enviar link de invitación"),
            ),
          ],
        ),
      ),
    );
  }
}
