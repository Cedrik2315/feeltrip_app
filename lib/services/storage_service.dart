import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../models/cart_item_model.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  static late SharedPreferences _prefs;

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // User
  Future<void> saveUser(User user) async {
    final userJson = json.encode(user.toJson());
    await _prefs.setString('user', userJson);
  }

  User? getUser() {
    final userJson = _prefs.getString('user');
    if (userJson == null) return null;
    return User.fromJson(json.decode(userJson));
  }

  Future<void> clearUser() async {
    await _prefs.remove('user');
  }

  // Token
  Future<void> saveToken(String token) async {
    await _prefs.setString('auth_token', token);
  }

  String? getToken() {
    return _prefs.getString('auth_token');
  }

  Future<void> clearToken() async {
    await _prefs.remove('auth_token');
  }

  // Cart
  Future<void> saveCart(List<CartItem> items) async {
    final cartJson = json.encode(
      items.map((item) => item.toJson()).toList(),
    );
    await _prefs.setString('cart', cartJson);
  }

  List<CartItem> getCart() {
    final cartJson = _prefs.getString('cart');
    if (cartJson == null) return [];
    final List<dynamic> decoded = json.decode(cartJson);
    return decoded.map((item) => CartItem.fromJson(item)).toList();
  }

  Future<void> clearCart() async {
    await _prefs.remove('cart');
  }

  // Preferences
  Future<void> setThemeMode(String mode) async {
    await _prefs.setString('theme_mode', mode);
  }

  String getThemeMode() {
    return _prefs.getString('theme_mode') ?? 'light';
  }

  Future<void> setLanguage(String language) async {
    await _prefs.setString('language', language);
  }

  String getLanguage() {
    return _prefs.getString('language') ?? 'es';
  }
}
