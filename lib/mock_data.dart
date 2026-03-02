import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/agency_model.dart';
import 'models/comment_model.dart';
import 'models/trip_model.dart';
import 'models/booking_model.dart';
import 'models/review_model.dart';
import 'models/user_model.dart';
import 'package:flutter/foundation.dart';

/// Datos MOCK para testing sin Firestore
/// Una vez arreglado Firebase, estos se pueden eliminar
class MockData {
  // Usuarios de prueba
  static final User testUser = User(
    id: 'user_1',
    email: 'juan.garcia@email.com',
    name: 'Juan GarcÃ­a',
    phone: '+34 612 345 678',
    profileImage: '',
    createdAt: DateTime(2024, 1, 15),
    favoriteTrips: ['trip_1', 'trip_3'],
  );

  // Viajes disponibles
  static final List<Trip> mockTrips = [
    Trip(
      id: 'trip_1',
      title: 'Auroras Boreales en TromsÃ¸',
      description:
          'Vive la magia de las auroras boreales bajo el cielo nocturno de TromsÃ¸. Un viaje de 5 dÃ­as explorando las luces mÃ¡s hermosas del planeta con la compaÃ±Ã­a de expertos locales.',
      destination: 'TromsÃ¸',
      country: 'Noruega',
      price: 1290.00,
      rating: 4.8,
      reviews: 248,
      duration: 5,
      difficulty: 'Moderado',
      images: [
        'https://images.unsplash.com/photo-1579033100235-f40c24f13083',
        'https://images.unsplash.com/photo-1506905925346-21bda4d32df4',
      ],
      highlights: [
        'Contemplar auroras boreales',
        'Paseo en trineo de perros',
        'Sauna tradicional noruega',
        'GastronomÃ­a local',
      ],
      startDate: DateTime(2026, 2, 15),
      endDate: DateTime(2026, 2, 20),
      maxParticipants: 20,
      currentParticipants: 12,
      category: 'Aventura',
      amenities: [
        'Alojamiento en cabaÃ±a',
        'Desayuno incluido',
        'GuÃ­a profesional',
        'Equipo de seguridad',
        'WiFi',
      ],
      guide: 'Magnus Erikson - GuÃ­a certificado en auroras boreales',
      isFeatured: true,
    ),
    Trip(
      id: 'trip_2',
      title: 'Cocina Toscana con Nonna',
      description:
          'Aprende a preparar los platos mÃ¡s autÃ©nticos de la cocina italiana junto a una familia toscana. 7 dÃ­as de experiencia gastronÃ³mica en el corazÃ³n de Italia.',
      destination: 'Toscana',
      country: 'Italia',
      price: 980.00,
      rating: 4.9,
      reviews: 156,
      duration: 7,
      difficulty: 'FÃ¡cil',
      images: [
        'https://images.unsplash.com/photo-1577003832154-bee79edf2d40',
        'https://images.unsplash.com/photo-1506905925346-21bda4d32df4',
      ],
      highlights: [
        'Clases de cocina tradicional',
        'Visita a mercados locales',
        'Cata de vinos toscanos',
        'DegustaciÃ³n de productos locales',
      ],
      startDate: DateTime(2026, 3, 10),
      endDate: DateTime(2026, 3, 17),
      maxParticipants: 8,
      currentParticipants: 5,
      category: 'GastronomÃ­a',
      amenities: [
        'Alojamiento en casa de campo',
        'Todas las comidas',
        'Transporte local',
        'Degustaciones',
      ],
      guide: 'Francesca Rossi - Chef y anfitriona local',
      isFeatured: true,
    ),
    Trip(
      id: 'trip_3',
      title: 'Bali Yoga Retreat',
      description:
          'Encuentra tu paz interior en los templos ancestrales de Bali. Un retiro de yoga de 10 dÃ­as en un paraÃ­so tropical con meditaciÃ³n, masajes y conexiÃ³n espiritual.',
      destination: 'Bali',
      country: 'Indonesia',
      price: 750.00,
      rating: 4.7,
      reviews: 312,
      duration: 10,
      difficulty: 'FÃ¡cil',
      images: [
        'https://images.unsplash.com/photo-1573346540319-403f5e0a7f1b',
        'https://images.unsplash.com/photo-1560493676-04071c5f467b',
      ],
      highlights: [
        'Clases diarias de yoga',
        'MeditaciÃ³n',
        'Masajes y tratamientos',
        'Visitas a templos sagrados',
      ],
      startDate: DateTime(2026, 4, 1),
      endDate: DateTime(2026, 4, 11),
      maxParticipants: 25,
      currentParticipants: 18,
      category: 'Bienestar',
      amenities: [
        'Resort de lujo',
        'Todas las comidas veganas',
        'Clases de yoga',
        'Spa',
        'WiFi',
      ],
      guide: 'Devi Wijaya - Instructora de yoga certificada',
      isFeatured: true,
    ),
    Trip(
      id: 'trip_4',
      title: 'Aventura en Machu Picchu',
      description:
          'Sube a la ciudadela perdida de los Incas en una expediciÃ³n de 6 dÃ­as. Camina por el Camino Inca y descubre la magia ancestral de Machu Picchu con guÃ­as expertos.',
      destination: 'Cusco',
      country: 'PerÃº',
      price: 1450.00,
      rating: 4.9,
      reviews: 189,
      duration: 6,
      difficulty: 'DifÃ­cil',
      images: [
        'https://images.unsplash.com/photo-1587595431973-160ef0d6470b',
        'https://images.unsplash.com/photo-1506905925346-21bda4d32df4',
      ],
      highlights: [
        'Camino Inca completo',
        'Machu Picchu al amanecer',
        'ArqueologÃ­a inca',
        'Comunidades locales',
      ],
      startDate: DateTime(2026, 5, 1),
      endDate: DateTime(2026, 5, 7),
      maxParticipants: 15,
      currentParticipants: 10,
      category: 'Aventura',
      amenities: [
        'GuÃ­a arqueolÃ³gico',
        'AclimataciÃ³n a altitud',
        'Comidas tradicionales',
        'Equipo de camping',
      ],
      guide: 'Carlos HuamÃ¡n - GuÃ­a especializado en historia inca',
      isFeatured: false,
    ),
    Trip(
      id: 'trip_5',
      title: 'ParÃ­s RomÃ¡ntico',
      description:
          'Experimenta la magia de la ciudad del amor. 5 dÃ­as recorriendo museos, cafÃ©s y monumentos icÃ³nicos de ParÃ­s con un guÃ­a local apasionado por la historia.',
      destination: 'ParÃ­s',
      country: 'Francia',
      price: 1100.00,
      rating: 4.6,
      reviews: 421,
      duration: 5,
      difficulty: 'FÃ¡cil',
      images: [
        'https://images.unsplash.com/photo-1502602898657-3e91760cbb34',
        'https://images.unsplash.com/photo-1506905925346-21bda4d32df4',
      ],
      highlights: [
        'Louvre y MusÃ©e d\'Orsay',
        'Torre Eiffel',
        'Crucero por el Sena',
        'Montmartre',
      ],
      startDate: DateTime(2026, 6, 1),
      endDate: DateTime(2026, 6, 6),
      maxParticipants: 30,
      currentParticipants: 22,
      category: 'Cultural',
      amenities: [
        'Hotel 4 estrellas',
        'Desayuno incluido',
        'Transporte pÃºblico',
        'Entradas a museos',
      ],
      guide: 'Sophie Dubois - Historiadora del arte',
      isFeatured: false,
    ),
  ];

