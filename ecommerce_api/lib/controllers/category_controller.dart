import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/category_model.dart';

class CategoryController extends ChangeNotifier {
  List<CategoryModel> _categories = [];
  bool _isLoading = false;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> getCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('${ApiConstants.apiBaseUrl}/categories'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        final List<dynamic> dataList = decoded['data'] ?? decoded['categories'] ?? [];
        _categories = dataList.map((e) => CategoryModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Categories fetch error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
