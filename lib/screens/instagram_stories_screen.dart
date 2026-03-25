import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../services/storage_service.dart';
import 'dart:io';

class InstagramStoriesScreen extends StatefulWidget {
  const InstagramStoriesScreen({super.key});

  @override
  State<InstagramStoriesScreen> createState() => _InstagramStoriesScreenState();
}

class _InstagramStoriesScreenState extends State<InstagramStoriesScreen> {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentIndex = 0;
  List<Map<String, dynamic>> _stories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  Future<void> _loadStories() async {
    FirebaseFirestore.instance
        .collection('instagram_stories')
        .where('expiresAt', isGreaterThan: Timestamp.now())
        .orderBy('expiresAt')
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _stories = snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
          _isLoading = false;
        });
        if (_stories.isNotEmpty) _startTimer();
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 5), () {
      if (_currentIndex < _stories.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      } else {
        if (mounted) Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _createStory() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final url = await StorageService.uploadStoryPhoto(File(image.path), uid);
    if (url == null) return;

    await FirebaseFirestore.instance.collection('instagram_stories').add({
      'userId': uid,
      'imageUrl': url,
      'createdAt': Timestamp.now(),
      'expiresAt': Timestamp.fromDate(
        DateTime.now().add(const Duration(hours: 24)),
      ),
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (_stories.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: Text('No hay stories activas', style: TextStyle(color: Colors.white)),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _createStory,
          child: const Icon(Icons.add),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _stories.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
              _startTimer();
            },
            itemBuilder: (context, index) {
              final story = _stories[index];
              return GestureDetector(
                onTapDown: (details) {
                  final width = MediaQuery.of(context).size.width;
                  if (details.globalPosition.dx < width / 2) {
                    if (_currentIndex > 0) {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    }
                  } else {
                    if (_currentIndex < _stories.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    }
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    image: story['imageUrl'] != null
                        ? DecorationImage(
                            image: NetworkImage(story['imageUrl'] as String),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: Colors.grey[900],
                  ),
                ),
              );
            },
          ),
          // Barra de progreso
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            right: 8,
            child: Row(
              children: List.generate(_stories.length, (index) {
                return Expanded(
                  child: Container(
                    height: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: index <= _currentIndex
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          // Botón cerrar
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.close, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createStory,
        child: const Icon(Icons.add),
      ),
    );
  }
}