  // ReseÃ±as de prueba
  static final List<Review> mockReviews = [
    Review(
      id: 'review_1',
      tripId: 'trip_1',
      userId: 'user_2',
      userName: 'MarÃ­a LÃ³pez',
      rating: 5.0,
      comment:
          'Una experiencia inolvidable. Las auroras boreales fueron espectaculares y nuestro guÃ­a fue excelente.',
      createdAt: DateTime(2026, 1, 10),
    ),
    Review(
      id: 'review_2',
      tripId: 'trip_1',
      userId: 'user_3',
      userName: 'Pedro MartÃ­nez',
      rating: 4.5,
      comment:
          'Muy bueno, aunque las auroras no siempre son garantizadas. El servicio fue perfecto.',
      createdAt: DateTime(2025, 12, 15),
    ),
    Review(
      id: 'review_3',
      tripId: 'trip_2',
      userId: 'user_4',
      userName: 'Andrea GÃ³mez',
      rating: 5.0,
      comment:
          'Nonna es increÃ­ble. AprendÃ­ autÃ©nticas recetas italianas y me trataron como familia.',
      createdAt: DateTime(2025, 11, 20),
    ),
  ];

  // Reservas de prueba
  static final List<Booking> mockBookings = [
    Booking(
      id: 'booking_1',
      userId: 'user_1',
      tripId: 'trip_1',
      tripTitle: 'Auroras Boreales en TromsÃ¸',
      numberOfPeople: 2,
      totalPrice: 2580.00,
      status: 'Confirmada',
      bookingDate: DateTime(2026, 1, 15),
      startDate: DateTime(2026, 2, 15),
      passengers: ['Juan GarcÃ­a', 'SofÃ­a GarcÃ­a'],
      paymentMethod: 'Tarjeta de CrÃ©dito',
      isPaid: true,
    ),
    Booking(
      id: 'booking_2',
      userId: 'user_1',
      tripId: 'trip_3',
      tripTitle: 'Bali Yoga Retreat',
      numberOfPeople: 1,
      totalPrice: 750.00,
      status: 'En Proceso',
      bookingDate: DateTime(2026, 1, 20),
      startDate: DateTime(2026, 4, 1),
      passengers: ['Juan GarcÃ­a'],
      paymentMethod: 'PayPal',
      isPaid: false,
    ),
  ];

