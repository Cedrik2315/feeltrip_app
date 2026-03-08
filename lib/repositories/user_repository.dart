import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

import '../config/app_flags.dart';
import '../config/firebase_config.dart';
import '../core/app_error.dart';
import '../core/result.dart';
import '../models/cart_item_model.dart';
import '../models/user_model.dart';
import '../mock_data.dart';

class UserRepository {
  UserRepository({
    fb_auth.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? fb_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final fb_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  String? get _userId => _auth.currentUser?.uid;
  bool get isAuthenticated => _auth.currentUser != null;

  Stream<fb_auth.User?> get authStateChanges => _auth.authStateChanges();

  Future<Result<fb_auth.User>> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      return Success(user);
    }
    return Failure(Exception('No hay usuario autenticado'));
  }

  Future<Result<User>> getUserProfile() async {
    if (useMockData) {
      return Success(MockData.testUser);
    }

    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Success(User(
        id: '',
        email: '',
        name: 'Viajero FeelTrip',
        phone: '',
        createdAt: DateTime.now(),
        profileImage: '',
        favoriteTrips: const [],
      ));
    }

    final defaults = User(
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

      return Success(User(
        id: defaults.id,
        email: (data['email'] ?? defaults.email).toString(),
        name: (data['name'] ?? defaults.name).toString(),
        phone: (data['phone'] ?? defaults.phone).toString(),
        createdAt: createdAt,
        profileImage: (data['profileImage'] ?? defaults.profileImage).toString(),
        favoriteTrips: const [],
      ));
    } catch (e, st) {
      return Failure(AppException.from(e), st);
    }
  }

  Future<Result<bool>> updateUserProfile({
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
        'createdAt': currentUser.metadata.creationTime ?? FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return const Success(true);
    } catch (e, st) {
      return Failure(AppException.from(e), st);
    }
  }

  Future<Result<List<CartItem>>> getCartItems() async {
    if (useMockData) {
      return const Success([]);
    }

    final uid = _userId;
    if (uid == null || uid.isEmpty) {
      return const Success([]);
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

  Future<Result<void>> addToCart(CartItem item) async {
    if (useMockData) {
      return const Success(null);
    }

    final uid = _userId;
    if (uid == null || uid.isEmpty) {
      return Failure(Exception('Debes iniciar sesión para usar el carrito'));
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

  Future<Result<void>> removeFromCart(String tripId) async {
    if (useMockData) {
      return const Success(null);
    }

    final uid = _userId;
    if (uid == null || uid.isEmpty) {
      return Failure(Exception('Debes iniciar sesión para usar el carrito'));
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

  Future<Result<void>> clearCart() async {
    if (useMockData) {
      return const Success(null);
    }

    final uid = _userId;
    if (uid == null || uid.isEmpty) {
      return Failure(Exception('Debes iniciar sesión para usar el carrito'));
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

  Future<Result<List<String>>> getFavoriteTripIds() async {
    if (useMockData) {
      return const Success([]);
    }

    final uid = _userId;
    if (uid == null || uid.isEmpty) {
      return const Success([]);
    }

    try {
      final snapshot = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(uid)
          .collection('favorites')
          .get();

      final ids = snapshot.docs.map((doc) => doc.id).toList();
      return Success(ids);
    } catch (e, st) {
      return Failure(AppException.from(e), st);
    }
  }

  Future<Result<bool>> toggleFavorite(String tripId) async {
    final uid = _userId;
    if (uid == null || uid.isEmpty) {
      return Failure(Exception('Debes iniciar sesión'));
    }

    try {
      final docRef = _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(uid)
          .collection('favorites')
          .doc(tripId);

      final doc = await docRef.get();
      if (doc.exists) {
        await docRef.delete();
        return const Success(false);
      } else {
        await docRef.set({'addedAt': FieldValue.serverTimestamp()});
        return const Success(true);
      }
    } catch (e, st) {
      return Failure(AppException.from(e), st);
    }
  }
}
