import 'package:flutter/material.dart';

class TravelDiaryScreen extends StatefulWidget {
  const TravelDiaryScreen({super.key});

  @override
  State<TravelDiaryScreen> createState() => _TravelDiaryScreenState();
}

class _TravelDiaryScreenState extends State<TravelDiaryScreen> {
  // late ExperienceController _controller;
  // bool _isAddingEntry = false;
  final _contentController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // // Get or create the controller
    // _controller = Get.isRegistered<ExperienceController>()
    //     ? Get.find<ExperienceController>()
    //     : Get.put(ExperienceController());

    // // Load diary entries if not already loaded
    // if (_controller.diaryEntries.isEmpty) {
    //   _controller.loadAllData();
    // }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Diario de Viaje'),
        backgroundColor: Colors.deepPurple,
      ),
      body: const Center(
        child: Text('Diario de viajes en construcción'),
      ),
    );
  }
}
