import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const Color boneWhite = Color(0xFFF5F5DC);
  static const Color terminalGreen = Color(0xFF00FF41);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('ESTATUTOS // PRIVACIDAD', 
          style: GoogleFonts.jetBrainsMono(fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.bold, color: boneWhite)),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: boneWhite),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PROTOCOLO DE PROTECCIÓN DE DATOS', 
              style: GoogleFonts.jetBrainsMono(fontSize: 14, color: terminalGreen, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(height: 1, width: 40, color: terminalGreen),
            const SizedBox(height: 32),
            
            _buildSection('1. RECOLECCIÓN DE TELEMETRÍA', 
              'FeelTrip recolecta información necesaria para tu expedición: correo electrónico, nombre, ubicación geográfica para el mapa de recuerdos y fotografías que decidas analizar con nuestra IA.'),
            
            _buildSection('2. PROCESAMIENTO IA (COGNITIVE LINK)', 
              'Utilizamos modelos de IA para generar crónicas de viaje. Tus fotos son procesadas de forma temporal y segura; FeelTrip no almacena rostros ni datos biométricos.'),
            
            _buildSection('3. SEGURIDAD DE DATOS OFFLINE', 
              'Tus diarios y momentos se guardan primero en tu dispositivo (criptografía local) y se sincronizan con la nube cuando detectamos conexión segura.'),
            
            _buildSection('04. TRANSACCIONES FINANCIERAS', 
              'Las transacciones son procesadas externamente por Mercado Pago. FeelTrip no almacena los datos de tu tarjeta de crédito o débito.'),
            
            _buildSection('05. DERECHOS DEL OPERADOR', 
              'Puedes solicitar la eliminación total de tu cuenta y datos desde la sección de Perfil o enviando un correo a soporte@feeltrip.app.'),
            
            _buildSection('06. ESTUDIOS DE TENDENCIAS', 
              'FeelTrip podrá utilizar datos agregados y totalmente anonimizados para realizar estudios sobre tendencias de viaje y turismo vivencial sin identificar nunca a individuos específicos.'),
            
            const SizedBox(height: 60),
            Center(
              child: Column(
                children: [
                  Text('FeelTrip Security Protocol v1.4', 
                    style: GoogleFonts.jetBrainsMono(fontSize: 8, color: boneWhite.withValues(alpha: 0.3))),
                  const SizedBox(height: 4),
                  Text('Última actualización: Abril 2026', 
                    style: GoogleFonts.jetBrainsMono(fontSize: 8, color: boneWhite.withValues(alpha: 0.3))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold, color: terminalGreen)),
          const SizedBox(height: 12),
          Text(content, style: GoogleFonts.ebGaramond(fontSize: 16, height: 1.5, color: boneWhite.withValues(alpha: 0.7))),
        ],
      ),
    );
  }
}
