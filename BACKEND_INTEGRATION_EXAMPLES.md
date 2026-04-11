# 💻 Ejemplos de Integración Backend

Este archivo muestra cómo integrar los nuevos modelos con Firebase y API REST.

---

## 1. Firebase Firestore Integration

### Estructura de Colecciones
```
firestore/
├── users/
│   └── {userId}/
│       ├── profile/
│       │   ├── name: String
│       │   ├── email: String
│       │   └── archetype: String (CONECTOR, TRANSFORMADO, etc.)
│       │
│       ├── stories/ (subcollection)
│       │   └── {storyId}/ → TravelerStory
│       │
│       ├── diaryEntries/ (subcollection)
│       │   └── {entryId}/ → DiaryEntry
│       │
│       └── impactMetrics/ (subcollection)
│           └── {timestamp}/ → ExperienceImpact
│
├── stories/ (public collection)
│   └── {storyId}/ → TravelerStory + userId ref
│
└── trips/
    └── {tripId}/
        ├── baseFields...
        ├── experienceType: String
        ├── emotions: List<String>
        ├── learnings: List<String>
        └── isTransformative: bool
```

### Implementation en Dart

#### Model Extension para Firestore
```dart
// experience_model.dart - agregar estos métodos

extension ExperienceImpactFirestore on ExperienceImpact {
  Map<String, dynamic> toFirestore() {
    return {
      'emotions': emotions,
      'learnings': learnings,
      'transformationStory': transformationStory,
      'impactScore': impactScore,
      'connectedSouls': connectedSouls,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  static ExperienceImpact fromFirestore(Map<String, dynamic> data) {
    return ExperienceImpact(
      emotions: List<String>.from(data['emotions'] ?? []),
      learnings: List<String>.from(data['learnings'] ?? []),
      transformationStory: data['transformationStory'] ?? '',
      impactScore: (data['impactScore'] ?? 0).toInt(),
      connectedSouls: List<String>.from(data['connectedSouls'] ?? []),
    );
  }
}

extension TravelerStoryFirestore on TravelerStory {
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'author': author,
      'title': title,
      'story': story,
      'emotionalHighlights': emotionalHighlights,
      'likes': likes,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static TravelerStory fromFirestore(Map<String, dynamic> data) {
    return TravelerStory(
      id: data['id'] ?? '',
      author: data['author'] ?? '',
      title: data['title'] ?? '',
      story: data['story'] ?? '',
      emotionalHighlights: List<String>.from(data['emotionalHighlights'] ?? []),
      likes: data['likes'] ?? 0,
      rating: (data['rating'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

extension DiaryEntryFirestore on DiaryEntry {
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'location': location,
      'content': content,
      'emotions': emotions,
      'reflectionDepth': reflectionDepth,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static DiaryEntry fromFirestore(Map<String, dynamic> data) {
    return DiaryEntry(
      id: data['id'] ?? '',
      location: data['location'] ?? '',
      content: data['content'] ?? '',
      emotions: List<String>.from(data['emotions'] ?? []),
      reflectionDepth: data['reflectionDepth'] ?? 1,
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
```

#### Service para Manejo de Historias
```dart
// services/story_service.dart (nuevo archivo)

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/experience_model.dart';

class StoryService {
  static final StoryService _instance = StoryService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  factory StoryService() {
    return _instance;
  }

  StoryService._internal();

  // Obtener todas las historias públicas
  Future<List<TravelerStory>> getPublicStories() async {
    try {
      final snapshot = await _firestore
          .collection('stories')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs
          .map((doc) => TravelerStory.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching stories: $e');
      return [];
    }
  }

  // Obtener historias por usuario
  Future<List<TravelerStory>> getUserStories(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('stories')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => TravelerStory.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching user stories: $e');
      return [];
    }
  }

  // Crear nueva historia
  Future<void> createStory(String userId, TravelerStory story) async {
    try {
      // Guardar en colección privada del usuario
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('stories')
          .doc(story.id)
          .set(story.toFirestore());

      // Publicar en colección pública
      await _firestore
          .collection('stories')
          .doc(story.id)
          .set({
            ...story.toFirestore(),
            'userId': userId,
            'published': true,
          });
    } catch (e) {
      print('Error creating story: $e');
      rethrow;
    }
  }

  // Dar like a una historia
  Future<void> likeStory(String storyId) async {
    try {
      await _firestore
          .collection('stories')
          .doc(storyId)
          .update({'likes': FieldValue.increment(1)});
    } catch (e) {
      print('Error liking story: $e');
      rethrow;
    }
  }

  // Eliminar historia
  Future<void> deleteStory(String userId, String storyId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('stories')
          .doc(storyId)
          .delete();

      await _firestore.collection('stories').doc(storyId).delete();
    } catch (e) {
      print('Error deleting story: $e');
      rethrow;
    }
  }
}
```

