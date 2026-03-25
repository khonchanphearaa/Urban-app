import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../services/secure_storage_service.dart';
import '../constants/api_constants.dart';
import '../models/user_model.dart';

class AuthController extends ChangeNotifier {
  bool isLoading = false;
  UserModel? user;
  String? lastError;

  /* For get token for requried when get production for api  */
  String? get token => user?.token;
  String? get refreshToken => user?.refreshToken;

  Map<String, String> get authHeaders => user?.authHeaders() ?? {};

  AuthController() {
    _loadFromStorage();
  }

  /* Function defin for isloading UI */
  void _toggleLoading() {
    isLoading = !isLoading;
    notifyListeners();
  }

  Map<String, dynamic> _normalizeAuthBody(Map<String, dynamic> body) {
    final Map<String, dynamic> normalized = {};

    if (body['user'] != null) normalized['user'] = body['user'];
    if (body['token'] != null) normalized['token'] = body['token'];
    if (body['access_token'] != null) normalized['token'] = body['access_token'];
    if (body['accessToken'] != null) normalized['token'] = body['accessToken'];
    if (body['refresh_token'] != null) {
      normalized['refreshToken'] = body['refresh_token'];
    }
    if (body['refreshToken'] != null) {
      normalized['refreshToken'] = body['refreshToken'];
    }

    if (body['data'] is Map) {
      final data = body['data'] as Map<String, dynamic>;
      if (data['user'] != null) normalized['user'] = data['user'];
      if (data['token'] != null) normalized['token'] = data['token'];
      if (data['access_token'] != null) normalized['token'] = data['access_token'];
      if (data['accessToken'] != null) normalized['token'] = data['accessToken'];
      if (data['refresh_token'] != null) {
        normalized['refreshToken'] = data['refresh_token'];
      }
      if (data['refreshToken'] != null) {
        normalized['refreshToken'] = data['refreshToken'];
      }
    }

    if (normalized['user'] == null && body.containsKey('email')) {
      normalized['user'] = body;
    }

    return normalized;
  }

  String _extractErrorMessage(String rawBody, {String fallback = 'Request failed'}) {
    try {
      final decoded = jsonDecode(rawBody);
      if (decoded is Map<String, dynamic>) {
        final fromData = decoded['data'];

        if (fromData is Map<String, dynamic> && fromData['message'] != null) {
          return fromData['message'].toString();
        }

        if (fromData is Map<String, dynamic> && fromData['error'] != null) {
          return fromData['error'].toString();
        }

        if (decoded['errors'] is List && (decoded['errors'] as List).isNotEmpty) {
          return (decoded['errors'] as List).first.toString();
        }

        if (decoded['errors'] is Map<String, dynamic>) {
          final errorsMap = decoded['errors'] as Map<String, dynamic>;
          for (final value in errorsMap.values) {
            if (value is List && value.isNotEmpty) return value.first.toString();
            if (value is String && value.trim().isNotEmpty) return value;
          }
        }

        if (decoded['message'] != null) return decoded['message'].toString();
        if (decoded['error'] != null) return decoded['error'].toString();
      }

      if (decoded is List && decoded.isNotEmpty) {
        return decoded.first.toString();
      }
    } catch (_) {}

    final plain = rawBody.trim();
    if (plain.isNotEmpty) return plain;
    return fallback;
  }

  String _mapLoginExceptionToMessage(Object e) {
    return 'Login failed. Please try again.';
  }

