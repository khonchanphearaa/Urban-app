import 'package:flutter_riverpod/flutter_riverpod.dart';
// Import your core api client
import '../../../../core/api/api_client.dart'; 
import '../../../../core/api/api_endpoints.dart';
import '../../../product/data/models/category_model.dart';
import '../../../product/data/models/product_model.dart';

// Category Provider
final categoriesProvider = FutureProvider<List<CategoryItem>>((ref) async {
  final dio = ref.watch(dioProvider); 
  
  try {
    final response = await dio.get(ApiEndpoints.categories);
    
    // 1. Debugging: This helps you see exactly what the API is sending in your console
    print("Category API Response: ${response.data}");

    // 2. Logic to handle both List and Object responses
    List<dynamic> rawData = [];
    
    if (response.data is List) {
      // If the API returns [ {...}, {...} ]
      rawData = response.data;
    } else if (response.data is Map) {
      // If the API returns { "categories": [...] } or { "data": [...] }
      rawData = response.data['categories'] ?? response.data['data'] ?? [];
    }

    // 3. Map to your model
    return rawData.map((json) => CategoryItem.fromJson(json)).toList();
    
  } catch (e) {
    print("Category Provider Error: $e");
    // Returning an empty list so the app doesn't crash
    return []; 
  }
});

// Product Provider
final productsProvider = FutureProvider<List<ProductModel>>((ref) async {
  try {
    final dio = ref.watch(dioProvider);
    final response = await dio.get(ApiEndpoints.products);
    
    // SAFE CHECK: Check if data is a List or an Object containing a list
    List<dynamic> rawData = [];
    if (response.data is List) {
      rawData = response.data;
    } else if (response.data is Map && response.data.containsKey('products')) {
      rawData = response.data['products'];
    } else if (response.data is Map && response.data.containsKey('data')) {
      rawData = response.data['data'];
    }

    return rawData.map((json) => ProductModel.fromJson(json)).toList();
  } catch (e) {
    // This will print the exact error in your console
    print("API Error Details: $e");
    throw Exception("Failed to load products: $e");
  }
});