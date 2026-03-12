import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/wishlist_controller.dart';
import '../../utils/router/app_router.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../home/home_view.dart';
import '../profile/profile_view.dart';

class WishlistView extends StatefulWidget {
  const WishlistView({super.key});

  @override
  State<WishlistView> createState() => _WishlistViewState();
}

class _WishlistViewState extends State<WishlistView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WishlistController>().fetchWishlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text( 'Wishlist', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
        actions: [
          if (wishlist.count > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text( '${wishlist.count} item${wishlist.count > 1 ? 's' : ''}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<WishlistController>().fetchWishlist(),
        child: _buildBody(wishlist),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 1,
        wishlistCount: wishlist.count,
        onTap: _handleNavTap,
      ),
    );
  }

  Widget _buildBody(WishlistController wishlist) {
    if (wishlist.isLoading && wishlist.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (wishlist.items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 140),
          Icon(Icons.favorite_border, size: 72, color: Colors.grey),
          SizedBox(height: 16),
          Center(
            child: Text( 'Your wishlist is empty',style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),),
          ),
          SizedBox(height: 8),
          Center( child: Text( 'Save products you love and they will appear here.', style: TextStyle(color: Colors.black54),),),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: wishlist.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final product = wishlist.items[index];
        final isProcessing = wishlist.isProcessing(product.id);

        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRouter.productDetails,
                arguments: product,
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 84,
                      height: 84,
                      child: Image.network(
                        product.imageUrl.isNotEmpty ? product.imageUrl.first: '',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          product.categoryName,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Remove from wishlist',
                    onPressed: isProcessing ? null : () {
                            context.read<WishlistController>().toggleWishlist(
                              context,
                              productId: product.id,
                              product: product,
                            );
                          },
                    icon: isProcessing ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.favorite, color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleNavTap(int index) {
    if (index == 1) return;
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeView()),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ProfileView()),
    );
  }
}