  /* Control Login */
  Future<bool> login(String email, String password) async {
    _toggleLoading();
    lastError = null;
    try {
      final payload = jsonEncode({'email': email, 'password': password});
      final res = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: payload,
      ).timeout(const Duration(seconds: 20));

      /* Log request/response for debugging */
      debugPrint('Login response (${res.statusCode}): ${res.body}');

      if (res.statusCode >= 200 && res.statusCode < 300) {
        Map<String, dynamic> body;
        try {
          final decoded = jsonDecode(res.body);
          if (decoded is! Map<String, dynamic>) {
            lastError = _extractErrorMessage(
              res.body,
              fallback: 'Invalid login response from server',
            );
            return false;
          }
          body = decoded;
        } catch (_) {
          lastError = _extractErrorMessage(
            res.body,
            fallback: 'Invalid login response from server',
          );
          return false;
        }
        final normalized = _normalizeAuthBody(body);

        user = UserModel.fromJson(normalized);

        if (user?.token == null || user!.token!.isEmpty) {
          lastError = 'Login succeeded but no access token returned';
          return false;
        }

        /* Persist token and user to secure storage for mobile */
        try {
          final token = user?.token;
          if (token != null) await SecureStorageService.saveToken(token);
          final refreshed = user?.refreshToken;
          if (refreshed != null && refreshed.isNotEmpty) {
            await SecureStorageService.saveRefreshToken(refreshed);
          }
          await SecureStorageService.saveUser(user!.toJson());
        } catch (_) {}

        lastError = null;
        return true;
      }

      lastError = _extractErrorMessage(
        res.body,
        fallback: 'Invalid email or password',
      );
      return false;
    } on TimeoutException {
      lastError = 'Login request timed out. Please try again.';
      return false;
    } on http.ClientException catch (e) {
      lastError = _mapLoginExceptionToMessage(e);
      return false;
    } catch (e) {
      debugPrint('Login exception: $e');
      lastError = _mapLoginExceptionToMessage(e);
      return false;
    } finally {
      _toggleLoading();
    }
  }

  /* Load persisted user/token on startup */
  Future<void> _loadFromStorage() async {
    try {
      final storedRefreshToken = await SecureStorageService.readRefreshToken();
      final userJson = await SecureStorageService.readUser();
      if (userJson != null) {
        final merged = Map<String, dynamic>.from(userJson);
        final currentRefreshToken = merged['refreshToken'];
        final isMissingRefresh =
            currentRefreshToken == null ||
            (currentRefreshToken is String && currentRefreshToken.isEmpty);

        if (isMissingRefresh &&
            storedRefreshToken != null &&
            storedRefreshToken.isNotEmpty) {
          merged['refreshToken'] = storedRefreshToken;
        }

        user = UserModel.fromJson(merged);
        notifyListeners();
        return;
      }

      final token = await SecureStorageService.readToken();
      if (token != null) {
        /* If only token stored, create minimal user with token */
        user = UserModel(
          id: null,
          name: null,
          email: '',
          token: token,
          refreshToken: storedRefreshToken,
        );
        notifyListeners();
      }
    } catch (_) {}
  }


  /* Control refresh token */
  Future<bool> refreshAccessToken() async {
    final currentRefreshToken =
        refreshToken ?? await SecureStorageService.readRefreshToken();

    if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
      lastError = 'Session expired. Please login again.';
      return false;
    }

    try {
      final uri = Uri.parse(ApiConstants.refreshToken);
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      final payloads = [
        {'refreshToken': currentRefreshToken},
        {'refresh_token': currentRefreshToken},
        {'token': currentRefreshToken},
      ];

      http.Response? res;
      for (final payload in payloads) {
        final candidate = await http.post(
          uri,
          headers: headers,
          body: jsonEncode(payload),
        );
        res = candidate;
        if (candidate.statusCode >= 200 && candidate.statusCode < 300) {
          break;
        }
        if (candidate.statusCode != 400 &&
            candidate.statusCode != 401 &&
            candidate.statusCode != 422) {
          break;
        }
      }

      if (res == null) {
        lastError = 'Failed to refresh session.';
        return false;
      }

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final decoded = jsonDecode(res.body);
        if (decoded is! Map<String, dynamic>) {
          lastError = 'Invalid refresh-token response.';
          return false;
        }

        final normalized = _normalizeAuthBody(decoded);
        final parsed = UserModel.fromJson(normalized);

        final mergedUser = (user ??
                UserModel(id: null, name: null, email: '', token: null))
            .copyWith(
              id: parsed.id,
              name: parsed.name,
              email: parsed.email.isNotEmpty ? parsed.email : null,
              role: parsed.role,
              avatar: parsed.avatar,
              token: parsed.token,
              refreshToken: parsed.refreshToken ?? currentRefreshToken,
            );

        if (mergedUser.token == null || mergedUser.token!.isEmpty) {
          lastError = 'Refresh succeeded but no access token returned.';
          return false;
        }

        user = mergedUser;
        await SecureStorageService.saveToken(mergedUser.token!);
        if (mergedUser.refreshToken != null &&
            mergedUser.refreshToken!.isNotEmpty) {
          await SecureStorageService.saveRefreshToken(mergedUser.refreshToken!);
        }
        await SecureStorageService.saveUser(mergedUser.toJson());
        lastError = null;
        notifyListeners();
        return true;
      }

      lastError = _extractErrorMessage(
        res.body,
        fallback: 'Failed to refresh session.',
      );
      return false;
    } catch (_) {
      lastError = 'Failed to refresh session.';
      return false;
    }
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

        final normalized = _normalizeAuthBody(body);
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
      
      debugPrint('ForgotPassword request body: ${jsonEncode({'email': email})}');
      debugPrint('ForgotPassword response (${res.statusCode}): ${res.body}');

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
    final refreshTokenToStore = updatedUser.refreshToken ?? refreshToken;
    if (refreshTokenToStore != null && refreshTokenToStore.isNotEmpty) {
      await SecureStorageService.saveRefreshToken(refreshTokenToStore);
    }
    await SecureStorageService.saveUser(updatedUser.toJson());
    notifyListeners();
  }
}
