import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../core/error_presenter.dart';
import '../core/result.dart';
import '../models/cart_item_model.dart';
import '../models/trip_model.dart';
import '../repositories/app_data_repository.dart';
import '../services/ai_service.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../services/observability_service.dart';
import '../services/travel_service.dart';
import 'cart_screen.dart';

class TripDetailScreen extends StatefulWidget {
  final String tripId;
  final String? initialPurpose;
  final List<String>? initialItinerary;

  const TripDetailScreen({
    super.key,
    required this.tripId,
    this.initialPurpose,
    this.initialItinerary,
  });

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  static const Uuid _uuid = Uuid();
  late Future<Result<Trip>> _trip;
  final ApiService _apiService = ApiService();
  final AppDataRepository _repository = AppDataRepository();
  final AIService _aiService = AIService();
  final TravelService _travelService = TravelService();
  final LocationService _locationService = LocationService();
  late final TextEditingController _itineraryPurposeController;
  int _selectedPeople = 1;
  bool _isFavorite = false;
  bool _isAddingToCart = false;
  bool _isLoadingMap = false;
  bool _isGeneratingItinerary = false;
  LatLng? _tripCoordinates;
  List<String> _aiItinerary = <String>[];

  @override
  void initState() {
    super.initState();
    _trip = _apiService.getTripDetails(widget.tripId);
    _itineraryPurposeController = TextEditingController(
      text: widget.initialPurpose ?? '',
    );
    _aiItinerary = List<String>.from(widget.initialItinerary ?? const <String>[]);
  }

  @override
  void dispose() {
    _aiService.dispose();
    _itineraryPurposeController.dispose();
    super.dispose();
  }

