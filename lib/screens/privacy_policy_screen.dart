import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Política de Privacidad'),
        backgroundColor: Colors.deepPurple,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Política de Privacidad',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'En FeelTrip, tu privacidad es importante para nosotros. Esta política explica qué información recopilamos y cómo la usamos.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '1. Información que Recopilamos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Recopilamos la información que nos proporcionas directamente, como tu nombre, email y contenido que publicas. También recopilamos datos de uso de la aplicación para mejorar nuestros servicios.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '2. Cómo Usamos tu Información',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Utilizamos tu información para operar y mejorar la aplicación, personalizar tu experiencia, comunicarnos contigo y para fines de seguridad. No compartiremos tu información personal con terceros sin tu consentimiento, excepto cuando sea requerido por la ley.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '3. Seguridad de los Datos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Tomamos medidas razonables para proteger tu información contra pérdida, robo y uso no autorizado. Sin embargo, ningún método de transmisión por Internet es 100% seguro.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Última actualización: 03 de Marzo de 2026',
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
