import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../../constants/api_constants.dart';
import '../../models/product_model.dart';
import '../../services/secure_storage_service.dart';

class AdminProductController extends ChangeNotifier {
  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _limit = 10;
  int _total = 0;
  int _totalPages = 1;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get limit => _limit;
  int get total => _total;
  int get totalPages => _totalPages;

  Future<String?> _getToken() async {
    return await SecureStorageService.readToken();
  }

  int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  int _safeTotalPages(int total, int limit) {
    if (limit <= 0) return 1;
    final pages = (total / limit).ceil();
    return pages < 1 ? 1 : pages;
  }

  Future<void> _refreshCurrentPage() async {
    await fetchProducts(page: _currentPage);
    if (_currentPage > _totalPages) {
      await fetchProducts(page: _totalPages);
    }
  }

  /* Fetch products with pagination */
  Future<void> fetchProducts({int page = 1, int? limit}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (limit != null && limit > 0) {
        _limit = limit;
      }

      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Not authenticated. Please login again.');
      }
      final query = {'page': page.toString(), 'limit': _limit.toString()};

      final response = await http.get(
        Uri.parse(
          '${ApiConstants.apiBaseUrl}/products',
        ).replace(queryParameters: query),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final dynamic dataField = data['data'];
        final List<dynamic> safeProducts = dataField is List
            ? List<dynamic>.from(dataField)
            : (data['products'] is List
                  ? List<dynamic>.from(data['products'])
                  : <dynamic>[]);

        _products = safeProducts
            .whereType<Map>()
            .map(
              (json) => ProductModel.fromJson(Map<String, dynamic>.from(json)),
            )
            .toList();

        _currentPage = _toInt(data['page'], fallback: page);
        _limit = _toInt(data['limit'], fallback: _limit);
        _total = _toInt(
          data['total'],
          fallback: _toInt(data['count'], fallback: _products.length),
        );
        _totalPages = _toInt(
          data['totalPages'],
          fallback: _safeTotalPages(_total, _limit),
        );

        if (_totalPages < 1) {
          _totalPages = 1;
        }

        _error = null;
      } else {
        _error = 'Failed to load products: ${response.body}';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /* Create a new product (multipart form-data) */
  Future<bool> createProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    required XFile image,
    required String categoryId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.apiBaseUrl}/products'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['name'] = name;
      request.fields['description'] = description;
      request.fields['price'] = price.toString();
      request.fields['stock'] = stock.toString();
      request.fields['category'] = categoryId;

      final imageBytes = await image.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'images',
          imageBytes,
          filename: image.name.isNotEmpty ? image.name : 'product_image.jpg',
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _refreshCurrentPage();
        _error = null;
        return true;
      } else {
        _error = 'Failed to create product: ${response.body}';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /* Update product */
  Future<bool> updateProduct({
    required String productId,
    required String name,
    required String description,
    required double price,
    required int stock,
    XFile? image,
    required String categoryId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('${ApiConstants.apiBaseUrl}/products/$productId'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['name'] = name;
      request.fields['description'] = description;
      request.fields['price'] = price.toString();
      request.fields['stock'] = stock.toString();
      request.fields['category'] = categoryId;


      if (image != null) {
        final imageBytes = await image.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'images',
            imageBytes,
            filename: image.name.isNotEmpty ? image.name : 'product_image.jpg',
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        await _refreshCurrentPage();
        _error = null;
        return true;
      } else {
        _error = 'Failed to update product: ${response.body}';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /* Delete product */
  Future<bool> deleteProduct(String productId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.delete(
        Uri.parse('${ApiConstants.apiBaseUrl}/products/$productId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        await _refreshCurrentPage();
        _error = null;
        return true;
      } else {
        _error = 'Failed to delete product';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /* Add stock to product */
  Future<bool> addStock(String productId, int quantity) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.patch(
        Uri.parse('${ApiConstants.apiBaseUrl}/products/$productId/stock'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'quantity': quantity}),
      );

      if (response.statusCode == 200) {
        await _refreshCurrentPage();
        _error = null;
        return true;
      } else {
        _error = 'Failed to add stock';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
