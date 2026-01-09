import '../../domain/entities/prodcut_entity.dart';

class ProductModel extends ProductEntity {
  ProductModel({
    required super.id,
    required super.imageUrl,
    required super.brandName,
    required super.productName,
    required super.price,
    super.originalPrice,
    super.isHot,
    super.isLiked,
  });

factory ProductModel.fromJson(Map<String, dynamic> json) {
  // Safe Image Handling
  String img = 'https://via.placeholder.com/150';
  if (json['images'] != null && (json['images'] as List).isNotEmpty) {
    img = json['images'][0]; // Get first image from array
  }

  // Safe Category/Brand Handling
  String brand = 'Urban';
  if (json['category'] != null && json['category'] is Map) {
    brand = json['category']['name'] ?? 'Urban';
  }

  return ProductModel(
    id: json['_id'] ?? '',
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