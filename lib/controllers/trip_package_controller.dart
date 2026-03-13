import 'package:get/get.dart';

class TripPackage {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String purpose;
  final double price;

  const TripPackage({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.purpose,
    required this.price,
  });
}

class TripPackageController extends GetxController {
  final RxList<TripPackage> tripPackages = <TripPackage>[].obs;
  final RxString selectedPurpose = ''.obs;

  List<String> get availablePurposes {
    final purposes = <String>{'Todos'};
    purposes.addAll(tripPackages.map((p) => p.purpose));
    return purposes.toList();
  }

  List<TripPackage> get filteredPackages {
    if (selectedPurpose.value.isEmpty) {
      return tripPackages;
    }
    return tripPackages.where((p) => p.purpose == selectedPurpose.value).toList();
  }

  void setPurposeFilter(String purpose) {
    selectedPurpose.value = purpose == 'Todos' ? '' : purpose;
  }

  @override
  void onInit() {
    super.onInit();
    tripPackages.assignAll(const [
      TripPackage(
        id: '1',
        title: 'Escapada de Bienestar',
        subtitle: 'Respira y reconecta en la naturaleza.',
        imageUrl: '',
        purpose: 'Bienestar',
        price: 299.0,
      ),
      TripPackage(
        id: '2',
        title: 'Aventura Andina',
        subtitle: 'Ruta activa para renovar energia.',
        imageUrl: '',
        purpose: 'Aventura',
        price: 399.0,
      ),
      TripPackage(
        id: '3',
        title: 'Retiro Creativo',
        subtitle: 'Espacio para inspirarte y crear.',
        imageUrl: '',
        purpose: 'Creatividad',
        price: 349.0,
      ),
    ]);
  }
}
