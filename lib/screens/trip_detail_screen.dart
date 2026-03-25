import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trip_model.dart';
import '../widgets/destination_map_widget.dart';

class TripDetailScreen extends StatefulWidget {
  const TripDetailScreen({super.key, required this.tripId});
  final String tripId;

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  Trip? loadedTrip;
  bool isLoading = true;
  String? errorMessage;
  int _selectedPeople = 1;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance.collection('trips').doc(widget.tripId).get().then((doc) {
      if (doc.exists) {
        setState(() {
          loadedTrip = Trip.fromJson(doc.data()!);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Viaje no encontrado';
          isLoading = false;
        });
      }
    }).catchError((Object error) {
      setState(() {
        errorMessage = 'Error cargando viaje: $error';
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalles del Viaje')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]!),
              const SizedBox(height: 16),
              Text(errorMessage!, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      );
    }

    final trip = loadedTrip!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Viaje'),
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
              color: Colors.grey[300]!,
              child: trip.imageUrl.isNotEmpty
                  ? PageView.builder(
                      itemCount: 1, // Solo una imagen por ahora, según el modelo
                      itemBuilder: (context, index) {
                        return Image.network(
                          trip.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                        );
                      },
                    )
                  : const Icon(Icons.image_not_supported),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
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
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 18, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(trip.destination),
                              ],
                            ),
                            const SizedBox(height: 12),
                            DestinationMapWidget(
                              destination: trip.destination,
                              latitude: 0.0, // Valores por defecto, ya que no están en el modelo
                              longitude: 0.0, // Valores por defecto, ya que no están en el modelo
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'desde',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '\$${trip.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

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
                        'Moderada', // Valor por defecto
                        'Dificultad',
                      ),
                      _buildInfoCard(
                        Icons.people,
                        '10', // Valor por defecto
                        'Máximo',
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Rating
                  Row(
                    children: [
                      RatingBar.builder(
                        initialRating: trip.rating,
                        minRating: 1,
                        allowHalfRating: true,
                        itemSize: 20,
                        itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                        onRatingUpdate: (_) {},
                        ignoreGestures: true,
                      ),
                      const SizedBox(width: 8),
                      const Text('0 reseñas'), // Valor por defecto
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Descripción
                  const Text(
                    'Descripción',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(trip.description),

                  const SizedBox(height: 20),

                  // Destino
                  const Text(
                    'País/Región',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(trip.destination), // Usamos destination ya que 'country' no existe

                  const SizedBox(height: 20),

                  // Guía
                  const Text(
                    'Guía',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('No asignado'), // Valor por defecto

                  const SizedBox(height: 20),

                  // Destacados
                  // 'highlights' no existe en el modelo actual, se omite o se usa un valor por defecto

                  // Amenidades
                  // 'amenities' no existe en el modelo actual, se omite o se usa un valor por defecto

                  // Fechas
                  const Text(
                    'Fechas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${DateFormat('dd/MM/yyyy').format(trip.createdAt.toLocal())} - ${DateFormat('dd/MM/yyyy').format(trip.createdAt.toLocal().add(Duration(days: trip.duration)))}', // Usamos createdAt y duration para simular fechas
                  ),

                  const SizedBox(height: 20),

                  // Seleccionar cantidad de personas
                  const Text(
                    'Cantidad de Viajeros',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed:
                              _selectedPeople > 1 ? () => setState(() => _selectedPeople--) : null,
                        ),
                        Text(
                          '$_selectedPeople',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => setState(() => _selectedPeople++), // No hay maxParticipants, se permite aumentar indefinidamente
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Botón de reservar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _showBookingDialog(context, trip);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Reservar Ahora',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Botón agregar al carrito
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Agregado al carrito',
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.deepPurple),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Agregar al Carrito',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.deepPurple, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  void _showBookingDialog(BuildContext context, Trip trip) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Reserva'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Viaje: ${trip.title}'),
            const SizedBox(height: 8),
            Text('Viajeros: $_selectedPeople'),
            const SizedBox(height: 8),
            Text(
              'Total: \$${(trip.price * _selectedPeople).toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reserva realizada con éxito'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}
