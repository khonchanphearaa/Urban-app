import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class SecureStorageService {
  static const _userKey = 'urban_user';
  static const _tokenKey = 'urban_token';
  static const _refreshTokenKey = 'urban_refresh_token';
  static const _pendingPaymentMd5Key = 'urban_pending_payment_md5';

  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /* Save token string */
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> readToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  static Future<void> saveRefreshToken(String refreshToken) async {
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  static Future<String?> readRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  static Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
  }

  /* Save user as JSON string */
  static Future<void> saveUser(Map<String, dynamic> userJson) async {
    await _storage.write(key: _userKey, value: jsonEncode(userJson));
  }

  static Future<Map<String, dynamic>?> readUser() async {
    final raw = await _storage.read(key: _userKey);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  static Future<void> deleteUser() async {
    await _storage.delete(key: _userKey);
  }

  static Future<void> savePendingPaymentMd5(String md5) async {
    await _storage.write(key: _pendingPaymentMd5Key, value: md5);
  }

  static Future<String?> readPendingPaymentMd5() async {
    return await _storage.read(key: _pendingPaymentMd5Key);
  }

  static Future<void> deletePendingPaymentMd5() async {
    await _storage.delete(key: _pendingPaymentMd5Key);
  }
}