  Future<void> _addToCart(Trip trip) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isAddingToCart = true);

    try {
      final cartResult = await _repository.getCurrentUserCartItems();
      final currentItems = cartResult.getOrElse(<CartItem>[]);
      final existing = currentItems.where((i) => i.tripId == trip.id).toList();
      final nextQuantity =
          (existing.isNotEmpty ? existing.first.quantity : 0) + _selectedPeople;

      await _repository.addOrUpdateCartItem(
        CartItem(
          tripId: trip.id,
          tripTitle: trip.title,
          price: trip.price,
          quantity: nextQuantity,
          destination: ', ',
          image: trip.images.isNotEmpty ? trip.images.first : '',
        ),
      );

      if (!mounted) return;
      await ObservabilityService.logAddToCart(
        tripId: trip.id,
        quantity: _selectedPeople,
        unitPrice: trip.price,
      );
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Agregado al carrito'),
          action: SnackBarAction(
            label: 'Ver carrito',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(ErrorPresenter.message(e)),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isAddingToCart = false);
    }
  }

  Future<void> _loadTripCoordinates(Trip trip) async {
    if (_isLoadingMap || _tripCoordinates != null) return;
    setState(() => _isLoadingMap = true);
    try {
      final coords = await _locationService
          .obtenerCoordenadas('${trip.destination}, ${trip.country}');
      if (!mounted) return;
      setState(() => _tripCoordinates = coords);
    } finally {
      if (mounted) setState(() => _isLoadingMap = false);
    }
  }

  Future<void> _generateItinerary(Trip trip) async {
    final messenger = ScaffoldMessenger.of(context);
    final purpose = _itineraryPurposeController.text.trim();
    final travelerType = purpose.isNotEmpty
        ? purpose
        : (trip.experienceType.isNotEmpty ? trip.experienceType : trip.category);

    setState(() => _isGeneratingItinerary = true);
    try {
      final generated = await _aiService.generatePersonalizedActivities(
        destination: '${trip.destination}, ${trip.country}',
        travelerType: travelerType,
        days: trip.duration > 0 ? trip.duration : 3,
      );
      final fallback = trip.highlights
          .where((h) => h.trim().isNotEmpty)
          .take(7)
          .toList();

      if (!mounted) return;
      setState(() {
        _aiItinerary = (generated ?? <String>[])
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .take(10)
            .toList();
        if (_aiItinerary.isEmpty) {
          _aiItinerary = fallback;
        }
      });

      if (_aiItinerary.isEmpty && mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('No se pudo generar itinerario por ahora.'),
            backgroundColor: Colors.orange,
          ),
        );
      } else if (_aiItinerary.isNotEmpty) {
        await _repository.saveItineraryDraft(
          tripId: trip.id,
          tripTitle: trip.title,
          destination: trip.destination,
          country: trip.country,
          purpose: purpose,
          itinerary: _aiItinerary,
        );
        if (mounted) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Itinerario IA guardado en tu perfil.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(ErrorPresenter.message(e)),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isGeneratingItinerary = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Result<Trip>>(
      future: _trip,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detalles del Viaje')),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text(ErrorPresenter.message(snapshot.error!))),
          );
        } else if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('No encontrado')),
            body: const Center(child: Text('Viaje no encontrado')),
          );
        }

        final result = snapshot.data!;
        final trip = result.getOrNull();
        
        if (trip == null) {
          final errorMsg = result.isFailure 
            ? 'Error al cargar el viaje'
            : 'Viaje no encontrado';
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text(errorMsg)),
          );
        }

        if (_tripCoordinates == null && !_isLoadingMap) {
          _loadTripCoordinates(trip);
        }

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
                // Galeria de imagenes
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
                                  const Icon(Icons.image_not_supported),
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
                      // Titulo y precio
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
                                    const Icon(Icons.location_on,
                                        size: 18, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(trip.destination),
                                  ],
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

                      // Informacion general
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

                      const SizedBox(height: 20),

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
                                const Icon(Icons.star, color: Colors.amber),
                            onRatingUpdate: (_) {},
                            ignoreGestures: true,
                          ),
                          const SizedBox(width: 8),
                          Text('${trip.reviews} reseñas'),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Descripcion
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
                        'Destino',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(trip.country),

                      const SizedBox(height: 20),

                      const Text(
                        'Mapa del destino',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 220,
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _isLoadingMap
                              ? const Center(child: CircularProgressIndicator())
                              : _tripCoordinates == null
                                  ? Container(
                                      color: Colors.grey[200],
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.all(12),
                                      child: const Text(
                                        'No se pudo cargar el mapa para este destino.',
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  : GoogleMap(
                                      initialCameraPosition: CameraPosition(
                                        target: _tripCoordinates!,
                                        zoom: 11,
                                      ),
                                      markers: <Marker>{
                                        Marker(
                                          markerId: const MarkerId('trip-destination'),
                                          position: _tripCoordinates!,
                                          infoWindow: InfoWindow(
                                            title: trip.destination,
                                            snippet: trip.country,
                                          ),
                                        ),
                                      },
                                      zoomControlsEnabled: false,
                                      myLocationButtonEnabled: false,
                                      mapToolbarEnabled: false,
                                    ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Itinerario IA para tu experiencia transformadora',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _itineraryPurposeController,
                        decoration: const InputDecoration(
                          labelText: 'Propósito del viaje',
                          hintText: 'Ej: sanar estrés, reconectar, aventura consciente',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _isGeneratingItinerary
                              ? null
                              : () => _generateItinerary(trip),
                          icon: _isGeneratingItinerary
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.auto_awesome),
                          label: Text(
                            _isGeneratingItinerary
                                ? 'Generando itinerario...'
                                : 'Generar itinerario con IA',
                          ),
                        ),
                      ),
                      if (_aiItinerary.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        ..._aiItinerary.asMap().entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Día ${entry.key + 1}: '),
                                Expanded(child: Text(entry.value)),
                              ],
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Guia
                      const Text(
                        'Guía',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(trip.guide),

                      const SizedBox(height: 20),

                      // Destacados
                      if (trip.highlights.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Destacados',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: trip.highlights
                                  .map((highlight) => Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.check_circle,
                                                color: Colors.green, size: 20),
                                            const SizedBox(width: 8),
                                            Expanded(child: Text(highlight)),
                                          ],
                                        ),
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),

                      // Amenidades
                      if (trip.amenities.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Incluye',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: trip.amenities
                                  .map((amenity) => Chip(label: Text(amenity)))
                                  .toList(),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),

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
                        '${DateFormat('dd/MM/yyyy').format(trip.startDate)} - ${DateFormat('dd/MM/yyyy').format(trip.endDate)}',
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
                              onPressed: _selectedPeople > 1
                                  ? () => setState(() => _selectedPeople--)
                                  : null,
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
                              onPressed: _selectedPeople < trip.maxParticipants
                                  ? () => setState(() => _selectedPeople++)
                                  : null,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Boton de reservar
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

                      // Boton agregar al carrito
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _isAddingToCart ? null : () => _addToCart(trip),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.deepPurple),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isAddingToCart
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text(
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
      },
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
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _showBookingDialog(BuildContext context, Trip trip) {
    final purposeController = TextEditingController();
    const providers = TravelService.supportedProviders;
    var selectedProviderId = providers.first.id;
    var aiActivities = <String>[];
    var isGeneratingPlan = false;
    String? planError;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Reservar experiencia'),
          content: SingleChildScrollView(
            child: Column(
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
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '¿Con qué proveedor quieres viajar?',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: providers
                      .map(
                        (provider) => ChoiceChip(
                          label: Text(provider.label),
                          selected: selectedProviderId == provider.id,
                          onSelected: (_) {
                            setDialogState(() => selectedProviderId = provider.id);
                          },
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: purposeController,
                  decoration: const InputDecoration(
                    labelText: 'Propósito de este viaje',
                    hintText: 'Ej: reconectar conmigo, sanar estrés, aventura',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: isGeneratingPlan
                        ? null
                        : () async {
                            final purpose = purposeController.text.trim();
                            final travelerType = purpose.isNotEmpty
                                ? purpose
                                : (trip.experienceType.isNotEmpty
                                    ? trip.experienceType
                                    : trip.category);

                            setDialogState(() {
                              isGeneratingPlan = true;
                              planError = null;
                            });

                            try {
                              final generated =
                                  await _aiService.generatePersonalizedActivities(
                                destination: trip.destination,
                                travelerType: travelerType,
                                days: trip.duration > 0 ? trip.duration : 3,
                              );

                              final fallback = trip.highlights
                                  .where((h) => h.trim().isNotEmpty)
                                  .take(5)
                                  .toList();

                              setDialogState(() {
                                aiActivities = (generated ?? <String>[])
                                    .map((a) => a.trim())
                                    .where((a) => a.isNotEmpty)
                                    .take(8)
                                    .toList();
                                if (aiActivities.isEmpty) {
                                  aiActivities = fallback;
                                }
                                if (aiActivities.isEmpty) {
                                  planError =
                                      'No se pudo generar un plan ahora. Intenta nuevamente.';
                                }
                              });
                            } catch (_) {
                              setDialogState(() {
                                planError =
                                    'No se pudo generar el plan con IA en este momento.';
                              });
                            } finally {
                              setDialogState(() => isGeneratingPlan = false);
                            }
                          },
                    icon: isGeneratingPlan
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: Text(
                      isGeneratingPlan
                          ? 'Generando plan...'
                          : 'Generar plan de actividades con IA',
                    ),
                  ),
                ),
                if (planError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    planError!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ],
                if (aiActivities.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Actividades sugeridas para tu propósito',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  ...aiActivities.map(
                    (activity) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• '),
                          Expanded(child: Text(activity)),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(this.context);
                Navigator.pop(dialogContext);

                try {
                  final selectedProvider = providers.firstWhere(
                    (provider) => provider.id == selectedProviderId,
                    orElse: () => providers.first,
                  );
                  final purpose = purposeController.text.trim();
                  final destinationQuery = '${trip.destination}, ${trip.country}';
                  final outboundUri = _travelService.buildProviderUri(
                    providerId: selectedProvider.id,
                    destination: destinationQuery,
                  );
                  final clickId = _uuid.v4();

                  await ObservabilityService.logAffiliateClick(
                    clickId: clickId,
                    providerId: selectedProvider.id,
                    tripId: trip.id,
                    destination: destinationQuery,
                  );

                  await _repository.createPartnerBookingIntent(
                    tripId: trip.id,
                    tripTitle: trip.title,
                    destination: trip.destination,
                    country: trip.country,
                    travelers: _selectedPeople,
                    totalAmount: trip.price * _selectedPeople,
                    providerId: selectedProvider.id,
                    providerLabel: selectedProvider.label,
                    clickId: clickId,
                    outboundUrl: outboundUri.toString(),
                    purpose: purpose,
                    aiActivities: aiActivities,
                  );

                  await _travelService.openProvider(
                    providerId: selectedProvider.id,
                    destination: destinationQuery,
                  );
                  if (!mounted) return;
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Redirigiendo al proveedor seleccionado.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(ErrorPresenter.message(e)),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              child: const Text('Ir a reservar'),
            ),
          ],
        ),
      ),
    );
  }
}






