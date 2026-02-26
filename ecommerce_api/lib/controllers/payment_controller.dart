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
    notifyListeners();

    try {
      final token = await SecureStorageService.readToken();
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null && token.isNotEmpty){
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
    notifyListeners();

    try {
      final token = await SecureStorageService.readToken();
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null && token.isNotEmpty){
        headers['Authorization'] = 'Bearer $token';
      }
      final response = await http.post(Uri.parse('${ApiConstants.apiBaseUrl}/payments/bakong/retry'),
        headers: headers,
        body: jsonEncode({'orderId': orderId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        payment = PaymentResponse.fromJson(body);
        notifyListeners();
        return payment;
      }

      String serverMessage = 'Failed to refresh KHQR payment';
      try {
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic>) {
          if (body['message'] != null){
            serverMessage = body['message'].toString();
          }
          else if (body['error'] != null){
            serverMessage = body['error'].toString();
          }
          else{
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

  /* Checking Status with md5 */
  Future<String?> checkStatus(
    BuildContext context, {
    required String orderId,
    String? md5,
  }) async {
    isChecking = true;
    notifyListeners();

    try {
      final token = await SecureStorageService.readToken();
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null && token.isNotEmpty){
        headers['Authorization'] = 'Bearer $token';
      }

      final body = <String, dynamic>{'orderId': orderId};

      /* If MD5 exists, include it for Bakong transaction verification */
      if (md5 != null && md5.isNotEmpty) {
        body['md5'] = md5;
      }

      final response = await http.post(Uri.parse('${ApiConstants.apiBaseUrl}/payments/checkStatus'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final payload = jsonDecode(response.body);
        Map<String, dynamic> map = payload is Map<String, dynamic>
            ? payload
            : {};

        final topLevelStatus = map['status']?.toString();
        final responseCode = map['responseCode'];
        final topLevelData = map['data'];

        
        if (topLevelStatus != null && topLevelStatus.isNotEmpty) {
          final normalizedStatus = topLevelStatus.toUpperCase().trim();
          status = normalizedStatus;
          notifyListeners();
          return status;
        }

        if (responseCode != null && topLevelData is Map<String, dynamic>) {

          /* Bakong returns responseCode: 0 for successful API call */
          if (responseCode == 0) {

            /* Check transaction status inside data object */
            final transactionStatus = topLevelData['status']?.toString();
            if (transactionStatus != null && transactionStatus.isNotEmpty) {
              final normalizedStatus = transactionStatus.toUpperCase().trim();
              
              if (normalizedStatus == 'PAID' || 
                  normalizedStatus == 'SUCCESS' || 
                  normalizedStatus == 'COMPLETED' ||
                  normalizedStatus == 'SUCCESSFUL') {
                status = 'PAID';
                notifyListeners();
                return status;
              }
              
              /* For other status */
              status = normalizedStatus;
              notifyListeners();
              return status;
            }
            
            /* responseCode 0 but no status in data → Transaction found but status unknown */
            status = 'PENDING';
            notifyListeners();
            return status;
          } else {
            
            /* responseCode != 0 means error or not found */
            status = 'FAILED';
            notifyListeners();
            return status;
          }
        }

        /*  Check nested data.status (alternative backend format) */
        if (topLevelData is Map<String, dynamic>) {
          final dataStatus = topLevelData['status']?.toString();
          if (dataStatus != null && dataStatus.isNotEmpty) {
            status = dataStatus.toUpperCase().trim();
            notifyListeners();
            return status;
          }
        }

        status = 'PENDING';
        notifyListeners();
        return status;
      }

      String serverMessage = 'Failed to check payment status';
      try {
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic>) {
          if (body['message'] != null){
            serverMessage = body['message'].toString();
          }
          else if (body['error'] != null){
            serverMessage = body['error'].toString();
          }
          else{
            serverMessage = response.body.toString();
          }
        } else {
          serverMessage = response.body.toString();
        }
      } catch (_) {
        serverMessage = response.body.toString();
      }

      lastError = serverMessage;
      return null;
    } catch (e) {
      lastError = e.toString();
      return null;
    } finally {
      isChecking = false;
      notifyListeners();
    }
  }
}
