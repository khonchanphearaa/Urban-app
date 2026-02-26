import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/secure_storage_service.dart';
import '../constants/api_constants.dart';
import '../models/user_model.dart';

class AuthController extends ChangeNotifier {
  bool isLoading = false;
  UserModel? user;
  String? lastError;

  /* For get token for requried when get production for api  */
  String? get token => user?.token;

  Map<String, String> get authHeaders => user?.authHeaders() ?? {};

  AuthController() {
    _loadFromStorage();
  }

  /* Function defin for isloading UI */
  void _toggleLoading() {
    isLoading = !isLoading;
    notifyListeners();
  }

  /* Control Login */
  Future<bool> login(String email, String password) async {
    _toggleLoading();
    try {
      final res = await http.post(
        Uri.parse(ApiConstants.login),
        body: {'email': email, 'password': password},
      );

      /* Log request/response for debugging */
      debugPrint('Login response (${res.statusCode}): ${res.body}');

      if (res.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(res.body);

        /* Check if is not define accessToken */
        final Map<String, dynamic> normalized = {};
        if (body['user'] != null) normalized['user'] = body['user'];
        if (body['token'] != null) normalized['token'] = body['token'];
        if (body['access_token'] != null) {
          normalized['token'] = body['access_token'];
        }
        if (body['accessToken'] != null) {
          normalized['token'] = body['accessToken'];
        }
        if (body['data'] is Map) {
          final data = body['data'] as Map<String, dynamic>;
          if (data['user'] != null) normalized['user'] = data['user'];
          if (data['token'] != null) normalized['token'] = data['token'];
          if (data['access_token'] != null) {
            normalized['token'] = data['access_token'];
          }
          if (data['accessToken'] != null) {
            normalized['token'] = data['accessToken'];
          }
        }

        if (normalized['user'] == null && body.containsKey('email')) {
          normalized['user'] = body;
        }

        user = UserModel.fromJson(normalized);

        /* Persist token and user to secure storage for mobile */
        try {
          final token = user?.token;
          if (token != null) await SecureStorageService.saveToken(token);
          await SecureStorageService.saveUser(user!.toJson());
        } catch (_) {}

        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      _toggleLoading();
    }
  }

  /* Load persisted user/token on startup */
  Future<void> _loadFromStorage() async {
    try {
      final userJson = await SecureStorageService.readUser();
      if (userJson != null) {
        user = UserModel.fromJson(userJson);
        notifyListeners();
        return;
      }

      final token = await SecureStorageService.readToken();
      if (token != null) {
        /* If only token stored, create minimal user with token */
        user = UserModel(id: null, name: null, email: '', token: token);
        notifyListeners();
      }
    } catch (_) {}
  }

  /* Control Register */
  Future<bool> register(
    String name,
    String email,
    String password,
    String confirmPassword,
  ) async {
    _toggleLoading();
    try {
      final res = await http.post(
        Uri.parse(ApiConstants.register),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
        }),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(res.body);

        final Map<String, dynamic> normalized = {};
        if (body['user'] != null) normalized['user'] = body['user'];
        if (body['token'] != null) normalized['token'] = body['token'];
        if (body['access_token'] != null) {
          normalized['token'] = body['access_token'];
        }
        if (body['accessToken'] != null){
          normalized['token'] = body['accessToken'];
        }
        if (body['data'] is Map) {
          final data = body['data'] as Map<String, dynamic>;
          if (data['user'] != null) normalized['user'] = data['user'];
          if (data['token'] != null) normalized['token'] = data['token'];
          if (data['access_token'] != null) {
            normalized['token'] = data['access_token'];
          }
          if (data['accessToken'] != null) {
            normalized['token'] = data['accessToken'];
          }
        }

        if (normalized['user'] == null && body.containsKey('email')) {
          normalized['user'] = body;
        }

        user = UserModel.fromJson(normalized);
        lastError = null;
        return true;
      }

      /* If still acess to resigter many this baned, Is protect from backend  */
      if (res.statusCode == 429) {
        final retryAfter = res.headers['retry-after'];
        lastError = retryAfter != null
            ? 'Too many registration attempts. Try again in $retryAfter seconds.'
            : 'Too many registration attempts. Try again later.';
        return false;
      }

      try {
        final body = jsonDecode(res.body);
        if (body is Map<String, dynamic> && body['message'] != null) {
          lastError = body['message'].toString();
        } else {
          final fallback = res.body.trim();
          lastError = fallback.isNotEmpty ? fallback : 'Register failed';
        }
      } catch (_) {
        final fallback = res.body.trim();
        lastError = fallback.isNotEmpty ? fallback : 'Register failed';
      }
      return false;
    } catch (e) {
      lastError = 'Register failed (exception)';
      return false;
    } finally {
      _toggleLoading();
    }
  }

  /* Control Forgot Password */
  Future<bool> forgotPassword(String email) async {
    _toggleLoading();
    try {
      /* Send JSON body and explicit headers; some backends require JSON content-type */
      final res = await http.post(
        Uri.parse(ApiConstants.forgotPassword),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email}),
      );
      
      /* Log request/response for debugging */
      // ignore: avoid_print
      print( 'ForgotPassword request -> ${ApiConstants.forgotPassword} body: ${jsonEncode({'email': email})}',);
      // ignore: avoid_print
      print('ForgotPassword response (${res.statusCode}): ${res.body}');

      if (res.statusCode >= 200 && res.statusCode < 300) {
        try {
          final body = jsonDecode(res.body);
          if (body is Map<String, dynamic> &&
              (body['user'] != null || body['email'] != null)) {
            user = UserModel.fromJson(body);
          }
        } catch (_) {}
        lastError = null;
        return true;
      }

      /* Non-success: capture message if present */
      try {
        final body = jsonDecode(res.body);
        if (body is Map<String, dynamic> && body['message'] != null) {
          lastError = body['message'].toString();
        } else {
          lastError = 'Failed to send OTP';
        }
      } catch (_) {
        lastError = 'Failed to send OTP (network error)';
      }
      return false;
    } catch (e) {
      lastError = 'Failed to send OTP (exception)';
      return false;
    } finally {
      _toggleLoading();
    }
  }

  /* Control Verify OTP */
  Future<bool> verifyOTP(String email, String otp) async {
    _toggleLoading();
    try {
      final payload = jsonEncode({'email': email, 'otp': otp});
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      var res = await http.post(
        Uri.parse(ApiConstants.verifyOtp),
        headers: headers,
        body: payload,
      );

      /* If backend uses a typo'd route, try that as a fallback */
      if (res.statusCode == 404) {
        res = await http.post(
          Uri.parse(ApiConstants.verityOtp),
          headers: headers,
          body: payload,
        );
      }

      if (res.statusCode >= 200 && res.statusCode < 300) {
        try {
          final decoded = jsonDecode(res.body);
          if (decoded is Map<String, dynamic>) {
            user = UserModel.fromJson(decoded);
          }
        } catch (_) {}
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      _toggleLoading();
    }
  }

  /* Control Reset Password */
  Future<bool> resetPassword(
    String email,
    String otp,
    String newPassword,
    String confirmPassword,
  ) async {
    _toggleLoading();
    try {
      final payload = jsonEncode({
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      });
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      final res = await http.post(
        Uri.parse(ApiConstants.resetPassword),
        headers: headers,
        body: payload,
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        try {
          final decoded = jsonDecode(res.body);
          if (decoded is Map<String, dynamic>) {
            user = UserModel.fromJson(decoded);
          }
        } catch (_) {}
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      _toggleLoading();
    }
  }

  /* Get a User Profile */
  Future<bool> fetchUserProfile() async {
    if (token == null) return false;

    try {
      final res = await http.get(
        Uri.parse('${ApiConstants.apiBaseUrl}/auth/getMe'),
        headers: authHeaders,
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['user'] != null) {
          final updatedUser = UserModel.fromJson({
            'user': body['user'],
            'token': user?.token, 
          });
          user = updatedUser;

          /* Update stored user data */
          try {
            await SecureStorageService.saveUser(user!.toJson());
          } catch (_) {}

          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> applyUpdatedUser(UserModel updatedUser) async {
    user = updatedUser;
    final tokenToStore = updatedUser.token ?? token;
    if (tokenToStore != null && tokenToStore.isNotEmpty) {
      await SecureStorageService.saveToken(tokenToStore);
    }
    await SecureStorageService.saveUser(updatedUser.toJson());
    notifyListeners();
  }
}
