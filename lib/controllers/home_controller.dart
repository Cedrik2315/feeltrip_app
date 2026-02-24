import '../models/experience_model.dart';
import '../models/trip_model.dart';
import '../services/api_service.dart';

class HomeController {
  HomeController(this._apiService);

  final ApiService _apiService;

  Future<List<Trip>> loadFeaturedTrips() async {
    final trips = await _apiService.getTrips();
    return trips.where((trip) => trip.isFeatured).take(5).toList();
  }

  List<TravelerStory> loadMockStories() {
    return [
      TravelerStory(
        id: '1',
        author: 'María García',
        title: 'Bajo la aurora boreal',
        story:
            'En Tromsø vimos las luces del norte y algo cambió dentro de mí. Lloré de alegría al ver la naturaleza en su máxima expresión.',
        emotionalHighlights: const ['Asombro', 'Gratitud', 'Transformación'],
        likes: 347,
        rating: 5.0,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      TravelerStory(
        id: '2',
        author: 'Juan López',
        title: 'Conexión en Perú',
        story:
            'Conocí a una familia quechua en el valle sagrado. Compartimos comida, risas e historias. Aprendí que la verdadera riqueza está en las conexiones humanas.',
        emotionalHighlights: const ['Conexión', 'Paz', 'Esperanza'],
        likes: 512,
        rating: 5.0,
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
      ),
      TravelerStory(
        id: '3',
        author: 'Isabella Romano',
        title: 'El legado de mi nonna',
        story:
            'Volvimos a Italia después de 40 años. Encontramos la casa de mis abuelos y conocimos primos que no sabía que existían. Mi identidad cobró nuevo sentido.',
        emotionalHighlights: const ['Nostalgia', 'Reflexión', 'Pertenencia'],
        likes: 289,
        rating: 4.8,
        createdAt: DateTime.now().subtract(const Duration(days: 21)),
      ),
    ];
  }
}

