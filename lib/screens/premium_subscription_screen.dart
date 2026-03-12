import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../controllers/premium_controller.dart';

class PremiumSubscriptionScreen extends StatelessWidget {
  const PremiumSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PremiumController controller = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hazte Mecenas'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.offerings.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'No hay planes de suscripción disponibles en este momento. Por favor, intenta más tarde.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final offering = controller.offerings
            .firstWhereOrNull((o) => o.availablePackages.isNotEmpty);

        if (offering == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'No se encontraron paquetes de suscripción válidos.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.stars, size: 64, color: Colors.amber),
              const SizedBox(height: 16),
              Text(
                'Conviértete en Mecenas de FeelTrip',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Apoya nuestro proyecto y desbloquea beneficios exclusivos para llevar tus viajes al siguiente nivel.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
              const SizedBox(height: 32),
              _buildBenefitItem(Icons.money_off, 'Experiencia sin Anuncios',
                  'Navega por la app sin interrupciones.'),
              _buildBenefitItem(Icons.lock_open, 'Contenido Exclusivo',
                  'Accede a historias y guías de viaje premium.'),
              _buildBenefitItem(Icons.analytics, 'Estadísticas Avanzadas',
                  'Mide tu transformación con métricas detalladas.'),
              _buildBenefitItem(Icons.favorite, 'Apoya a los Creadores',
                  'Una parte de tu suscripción va a los creadores de historias.'),
              const SizedBox(height: 32),
              ...offering.availablePackages
                  .map((package) =>
                      _buildPackageCard(context, package, controller))
                  .toList(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.deepPurple, size: 30),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
    );
  }

  Widget _buildPackageCard(
      BuildContext context, Package package, PremiumController controller) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              package.storeProduct.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              package.storeProduct.description,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              package.storeProduct.priceString,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => controller.purchase(package),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Seleccionar Plan'),
            ),
          ],
        ),
      ),
    );
  }
}
