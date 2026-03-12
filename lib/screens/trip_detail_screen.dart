import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';

import '../models/trip_model.dart';
import '../constants/strings.dart';
import '../controllers/cart_controller.dart';

class TripDetailScreen extends StatefulWidget {
  final String tripId;

  const TripDetailScreen({super.key, required this.tripId});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  late Future<Trip?> _tripFuture;
  final CartController _cartController = Get.find();

  @override
  void initState() {
    super.initState();
    _tripFuture = _fetchTripDetails();
  }

  Future<Trip?> _fetchTripDetails() async {
    try {
      // Asumimos que los viajes están en una colección 'trips'
      final docSnapshot = await FirebaseFirestore.instance
          .collection('trips')
          .doc(widget.tripId)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        // Aseguramos que el ID esté en el mapa para el modelo
        data['id'] = docSnapshot.id;
        return Trip.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching trip: $e");
      return null;
    }
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
              child: Text('No se pudo cargar el viaje. Inténtalo de nuevo.'),
            );
          }

          final trip = snapshot.data!;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250.0,
                floating: false,
                pinned: true,
                backgroundColor: Colors.deepPurple,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(trip.destination,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(blurRadius: 10.0, color: Colors.black54)
                          ])),
                  background: trip.images.isNotEmpty
                      ? CarouselSlider(
                          options: CarouselOptions(
                            height: 300,
                            viewportFraction: 1.0,
                            autoPlay: true,
                          ),
                          items: trip.images
                              .map((item) => CachedNetworkImage(
                                    imageUrl: item,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ))
                              .toList(),
                        )
                      : Container(color: Colors.grey),
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
                        Text(
                          trip.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const Divider(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Precio por persona',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              '\$${trip.price.toStringAsFixed(2)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                      color: Colors.deepPurple,
                                      fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
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
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () => _cartController.addToCart(trip),
              icon: const Icon(Icons.shopping_cart_outlined),
              label: const Text('Añadir al Carrito'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
            ),
          );
        },
      ),
    );
  }
}