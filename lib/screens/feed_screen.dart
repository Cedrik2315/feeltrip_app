import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/firebase_config.dart';
import '../models/experience_model.dart';
import '../services/story_service.dart';
import 'stories_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final StoryService _storyService = StoryService();

  List<TravelerStory> _stories = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool get _hasMore => _lastDocument != null;

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  Future<void> _loadStories() async {
    if (_isLoading) return;
    _isLoading = true;
    if (mounted) setState(() {});

    try {
      final fetchedStories = await _storyService.getPublicStories(limit: 10);
      _stories = fetchedStories;
      if (fetchedStories.isNotEmpty) {
        final lastStoryDocId = fetchedStories.last.id;
        final lastDoc = await FirebaseFirestore.instance
            .collection(FirebaseConfig.storiesCollection)
            .doc(lastStoryDocId)
            .get();
        _lastDocument = lastDoc;
      } else {
        _lastDocument = null;
      }
    } catch (e) {
      print('Error loading stories: $e');
    }
    _isLoading = false;
    if (mounted) setState(() {});
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore || _isLoading) return;
    _isLoadingMore = true;
    if (mounted) setState(() {});

    try {
      final firestore = FirebaseFirestore.instance;
      final query = firestore
          .collection(FirebaseConfig.storiesCollection)
          .orderBy(FirebaseConfig.createdAtField, descending: true)
          .startAfterDocument(_lastDocument!)
          .limit(10);
      final snapshot = await query.get();
      final newStories =
          snapshot.docs.map((doc) => TravelerStory.fromFirestore(doc)).toList();
      _stories.addAll(newStories);
      if (newStories.isNotEmpty) {
        final lastStoryDocId = newStories.last.id;
        final lastDoc = await firestore
            .collection(FirebaseConfig.storiesCollection)
            .doc(lastStoryDocId)
            .get();
        _lastDocument = lastDoc;
      } else {
        _lastDocument = null;
      }
    } catch (e) {
      print('Error loading more stories: $e');
    }
    _isLoadingMore = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed Público'),
        backgroundColor: Colors.deepPurple,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _stories.clear();
          _lastDocument = null;
          await _loadStories();
        },
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _stories.isEmpty
                ? const Center(child: Text('No hay historias'))
                : ListView.builder(
                    itemCount: _stories.length +
                        (_isLoadingMore ? 1 : 0) +
                        (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _stories.length) {
                        if (_isLoadingMore) {
                          return const Center(
                              child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ));
                        }
                        if (_hasMore) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ElevatedButton(
                                onPressed: _loadMore,
                                child: const Text('Cargar más'),
                              ),
                            ),
                          );
                        }
                      }
                      final story = _stories[index];
                      return ListTile(
                        title: Text(story.title),
                        subtitle: Text(story.story),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${story.likes}'),
                            IconButton(
                              icon: const Icon(Icons.share),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const StoriesScreen()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
