import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../constants/api_constants.dart';
import '../../models/category_model.dart';
import '../../services/secure_storage_service.dart';

class AdminCategoryController extends ChangeNotifier {
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<String?> _getToken() async {
    return await SecureStorageService.readToken();
  }

  /* Fetch all categories */
  Future<void> fetchCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('${ApiConstants.apiBaseUrl}/categories'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final categoryList = data['data'] ?? data['categories'] ?? [];
        _categories = (categoryList as List)
            .map((json) => CategoryModel.fromJson(json))
            .toList();
        _error = null;
      } else {
        _error = 'Failed to load categories';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /* Create a new category */
  Future<bool> createCategory({
    required String name,
    required String description,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.apiBaseUrl}/categories'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'name': name, 'description': description}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchCategories();
        _error = null;
        return true;
      } else {
        _error = 'Failed to create category: ${response.body}';
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

  /* Update category */
  Future<bool> updateCategory({
    required String categoryId,
    required String name,
    required String description,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.put(
        Uri.parse('${ApiConstants.apiBaseUrl}/categories/$categoryId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'name': name, 'description': description}),
      );

      if (response.statusCode == 200) {
        await fetchCategories();
        _error = null;
        return true;
      } else {
        _error = 'Failed to update category: ${response.body}';
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

  /* Delete category */
  Future<bool> deleteCategory(String categoryId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.delete(
        Uri.parse('${ApiConstants.apiBaseUrl}/categories/$categoryId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        await fetchCategories();
        _error = null;
        return true;
      } else {
        _error = 'Failed to delete category';
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
