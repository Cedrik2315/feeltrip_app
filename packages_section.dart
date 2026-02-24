import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:feeltrip_app/controllers/trip_package_controller.dart';
import 'package:feeltrip_app/widgets/trip_package_card.dart';

class PackagesSection extends StatelessWidget {
  late final TripPackageController controller;

  PackagesSection({super.key}) {
    // Inicialización segura del controlador
    if (Get.isRegistered<TripPackageController>()) {
      controller = Get.find<TripPackageController>();
    } else {
      controller = Get.put(TripPackageController());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Paquetes Destacados', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextButton(onPressed: () {}, child: const Text('Ver todo')),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Filtros por Propósito
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Obx(() => Row(
            children: controller.availablePurposes.map((purpose) {
              final isSelected = (purpose == 'Todos' && controller.selectedPurpose.value.isEmpty) || 
                                 (purpose == controller.selectedPurpose.value);
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(purpose),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) controller.setPurposeFilter(purpose);
                  },
                  selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? Theme.of(context).primaryColor : Colors.black,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            }).toList(),
          )),
        ),
        const SizedBox(height: 16),

        SizedBox(
          height: 280,
          child: Obx(() {
            if (controller.tripPackages.isEmpty) {
              return const Center(child: Text("Cargando paquetes..."));
            }
            final displayPackages = controller.filteredPackages;
            if (displayPackages.isEmpty) {
              return const Center(child: Text("No hay paquetes para este propósito"));
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              scrollDirection: Axis.horizontal,
              itemCount: displayPackages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: TripPackageCard(
                    package: displayPackages[index],
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/trip-details',
                      arguments: displayPackages[index].id,
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}