import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final _storage = const FlutterSecureStorage();

  // Keys
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userKey = 'user_data';
  static const _userIdKey = 'user_id';
  static const _conversationSettingsKey = 'conversation_settings';
  static const _accessTokenExpiryKey = 'access_token_expiry';
  static const _refreshTokenExpiryKey = 'refresh_token_expiry';

  // Access Token
  Future<void> saveTokenWithExpiry(
    String token, {
    bool isRefreshToken = false,
  }) async {
    await _storage.write(
      key: isRefreshToken ? _refreshTokenKey : _accessTokenKey,
      value: token,
    );

    // Lưu thời gian hết hạn
    final expiryTime = DateTime.now().add(
      Duration(minutes: isRefreshToken ? 43200 : 15), // 30 ngày = 43200 phút
    );

    await _storage.write(
      key: isRefreshToken ? _refreshTokenExpiryKey : _accessTokenExpiryKey,
      value: expiryTime.toIso8601String(),
    );
  }

  // Check nếu token đã hết hạn
  Future<bool> isTokenExpired({bool isRefreshToken = false}) async {
    final expiryStr = await _storage.read(
      key: isRefreshToken ? _refreshTokenExpiryKey : _accessTokenExpiryKey,
    );

    if (expiryStr == null) return true;

    final expiryTime = DateTime.parse(expiryStr);
    return DateTime.now().isAfter(expiryTime);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _accessTokenKey);
  }

  // Refresh Token
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
  }

  // User Data
  Future<void> saveUser(Map<String, dynamic> userData) async {
    final userJson = jsonEncode(userData);
    await _storage.write(key: _userKey, value: userJson);
  }

  Future<Map<String, dynamic>?> getUser() async {
    final userJson = await _storage.read(key: _userKey);
    if (userJson != null) {
      return jsonDecode(userJson);
    }
    return null;
  }

  Future<void> deleteUser() async {
    await _storage.delete(key: _userKey);
  }

  // User ID
  Future<void> saveUserId(int userId) async {
    await _storage.write(key: _userIdKey, value: userId.toString());
  }

  Future<int?> getUserId() async {
    final userIdStr = await _storage.read(key: _userIdKey);
    if (userIdStr != null) {
      return int.tryParse(userIdStr);
    }
    return null;
  }

  Future<void> deleteUserId() async {
    await _storage.delete(key: _userIdKey);
  }

  // Conversation Settings
  Future<void> saveConversationSettings(Map<String, dynamic> settings) async {
    final settingsJson = jsonEncode(settings);
    await _storage.write(key: _conversationSettingsKey, value: settingsJson);
  }

  Future<Map<String, dynamic>?> getConversationSettings() async {
    final settingsJson = await _storage.read(key: _conversationSettingsKey);
    if (settingsJson != null) {
      return jsonDecode(settingsJson);
    }
    return null;
  }

  Future<void> deleteConversationSettings() async {
    await _storage.delete(key: _conversationSettingsKey);
  }

  // Clear all data
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
