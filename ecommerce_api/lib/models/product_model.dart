class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final List<String> imageUrl;
  final String categoryName;
  final String? categoryId;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.categoryName,
    this.categoryId,
  });

  /* Helper getter for admin - returns first image URL */
  String get image => imageUrl.isNotEmpty ? imageUrl.first : '';

  // Helper getter for admin - category as object
  CategoryInfo? get category =>
      categoryId != null ? CategoryInfo(id: categoryId!) : null;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    int parseStock(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString()) ?? 0;
    }

    double parsePrice(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0;
    }

    String parseId(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    /* Helper function to parse category name with fallback */
    String parseCategoryName(dynamic value) {
      if (value is Map<String, dynamic>) {
        return value['name']?.toString() ?? 'General';
      }
      return 'General';
    }

    String? parseCategoryId(dynamic value) {
      if (value is Map<String, dynamic>) {
        final categoryId = value['_id'] ?? value['id'];
        return categoryId?.toString();
      }
      return null;
    }

    return ProductModel(
      id: parseId(json['_id'] ?? json['id']),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: parsePrice(json['price']),
      stock: parseStock(json['stock'] ?? json['quantity']),
      // API returns an array of images
      imageUrl:
          (json['images'] as List?)?.map((img) => img.toString()).toList() ??
          [],
      // Nested category object
      categoryName: parseCategoryName(json['category']),
      categoryId: parseCategoryId(json['category']),
    );
  }
}

// Helper class for category info
class CategoryInfo {
  final String id;
  CategoryInfo({required this.id});
}
