import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/order_model.dart';
import '../services/secure_storage_service.dart';

class OrderController extends ChangeNotifier {
  bool isLoading = false;
  String? lastError;

  Future<String?> placeOrder(
    BuildContext context, {
    required OrderRequest request,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final token = await SecureStorageService.readToken();
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null && token.isNotEmpty){
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.post(Uri.parse('${ApiConstants.apiBaseUrl}/orders'),
        headers: headers,
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        lastError = null;
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final orderId = OrderResponse.fromJson(body).orderId;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed successfully'),
            backgroundColor: Colors.green,
          ),
        );
        return orderId;
      }

      String serverMessage = 'Failed to place order';
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
}
