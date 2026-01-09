import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/theme/app_colors.dart';
import '../../../product/domain/entities/prodcut_entity.dart';
import '../../../product/presentation/widgets/product_cart.dart';
import '../providers/home_providers.dart';


// Import your new widgets
import '../../../product/presentation/widgets/category_list.dart';
import '../../../product/presentation/widgets/seasonal_sale_banner.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      bottomNavigationBar: _buildBottomNav(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // 1. Search Bar
              _buildSearchBar(),
              const SizedBox(height: 25),

              // 2. Categories Horizontal List (Now using separate file)
              const HomeCategoryList(), 
              const SizedBox(height: 25),

              // 3. Promo Banner (Now using separate file)
              const SeasonalSaleBanner(),
              const SizedBox(height: 25),

              // 4. Trending Header
              _buildSectionHeader("Trending Now"),
              const SizedBox(height: 30),

              // 5. Product Grid
              productAsync.when(
                data: (products) => GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.55,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 20,
                  ),
                  itemBuilder: (context, index){
                    return ProductCard(product: products[index]);
                  },
                ),
                /* Show loading spinner while Render API wakes up */
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(
                      color: AppColors.accentRed,
                    ),
                  ),
                ),
                /* show error message if API fails */
                error: (err, stack) => Center(
                  child: Text("Error: Check your intenert or API"),
                )
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI Components ---

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      title: const Text(
        "Urban",
        style: TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, color: AppColors.primary)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.primary)),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: "Search fashion & lifestyle",
        prefixIcon: const Icon(Icons.search, color: AppColors.secondary),
        suffixIcon: const Icon(Icons.filter_center_focus, color: AppColors.secondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
        const Text("View All", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.accentRed)),
      ],
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.accentRed,
      unselectedItemColor: AppColors.secondary,
      currentIndex: 0,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.compass_calibration), label: 'Explore'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Wishlist'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    );
  }
}
final List<ProductEntity> dummyProducts = [
  ProductEntity(id: '1', imageUrl: 'https://i.imgur.com/D6W08qK.jpeg', brandName: 'LUMIERE STUDIO', productName: 'Oversized Linen Shirt', price: 79.00, isHot: true),
  ProductEntity(id: '2', imageUrl: 'https://i.imgur.com/7D7I8q2.jpeg', brandName: 'AURA ATELIER', productName: 'Quilted Leather Bag', price: 125.00, originalPrice: 180.00, isLiked: true),
  ProductEntity(id: '3', imageUrl: 'https://i.imgur.com/9Q6I7q3.jpeg', brandName: 'VELOCE FOOTWEAR', productName: 'Court Classics White', price: 95.00),
  ProductEntity(id: '4', imageUrl: 'https://i.imgur.com/2F8I9q4.jpeg', brandName: 'ELYSIAN GOLD', productName: '18k Chain Necklace', price: 210.00),
];