#### Service para Manejo de Diario
```dart
// services/diary_service.dart (nuevo archivo)

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/experience_model.dart';

class DiaryService {
  static final DiaryService _instance = DiaryService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  factory DiaryService() {
    return _instance;
  }

  DiaryService._internal();

  // Obtener entradas del diario
  Future<List<DiaryEntry>> getUserDiaryEntries(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('diaryEntries')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => DiaryEntry.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching diary entries: $e');
      return [];
    }
  }

  // Crear entrada de diario
  Future<void> createDiaryEntry(String userId, DiaryEntry entry) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('diaryEntries')
          .doc(entry.id)
          .set(entry.toFirestore());

      // Actualizar estadísticas del usuario
      await _updateUserStats(userId);
    } catch (e) {
      print('Error creating diary entry: $e');
      rethrow;
    }
  }

  // Actualizar entrada
  Future<void> updateDiaryEntry(
      String userId, DiaryEntry entry) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('diaryEntries')
          .doc(entry.id)
          .update(entry.toFirestore());

      await _updateUserStats(userId);
    } catch (e) {
      print('Error updating diary entry: $e');
      rethrow;
    }
  }

  // Eliminar entrada
  Future<void> deleteDiaryEntry(String userId, String entryId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('diaryEntries')
          .doc(entryId)
          .delete();

      await _updateUserStats(userId);
    } catch (e) {
      print('Error deleting diary entry: $e');
      rethrow;
    }
  }

  // Helper privado: actualizar estadísticas
  Future<void> _updateUserStats(String userId) async {
    try {
      final entries = await getUserDiaryEntries(userId);

      if (entries.isEmpty) return;

      // Calcular promedios
      double avgDepth = entries
          .map((e) => e.reflectionDepth)
          .reduce((a, b) => a + b) /
          entries.length;

      // Contar emociones únicas
      final uniqueEmotions = <String>{};
      for (var entry in entries) {
        uniqueEmotions.addAll(entry.emotions);
      }

      // Calcular impacto general
      int impactScore = ((avgDepth / 5) * 100).toInt();

      // Guardar estadísticas
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
            'diaryStats': {
              'entryCount': entries.length,
              'avgReflectionDepth': avgDepth,
              'uniqueEmotionCount': uniqueEmotions.length,
              'overallImpactScore': impactScore,
              'lastEntryDate': entries.first.createdAt.toIso8601String(),
            },
          });
    } catch (e) {
      print('Error updating user stats: $e');
    }
  }
}
```

---

## 2. API REST Integration

Si prefieres REST sobre Firestore:

