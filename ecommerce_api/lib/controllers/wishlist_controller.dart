import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/product_model.dart';
import '../services/secure_storage_service.dart';

class WishlistController extends ChangeNotifier {
  final List<ProductModel> _items = [];
  final Set<String> _processingIds = <String>{};
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<ProductModel> get items => List.unmodifiable(_items);
  int get count => _items.length;

  bool isInWishlist(String productId) {
    return _items.any((item) => item.id == productId);
  }

  bool isProcessing(String productId) {
    return _processingIds.contains(productId);
  }

  Future<bool> fetchWishlist({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final token = await SecureStorageService.readToken();
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(Uri.parse('${ApiConstants.apiBaseUrl}/products/wishlist'),headers: headers);

      if (response.statusCode != 200) {
        return false;
      }

      final decoded = jsonDecode(response.body);
      final rawList =
          (decoded is Map<String, dynamic> && decoded['data'] is List)
          ? decoded['data'] as List<dynamic>
          : <dynamic>[];

      final parsedItems = <ProductModel>[];
      final seen = <String>{};

      for (final entry in rawList) {
        final normalized = _normalizeProductMap(entry);
        if (normalized == null) continue;

        final product = ProductModel.fromJson(normalized);
        if (product.id.isEmpty || seen.contains(product.id)) continue;

        seen.add(product.id);
        parsedItems.add(product);
      }

      _items
        ..clear()
        ..addAll(parsedItems);

      return true;
    } catch (_) {
      return false;
    } finally {
      if (!silent) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  /* Toggle wishlist Add/Remove when click the first is Add, If click second time is Remove */
  Future<bool> toggleWishlist(
    BuildContext context, {
    required String productId,
    ProductModel? product,
    bool showSnackBar = true,
  }) async {
    if (_processingIds.contains(productId)) return false;

    _processingIds.add(productId);
    notifyListeners();

    final wasInWishlist = isInWishlist(productId);

    try {
      final token = await SecureStorageService.readToken();
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.post(Uri.parse('${ApiConstants.apiBaseUrl}/products/$productId/wishlist'),headers: headers,);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          _extractMessage(response.body, fallback: 'Wishlist action failed'),
        );
      }

      if (wasInWishlist) {
        _items.removeWhere((item) => item.id == productId);
      } else if (product != null) {
        _items.insert(0, product);
      }

      final refreshed = await fetchWishlist(silent: true);

      if (showSnackBar) {
        if (!context.mounted) return true;
        final message = _extractMessage(
          response.body,
          fallback: wasInWishlist
              ? 'Removed from wishlist'
              : 'Added to wishlist',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: refreshed || !wasInWishlist
                ? Colors.green
                : Colors.orange,
          ),
        );
      }

      return true;
    } catch (e) {
      if (showSnackBar) {
        if (!context.mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
      return false;
    } finally {
      _processingIds.remove(productId);
      notifyListeners();
    }
  }

  String _extractMessage(String rawBody, {required String fallback}) {
    try {
      final decoded = jsonDecode(rawBody);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'] ?? decoded['error'];
        if (message != null && message.toString().trim().isNotEmpty) {
          return message.toString();
        }
      }
    } catch (_) {}

    return fallback;
  }

  Map<String, dynamic>? _normalizeProductMap(dynamic raw) {
    dynamic source = raw;
    if (source is Map<String, dynamic> &&
        source['product'] is Map<String, dynamic>) {
      source = source['product'];
    }
    if (source is! Map<String, dynamic>) return null;

    final imageSource =
        source['images'] ?? source['imageUrl'] ?? source['image'];
    final images = <String>[];
    if (imageSource is List) {
      images.addAll(
        imageSource.map((e) => e.toString()).where((e) => e.trim().isNotEmpty),
      );
    } else if (imageSource is String && imageSource.trim().isNotEmpty) {
      images.add(imageSource);
    }

    final category = source['category'] is Map<String, dynamic>
        ? source['category'] as Map<String, dynamic>
        : <String, dynamic>{'name': source['categoryName'] ?? 'General'};

    return {
      '_id': source['_id'] ?? source['id'] ?? source['productId'] ?? '',
      'name': source['name'] ?? 'Unknown Product',
      'description': source['description'] ?? '',
      'price': _toNum(source['price']),
      'stock': source['stock'] ?? source['quantity'] ?? 0,
      'images': images,
      'category': category,
    };
  }

  num _toNum(dynamic value) {
    if (value is num) return value;
    if (value is String) {
      return num.tryParse(value) ?? 0;
    }
    return 0;
  }
}
