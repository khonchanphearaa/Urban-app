import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/cart_item.dart';
import '../models/cart_model.dart';
import '../services/secure_storage_service.dart';
import '../constants/api_constants.dart';

class CartController extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /* Local list of cart items (dynamic) */
  final List<CartItem> _items = [];
  List<CartItem> get items => List.unmodifiable(_items);


  Future<bool> addToCart(
    BuildContext context, {
    required String productId,
    required String name,
    required String imageUrl,
    required String size,
    required int quantity,
    required double price,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final cartPayload = CartModel(
        productId: productId,
        quantity: quantity,
        size: size.isNotEmpty ? size : null,
      );

      final token = await SecureStorageService.readToken();
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null && token.isNotEmpty) headers['Authorization'] = 'Bearer $token';

      final response = await http.post(
        Uri.parse('${ApiConstants.apiBaseUrl}/cart/add'),
        headers: headers,
        body: jsonEncode(cartPayload.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {

        /* Add to local list */
        final existingIndex = _items.indexWhere((i) => i.id == productId && i.size == size);
        if (existingIndex >= 0) {

          /* increase quantity */
          final existing = _items[existingIndex];
          _items[existingIndex] = CartItem(
            id: existing.id,
            name: existing.name,
            imageUrl: existing.imageUrl,
            size: existing.size,
            quantity: existing.quantity + quantity,
            price: existing.price,
          );
        } else {
          _items.add(CartItem(
            id: productId,
            name: name,
            imageUrl: imageUrl,
            size: size,
            quantity: quantity,
            price: price,
          ));
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Item added to cart!"), backgroundColor: Colors.green),
        );
        return true;
      } else {
        /* Try to extract a message from the response body for better debugging */
        String serverMessage = 'Failed to add to cart';
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
        throw Exception(serverMessage);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Remove item
  void removeItem(String productId, String size) {
    _items.removeWhere((i) => i.id == productId && i.size == size);
    notifyListeners();
  }

  // Update quantity
  void updateQuantity(String productId, String size, int quantity) {
    final idx = _items.indexWhere((i) => i.id == productId && i.size == size);
    if (idx >= 0) {
      final item = _items[idx];
      _items[idx] = CartItem(
        id: item.id,
        name: item.name,
        imageUrl: item.imageUrl,
        size: item.size,
        quantity: quantity,
        price: item.price,
      );
      notifyListeners();
    }
  }

  /* Clear all items from cart */
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  /* Fucntion checkout: post items to API to update stock */
  Future<bool> checkoutAndUpdateStock(BuildContext context) async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cart is empty"), backgroundColor: Colors.orange),
      );
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final token = await SecureStorageService.readToken();
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null && token.isNotEmpty) headers['Authorization'] = 'Bearer $token';

      for (final item in _items) {
        final payload = {
          'productId': item.id,
          'quantity': item.quantity,
        };

        final response = await http.post(
          Uri.parse('${ApiConstants.apiBaseUrl}/cart/add'),
          headers: headers,
          body: jsonEncode(payload),
        );

        if (response.statusCode != 200 && response.statusCode != 201) {
          String serverMessage = 'Failed to update stock';
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
          throw Exception(serverMessage);
        }
      }

      clearCart();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Checkout complete"), backgroundColor: Colors.green),
      );
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}