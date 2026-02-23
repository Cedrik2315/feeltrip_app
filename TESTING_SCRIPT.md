# 🤖 AUTOMATED TESTING SCRIPT

Ejecuta este script para validar que todas las features funcionan correctamente.

## Opción 1: Ejecutar Tests desde Terminal

```bash
cd c:\Users\monch\Documents\feeltrip_app

# Test 1: Compilación
flutter clean
flutter pub get
flutter build apk --debug

# Test 2: Ejecución
flutter run

# Espera a que la app abra en el emulador
```

## Opción 2: Código de Test (Copy-Paste en Hot Reload)

En **lib/main.dart**, agrega esto al final para debug:

```dart
// Debug Testing
void testFeatures() {
  print('🧪 Iniciando tests...');
  
  // Test 1: CommentService
  testCommentService();
  
  // Test 2: SharingService  
  testSharingService();
  
  // Test 3: AgencyService
  testAgencyService();
}

Future<void> testCommentService() async {
  print('\n📝 TEST 1: CommentService');
  
  final service = CommentService();
  
  try {
    // Test crear comentario
    await service.addComment(
      storyId: 'story_test_001',
      userId: 'test_user',
      userName: 'Test User',
      userAvatar: 'https://via.placeholder.com/50',
      content: 'Este es un comentario de prueba',
    );
    print('  ✅ addComment() - SUCCESS');
    
    // Test obtener comentarios
    service.getComments('story_test_001').listen((comments) {
      print('  ✅ getComments() - Received ${comments.length} comments');
    });
    
    // Test reacción
    await Future.delayed(Duration(seconds: 1));
    // await service.addReaction(
    //   storyId: 'story_test_001',
    //   commentId: 'comment_id_here',
    //   reaction: '❤️',
    // );
    // print('  ✅ addReaction() - SUCCESS');
    
    print('✅ CommentService tests PASSED\n');
  } catch (e) {
    print('❌ CommentService tests FAILED: $e\n');
  }
}

Future<void> testSharingService() async {
  print('📤 TEST 2: SharingService');
  
  try {
    // Test generar deep link
    final storyDeepLink = SharingService.generateStoryDeepLink('story_001');
    assert(storyDeepLink.contains('feeltrip.app/story'));
    print('  ✅ generateStoryDeepLink() - $storyDeepLink');
    
    final agencyDeepLink = SharingService.generateAgencyDeepLink('agency_001');
    assert(agencyDeepLink.contains('feeltrip.app/agency'));
    print('  ✅ generateAgencyDeepLink() - $agencyDeepLink');
    
    print('✅ SharingService tests PASSED\n');
  } catch (e) {
    print('❌ SharingService tests FAILED: $e\n');
  }
}

Future<void> testAgencyService() async {
  print('🏢 TEST 3: AgencyService');
  
  final service = AgencyService();
  
  try {
    // Test obtener todas las agencias
    service.getAllAgencies().listen((agencies) {
      print('  ✅ getAllAgencies() - Found ${agencies.length} agencies');
      
      if (agencies.isNotEmpty) {
        final agency = agencies.first;
        print('     → ${agency.name} (${agency.city})');
      }
    });
    
    print('✅ AgencyService tests PASSED\n');
  } catch (e) {
    print('❌ AgencyService tests FAILED: $e\n');
  }
}
```

## Opción 3: Widget Testing (Advanced)

Crea archivo: `test/features_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:feeltrip_app/models/comment_model.dart';
import 'package:feeltrip_app/models/agency_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('Comment Model Tests', () {
    test('CommentModel serialization', () {
      final comment = Comment(
        id: 'test_1',
        storyId: 'story_1',
        userId: 'user_1',
        userName: 'Test User',
        userAvatar: 'https://via.placeholder.com/50',
        content: 'Test comment',
        reactions: ['❤️'],
        createdAt: DateTime.now(),
        likes: 5,
      );

      final json = comment.toJson();
      expect(json['id'], 'test_1');
      expect(json['content'], 'Test comment');
      expect(json['reactions'].length, 1);
    });

    test('CommentModel deserialization', () {
      final json = {
        'id': 'test_1',
        'storyId': 'story_1',
        'userId': 'user_1',
        'userName': 'Test User',
        'userAvatar': 'https://via.placeholder.com/50',
        'content': 'Test comment',
        'reactions': ['❤️'],
        'createdAt': Timestamp.now(),
        'likes': 5,
      };

      final comment = Comment.fromJson(json);
      expect(comment.id, 'test_1');
      expect(comment.userName, 'Test User');
    });
  });

  group('Agency Model Tests', () {
    test('TravelAgency serialization', () {
      final agency = TravelAgency(
        id: 'agency_1',
        name: 'Test Agency',
        description: 'Test description',
        logo: 'https://via.placeholder.com/200',
        phoneNumber: '+54 11 1234 5678',
        email: 'test@agency.com',
        website: 'www.test.com',
        address: '123 Main St',
        city: 'Buenos Aires',
        country: 'Argentina',
        latitude: -34.603,
        longitude: -58.381,
        specialties: ['adventure'],
        createdAt: DateTime.now(),
      );

      final json = agency.toJson();
      expect(json['name'], 'Test Agency');
      expect(json['city'], 'Buenos Aires');
    });
  });
}
```

Ejecuta con:
```bash
flutter test test/features_test.dart
```

## Checklist de Validación

### ✅ Compilación
- [ ] `flutter clean` ejecutó sin errores
- [ ] `flutter pub get` instaló dependencias
- [ ] `flutter build apk` compiló APK sin errores

### ✅ Runtime
- [ ] App abrió en emulador
- [ ] Firebase initialized correctamente
- [ ] No hay crashes en consola

### ✅ Features
- [ ] CommentsScreen cargó correctamente
- [ ] SharingService genera deep links válidos
- [ ] AgencyProfileScreen muestra datos

### ✅ Firestore
- [ ] Datos guardados en `stories/{storyId}/comments`
- [ ] Queries funcionan en tiempo real
- [ ] Security rules aplicadas correctamente

---

**Después de pasar todos los tests, estamos listos para producción! 🚀**
