import 'package:flutter/material.dart';
import '../../../../common/theme/app_colors.dart';
import '../../domain/entities/prodcut_entity.dart';

class ProductCard extends StatelessWidget {
  final ProductEntity product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Image and Stacked elements (Heart, HOT tag)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                // Use CachedNetworkImage in real app, Placeholder for now
                child: AspectRatio(
                  aspectRatio: 0.75, // Taller than wide format
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Favorite Icon
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
              // HOT Tag
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

          // 2. Brand Name
          Text(
            product.brandName.toUpperCase(),
            style: TextStyle(color: AppColors.accentRed, fontSize: 10, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),

          // 3. Product Name
          Text(
            product.productName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),

          // 4. Pricing Info
          Row(
            children: [
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              if (product.originalPrice != null) ...[
                const SizedBox(width: 8),
                Text(
                  '\$${product.originalPrice!.toStringAsFixed(2)}',
                  style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 12,
                      decoration: TextDecoration.lineThrough),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }
}