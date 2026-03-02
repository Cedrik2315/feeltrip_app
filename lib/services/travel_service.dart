import 'package:url_launcher/url_launcher.dart';

class TravelService {
  // Función para abrir Airbnb con una búsqueda pre-configurada
  Future<void> buscarEnAirbnb(String destino) async {
    // Formateamos el destino para la URL (ej: "Toscana, Italia")
    final query = Uri.encodeComponent(destino);
    final url = Uri.parse("https://www.airbnb.com/s/$query/homes");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'No se pudo abrir la búsqueda de Airbnb';
    }
  }
}
