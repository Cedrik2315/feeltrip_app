import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../config/app_flags.dart';
import '../config/firebase_config.dart';
import '../core/app_error.dart';
import '../core/result.dart';
import '../mock_data.dart';
import '../models/booking_model.dart';
import '../models/cart_item_model.dart';
import '../models/trip_model.dart';
import '../models/user_model.dart' as app_user;
import '../services/api_service.dart';

class AppDataRepository {
  AppDataRepository({
    ApiService? apiService,
    fb_auth.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _apiService = apiService ?? ApiService(),
        _auth = auth ?? fb_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final ApiService _apiService;
  final fb_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  static final List<CartItem> _mockCartItems = <CartItem>[
    CartItem(
      tripId: 'trip_1',
      tripTitle: 'Tromso Aurora Borealis',
      destination: 'Noruega',
      price: 1290,
      quantity: 1,
      image: 'NIGHT',
    ),
    CartItem(
      tripId: 'trip_2',
      tripTitle: 'Cocina Toscana',
      destination: 'Italia',
      price: 980,
      quantity: 1,
      image: 'PASTA',
    ),
  ];

  bool get isMockMode => useMockData;

  Result<List<Trip>> _filterTrips(
    List<Trip> trips,
    String? query,
    String? category,
    String? difficulty,
    double? maxPrice,
  ) {
    final normalizedQuery = (query ?? '').trim().toLowerCase();

    try {
      final filtered = trips.where((trip) {
        final matchesQuery = normalizedQuery.isEmpty ||
            trip.title.toLowerCase().contains(normalizedQuery) ||
            trip.destination.toLowerCase().contains(normalizedQuery) ||
            trip.country.toLowerCase().contains(normalizedQuery);

        final matchesCategory = category == null ||
            category == 'Todos' ||
            trip.category.toLowerCase() == category.toLowerCase();

        final matchesDifficulty = difficulty == null ||
            difficulty == 'Todos' ||
            trip.difficulty.toLowerCase() == difficulty.toLowerCase();

        final matchesPrice = maxPrice == null || trip.price <= maxPrice;

        return matchesQuery &&
            matchesCategory &&
            matchesDifficulty &&
            matchesPrice;
      }).toList();
      return Success(filtered);
    } catch (e, st) {
      return Failure(e, st);
    }
  }

  Future<Result<List<Trip>>> searchTrips({
    String? query,
    String? category,
    String? difficulty,
    double? maxPrice,
  }) async {
    final normalizedQuery = (query ?? '').trim().toLowerCase();

    if (useMockData) {
      return _filterTrips(
        MockData.mockTrips,
        normalizedQuery,
        category,
        difficulty,
        maxPrice,
      );
    }

    final result = await _apiService.getTrips(
      destination: normalizedQuery.isEmpty ? null : normalizedQuery,
    );

    return result.fold(
      onFailure: (error, stackTrace) => Failure(AppException.from(error)),
      onSuccess: (trips) =>
          _filterTrips(trips, normalizedQuery, category, difficulty, maxPrice),
    );
  }

  Future<Result<List<Booking>>> getCurrentUserBookings() async {
    if (useMockData) {
      return Success(MockData.mockBookings);
    }

    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      return const Success(<Booking>[]);
    }

    final result = await _apiService.getUserBookings(uid);
    return result.fold(
      onFailure: (error, stackTrace) => Failure(AppException.from(error)),
      onSuccess: (bookings) => Success(bookings),
    );
  }

  Future<Result<bool>> cancelBooking(String bookingId) async {
    if (useMockData) {
      return const Success(true);
    }

    final result = await _apiService.cancelBooking(bookingId);
    return result.fold(
      onFailure: (error, stackTrace) =>
          Failure(AppException.from(error), stackTrace),
      onSuccess: (success) => Success(success),
    );
  }

  Future<Result<app_user.User>> getCurrentUserProfile() async {
    if (useMockData) {
      return Success(MockData.testUser);
    }

    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Success(app_user.User(
        id: '',
        email: '',
        name: 'Viajero FeelTrip',
        phone: '',
        createdAt: DateTime.now(),
        profileImage: '',
        favoriteTrips: const [],
      ));
    }

    final defaults = app_user.User(
      id: currentUser.uid,
      email: currentUser.email ?? '',
      name: currentUser.displayName ?? 'Viajero FeelTrip',
      phone: currentUser.phoneNumber ?? '',
      createdAt: currentUser.metadata.creationTime ?? DateTime.now(),
      profileImage: currentUser.photoURL ?? '',
      favoriteTrips: const [],
    );

    try {
      final profileDoc = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(currentUser.uid)
          .collection('private')
          .doc(FirebaseConfig.userProfileDoc)
          .get();

      if (!profileDoc.exists || profileDoc.data() == null) {
        return Success(defaults);
      }

      final data = profileDoc.data()!;
      final createdAtRaw = data['createdAt'];
      final createdAt = createdAtRaw is Timestamp
          ? createdAtRaw.toDate()
          : defaults.createdAt;

      return Success(app_user.User(
        id: defaults.id,
        email: (data['email'] ?? defaults.email).toString(),
        name: (data['name'] ?? defaults.name).toString(),
        phone: (data['phone'] ?? defaults.phone).toString(),
        createdAt: createdAt,
        profileImage:
            (data['profileImage'] ?? defaults.profileImage).toString(),
        favoriteTrips: const [],
      ));
    } catch (e, st) {
      return Failure(AppException.from(e), st);
    }
  }

