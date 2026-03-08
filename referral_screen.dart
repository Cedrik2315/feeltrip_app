import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class ReferralPassport extends StatelessWidget {
  final String userReferralCode = "EXPLORA-2026"; // Esto vendría de Firebase

  const ReferralPassport({super.key});

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
            // El QR con estilo FeelTrip
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber, width: 4),
              ),
              child: QrImageView(
                data: "https://feeltrip.app/join/$userReferralCode",
                version: QrVersions.auto,
                size: 200.0,
                // Configuración de color para versiones recientes de qr_flutter
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Color(0xFF0F0F1A), // Nuestro azul oscuro
                ),
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Color(0xFF0F0F1A),
                ),
              ),
            ),

            const SizedBox(height: 20),
            // Código en texto para copiar
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: userReferralCode));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Código copiado al portapapeles')),
                );
              },
              child: Text(
                "Código: $userReferralCode 📋",
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.amber),
              ),
            ),

            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => Share.share(
                  "¡Únete a mi expedición! Usa mi código $userReferralCode"),
              icon: const Icon(Icons.share),
              label: const Text("Enviar link de invitación"),
            ),
          ],
        ),
      ),
    );
  }
}
