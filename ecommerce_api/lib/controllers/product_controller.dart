import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/product_model.dart';

class ProductController extends ChangeNotifier {
  List<ProductModel> products = [];
  bool isLoading = false;

  Future<void> getAllProducts() async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse("${ApiConstants.apiBaseUrl}/products"));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        final List<dynamic> productList = decodedData['data']; 
        
        products = productList.map((item) => ProductModel.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint("API Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


  /* Get categories */
  Future<void> getProductsByCategory(String categoryId) async {
    isLoading = true;
    notifyListeners();

    try {
      final uri = Uri.parse('${ApiConstants.apiBaseUrl}/products?category=$categoryId');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        final List<dynamic> productList = decodedData['data'] ?? [];
        products = productList.map((item) => ProductModel.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint('API Error (by category): $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}