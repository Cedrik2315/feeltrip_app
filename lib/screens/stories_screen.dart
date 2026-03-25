import 'package:flutter/material.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key, this.tripId});

  final String? tripId;

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  // late ExperienceController _controller;
  // final TextEditingController _searchController = TextEditingController();
  // final RxList<TravelerStory> _filteredStories = <TravelerStory>[].obs;
  // String? _selectedTag;

  @override
  void initState() {
    super.initState();
    // _controller = Get.isRegistered<ExperienceController>()
    //     ? Get.find<ExperienceController>()
    //     : Get.put(ExperienceController());

    // if (_controller.stories.isEmpty) {
    //   _controller.loadAllData();
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historias de Viaje'),
        backgroundColor: Colors.deepPurple,
      ),
      body: const Center(
        child: Text('Funcionalidad de Stories pendiente de refactorización'),
      ),
    );
  }
}
