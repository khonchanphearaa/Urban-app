import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../../../common/theme/app_colors.dart';

// Note: selectedCategoryProvider is imported from home_providers.dart
// Do not redefine it here - we use the shared provider

class HomeCategoryList extends ConsumerWidget {
  const HomeCategoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedId = ref.watch(selectedCategoryProvider);

    return SizedBox(
      height: 110,
      child: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(
              child: Text("No Categories", style: TextStyle(fontSize: 12)),
            );
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemBuilder: (context, index) {
              final category = categories[index];
              // Check if this specific item is the one selected
              final isSelected = selectedId == category.id;

              return GestureDetector(
                onTap: () {
                  debugPrint("Clicked Category: ${category.title} with ID: ${category.id}");
                  // Update the provider when clicked
                  ref.read(selectedCategoryProvider.notifier).state = category.id;
                  debugPrint("Selected Category ID: ${category.id}");
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            // Border shows if isSelected is true
                            color: isSelected ? AppColors.accentRed : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: NetworkImage(category.image),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category.title,
                        style: TextStyle(
                          fontSize: 12,
                          // Make text bold if selected
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? AppColors.accentRed : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const _CategoryShimmer(),
        error: (err, stack) => const Icon(Icons.error_outline, color: Colors.grey),
      ),
    );
  }
}

// ... Keep your _CategoryShimmer class below exactly as it was

// Simple internal Shimmer placeholder
class _CategoryShimmer extends StatelessWidget {
  const _CategoryShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(right: 20),
        child: Column(
          children: [
            CircleAvatar(radius: 35, backgroundColor: Colors.grey[100]),
            const SizedBox(height: 8),
            Container(width: 40, height: 10, color: Colors.grey[100]),
          ],
        ),
      ),
    );
  }
}