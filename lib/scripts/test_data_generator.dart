import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

/// Script para crear datos de prueba en Firestore
/// Ejecutar una sola vez para llenar la base de datos con datos para testing

class TestDataGenerator {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Crear datos de prueba completos
  static Future<void> generateAllTestData() async {
    // log eliminado: 🚀 Generando datos de prueba...

    try {
      await generateTestStories();
      await generateTestAgencies();
      // log eliminado: ✅ Datos de prueba generados exitosamente
    } catch (e) {
      // log eliminado: ❌ Error generando datos de prueba: $e
    }
  }

  /// Crear historias de prueba
  static Future<void> generateTestStories() async {
    print('📝 Generando historias de prueba...');

    final stories = [
      {
        'title': 'Mi aventura en Patagonia',
        'story':
            'Fue increíble caminar entre los glaciares. La naturaleza es majestuosa y te llena el alma.',
        'author': 'Juan Pérez',
        'userId': 'test_user_1',
        'rating': 4.8,
        'likes': 25,
        'emotionalHighlights': ['aventura', 'naturaleza', 'reflexión'],
        'createdAt': Timestamp.now(),
      },
      {
        'title': 'Yoga en Bali',
        'story':
            'Una experiencia transformadora. El atardecer sobre el océano mientras practicas yoga es simplemente mágico.',
        'author': 'Maria García',
        'userId': 'test_user_2',
        'rating': 4.9,
        'likes': 42,
        'emotionalHighlights': ['tranquilidad', 'transformación', 'conexión'],
        'createdAt': Timestamp.now(),
      },
      {
        'title': 'Aventura en Nueva Zelanda',
        'story':
            'Skydiving sobre Queenstown fue el momento más emocionante de mi vida. Puro adrenalina y belleza.',
        'author': 'Carlos López',
        'userId': 'test_user_3',
        'rating': 4.7,
        'likes': 18,
        'emotionalHighlights': ['adrenalina', 'valentía', 'belleza'],
        'createdAt': Timestamp.now(),
      },
      {
        'title': 'Gastronomía en Italia',
        'story':
            'Pasé 10 días descubriendo los sabores auténticos de Italia. Cada comida era un viaje sensorial.',
        'author': 'Ana Martínez',
        'userId': 'test_user_4',
        'rating': 4.6,
        'likes': 31,
        'emotionalHighlights': ['sabor', 'cultura', 'placer'],
        'createdAt': Timestamp.now(),
      },
    ];

    for (var story in stories) {
      final storyId = const Uuid().v4();
      await _firestore.collection('stories').doc(storyId).set({
        'id': storyId,
        ...story,
      });
      print('  ✅ Story creada: ${story['title']}');
    }
  }

  /// Crear agencias de prueba
  static Future<void> generateTestAgencies() async {
    print('🏢 Generando agencias de prueba...');

    final agencies = [
      {
        'name': 'FeelTrip Adventures',
        'description':
            'Especialistas en experiencias de aventura auténtica en América Latina. Con 15 años de experiencia en turismo vivencial.',
        'logo': 'https://via.placeholder.com/200?text=FeelTrip+Adventures',
        'city': 'Buenos Aires',
        'country': 'Argentina',
        'latitude': -34.603,
        'longitude': -58.381,
        'specialties': ['adventure', 'cultural'],
        'rating': 4.8,
        'reviewCount': 45,
        'followers': 250,
        'verified': true,
        'phoneNumber': '+54 11 1234 5678',
        'email': 'info@feeltripadventures.com',
        'website': 'www.feeltripadventures.com',
        'socialMedia': [
          'instagram.com/feeltripadventures',
          'facebook.com/feeltripadventures'
        ],
        'createdAt': Timestamp.now(),
      },
      {
        'name': 'Serenity Retreat',
        'description':
            'Retiros de bienestar y transformación. Yoga, meditación y conexión con la naturaleza en destinos paradisíacos.',
        'logo': 'https://via.placeholder.com/200?text=Serenity+Retreat',
        'city': 'Bali',
        'country': 'Indonesia',
        'latitude': -8.6705,
        'longitude': 115.2126,
        'specialties': ['relaxation', 'spiritual'],
        'rating': 4.9,
        'reviewCount': 68,
        'followers': 380,
        'verified': true,
        'phoneNumber': '+62 361 1234 567',
        'email': 'hello@serenityretreat.com',
        'website': 'www.serenityretreat.com',
        'socialMedia': [
          'instagram.com/serenityretreat',
          'facebook.com/serenityretreat'
        ],
        'createdAt': Timestamp.now(),
      },
      {
        'name': 'Kiwi Extreme Sports',
        'description':
            'Experiencias de adrenalina y deportes extremos en Nueva Zelanda. Para los que buscan emociones fuertes.',
        'logo': 'https://via.placeholder.com/200?text=Kiwi+Extreme',
        'city': 'Queenstown',
        'country': 'New Zealand',
        'latitude': -42.4316,
        'longitude': 171.1787,
        'specialties': ['adventure', 'extreme_sports'],
        'rating': 4.7,
        'reviewCount': 52,
        'followers': 310,
        'verified': true,
        'phoneNumber': '+64 3 442 7100',
        'email': 'contact@kiwiextreme.com',
        'website': 'www.kiwiextreme.com',
        'socialMedia': [
          'instagram.com/kiwiextreme',
          'facebook.com/kiwiextreme'
        ],
        'createdAt': Timestamp.now(),
      },
      {
        'name': 'Dolce Vita Tours',
        'description':
            'Tours gastronómicos y culturales en Italia. Descubre la autenticidad italiana comiendo como un local.',
        'logo': 'https://via.placeholder.com/200?text=Dolce+Vita',
        'city': 'Roma',
        'country': 'Italy',
        'latitude': 41.9028,
        'longitude': 12.4964,
        'specialties': ['cultural', 'gastronomy'],
        'rating': 4.6,
        'reviewCount': 75,
        'followers': 420,
        'verified': true,
        'phoneNumber': '+39 06 1234 5678',
        'email': 'ciao@dolcevitours.com',
        'website': 'www.dolcevitours.com',
        'socialMedia': [
          'instagram.com/dolcevitours',
          'facebook.com/dolcevitours'
        ],
        'createdAt': Timestamp.now(),
      },
    ];

    for (var agency in agencies) {
      final agencyId = const Uuid().v4();
      await _firestore.collection('agencies').doc(agencyId).set({
        'id': agencyId,
        ...agency,
      });
      print('  ✅ Agencia creada: ${agency['name']}');
    }
  }
}