  // ===== HISTORIAS MOCK =====
  static final List<Map<String, dynamic>> mockStories = [
    {
      'id': 'story_001',
      'title': 'Mi aventura en Patagonia',
      'story': 'Fue increÃ­ble caminar entre los glaciares. La naturaleza es majestuosa. '
          'Vi pingÃ¼inos y una ballena azul desde la orilla del fiordo.',
      'author': 'Juan PÃ©rez',
      'userId': 'user123',
      'rating': 4.8,
      'likes': 25,
      'emotionalHighlights': ['aventura', 'naturaleza'],
      'createdAt': Timestamp.now(),
      'imageUrl': 'https://via.placeholder.com/400x300?text=Patagonia',
    },
    {
      'id': 'story_002',
      'title': 'Atardecer en Bali',
      'story': 'El atardecer fue mÃ¡gico. Miles de turistas en las playas, pero el momento '
          'fue Ãºnico. ComprÃ© souvenirs locales y probÃ© comida tradicional balinesa.',
      'author': 'MarÃ­a GarcÃ­a',
      'userId': 'user456',
      'rating': 4.9,
      'likes': 42,
      'emotionalHighlights': ['romance', 'relajaciÃ³n'],
      'createdAt': Timestamp.now(),
      'imageUrl': 'https://via.placeholder.com/400x300?text=Bali+Sunset',
    },
    {
      'id': 'story_003',
      'title': 'Trek en PerÃº - Machu Picchu',
      'story': 'Una experiencia transformadora. Subir la montaÃ±a fue cansador pero '
          'gratificante. Ver Machu Picchu de frente cambiÃ³ mi perspectiva de la vida.',
      'author': 'Carlos LÃ³pez',
      'userId': 'user789',
      'rating': 5.0,
      'likes': 89,
      'emotionalHighlights': ['inspiraciÃ³n', 'aventura'],
      'createdAt': Timestamp.now(),
      'imageUrl': 'https://via.placeholder.com/400x300?text=Machu+Picchu',
    },
  ];

  // ===== COMENTARIOS MOCK =====
  static final Map<String, List<Map<String, dynamic>>> mockComments = {
    'story_001': [
      {
        'id': 'comment_001',
        'storyId': 'story_001',
        'userId': 'user456',
        'userName': 'MarÃ­a GarcÃ­a',
        'userAvatar': 'https://via.placeholder.com/40',
        'content': 'Â¡QuÃ© hermosa aventura! Me encantarÃ­a ir a Patagonia algÃºn dÃ­a.',
        'reactions': ['â¤ï¸', 'â¤ï¸', 'ðŸ˜'],
        'createdAt': Timestamp.now(),
        'likes': 3,
      },
      {
        'id': 'comment_002',
        'storyId': 'story_001',
        'userId': 'user789',
        'userName': 'Carlos LÃ³pez',
        'userAvatar': 'https://via.placeholder.com/40',
        'content': 'Los glaciares son impresionantes. El cambio climÃ¡tico es real.',
        'reactions': ['ðŸ”¥'],
        'createdAt': Timestamp.now(),
        'likes': 1,
      },
    ],
    'story_002': [
      {
        'id': 'comment_003',
        'storyId': 'story_002',
        'userId': 'user123',
        'userName': 'Juan PÃ©rez',
        'userAvatar': 'https://via.placeholder.com/40',
        'content': 'Bali es un paraÃ­so. Â¿QuÃ© hotel recomendarÃ­as?',
        'reactions': ['ðŸ˜', 'ðŸ˜'],
        'createdAt': Timestamp.now(),
        'likes': 2,
      },
    ],
    'story_003': [
      {
        'id': 'comment_004',
        'storyId': 'story_003',
        'userId': 'user456',
        'userName': 'MarÃ­a GarcÃ­a',
        'userAvatar': 'https://via.placeholder.com/40',
        'content': 'Machu Picchu es de otro mundo. Inspirador 100%',
        'reactions': ['â¤ï¸', 'â¤ï¸', 'â¤ï¸', 'ðŸ˜'],
        'createdAt': Timestamp.now(),
        'likes': 4,
      },
    ],
  };

