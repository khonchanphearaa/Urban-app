import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/payment_model.dart';
import '../services/secure_storage_service.dart';

class PaymentController extends ChangeNotifier {
  bool isLoading = false;
  String? lastError;
  PaymentResponse? payment;
  String? status;
  bool isChecking = false;

  Future<PaymentResponse?> requestBakongQr(
    BuildContext context, {
    required String orderId,
  }) async {
    isLoading = true;
    lastError = null;
    status = null;
    payment = null; 
    notifyListeners();

    try {
      final token = await SecureStorageService.readToken();
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.apiBaseUrl}/payments/bakong'),
        headers: headers,
        body: jsonEncode({'orderId': orderId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        payment = PaymentResponse.fromJson(body);
        final generatedMd5 = payment?.md5?.trim();
        if (generatedMd5 != null && generatedMd5.isNotEmpty) {
          await SecureStorageService.savePendingPaymentMd5(generatedMd5);
        }
        notifyListeners();
        return payment;
      }

      String serverMessage = 'Failed to create KHQR payment';
      try {
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic>) {
          if (body['message'] != null) {
            serverMessage = body['message'].toString();
          } else if (body['error'] != null) {
            serverMessage = body['error'].toString();
          } else {
            serverMessage = response.body.toString();
          }
        } else {
          serverMessage = response.body.toString();
        }
      } catch (_) {
        serverMessage = response.body.toString();
      }

      lastError = serverMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(serverMessage), backgroundColor: Colors.red),
      );
      return null;
    } catch (e) {
      lastError = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /* REST api Bakong retry again generate khqr */
  Future<PaymentResponse?> retryBakongQr(
    BuildContext context, {
    required String orderId,
  }) async {
    isLoading = true;
    lastError = null;
    status = null;
    payment = null;
    notifyListeners();

    try {
      final token = await SecureStorageService.readToken();
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      final response = await http.post(
        Uri.parse('${ApiConstants.apiBaseUrl}/payments/bakong/retry'),
        headers: headers,
        body: jsonEncode({'orderId': orderId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        payment = PaymentResponse.fromJson(body);
        final generatedMd5 = payment?.md5?.trim();
        if (generatedMd5 != null && generatedMd5.isNotEmpty) {
          await SecureStorageService.savePendingPaymentMd5(generatedMd5);
        }
        notifyListeners();
        return payment;
      }

      String serverMessage = 'Failed to refresh KHQR payment';
      try {
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic>) {
          if (body['message'] != null) {
            serverMessage = body['message'].toString();
          } else if (body['error'] != null) {
            serverMessage = body['error'].toString();
          } else {
            serverMessage = response.body.toString();
          }
        } else {
          serverMessage = response.body.toString();
        }
      } catch (_) {
        serverMessage = response.body.toString();
      }

      lastError = serverMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(serverMessage), backgroundColor: Colors.red),
      );
      return null;
    } catch (e) {
      lastError = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /* Check payment status.*/
  Future<String?> checkStatus(
    BuildContext context, {
    required String md5,
  }) async {
    isChecking = true;
    notifyListeners();

    try {
      final token = await SecureStorageService.readToken();
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final normalizedMd5 = md5.trim();
      if (normalizedMd5.isEmpty) {
        lastError = 'Missing payment identifier (md5).';
        return null;
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.apiBaseUrl}/payments/checkStatus'),
        headers: headers,
        body: jsonEncode({'md5': normalizedMd5}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final payload = jsonDecode(response.body);

        if (payload is Map<String, dynamic>) {
          final rawStatus = payload['status']?.toString().toUpperCase().trim();
          final isSuccess = payload['success'] == true;

          if (isSuccess && rawStatus == 'PAID') {
            status = 'PAID';
            notifyListeners();
            return status;
          }

          if (rawStatus == 'CANCELLED' ||
              rawStatus == 'EXPIRED' ||
              rawStatus == 'FAILED') {
            status = rawStatus;
            notifyListeners();
            return status;
          }

          status = 'PENDING';
          notifyListeners();
          return status;
        }
      }
      status = 'PENDING';
      notifyListeners();
      return status;
    } catch (e) {
      lastError = e.toString();
      return null;
    } finally {
      isChecking = false;
      notifyListeners();
    }
  }
}