  Future<Result<bool>> updateCurrentUserProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    if (useMockData) {
      return const Success(true);
    }

    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return const Success(false);
    }

    try {
      if (name.trim().isNotEmpty && currentUser.displayName != name.trim()) {
        await currentUser.updateDisplayName(name.trim());
      }

      await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(currentUser.uid)
          .collection('private')
          .doc(FirebaseConfig.userProfileDoc)
          .set({
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'profileImage': currentUser.photoURL ?? '',
        'createdAt':
            currentUser.metadata.creationTime ?? FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return const Success(true);
    } catch (e, st) {
      return Failure(AppException.from(e), st);
    }
  }

  Future<Result<List<CartItem>>> getCurrentUserCartItems() async {
    if (useMockData) {
      return Success(List<CartItem>.from(_mockCartItems));
    }

    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      return const Success(<CartItem>[]);
    }

    try {
      final snapshot = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(uid)
          .collection('cartItems')
          .orderBy('updatedAt', descending: true)
          .get();

      final items = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['tripId'] = data['tripId'] ?? doc.id;
        return CartItem.fromJson(data);
      }).toList();
      return Success(items);
    } catch (e, st) {
      return Failure(AppException.from(e), st);
    }
  }

  Future<Result<void>> addOrUpdateCartItem(CartItem item) async {
    if (useMockData) {
      final index = _mockCartItems.indexWhere((it) => it.tripId == item.tripId);
      if (index == -1) {
        _mockCartItems.add(item);
      } else {
        _mockCartItems[index].quantity = item.quantity;
      }
      return const Success(null);
    }

    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      return Failure(Exception('Debes iniciar sesion para usar el carrito'));
    }

    try {
      await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(uid)
          .collection('cartItems')
          .doc(item.tripId)
          .set({
        ...item.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return const Success(null);
    } catch (e, st) {
      return Failure(AppException.from(e), st);
    }
  }

  Future<Result<void>> updateCartItemQuantity({
    required String tripId,
    required int quantity,
  }) async {
    if (quantity <= 0) {
      return removeCartItem(tripId);
    }

    if (useMockData) {
      final index = _mockCartItems.indexWhere((it) => it.tripId == tripId);
      if (index != -1) {
        _mockCartItems[index].quantity = quantity;
      }
      return const Success(null);
    }

    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      return Failure(Exception('Debes iniciar sesion para usar el carrito'));
    }

    try {
      await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(uid)
          .collection('cartItems')
          .doc(tripId)
          .set({
        'tripId': tripId,
        'quantity': quantity,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return const Success(null);
    } catch (e, st) {
      return Failure(AppException.from(e), st);
    }
  }

  Future<Result<void>> removeCartItem(String tripId) async {
    if (useMockData) {
      _mockCartItems.removeWhere((it) => it.tripId == tripId);
      return const Success(null);
    }

    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      return Failure(Exception('Debes iniciar sesion para usar el carrito'));
    }

    try {
      await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(uid)
          .collection('cartItems')
          .doc(tripId)
          .delete();
      return const Success(null);
    } catch (e, st) {
      return Failure(AppException.from(e), st);
    }
  }

  Future<Result<void>> clearCurrentUserCart() async {
    if (useMockData) {
      _mockCartItems.clear();
      return const Success(null);
    }

    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      return Failure(Exception('Debes iniciar sesion para usar el carrito'));
    }

    try {
      final items = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(uid)
          .collection('cartItems')
          .get();

      final batch = _firestore.batch();
      for (final doc in items.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      return const Success(null);
    } catch (e, st) {
      return Failure(AppException.from(e), st);
    }
  }

  Future<Result<Map<String, dynamic>>> startCheckout({
    required List<CartItem> items,
    String currency = 'usd',
    String? successUrl,
    String? cancelUrl,
  }) async {
    if (items.isEmpty) {
      return Failure(Exception('No hay items para checkout'));
    }

    if (useMockData) {
      return const Success(<String, dynamic>{
        'ok': true,
        'orderId': 'mock_order_1',
        'checkoutUrl': null,
        'status': 'mock',
      });
    }

    final result = await _apiService.createCheckoutSession(
      items: items
          .map((item) => <String, dynamic>{
                'tripId': item.tripId,
                'quantity': item.quantity,
              })
          .toList(),
      currency: currency,
      successUrl: successUrl,
      cancelUrl: cancelUrl,
    );

    return result.fold(
      onFailure: (error, stackTrace) => Failure(AppException.from(error)),
      onSuccess: (data) => Success(data),
    );
  }

  Future<Result<Map<String, dynamic>>> getCheckoutOrderStatus(
      String orderId) async {
    if (useMockData) {
      return Success(<String, dynamic>{
        'ok': true,
        'orderId': orderId,
        'status': 'paid',
      });
    }

    final result = await _apiService.getCheckoutOrderStatus(orderId);
    return result.fold(
      onFailure: (error, stackTrace) => Failure(AppException.from(error)),
      onSuccess: (data) => Success(data),
    );
  }

  Future<Result<String>> createPartnerBookingIntent({
    required String tripId,
    required String tripTitle,
    required String destination,
    required String country,
    required int travelers,
    required double totalAmount,
    required String providerId,
    required String providerLabel,
    required String clickId,
    required String outboundUrl,
    required String purpose,
    required List<String> aiActivities,
  }) async {
    if (useMockData) {
      return const Success('mock_booking_intent');
    }

    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      return Failure(Exception('Debes iniciar sesion para reservar'));
    }

    try {
      final ref = _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(uid)
          .collection('bookingIntents')
          .doc();

      await ref.set({
        'id': ref.id,
        'tripId': tripId,
        'tripTitle': tripTitle,
        'destination': destination,
        'country': country,
        'travelers': travelers,
        'totalAmount': totalAmount,
        'providerId': providerId,
        'providerLabel': providerLabel,
        'clickId': clickId,
        'outboundUrl': outboundUrl,
        'purpose': purpose,
        'aiActivities': aiActivities,
        'status': 'redirected_to_partner',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return Success(ref.id);
    } catch (e, st) {
      return Failure(AppException.from(e), st);
    }
  }

  Future<Result<List<Map<String, dynamic>>>>
      getCurrentUserBookingIntents() async {
    if (useMockData) {
      return Success(<Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'mock_intent_1',
          'tripTitle': 'Tromso Aurora Borealis',
          'destination': 'Tromso',
          'country': 'Noruega',
          'providerLabel': 'Booking.com',
          'providerId': 'booking',
          'clickId': 'click_mock_1',
          'outboundUrl': 'https://www.booking.com/searchresults.html?ss=Tromso',
          'purpose': 'Desconectar del estrés y reconectar',
          'aiActivities': <String>[
            'Caminata nocturna para observar auroras',
            'Sesión de journaling con guía local',
            'Baño térmico y respiración consciente',
          ],
          'status': 'redirected_to_partner',
          'createdAt': DateTime.now().subtract(const Duration(days: 1)),
        },
      ]);
    }

    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      return const Success(<Map<String, dynamic>>[]);
    }

    try {
      final snapshot = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(uid)
          .collection('bookingIntents')
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      final intents = snapshot.docs
          .map((doc) => <String, dynamic>{
                ...doc.data(),
                'id': doc.id,
              })
          .toList();
      return Success(intents);
    } catch (e, st) {
      return Failure(AppException.from(e), st);
    }
  }

  Future<Result<String>> saveItineraryDraft({
    required String tripId,
    required String tripTitle,
    required String destination,
    required String country,
    required String purpose,
    required List<String> itinerary,
  }) async {
    if (itinerary.isEmpty) {
      return Failure(Exception('No hay itinerario para guardar'));
    }

    if (useMockData) {
      return const Success('mock_itinerary_draft_1');
    }

    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      return Failure(Exception('Debes iniciar sesion para guardar itinerario'));
    }

    try {
      final ref = _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(uid)
          .collection('itineraryDrafts')
          .doc();

      await ref.set({
        'id': ref.id,
        'tripId': tripId,
        'tripTitle': tripTitle,
        'destination': destination,
        'country': country,
        'purpose': purpose,
        'itinerary': itinerary,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return Success(ref.id);
    } catch (e, st) {
      return Failure(AppException.from(e), st);
    }
  }

  Future<Result<List<Map<String, dynamic>>>>
      getCurrentUserItineraryDrafts() async {
    if (useMockData) {
      return Success(<Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'mock_itinerary_1',
          'tripId': 'trip_1',
          'tripTitle': 'Tromso Aurora Borealis',
          'destination': 'Tromso',
          'country': 'Noruega',
          'purpose': 'Reconexión personal',
          'itinerary': <String>[
            'Caminata consciente al amanecer',
            'Sesión de journaling emocional',
            'Actividad cultural local guiada',
          ],
          'createdAt': DateTime.now().subtract(const Duration(hours: 8)),
        },
      ]);
    }

    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      return const Success(<Map<String, dynamic>>[]);
    }

    try {
      final snapshot = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(uid)
          .collection('itineraryDrafts')
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      final drafts = snapshot.docs
          .map((doc) => <String, dynamic>{
                ...doc.data(),
                'id': doc.id,
              })
          .toList();
      return Success(drafts);
    } catch (e, st) {
      return Failure(AppException.from(e), st);
    }
  }
}
