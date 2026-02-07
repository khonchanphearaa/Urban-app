import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../../../common/theme/app_colors.dart';

class SeasonalSaleBanner extends ConsumerWidget {
  const SeasonalSaleBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);

    return productsAsync.when(
      data: (products) {
        if (products.isEmpty) return const SizedBox.shrink();

        final featuredProduct = products.first;

        return Container(
          width: double.infinity,
          // 1. Remove fixed height or change to constraints
          constraints: const BoxConstraints(minHeight: 160),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: NetworkImage(featuredProduct.imageUrl),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5), // Slightly darker for better contrast
                BlendMode.darken,
              ),
            ),
          ),
          child: Padding(
            // 2. Increase padding slightly to give content room
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // 3. Allow column to shrink/wrap
              children: [
                const Text(
                  "SEASONAL SALE",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12, // Slightly smaller to save space
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                // 4. Wrap text in Flexible or use maxLines to prevent overflow
                Text(
                  "Up to 40% Off on\n${featuredProduct.productName}",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20, // Reduced from 22 to fit better
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                // 5. Button
                SizedBox(
                  height: 36, // Fixed height for button to keep it compact
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentRed,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    onPressed: () {},
                    child: const Text("Shop Now", style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}