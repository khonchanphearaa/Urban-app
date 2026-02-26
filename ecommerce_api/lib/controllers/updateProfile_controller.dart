// ignore_for_file: file_names
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../services/secure_storage_service.dart';
import 'auth_controller.dart';

class UpdateProfileController extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> updateProfile(
    BuildContext context, {
    required AuthController authController,
    required String name,
    required String email,
    File? avatarFile,
    String? currentPassword,
    String? newPassword,
  }) async {
    _setLoading(true);

    try {
      final bearer = authController.token ?? await SecureStorageService.readToken();
      if (bearer == null || bearer.isEmpty) {
        if (!context.mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login again.'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }

      final safeCurrentPassword = (currentPassword ?? '').trim();
      final safeNewPassword = (newPassword ?? '').trim();

      Future<http.Response> sendMultipart(String method) async {
        final request = http.MultipartRequest(
          method,
          Uri.parse(ApiConstants.updateProfile),
        );

        request.headers['Authorization'] = 'Bearer $bearer';
        request.headers['Accept'] = 'application/json';
        request.headers['Content-Type'] = 'multipart/form-data';

        request.fields['name'] = name.trim();
        request.fields['email'] = email.trim();

        if (safeCurrentPassword.isNotEmpty) {
          request.fields['currentPassword'] = safeCurrentPassword;
        }
        if (safeNewPassword.isNotEmpty) {
          request.fields['newPassword'] = safeNewPassword;
        }

      /* For upload image via form-data */
        if (avatarFile != null) {
          request.files.add(
            await http.MultipartFile.fromPath('avatar', avatarFile.path),
          );
        }

        final streamed = await request.send();
        return http.Response.fromStream(streamed);
      }

      var response = await sendMultipart('POST');
      if (response.statusCode == 404 || response.statusCode == 405) {
        response = await sendMultipart('PATCH');
      }
      if (response.statusCode == 404 || response.statusCode == 405) {
        response = await sendMultipart('PUT');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        await authController.fetchUserProfile();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
        return true;
      }

      String message = 'Failed to update profile';
      try {
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic>) {
          if (body['message'] != null) {
            message = body['message'].toString();
          } else if (body['error'] != null) {
            message = body['error'].toString();
          }
        }
      } catch (_) {}

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