  // ===== AGENCIAS MOCK =====
  static final List<Map<String, dynamic>> mockAgencies = [
    {
      'id': 'agency_001',
      'name': 'FeelTrip Adventures',
      'description': 'Agencia especializada en aventuras de naturaleza y experiencias transformadoras. '
          'Con mÃ¡s de 10 aÃ±os de experiencia en turismo responsable.',
      'logo': 'https://via.placeholder.com/200',
      'city': 'Buenos Aires',
      'country': 'Argentina',
      'latitude': -34.603,
      'longitude': -58.381,
      'specialties': ['adventure', 'nature'],
      'rating': 4.8,
      'reviewCount': 45,
      'followers': 250,
      'verified': true,
      'phoneNumber': '+54 11 1234 5678',
      'email': 'info@feeltrip.com',
      'website': 'www.feeltrip.com',
      'socialMedia': ['https://instagram.com/feeltrip', 'https://facebook.com/feeltrip'],
      'createdAt': Timestamp.now(),
    },
    {
      'id': 'agency_002',
      'name': 'Wanderlust Experiences',
      'description': 'Tours personalizados a los destinos mÃ¡s exÃ³ticos del mundo. '
          'Nuestro equipo te acompaÃ±arÃ¡ en cada paso de tu viaje.',
      'logo': 'https://via.placeholder.com/200',
      'city': 'Lima',
      'country': 'PerÃº',
      'latitude': -12.046,
      'longitude': -77.043,
      'specialties': ['culture', 'hiking', 'adventure'],
      'rating': 4.9,
      'reviewCount': 78,
      'followers': 412,
      'verified': true,
      'phoneNumber': '+51 1 456 7890',
      'email': 'contact@wanderlust.pe',
      'website': 'www.wanderlustexperiences.pe',
      'socialMedia': ['https://instagram.com/wanderlust', 'https://tiktok.com/@wanderlust'],
      'createdAt': Timestamp.now(),
    },
    {
      'id': 'agency_003',
      'name': 'Bali Dreams Travel',
      'description': 'Especialistas en destinos asiÃ¡ticos. Desde playas hasta templos, '
          'te llevamos a los lugares mÃ¡s especiales de Indonesia.',
      'logo': 'https://via.placeholder.com/200',
      'city': 'Denpasar',
      'country': 'Indonesia',
      'latitude': -8.667,
      'longitude': 115.217,
      'specialties': ['beach', 'culture', 'relaxation'],
      'rating': 4.7,
      'reviewCount': 56,
      'followers': 189,
      'verified': false,
      'phoneNumber': '+62 361 123 456',
      'email': 'hello@balidreams.id',
      'website': 'www.balidreamstravel.id',
      'socialMedia': ['https://instagram.com/balidreams'],
      'createdAt': Timestamp.now(),
    },
  ];

  /// Obtener todas las historias (simulando Firestore)
  static List<Trip> getStories() {
    return mockStories.map((data) {
      return Trip(
        id: data['id'],
        title: data['title'],
        description: data['story'],
        destination: data['author'],
        country: 'Argentina',
        price: 0.0,
        rating: data['rating'],
        reviews: 0,
        duration: 5,
        difficulty: 'FÃ¡cil',
        images: [data['imageUrl']],
        highlights: data['emotionalHighlights'],
        startDate: (data['createdAt'] as Timestamp).toDate(),
        endDate: (data['createdAt'] as Timestamp).toDate(),
        maxParticipants: 30,
        currentParticipants: 0,
        category: 'Aventura',
        amenities: [],
        guide: '',
        isFeatured: true,
        experienceType: 'adventure',
        emotions: [],
        learnings: [],
        transformationMessage: '',
        culturalConnections: [],
        isTransformative: false,
      );
    }).toList();
  }

