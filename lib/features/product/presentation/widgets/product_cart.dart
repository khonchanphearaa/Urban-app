import 'package:flutter/material.dart';
import '../../../../common/theme/app_colors.dart';
import '../../domain/entities/prodcut_entity.dart';
import '../pages/product_detail_page.dart';

class ProductCard extends StatelessWidget {
  final ProductEntity product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Image and Stacked elements (Hero added here)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 0.75,
                    child: Hero(
                      tag: 'product_image_${product.id}', // Unique tag for animation
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      product.isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 18,
                      color: product.isLiked ? AppColors.accentRed : AppColors.primary,
                    ),
                  ),
                ),
                if (product.isHot)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accentRed,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'HOT',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              product.brandName.toUpperCase(),
              style: const TextStyle(color: AppColors.accentRed, fontSize: 10, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              product.productName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (product.originalPrice != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '\$${product.originalPrice!.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: AppColors.secondary,
                        fontSize: 12,
                        decoration: TextDecoration.lineThrough),
                  ),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }
}