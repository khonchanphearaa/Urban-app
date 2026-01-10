import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/theme/app_colors.dart';
import '../../../product/presentation/widgets/product_cart.dart';
import '../../../product/data/models/product_model.dart';
import '../providers/home_providers.dart';

// Provider for sort option
final sortOptionProvider = StateProvider<SortOption>((ref) => SortOption.none);

// Provider for filtered/sorted products in explore page
final exploreProductsProvider = Provider<AsyncValue<List<ProductModel>>>((ref) {
  final productsAsync = ref.watch(productsProvider);
  final sortOption = ref.watch(sortOptionProvider);

  return productsAsync.whenData((products) {
    List<ProductModel> sortedProducts = List.from(products);
    
    switch (sortOption) {
      case SortOption.priceLowToHigh:
        sortedProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceHighToLow:
        sortedProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.nameAZ:
        sortedProducts.sort((a, b) => a.productName.compareTo(b.productName));
        break;
      case SortOption.nameZA:
        sortedProducts.sort((a, b) => b.productName.compareTo(a.productName));
        break;
      case SortOption.none:
        // Keep original order
        break;
    }
    
    return sortedProducts;
  });
});

enum SortOption {
  none,
  priceLowToHigh,
  priceHighToLow,
  nameAZ,
  nameZA,
}

class ExplorePage extends ConsumerWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(exploreProductsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Summer Collection",
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement search functionality
            },
            icon: const Icon(Icons.search, color: AppColors.primary),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Row
          _buildFilterBar(context, ref),
          
          Expanded(
            child: productsAsync.when(
              data: (products) => RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(productsProvider);
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // Items count header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 8),
                        child: Text(
                          "${products.length} ITEMS FOUND",
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    // Product grid
                    SliverPadding(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.48,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => ProductCard(product: products[index]),
                          childCount: products.length,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.accentRed),
              ),
              error: (e, s) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: AppColors.secondary),
                    const SizedBox(height: 16),
                    const Text(
                      "Error loading products",
                      style: TextStyle(color: AppColors.secondary),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => ref.invalidate(productsProvider),
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildCartFAB(),
    );
  }

  Widget _buildFilterBar(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _filterChip(
            ref,
            Icons.tune,
            "Filter",
            onTap: () {
              // TODO: Show filter bottom sheet
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Filter functionality coming soon")),
              );
            },
          ),
          _filterChip(
            ref,
            null,
            "Sort by",
            hasArrow: true,
            onTap: () => _showSortDialog(context, ref),
          ),
          _filterChip(
            ref,
            null,
            "Size",
            hasArrow: true,
            onTap: () {
              // TODO: Show size filter
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Size filter coming soon")),
              );
            },
          ),
          _filterChip(
            ref,
            null,
            "Price",
            hasArrow: true,
            onTap: () => _showSortDialog(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(
    WidgetRef ref,
    IconData? icon,
    String label, {
    bool hasArrow = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) Icon(icon, size: 16, color: AppColors.primary),
            if (icon != null) const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
                fontSize: 13,
              ),
            ),
            if (hasArrow) const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.secondary),
          ],
        ),
      ),
    );
  }

  void _showSortDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                "Sort by",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            _sortOptionTile(
              context,
              ref,
              "None",
              SortOption.none,
            ),
            _sortOptionTile(
              context,
              ref,
              "Price: Low to High",
              SortOption.priceLowToHigh,
            ),
            _sortOptionTile(
              context,
              ref,
              "Price: High to Low",
              SortOption.priceHighToLow,
            ),
            _sortOptionTile(
              context,
              ref,
              "Name: A to Z",
              SortOption.nameAZ,
            ),
            _sortOptionTile(
              context,
              ref,
              "Name: Z to A",
              SortOption.nameZA,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sortOptionTile(
    BuildContext context,
    WidgetRef ref,
    String title,
    SortOption option,
  ) {
    final currentSort = ref.watch(sortOptionProvider);
    final isSelected = currentSort == option;

    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppColors.accentRed : AppColors.primary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: AppColors.accentRed)
          : null,
      onTap: () {
        ref.read(sortOptionProvider.notifier).state = option;
        Navigator.pop(context);
      },
    );
  }

  Widget _buildCartFAB() {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        FloatingActionButton(
          onPressed: () {},
          backgroundColor: AppColors.accentRed,
          child: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: const Text("2", style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
        )
      ],
    );
  }
}