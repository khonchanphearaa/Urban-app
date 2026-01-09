import 'package:flutter_riverpod/flutter_riverpod.dart';
// Import your core api client
import '../../../../core/api/api_client.dart'; 
import '../../../../core/api/api_endpoints.dart';
import '../../../product/data/models/category_model.dart';
import '../../../product/data/models/product_model.dart';

// Category Provider
final categoriesProvider = FutureProvider<List<CategoryItem>>((ref) async {
  // Use the provider from api_client.dart
  final dio = ref.watch(dioProvider); 
  
  final response = await dio.get(ApiEndpoints.categories);
  final List data = response.data;
  return data.map((json) => CategoryItem.fromJson(json)).toList();
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