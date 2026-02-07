class ProductEntity {
  final String id;
  final String categoryId; // Added to allow category filtering
  final String imageUrl;
  final String brandName;
  final String productName;
  final double price;
  final double? originalPrice; // Nullable if not on sale
  final bool isHot;
  final bool isLiked;

  ProductEntity({
    required this.id,
    required this.categoryId, // Required field
    required this.imageUrl,
    required this.brandName,
    required this.productName,
    required this.price,
    this.originalPrice,
    this.isHot = false,
    this.isLiked = false,
  });
}

// Updated Static Products with categoryId
final List<ProductEntity> staticProducts = [
  ProductEntity(
    id: '1',
    categoryId: 'all', // Default or specific category ID
    imageUrl: 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=500',
    brandName: 'LUMIERE STUDIO',
    productName: 'Oversized Linen Shirt',
    price: 79.00,
    isHot: true,
  ),
  ProductEntity(
    id: '2',
    categoryId: 'bags', // Example category ID
    imageUrl: 'https://images.unsplash.com/photo-1548036235-861c005a2460?w=500',
    brandName: 'AURA ATELIER',
    productName: 'Quilted Leather Bag',
    price: 125.00,
    originalPrice: 180.00,
    isLiked: true,
  ),
];