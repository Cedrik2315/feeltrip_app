﻿import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';

import '../services/destination_service.dart';
import '../models/trip_model.dart';
import '../services/analytics_service.dart';
import '../constants/strings.dart';
import '../controllers/cart_controller.dart';
import '../widgets/affiliate_widget.dart';

class TripDetailScreen extends StatefulWidget {
  final String tripId;

  const TripDetailScreen({super.key, required this.tripId});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  late Future<Trip?> _tripFuture;
  List<String> _unsplashImages = [];
  final CartController _cartController = Get.find();
  bool _isDescriptionExpanded = false;

  // Mock data para el itinerario
  final List<Map<String, String>> _mockItinerary = [
    {
      'day': '1',
      'title': 'Llegada y Bienvenida',
      'description':
          'Recepción en el aeropuerto y traslado al hotel. Cena de bienvenida para conocer al grupo.'
    },
    {
      'day': '2',
      'title': 'Exploración de la Ciudad',
      'description':
          'Tour guiado por los principales puntos históricos y culturales.'
    },
    {
      'day': '3',
      'title': 'Aventura en la Naturaleza',
      'description':
          'Excursión a la reserva natural, con senderismo y observación de fauna.'
    },
    {
      'day': '4',
      'title': 'Día de Reflexión',
      'description':
          'Talleres de mindfulness y yoga. Tarde libre para exploración personal.'
    },
    {
      'day': '5',
      'title': 'Cena de Despedida',
      'description':
          'Cena de despedida para compartir las experiencias del viaje.'
    },
  ];

  @override
  void initState() {
    super.initState();
    _tripFuture = _fetchTripDetails();
    _tripFuture.then((trip) async {
      if (trip != null && mounted) {
        AnalyticsService.logViewTrip(trip.id, trip.destination);
        if (trip.images.isEmpty) {
          final imgs =
              await DestinationService.getDestinationPhotos(trip.destination);
          if (mounted) {
            setState(() {
              _unsplashImages = imgs;
            });
          }
        }
      }
    });
  }

  Future<Trip?> _fetchTripDetails() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('trips')
          .doc(widget.tripId)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        data['id'] = docSnapshot.id;
        return Trip.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching trip: $e");
      return null;
    }
  }

  Widget _buildStatsRow(Trip trip, BuildContext context) {
    const duration = 5;
    const groupSize = "4-10";
    const rating = 4.8;

    Widget buildStatCard(IconData icon, String label, String value) {
      return Card(
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 50 / 255),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          child: Column(
            children: [
              Icon(icon, color: Colors.deepPurple, size: 24),
              const SizedBox(height: 4),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 2),
              Text(value,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        buildStatCard(Icons.calendar_today, 'Duración', '$duration días'),
        buildStatCard(Icons.group, 'Grupo', groupSize),
        buildStatCard(Icons.star, 'Rating', '$rating'),
        buildStatCard(Icons.public, 'Destino', trip.destination),
      ],
    );
  }

  Widget _buildExpandableDescription(Trip trip, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          firstChild: Text(
            trip.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          secondChild: Text(
            trip.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          crossFadeState: _isDescriptionExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
        InkWell(
          onTap: () =>
              setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _isDescriptionExpanded ? 'Ver menos' : 'Ver más',
              style: const TextStyle(
                  color: Colors.deepPurple, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItinerary(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Itinerario del Viaje',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _mockItinerary.length,
          itemBuilder: (context, index) => _buildItineraryItem(
              context,
              _mockItinerary[index],
              index == 0,
              index == _mockItinerary.length - 1),
        ),
      ],
    );
  }

  Widget _buildItineraryItem(BuildContext context, Map<String, String> dayInfo,
      bool isFirst, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                if (!isFirst)
                  Expanded(
                      child: Container(
                          width: 2, color: Colors.deepPurple.shade100)),
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.deepPurple,
                  child: Text(dayInfo['day']!,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                if (!isLast)
                  Expanded(
                      child: Container(
                          width: 2, color: Colors.deepPurple.shade100)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Card(
                elevation: 2,
                shadowColor: Colors.black.withValues(alpha: 50 / 255),
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dayInfo['title']!,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dayInfo['description']!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyPlaces(String destination) {
    const double lat = 40.4168;
    const double lng = -3.7038;

    return FutureBuilder<List<NearbyRestaurant>>(
      future: DestinationService.getNearbyRestaurants(lat, lng),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              children: List.generate(
                3,
                (index) => Container(
                  width: 140,
                  height: 120,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final restaurants = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🍽️ Lugares recomendados',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: restaurants.length,
                  itemBuilder: (context, index) {
                    final restaurant = restaurants[index];
                    return Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 12),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                restaurant.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Text('🍽️ ',
                                      style: TextStyle(fontSize: 12)),
                                  Expanded(
                                    child: Text(
                                      restaurant.category.isNotEmpty
                                          ? restaurant.category
                                          : 'Restaurante',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    restaurant.rating != null
                                        ? '$restaurant.rating!.toStringAsFixed(1)'
                                        : 'N/D',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                '250 m',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Trip?>(
        future: _tripFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(
                child: Text('No se pudo cargar el viaje. Inténtalo de nuevo.'));
          }

          final trip = snapshot.data!;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300.0,
                floating: false,
                pinned: true,
                backgroundColor: Colors.deepPurple,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withValues(alpha: 100 / 255),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    trip.destination,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(blurRadius: 10.0, color: Color(0x8A000000))
                      ],
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Builder(
                        builder: (context) {
                          final images = trip.images.isNotEmpty
                              ? trip.images
                              : _unsplashImages;
                          if (images.isEmpty) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.landscape,
                                  color: Colors.grey, size: 100),
                            );
                          }
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              CarouselSlider(
                                options: CarouselOptions(
                                  height: 350.0,
                                  viewportFraction: 1.0,
                                  autoPlay: true,
                                ),
                                items: images
                                    .map((item) => CachedNetworkImage(
                                          imageUrl: item,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        ))
                                    .toList(),
                              ),
                              if (_unsplashImages.isNotEmpty)
                                const Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: Text(
                                    '📸 Unsplash',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 150,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 200 / 255),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 60,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 80 / 255),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Text(
                            '\$${trip.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.title,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        if (trip.isTransformative)
                          Chip(
                            label: const Text(
                                AppStrings.homeTransformativeExperience),
                            backgroundColor: Colors.purple.shade50,
                            labelStyle: TextStyle(
                                color: Colors.purple.shade800,
                                fontWeight: FontWeight.w600),
                          ),
                        const SizedBox(height: 16),
                        _buildStatsRow(trip, context),
                        const SizedBox(height: 24),
                        _buildExpandableDescription(trip, context),
                        const Divider(height: 32),
                        _buildItinerary(context),
                        _buildNearbyPlaces(trip.destination),
                        AffiliateWidget(destination: trip.destination),
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: FutureBuilder<Trip?>(
        future: _tripFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const SizedBox.shrink();
          }
          final trip = snapshot.data!;
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 30 / 255),
                  blurRadius: 20,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple, Colors.purple.shade700],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    AnalyticsService.logAddToCart(trip.id, trip.price);
                    _cartController.addToCart(trip);
                  },
                  icon: const Icon(Icons.shopping_cart_outlined,
                      color: Colors.white),
                  label: Text('Añadir por \$${trip.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
