import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../models/trip_model.dart';
import '../models/experience_model.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Trip>> _trips;
  int _carouselIndex = 0;
  List<Trip> _featuredTrips = [];
  List<TravelerStory> _stories = [];

  @override
  void initState() {
    super.initState();
    _trips = _apiService.getTrips();
    _loadFeaturedTrips();
    _loadStories();
  }

  void _loadFeaturedTrips() {
    _apiService.getTrips().then((trips) {
      setState(() {
        _featuredTrips =
            trips.where((trip) => trip.isFeatured).toList().take(5).toList();
      });
    });
  }

  void _loadStories() {
    // Mock stories data
    setState(() {
      _stories = [
        TravelerStory(
          id: '1',
          author: 'María García',
          title: 'Bajo la aurora boreal',
          story:
              'En Tromsø, vimos las luces del norte y algo cambió dentro de mí. Lloré de alegría viendo la naturaleza en su máxima expresión.',
          emotionalHighlights: ['Asombro', 'Gratitud', 'Transformación'],
          likes: 347,
          rating: 5.0,
          createdAt: DateTime.now().subtract(Duration(days: 7)),
        ),
        TravelerStory(
          id: '2',
          author: 'Juan López',
          title: 'Conexión en Perú',
          story:
              'Conocí a una familia quechua en el valle sagrado. Compartimos comida, risas y historias. Aprendí que la verdadera riqueza está en las conexiones humanas.',
          emotionalHighlights: ['Conexión', 'Paz', 'Esperanza'],
          likes: 512,
          rating: 5.0,
          createdAt: DateTime.now().subtract(Duration(days: 14)),
        ),
        TravelerStory(
          id: '3',
          author: 'Isabella Romano',
          title: 'El legado de mi nonna',
          story:
              'Volvimos a Italia después de 40 años. Encontramos la casa de mis abuelos y conocimos primos que no sabía que existían. Mi identidad cobró nuevo sentido.',
          emotionalHighlights: ['Nostalgia', 'Reflexión', 'Pertenencia'],
          likes: 289,
          rating: 4.8,
          createdAt: DateTime.now().subtract(Duration(days: 21)),
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FeelTrip - Viajes Transformadores'),
        elevation: 0,
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Banner - Experiencias Vivenciales
            Container(
              color: Colors.deepPurple,
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✨ Viajes que Transforman',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No solo viajes, sino experiencias que cambian tu perspectiva de vida',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar destino transformador...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.calendar_today),
                          label: Text('Fechas'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.deepPurple,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.people),
                          label: Text('Viajeros'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.deepPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // CTA: Descubre tu tipo de viajero
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple[300]!, Colors.deepPurple],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      '🎯 Descubre Tu Tipo de Viajero',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Responde nuestro quiz para recibir recomendaciones personalizadas basadas en tus valores y emociones',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/quiz');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.deepPurple,
                        ),
                        child: Text('Empezar Quiz'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Traveler Archetypes
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tipos de Experiencias',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildArchetypeCard(
                          '💕',
                          'Conector',
                          'Conexiones humanas\ny culturales',
                          Colors.red,
                        ),
                        _buildArchetypeCard(
                          '🦋',
                          'Transformado',
                          'Crecimiento personal\ny reflexión',
                          Colors.deepPurple,
                        ),
                        _buildArchetypeCard(
                          '⚡',
                          'Aventurero',
                          'Adrenalina y\nnuevas emociones',
                          Colors.orange,
                        ),
                        _buildArchetypeCard(
                          '🌅',
                          'Contemplativo',
                          'Paz interior y\nconexión con la naturaleza',
                          Colors.cyan,
                        ),
                        _buildArchetypeCard(
                          '📚',
                          'Aprendiz',
                          'Conocimiento y\ndescubrimiento',
                          Colors.green,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Featured Transformative Trips
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Viajes Destacados',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  if (_featuredTrips.isNotEmpty)
                    Column(
                      children: [
                        CarouselSlider.builder(
                          itemCount: _featuredTrips.length,
                          options: CarouselOptions(
                            height: 250,
                            autoPlay: true,
                            enlargeCenterPage: true,
                            onPageChanged: (index, reason) {
                              setState(() {
                                _carouselIndex = index;
                              });
                            },
                          ),
                          itemBuilder: (context, index, realIndex) {
                            final trip = _featuredTrips[index];
                            return TripCard(trip: trip);
                          },
                        ),
                        SizedBox(height: 12),
                        AnimatedSmoothIndicator(
                          activeIndex: _carouselIndex,
                          count: _featuredTrips.length,
                          effect: ExpandingDotsEffect(),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Historias de Viajeros Transformados
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Historias de Transformación',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed('/stories');
                        },
                        child: Text(
                          'Ver todas',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  ..._stories
                      .take(2)
                      .map((story) => _buildStoryPreviewCard(story))
                      .toList(),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Quick Access Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mi Experiencia',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickAccessCard(
                          '📔',
                          'Mi Diario',
                          'Registra tus emociones',
                          () {
                            Navigator.of(context).pushNamed('/diary');
                          },
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickAccessCard(
                          '📊',
                          'Mi Impacto',
                          'Mide tu transformación',
                          () {
                            Navigator.of(context).pushNamed('/impact-dashboard');
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildArchetypeCard(
      String emoji, String title, String description, Color color) {
    return Container(
      width: 140,
      margin: EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      padding: EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(emoji, style: TextStyle(fontSize: 28)),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          SizedBox(height: 6),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryPreviewCard(TravelerStory story) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.deepPurple[200],
                  child: Text(story.author[0]),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        story.author,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        story.title,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber),
                    Text(
                      '${story.rating}',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              story.story,
              style: TextStyle(fontSize: 13),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 6,
              children: story.emotionalHighlights
                  .map(
                    (emotion) => Chip(
                      label: Text(emotion),
                      backgroundColor: Colors.purple[50],
                      labelStyle: TextStyle(fontSize: 11),
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.favorite, size: 16, color: Colors.red),
                SizedBox(width: 4),
                Text(
                  '${story.likes}',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessCard(
      String emoji, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: TextStyle(fontSize: 28)),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TripCard extends StatelessWidget {
  final Trip trip;

  const TripCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/trip-details', arguments: trip.id);
      },
      child: Card(
        margin: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              width: double.infinity,
              color: Colors.grey[300],
              child: Center(
                child: Icon(Icons.image, size: 50, color: Colors.grey[600]),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.destination,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  if (trip.isTransformative)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.purple[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Experiencia Transformadora',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.purple[800],
                        ),
                      ),
                    ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${trip.price}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.amber),
                          SizedBox(width: 4),
                          Text('${trip.rating}'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
