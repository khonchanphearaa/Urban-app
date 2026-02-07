import 'package:flutter/foundation.dart'; // Required for debugPrint
import '../../domain/entities/prodcut_entity.dart';

class ProductModel extends ProductEntity {
  ProductModel({
    required super.id,
    required super.categoryId,
    required super.imageUrl,
    required super.brandName,
    required super.productName,
    required super.price,
    super.originalPrice,
    super.isHot,
    super.isLiked,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // --- ADD THE DEBUG CODE HERE ---
    final catId = json['category'] != null ? json['category']['_id'] : 'null';
    debugPrint("Mapping Product: ${json['name']} -> CategoryID: $catId");
    // -------------------------------

    String img = 'https://via.placeholder.com/150';
    if (json['images'] != null && (json['images'] as List).isNotEmpty) {
      img = json['images'][0];
    }

    String brand = 'Urban';
    if (json['category'] != null && json['category'] is Map) {
      brand = json['category']['name'] ?? 'Urban';
    }

    return ProductModel(
      id: json['_id'] ?? '',
      categoryId: catId, // Using the catId we just printed
      imageUrl: img,
      brandName: brand,
      productName: json['name'] ?? 'Unknown Product',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['oldPrice'] as num?)?.toDouble(),
      isHot: (json['stock'] ?? 0) < 5,
      isLiked: false,
    );
  }
}