```dart
// services/experience_api_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/experience_model.dart';

class ExperienceApiService {
  static const String baseUrl = 'https://api.feeltrip.com/api';
  final http.Client _httpClient;
  final String? _authToken;

  ExperienceApiService(this._httpClient, this._authToken);

  // ============ STORIES ============

  Future<List<TravelerStory>> getStories() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/stories'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => TravelerStory.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load stories');
      }
    } catch (e) {
      print('Error fetching stories: $e');
      rethrow;
    }
  }

  Future<List<TravelerStory>> getUserStories(String userId) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/users/$userId/stories'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => TravelerStory.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load user stories');
      }
    } catch (e) {
      print('Error fetching user stories: $e');
      rethrow;
    }
  }

  Future<TravelerStory> createStory(
      String userId, TravelerStory story) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/users/$userId/stories'),
        headers: _getHeaders(),
        body: json.encode(story.toJson()),
      );

      if (response.statusCode == 201) {
        return TravelerStory.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create story');
      }
    } catch (e) {
      print('Error creating story: $e');
      rethrow;
    }
  }

  Future<void> likeStory(String storyId) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/stories/$storyId/like'),
        headers: _getHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to like story');
      }
    } catch (e) {
      print('Error liking story: $e');
      rethrow;
    }
  }

  // ============ DIARY ============

  Future<List<DiaryEntry>> getDiaryEntries(String userId) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/users/$userId/diary'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => DiaryEntry.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load diary entries');
      }
    } catch (e) {
      print('Error fetching diary entries: $e');
      rethrow;
    }
  }

  Future<DiaryEntry> createDiaryEntry(
      String userId, DiaryEntry entry) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/users/$userId/diary'),
        headers: _getHeaders(),
        body: json.encode(entry.toJson()),
      );

      if (response.statusCode == 201) {
        return DiaryEntry.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create diary entry');
      }
    } catch (e) {
      print('Error creating diary entry: $e');
      rethrow;
    }
  }

  // ============ IMPACT ============

  Future<ExperienceImpact> getImpact(String userId) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/users/$userId/impact'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return ExperienceImpact.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load impact data');
      }
    } catch (e) {
      print('Error fetching impact: $e');
      rethrow;
    }
  }

  Future<ExperienceImpact> calculateImpact(String userId) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/users/$userId/impact/calculate'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return ExperienceImpact.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to calculate impact');
      }
    } catch (e) {
      print('Error calculating impact: $e');
      rethrow;
    }
  }

  // ============ QUIZ ============

  Future<String> saveQuizResult(String userId, Map<String, dynamic> result) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/users/$userId/quiz-result'),
        headers: _getHeaders(),
        body: json.encode(result),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['archetype'];
      } else {
        throw Exception('Failed to save quiz result');
      }
    } catch (e) {
      print('Error saving quiz result: $e');
      rethrow;
    }
  }

  // ============ HELPERS ============

  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      if (_authToken != null) 'Authorization': 'Bearer $_authToken',
    };
  }
}
```

---

## 3. GetX State Management (Recomendado)

```dart
// controllers/experience_controller.dart

import 'package:get/get.dart';
import '../models/experience_model.dart';
import '../services/story_service.dart';
import '../services/diary_service.dart';

class ExperienceController extends GetxController {
  final StoryService _storyService = StoryService();
  final DiaryService _diaryService = DiaryService();

  RxList<TravelerStory> stories = <TravelerStory>[].obs;
  RxList<DiaryEntry> diaryEntries = <DiaryEntry>[].obs;
  Rx<ExperienceImpact?> impact = Rx<ExperienceImpact?>(null);
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  String? userId;

  @override
  void onInit() {
    super.onInit();
    // Obtener userId de almacenamiento o controller de auth
    loadAllData();
  }

  Future<void> loadAllData() async {
    try {
      isLoading.value = true;
      await Future.wait([
        loadStories(),
        loadDiaryEntries(),
      ]);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadStories() async {
    try {
      final fetchedStories = await _storyService.getPublicStories();
      stories.assignAll(fetchedStories);
    } catch (e) {
      print('Error loading stories: $e');
    }
  }

  Future<void> loadDiaryEntries() async {
    if (userId == null) return;
    try {
      final entries = await _diaryService.getUserDiaryEntries(userId!);
      diaryEntries.assignAll(entries);
    } catch (e) {
      print('Error loading diary: $e');
    }
  }

  Future<void> addDiaryEntry(DiaryEntry entry) async {
    if (userId == null) return;
    try {
      await _diaryService.createDiaryEntry(userId!, entry);
      diaryEntries.insert(0, entry);
    } catch (e) {
      errorMessage.value = 'Error: $e';
    }
  }

  Future<void> addStory(TravelerStory story) async {
    if (userId == null) return;
    try {
      await _storyService.createStory(userId!, story);
      stories.insert(0, story);
    } catch (e) {
      errorMessage.value = 'Error: $e';
    }
  }

  Future<void> likeStory(String storyId) async {
    try {
      await _storyService.likeStory(storyId);
      final index = stories.indexWhere((s) => s.id == storyId);
      if (index != -1) {
        stories[index].likes++;
        stories.refresh();
      }
    } catch (e) {
      print('Error liking story: $e');
    }
  }
}
```

