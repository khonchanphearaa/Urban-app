import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/presentation/providers/home_providers.dart';

class HomeCategoryList extends ConsumerWidget {
  const HomeCategoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the categoriesProvider we defined earlier
    final categoriesAsync = ref.watch(categoriesProvider);

    return SizedBox(
      height: 110,
      child: categoriesAsync.when(
        // 1. Loading State
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.red, strokeWidth: 2),
        ),
        
        // 2. Error State
        error: (err, stack) => Center(
          child: Text(
            "Error loading categories",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
        
        // 3. Data State (When API returns successfully)
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(child: Text("No categories found"));
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: index == 0 ? Colors.red : Colors.transparent,
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
                      style: const TextStyle(
                        fontSize: 12, 
                        fontWeight: FontWeight.w500
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}