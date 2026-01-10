import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart'; 
import '../../../../core/api/api_endpoints.dart';
import '../../../product/data/models/category_model.dart';
import '../../../product/data/models/product_model.dart';

// This provider tracks which category ID is currently selected in the UI
// We default it to 'all' so all products show initially.
final selectedCategoryProvider = StateProvider<String>((ref) => 'all');

// 1.5. This provider tracks the search query text
// Empty string means no search filter is applied
final searchQueryProvider = StateProvider<String>((ref) => '');

// Category Provider: Fetches categories and adds the "All" home button
final categoriesProvider = FutureProvider<List<CategoryItem>>((ref) async {
  final dio = ref.watch(dioProvider); 
  
  try {
    final response = await dio.get(ApiEndpoints.categories);
    
    List<dynamic> rawData = [];
    if (response.data is List) {
      rawData = response.data;
    } else if (response.data is Map) {
      rawData = response.data['categories'] ?? response.data['data'] ?? [];
    }

    // Map the API data to CategoryItem objects
    List<CategoryItem> apiCategories = rawData.map((json) => CategoryItem.fromJson(json)).toList();

    // Insert the "All" category at the very beginning (index 0)
    final allCategory = CategoryItem(
      id: 'all', 
      title: 'All', 
      image: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=500' 
    );

    return [allCategory, ...apiCategories];
    
  } catch (e) {
    // Fallback if API fails: Return at least the 'All' button
    return [CategoryItem(id: 'all', title: 'All', image: 'https://via.placeholder.com/150')];
  }
});

// 3. Raw Product Provider: Fetches everything from the database
final productsProvider = FutureProvider<List<ProductModel>>((ref) async {
  try {
    final dio = ref.watch(dioProvider);
    final response = await dio.get(ApiEndpoints.products);
    
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
    print("API Error Details: $e");
    throw Exception("Failed to load products: $e");
  }
});

// 4. FILTERED Product Provider: This is what your GridView should watch!
// It automatically updates when the user clicks a category button or types in search.
// Filters products by category (ID/name) and search query (product name/brand)
final filteredProductsProvider = Provider<AsyncValue<List<ProductModel>>>((ref) {
  final allProductsAsync = ref.watch(productsProvider);
  final selectedId = ref.watch(selectedCategoryProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final categoriesAsync = ref.watch(categoriesProvider);

  // Combine both async values properly
  return allProductsAsync.when(
    data: (products) {
      List<ProductModel> categoryFilteredProducts = products;

      // Step 1: Filter by category if not "all"
      if (selectedId != 'all') {
        // Get the category title (e.g., "iPhone", "Shirt") from the selected category
        return categoriesAsync.when(
          data: (categories) {
            final match = categories.firstWhere(
              (cat) => cat.id == selectedId,
              orElse: () => CategoryItem(id: '', title: '', image: ''),
            );
            final selectedTitle = match.title;

            // Filter products by both category ID and category name
            categoryFilteredProducts = products.where((product) {
              // Logic A: Match by category ID (primary method)
              final bool matchesId = product.categoryId == selectedId;
              
              // Logic B: Match by category name/title (backup method)
              final bool matchesName = product.brandName.toLowerCase().trim() == 
                                       selectedTitle.toLowerCase().trim();

              return matchesId || matchesName;
            }).toList();

            // Step 2: Apply search filter if search query is not empty
            final finalProducts = _applySearchFilter(categoryFilteredProducts, searchQuery);
            return AsyncValue.data(finalProducts);
          },
          loading: () => AsyncValue.loading(),
          error: (error, stack) => AsyncValue.error(error, stack),
        );
      } else {
        // If "All" is selected, only apply search filter
        final finalProducts = _applySearchFilter(products, searchQuery);
        return AsyncValue.data(finalProducts);
      }
    },
    loading: () => AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Helper function to filter products by search query
// Searches in both product name and brand name
List<ProductModel> _applySearchFilter(List<ProductModel> products, String searchQuery) {
  if (searchQuery.isEmpty || searchQuery.trim().isEmpty) {
    return products;
  }

  final query = searchQuery.toLowerCase().trim();
  
  return products.where((product) {
    // Search in product name
    final matchesProductName = product.productName.toLowerCase().contains(query);
    
    // Search in brand name
    final matchesBrandName = product.brandName.toLowerCase().contains(query);
    
    // Return true if either product name or brand name matches
    return matchesProductName || matchesBrandName;
  }).toList();
}