---

## 4. Uso en Pantallas

```dart
// stories_screen.dart - con backend integrado

class StoriesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ExperienceController>();

    return Scaffold(
      appBar: AppBar(title: Text('Historias de Transformación')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.stories.isEmpty) {
          return Center(child: Text('No hay historias aún'));
        }

        return ListView.builder(
          itemCount: controller.stories.length,
          itemBuilder: (context, index) {
            final story = controller.stories[index];
            return _buildStoryCard(story, () {
              controller.likeStory(story.id);
            });
          },
        );
      }),
    );
  }

  Widget _buildStoryCard(TravelerStory story, VoidCallback onLike) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: Text(story.author[0])),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(story.author, style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(story.title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber),
                    Text('${story.rating}'),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(story.story),
            SizedBox(height: 12),
            Wrap(
              spacing: 6,
              children: story.emotionalHighlights
                  .map((e) => Chip(label: Text(e)))
                  .toList(),
            ),
            SizedBox(height: 8),
            GestureDetector(
              onTap: onLike,
              child: Row(
                children: [
                  Icon(Icons.favorite, size: 16, color: Colors.red),
                  SizedBox(width: 4),
                  Text('${story.likes}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 5. Modelos JSON Esperados

### Story JSON
```json
{
  "id": "story_001",
  "author": "María García",
  "title": "Bajo la aurora boreal",
  "story": "En Tromsø, vimos las luces...",
  "emotionalHighlights": ["Asombro", "Gratitud", "Transformación"],
  "likes": 347,
  "rating": 5.0,
  "createdAt": "2024-01-15T10:30:00Z"
}
```

### DiaryEntry JSON
```json
{
  "id": "diary_001",
  "location": "Tromsø, Noruega",
  "content": "Reflexión personal aquí...",
  "emotions": ["Asombro", "Gratitud"],
  "reflectionDepth": 5,
  "createdAt": "2024-01-16T14:20:00Z"
}
```

### ExperienceImpact JSON
```json
{
  "emotions": ["Asombro", "Gratitud", "Paz"],
  "learnings": ["Aceptación", "Compasión"],
  "transformationStory": "Mi viaje me enseñó...",
  "impactScore": 75,
  "connectedSouls": ["user_002", "user_003"]
}
```

---

## 6. Instalación de Dependencias

```yaml
# pubspec.yaml - agregar estas líneas

dependencies:
  firebase_core: ^2.32.0
  cloud_firestore: ^4.17.5
  firebase_auth: ^4.16.0
  http: ^0.13.6
  get: ^4.7.3
```

```bash
flutter pub get
```

---

## 7. Testing Unitario Ejemplo

```dart
// test/services/story_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feeltrip_app/services/story_service.dart';
import 'package:feeltrip_app/models/experience_model.dart';

void main() {
  group('StoryService Tests', () {
    late StoryService storyService;

    setUp(() {
      storyService = StoryService();
    });

    test('getPublicStories returns list of stories', () async {
      final stories = await storyService.getPublicStories();
      expect(stories, isA<List<TravelerStory>>());
    });

    test('createStory adds story to database', () async {
      final story = TravelerStory(
        id: 'test_story',
        author: 'Test Author',
        title: 'Test Story',
        story: 'Test content',
        emotionalHighlights: ['Alegría'],
        likes: 0,
        rating: 5.0,
        createdAt: DateTime.now(),
      );

      await storyService.createStory('test_user', story);
      // Assert con Firestore mock
    });
  });
}
```

---

**Próximo Paso**: Elegir entre Firebase (recomendado para inicio rápido) o API REST (más escalable) según tus necesidades.

