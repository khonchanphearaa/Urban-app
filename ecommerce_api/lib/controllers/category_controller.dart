import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/category_model.dart';

class CategoryController extends ChangeNotifier {
  List<CategoryModel> categories = [];
  bool isLoading = false;

  Future<void> getCategories() async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('${ApiConstants.apiBaseUrl}/categories'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        final List<dynamic> dataList = decoded['data'] ?? decoded['categories'] ?? [];
        categories = dataList.map((e) => CategoryModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Categories fetch error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
