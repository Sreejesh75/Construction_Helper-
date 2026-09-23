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
    await _secureStorage.write(key: _userIdKey, value: userId);
  }

  /// Securely retrieve User ID (with fallback & migration from legacy SharedPreferences)
  static Future<String?> getUserId() async {
    String? userId = await _secureStorage.read(key: _userIdKey);
    if (userId == null) {
      // Check legacy SharedPreferences for migration
      final prefs = await SharedPreferences.getInstance();
      userId = prefs.getString(_userIdKey);
      if (userId != null) {
        // Migrate to secure storage & delete legacy plain-text key
        await saveUserId(userId);
        await prefs.remove(_userIdKey);
      }
    }
    return userId;
  }

  /// Securely save Auth Token
  static Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _authTokenKey, value: token);
  }

  /// Securely retrieve Auth Token
  static Future<String?> getToken() async {
    return await _secureStorage.read(key: _authTokenKey);
  }

  /// Securely clear all credentials on logout
  static Future<void> clear() async {
    await _secureStorage.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

