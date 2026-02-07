import 'package:ecommerce_app/features/cart/presentation/pages/cart_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/theme/app_colors.dart';
import '../../../product/presentation/widgets/product_cart.dart';
import '../../../product/presentation/widgets/category_list.dart';
import '../../../product/presentation/widgets/seasonal_sale_banner.dart';
import '../providers/home_providers.dart';
import '../widgets/empty_state_widget.dart';
import 'explore_page.dart';
import 'wishlist_page.dart';
import 'profile_page.dart';
import '../../../cart/presentation/providers/cart_provider.dart';

// Provider to track current navigation index
final navigationIndexProvider = StateProvider<int>((ref) => 0);

class MainNavigationPage extends ConsumerWidget {
  const MainNavigationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);

    // List of pages corresponding to each navigation item
    final pages = const [
      HomePageContent(), // Home page without bottom nav (we add it here)
      ExplorePage(),
      WishlistPage(),
      ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: _buildBottomNav(ref, currentIndex),
    );
  }

  Widget _buildBottomNav(WidgetRef ref, int currentIndex) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.accentRed,
      unselectedItemColor: AppColors.secondary,
      currentIndex: currentIndex,
      onTap: (index) {
        ref.read(navigationIndexProvider.notifier).state = index;
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.compass_calibration),
          label: 'Explore',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          label: 'Wishlist',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}

// Separate widget for HomePage content (without bottom nav since it's managed here)
class HomePageContent extends ConsumerWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredProductsAsync = ref.watch(filteredProductsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(categoriesProvider);
          ref.invalidate(productsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // 1. Search Bar
                _buildSearchBar(ref),
                const SizedBox(height: 25),
                // 2. Categories Horizontal List
                const HomeCategoryList(),
                const SizedBox(height: 25),
                // 3. Promo Banner
                const SeasonalSaleBanner(),
                const SizedBox(height: 25),
                // 4. Trending Header
                _buildSectionHeader("Trending Now"),
                const SizedBox(height: 30),
                // 5. Product Grid
                filteredProductsAsync.when(
                  data: (products) {
                    if (products.isEmpty) {
                      return EmptyStateWidget(
                        title: "No Products Found",
                        message: "We don't have items for this category yet.",
                        onRetry: () => ref.invalidate(productsProvider),
                      );
                    }
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: products.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.55,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 20,
                      ),
                      itemBuilder: (context, index) {
                        return ProductCard(product: products[index]);
                      },
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(color: AppColors.accentRed),
                    ),
                  ),
                  error: (err, stack) => Center(
                    child: Column(
                      children: [
                        const Text("Error: Check your connection or API"),
                        TextButton(
                          onPressed: () => ref.invalidate(productsProvider),
                          child: const Text("Retry"),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: false,
      title: const Text(
        "Urban",
        style: TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none, color: AppColors.primary),
        ),
        // Use Consumer to update ONLY the badge when the cart changes
        Consumer(
          builder: (context, ref, child) {
            final cartCount = ref.watch(cartCountProvider);
            return Padding(
              padding: const EdgeInsets.only(right: 8.0, top: 8.0),
              child: Badge(
                label: Text('$cartCount'),
                isLabelVisible: cartCount > 0,
                backgroundColor: AppColors.accentRed,
                child: IconButton(
                  onPressed: () {
                    // FIXED: Now works because context is available
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CartPage()),
                    );
                  },
                  icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.primary),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
} 
  Widget _buildSearchBar(WidgetRef ref) {
    final searchQuery = ref.watch(searchQueryProvider);
    return _SearchBar(
      searchQuery: searchQuery,
      onChanged: (value) {
        ref.read(searchQueryProvider.notifier).state = value;
      },
      onClear: () {
        ref.read(searchQueryProvider.notifier).state = '';
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const Text(
          "View All",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.accentRed,
          ),
        ),
      ],
    );
  }

// Search bar widget
class _SearchBar extends StatefulWidget {
  final String searchQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.searchQuery,
    required this.onChanged,
    required this.onClear,
  });

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(_SearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _controller.text = widget.searchQuery;
      _controller.selection = TextSelection.collapsed(offset: widget.searchQuery.length);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: "Search fashion & lifestyle",
        prefixIcon: const Icon(Icons.search, color: AppColors.secondary),
        suffixIcon: widget.searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: AppColors.secondary),
                onPressed: widget.onClear,
              )
            : const Icon(Icons.filter_center_focus, color: AppColors.secondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }
}
