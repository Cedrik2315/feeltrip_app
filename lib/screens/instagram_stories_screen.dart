import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class InstagramStory {
  final String id;
  final String imageUrl;
  final String text;
  final DateTime expiresAt;

  InstagramStory({
    required this.id,
    required this.imageUrl,
    required this.text,
    required this.expiresAt,
  });
}

class InstagramStoriesScreen extends StatefulWidget {
  const InstagramStoriesScreen({super.key});

  @override
  State<InstagramStoriesScreen> createState() => _InstagramStoriesScreenState();
}

class _InstagramStoriesScreenState extends State<InstagramStoriesScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;
  final List<InstagramStory> stories = [
    InstagramStory(
      id: '1',
      imageUrl:
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
      text: 'Tromsø bajo la aurora 🌌',
      expiresAt: DateTime.now().add(const Duration(hours: 20)),
    ),
    InstagramStory(
      id: '2',
      imageUrl:
          'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=400',
      text: 'Valle Sagrado, Perú ❤️',
      expiresAt: DateTime.now().add(const Duration(hours: 22)),
    ),
    InstagramStory(
      id: '3',
      imageUrl:
          'https://images.unsplash.com/photo-1571896349840-e26f4eee2ea0?w=400',
      text: 'Nonna en Toscana 🇮🇹',
      expiresAt: DateTime.now().add(const Duration(hours: 18)),
    ),
    InstagramStory(
      id: '4',
      imageUrl:
          'https://images.unsplash.com/photo-1519046904884-53103b34b206?w=400',
      text: 'Yoga en Bali 🧘‍♀️',
      expiresAt: DateTime.now().subtract(const Duration(hours: 2)), // Expired
    ),
    InstagramStory(
      id: '5',
      imageUrl:
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
      text: 'Queenstown Bungee 🪂',
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    final activeStories =
        stories.where((s) => s.expiresAt.isAfter(DateTime.now())).toList();
    if (activeStories.isEmpty) {
      // Navigator.pop(context);
    } else {
      _pageController = PageController();
      _startTimer(activeStories.length);
    }
  }

  void _startTimer(int storyCount) {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_currentIndex < storyCount - 1) {
        _pageController.nextPage(
            duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
      } else {
        timer.cancel();
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeStories =
        stories.where((s) => s.expiresAt.isAfter(DateTime.now())).toList();
    if (activeStories.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.hourglass_empty, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('No hay stories disponibles\n(Expiradas o ninguna)'),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
              _timer?.cancel();
              _startTimer(activeStories.length - index);
            },
            itemCount: activeStories.length,
            itemBuilder: (context, index) {
              final story = activeStories[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: story.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: Colors.black),
                    errorWidget: (context, url, error) =>
                        Container(color: Colors.grey),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            story.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Expira: ${story.expiresAt.toLocal().toString().substring(0, 16)}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          // Top progress bars
          Positioned(
            top: MediaQuery.of(context).padding.top + 40,
            left: 16,
            right: 16,
            child: Row(
              children: List.generate(activeStories.length, (index) {
                final isActive = _currentIndex == index;
                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 3,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.white : Colors.white38,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          // Swipe hints
          Positioned(
            right: 40,
            bottom: 100,
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! > 0) {
                  _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn);
                }
              },
              child: const Icon(Icons.arrow_back_ios,
                  color: Colors.white70, size: 30),
            ),
          ),
          Positioned(
            left: 40,
            bottom: 100,
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! < 0) {
                  _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn);
                }
              },
              child: const Icon(Icons.arrow_forward_ios,
                  color: Colors.white70, size: 30),
            ),
          ),
          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const CircleAvatar(
                backgroundColor: Colors.black54,
                child: Icon(Icons.close, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