  /// Obtener historia por ID
  static Trip? getStoryById(String id) {
    final data = mockStories.firstWhere(
      (story) => story['id'] == id,
      orElse: () => {},
    );
    if (data.isEmpty) return null;
    
    return Trip(
      id: data['id'],
      title: data['title'],
      description: data['story'],
      destination: data['author'],
      country: 'Argentina',
      price: 0.0,
      rating: data['rating'],
      reviews: 0,
      duration: 5,
      difficulty: 'FÃ¡cil',
      images: [data['imageUrl']],
      highlights: data['emotionalHighlights'],
      startDate: (data['createdAt'] as Timestamp).toDate(),
      endDate: (data['createdAt'] as Timestamp).toDate(),
      maxParticipants: 30,
      currentParticipants: 0,
      category: 'Aventura',
      amenities: [],
      guide: '',
      isFeatured: true,
      experienceType: 'adventure',
      emotions: [],
      learnings: [],
      transformationMessage: '',
      culturalConnections: [],
      isTransformative: false,
    );
  }

  /// Obtener comentarios por historia
  static List<Comment> getCommentsByStory(String storyId) {
    final comments = mockComments[storyId] ?? [];
    return comments.map((data) {
      return Comment(
        id: data['id'],
        storyId: data['storyId'],
        userId: data['userId'],
        userName: data['userName'],
        userAvatar: data['userAvatar'],
        content: data['content'],
        reactions: List<String>.from(data['reactions']),
        createdAt: data['createdAt'],
        likes: data['likes'],
      );
    }).toList();
  }

  /// Obtener todas las agencias
  static List<TravelAgency> getAgencies() {
    return mockAgencies.map((data) {
      return TravelAgency(
        id: data['id'],
        name: data['name'],
        description: data['description'],
        logo: data['logo'],
        city: data['city'],
        country: data['country'],
        latitude: data['latitude'],
        longitude: data['longitude'],
        specialties: List<String>.from(data['specialties']),
        rating: data['rating'].toDouble(),
        reviewCount: data['reviewCount'],
        followers: data['followers'],
        verified: data['verified'],
        phoneNumber: data['phoneNumber'],
        email: data['email'],
        website: data['website'],
        address: '${data['city']}, ${data['country']}',
        socialMedia: List<String>.from(data['socialMedia'] ?? {}),
        experiences: [],
        createdAt: data['createdAt'],
      );
    }).toList();
  }

  /// Obtener agencia por ID
  static TravelAgency? getAgencyById(String id) {
    final data = mockAgencies.firstWhere(
      (agency) => agency['id'] == id,
      orElse: () => {},
    );
    if (data.isEmpty) return null;
    
    return TravelAgency(
      id: data['id'],
      name: data['name'],
      description: data['description'],
      logo: data['logo'],
      city: data['city'],
      country: data['country'],
      latitude: data['latitude'],
      longitude: data['longitude'],
      specialties: List<String>.from(data['specialties']),
      rating: data['rating'].toDouble(),
      reviewCount: data['reviewCount'],
      followers: data['followers'],
      verified: data['verified'],
      phoneNumber: data['phoneNumber'],
      email: data['email'],
      website: data['website'],
      address: '${data['city']}, ${data['country']}',
      socialMedia: List<String>.from(data['socialMedia'] ?? []),
      experiences: [],
      createdAt: data['createdAt'],
    );
  }

  /// Obtener agencias por ciudad
  static List<TravelAgency> getAgenciesByCity(String city) {
    return mockAgencies
        .where((agency) => agency['city'].toLowerCase().contains(city.toLowerCase()))
        .map((data) {
      return TravelAgency(
        id: data['id'],
        name: data['name'],
        description: data['description'],
        logo: data['logo'],
        city: data['city'],
        country: data['country'],
        latitude: data['latitude'],
        longitude: data['longitude'],
        specialties: List<String>.from(data['specialties']),
        rating: data['rating'].toDouble(),
        reviewCount: data['reviewCount'],
        followers: data['followers'],
        verified: data['verified'],
        phoneNumber: data['phoneNumber'],
        email: data['email'],
        website: data['website'],
        address: '${data['city']}, ${data['country']}',
        socialMedia: List<String>.from(data['socialMedia'] ?? {}),
        experiences: [],
        createdAt: data['createdAt'],
      );
    }).toList();
  }
}

// FunciÃ³n para usar en pruebas
void main() {
  debugPrint('=== DATOS DE PRUEBA DISPONIBLES ===');
  debugPrint('Usuario: ${MockData.testUser.name}');
  debugPrint('Viajes disponibles: ${MockData.mockTrips.length}');
  debugPrint('ReseÃ±as: ${MockData.mockReviews.length}');
  debugPrint('Reservas: ${MockData.mockBookings.length}');
}
