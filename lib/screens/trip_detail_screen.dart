import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import '../models/trip_model.dart';
import '../models/booking_model.dart';
import '../services/api_service.dart';

class TripDetailScreen extends StatefulWidget {
  final String tripId;

  const TripDetailScreen({required this.tripId});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  late Future<Trip> _trip;
  final ApiService _apiService = ApiService();
  int _selectedPeople = 1;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _trip = _apiService.getTripDetails(widget.tripId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Trip>(
      future: _trip,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text('Detalles del Viaje')),
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text('Error')),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: Text('No encontrado')),
            body: Center(child: Text('Viaje no encontrado')),
          );
        }

        final trip = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: Text('Detalles del Viaje'),
            backgroundColor: Colors.deepPurple,
            actions: [
              IconButton(
                icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
                onPressed: () {
                  setState(() {
                    _isFavorite = !_isFavorite;
                  });
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Galería de imágenes
                Container(
                  height: 250,
                  color: Colors.grey[300],
                  child: trip.images.isNotEmpty
                      ? PageView.builder(
                          itemCount: trip.images.length,
                          itemBuilder: (context, index) {
                            return Image.network(
                              trip.images[index],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  Icon(Icons.image_not_supported),
                            );
                          },
                        )
                      : Icon(Icons.image_not_supported),
                ),

                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título y precio
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  trip.title,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.location_on,
                                        size: 18, color: Colors.grey),
                                    SizedBox(width: 4),
                                    Text(trip.destination),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'desde',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '\$${trip.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 16),

                      // Información general
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildInfoCard(
                            Icons.calendar_today,
                            '${trip.duration} días',
                            'Duración',
                          ),
                          _buildInfoCard(
                            Icons.trending_up,
                            trip.difficulty,
                            'Dificultad',
                          ),
                          _buildInfoCard(
                            Icons.people,
                            '${trip.maxParticipants}',
                            'Máximo',
                          ),
                        ],
                      ),

                      SizedBox(height: 20),

                      // Rating
                      Row(
                        children: [
                          RatingBar.builder(
                            initialRating: trip.rating,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 20,
                            itemBuilder: (context, _) =>
                                Icon(Icons.star, color: Colors.amber),
                            onRatingUpdate: (_) {},
                            ignoreGestures: true,
                          ),
                          SizedBox(width: 8),
                          Text('${trip.reviews} reseñas'),
                        ],
                      ),

                      SizedBox(height: 20),

                      // Descripción
                      Text(
                        'Descripción',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(trip.description),

                      SizedBox(height: 20),

                      // Destino
                      Text(
                        'Destino',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(trip.country),

                      SizedBox(height: 20),

                      // Guía
                      Text(
                        'Guía',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(trip.guide),

                      SizedBox(height: 20),

                      // Destacados
                      if (trip.highlights.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Destacados',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: trip.highlights
                                  .map((highlight) => Padding(
                                        padding: EdgeInsets.only(bottom: 8),
                                        child: Row(
                                          children: [
                                            Icon(Icons.check_circle,
                                                color: Colors.green, size: 20),
                                            SizedBox(width: 8),
                                            Expanded(child: Text(highlight)),
                                          ],
                                        ),
                                      ))
                                  .toList(),
                            ),
                            SizedBox(height: 20),
                          ],
                        ),

                      // Amenidades
                      if (trip.amenities.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Incluye',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: trip.amenities
                                  .map((amenity) => Chip(label: Text(amenity)))
                                  .toList(),
                            ),
                            SizedBox(height: 20),
                          ],
                        ),

                      // Fechas
                      Text(
                        'Fechas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${DateFormat('dd/MM/yyyy').format(trip.startDate)} - ${DateFormat('dd/MM/yyyy').format(trip.endDate)}',
                      ),

                      SizedBox(height: 20),

                      // Seleccionar cantidad de personas
                      Text(
                        'Cantidad de Viajeros',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: _selectedPeople > 1
                                  ? () => setState(() => _selectedPeople--)
                                  : null,
                            ),
                            Text(
                              '$_selectedPeople',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: _selectedPeople < trip.maxParticipants
                                  ? () => setState(() => _selectedPeople++)
                                  : null,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24),

                      // Botón de reservar
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _showBookingDialog(context, trip);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            'Reservar Ahora',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 12),

                      // Botón agregar al carrito
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Agregado al carrito',
                                ),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.deepPurple),
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            'Agregar al Carrito',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.deepPurple, size: 28),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _showBookingDialog(BuildContext context, Trip trip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar Reserva'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Viaje: ${trip.title}'),
            SizedBox(height: 8),
            Text('Viajeros: $_selectedPeople'),
            SizedBox(height: 8),
            Text(
              'Total: \$${(trip.price * _selectedPeople).toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.deepPurple,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Reserva realizada con éxito'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
            ),
            child: Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}
