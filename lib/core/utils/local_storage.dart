import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const _userIdKey = 'user_id';
  static const _authTokenKey = 'auth_token';

  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  /// Securely save User ID
  static Future<void> saveUserId(String userId) async {
    try {
      await _secureStorage.write(key: _userIdKey, value: userId);
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userIdKey, userId);
    }
  }

  /// Securely retrieve User ID (with fallback & migration from legacy SharedPreferences)
  static Future<String?> getUserId() async {
    try {
      String? userId = await _secureStorage.read(key: _userIdKey);
      if (userId == null) {
        final prefs = await SharedPreferences.getInstance();
        userId = prefs.getString(_userIdKey);
        if (userId != null) {
          await saveUserId(userId);
          await prefs.remove(_userIdKey);
        }
      }
      return userId;
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userIdKey);
    }
  }

  /// Securely save Auth Token
  static Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: _authTokenKey, value: token);
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_authTokenKey, token);
    }
  }

  /// Securely retrieve Auth Token
  static Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: _authTokenKey);
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_authTokenKey);
    }
  }

  /// Securely clear all credentials on logout
  static Future<void> clear() async {
    try {
      await _secureStorage.deleteAll();
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}


