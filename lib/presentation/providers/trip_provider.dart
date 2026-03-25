import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feeltrip_app/models/trip_model.dart';  
import 'package:flutter_riverpod/flutter_riverpod.dart';

final featuredTripsProvider = FutureProvider<List<Trip>>((ref) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('trips')
      .where('isFeatured', isEqualTo: true)
      .limit(5)
      .get();

  return snapshot.docs.map(Trip.fromFirestore).toList();
});
