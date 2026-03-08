import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:card_swiper/card_swiper.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/payment_controller.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/wishlist_controller.dart';
import '../../models/product_model.dart';
import '../../notifications/notification_alert_model.dart';
import '../../notifications/notification_alert_storage.dart';
import '../../utils/router/app_router.dart';
import '../../services/secure_storage_service.dart';
import '../../constants/banner_images.dart';
import '../../widgets/not_found_widget.dart';
import '../../widgets/profile_drawer.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../widgets/ai_chat_bottom_sheet.dart';
import '../cart/cart_view.dart';
import '../wishlist/wishlist_view.dart';
import '../profile/profile_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedCategoryIndex = -1;
  String? _addingToCartProductId;
  int? _hoveredProductIndex;
  bool _isCheckingPaymentStatus = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductController>().getAllProducts();
      context.read<CategoryController>().getCategories();
      context.read<WishlistController>().fetchWishlist(silent: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProv = context.watch<ProductController>();
    final wishlist = context.watch<WishlistController>();
    final cart = context.watch<CartController>();
    final itemCount = cart.items.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      extendBody: true,
      appBar: _buildAppBar(),
      drawer: const ProfileDrawer(),
      body: SafeArea(
        bottom: false,
        /* for change bg transparent btn navbar */
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              const SizedBox(height: 16),
              _buildBannerCarousel(),
              const SizedBox(height: 16),
              _buildCategories(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Trending Now",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  if (_selectedCategoryIndex != -1)
                    TextButton(
                      onPressed: () {
                        setState(() => _selectedCategoryIndex = -1);
                        context.read<ProductController>().getAllProducts();
                      },
                      child: const Text("Clear Filter"),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(child: _buildProductsSection(productProv)),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingButtons(itemCount),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 0,
        wishlistCount: wishlist.count,
        onTap: _handleNavTap,
      ),
    );
  }

  void _handleNavTap(int index) {
    if (index == 0) return;
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WishlistView()),
      );
      return;
    }
    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfileView()),
      );
    }
  }

  PreferredSizeWidget _buildAppBar() {
    final auth = context.watch<AuthController>();
    final isLoggedIn = (auth.token ?? '').isNotEmpty;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text(
        "Discovery",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: Colors.black,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _isCheckingPaymentStatus ? null : _handlePaymentStatusNotification,
          icon: _isCheckingPaymentStatus ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.notifications_none, color: Colors.black),
          tooltip: 'Notifications',
        ),

        if (!isLoggedIn)
          IconButton(
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                builder: (sheetContext) {
                  return SafeArea(
                    child: Wrap(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.login),
                          title: const Text('Login'),
                          onTap: () {
                            Navigator.pop(sheetContext);
                            Navigator.pushNamed(context, AppRouter.login);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.app_registration),
                          title: const Text('Register'),
                          onTap: () {
                            Navigator.pop(sheetContext);
                            Navigator.pushNamed(context, AppRouter.register);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            icon: const Icon(Icons.person_add_alt_1, color: Colors.black),
            tooltip: 'Login or Register',
          ),

        if (isLoggedIn)
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout, color: Colors.black),
            tooltip: 'Logout',
          ),
      ],
    );
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await SecureStorageService.deleteToken();
      await SecureStorageService.deleteUser();
      await SecureStorageService.deletePendingPaymentOrderId();
      await NotificationAlertStorage.clearAlerts();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRouter.login,
          (route) => false,
        );
      }
    }
  }

  // Search bar unused
  // Widget _buildSearchBar() {
  //   return TextField(
  //     decoration: InputDecoration(
  //       hintText: "Search fashion & lifestyle",
  //       prefixIcon: const Icon(Icons.search),
  //       suffixIcon: const Icon(Icons.qr_code_scanner),
  //       filled: true,
  //       fillColor: Colors.white,
  //       border: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(15),
  //         borderSide: BorderSide.none,
  //       ),
  //     ),
  //   );
  // }

  Widget _buildBannerCarousel() {
    return SizedBox(
      height: 150,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Swiper(
          itemCount: BannerImages.banners.length,
          autoplay: true,
          autoplayDelay: 5000,
          duration: 800,
          viewportFraction: 0.9,
          scale: 0.95,
          pagination: const SwiperPagination(
            builder: DotSwiperPaginationBuilder(
              color: Colors.white60,
              activeColor: Colors.white,
              size: 8,
              activeSize: 10,
            ),
          ),
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  width: 800,
                  BannerImages.banners[index],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.image, size: 48, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategories() {
    final catProv = context.watch<CategoryController>();
    if (catProv.isLoading) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final cats = catProv.categories;

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cats.length,
        itemBuilder: (context, index) {
          final c = cats[index];
          final isSelected = index == _selectedCategoryIndex;
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                if (index == _selectedCategoryIndex) return;
                setState(() => _selectedCategoryIndex = index);
                context.read<ProductController>().getProductsByCategory(c.id);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected ? const LinearGradient(
                          colors: [Color(0xFF4597E5), Color(0xFF3B7FCC)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected ? null : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected ? const Color(0xFF4597E5).withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.08),
                      blurRadius: isSelected ? 12 : 8,
                      offset: Offset(0, isSelected ? 4 : 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    c.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductsSection(ProductController productProv) {
    final hasProducts = productProv.products.isNotEmpty;

    if (!hasProducts && productProv.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: _buildProductGrid(productProv.products),
        ),
        if (hasProducts)
          IgnorePointer(
            ignoring: !productProv.isLoading,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: productProv.isLoading ? 1 : 0,
              child: Container(
                color: Colors.white.withValues(alpha: 0.45),
                alignment: Alignment.center,
                child: const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2.6),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProductGrid(List<ProductModel> products) {
    final wishlist = context.watch<WishlistController>();

    if (products.isEmpty) {
      return const NotFoundWidget(
        message: 'No Products Found!',
        subtitle: 'Try again your filters or check back later',
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final isAdding = _addingToCartProductId == product.id;
        final isHovered = _hoveredProductIndex == index;
        final isWishlisted = wishlist.isInWishlist(product.id);
        final isWishlistProcessing = wishlist.isProcessing(product.id);

        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRouter.productDetails,
              arguments: product,
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (_) => setState(() => _hoveredProductIndex = index),
                  onExit: (_) => setState(() => _hoveredProductIndex = null),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Hero(
                          tag: product.id,
                          child: Image.network(
                            product.imageUrl.isNotEmpty ? product.imageUrl[0] : "",
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(child: Icon(Icons.broken_image)),
                          ),
                        ),
                      ),
                      // Stock badge
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            /* IF stock > 10 is color: green, If stock > 0 color: orange, < 0 color red out of stock */
                            color: product.stock > 10
                                ? Colors.green
                                : (product.stock > 0
                                      ? Colors.orange
                                      : Colors.red),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            product.stock > 0 ? 'Stock: ${product.stock}' : 'Out of Stock',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        top: 8,
                        left: 8,
                        child: Material(
                          color: Colors.white.withValues(alpha: 0.85),
                          shape: const CircleBorder(),
                          child: IconButton(
                            onPressed: isWishlistProcessing ? null: () {
                                    context
                                        .read<WishlistController>()
                                        .toggleWishlist(
                                          context,
                                          productId: product.id,
                                          product: product,
                                        );
                                  },
                            icon: isWishlistProcessing ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.red,
                                    ),
                                  )
                                : Icon(
                                    isWishlisted ? Icons.favorite : Icons.favorite_border,
                                    color: isWishlisted ? Colors.red : Colors.black87,
                                    size: 20,
                                  ),
                          ),
                        ),
                      ),

                      // Add to cart button on hover (positioned bottom-right)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: isHovered ? 1.0 : 0.0,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: product.stock > 0 && !isAdding ? () => _addToCartQuick(product) : null,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                                child: isAdding
                                    ? const Padding(
                                        padding: EdgeInsets.all(10),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.shopping_cart,
                                        color: Color.fromARGB(
                                          255,
                                          69,
                                          151,
                                          229,
                                        ),
                                        size: 24,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Categories: ${product.categoryName.toUpperCase()}",
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Name: ${product.name}",
                style: const TextStyle(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text.rich(
                TextSpan(
                  text: "Price: ",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ), // Style for label
                  children: [
                    TextSpan(
                      text: "\$${product.price}",
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.blue,
                      ), // Your specific font size here
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFloatingButtons(int itemCount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 68),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (itemCount > 0) ...[
            _buildCartFAB(itemCount),
            const SizedBox(height: 12),
          ],
          _buildAiChatFAB(),
        ],
      ),
    );
  }

  Widget _buildAiChatFAB() {
    return FloatingActionButton(
      heroTag: 'ai_chat_fab',
      onPressed: _openAiChatBottomSheet,
      backgroundColor: const Color(0xFF4597E5),
      child: const Icon(Icons.smart_toy_rounded, color: Colors.white),
    );
  }

  Future<void> _openAiChatBottomSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const AiChatBottomSheet(),
    );
  }

  Widget _buildCartFAB(int itemCount) {
    return FloatingActionButton(
      heroTag: 'cart_fab',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CartView()),
        );
      },

      /* background transparent for floatingActionButton with icon shop  */
      // backgroundColor: const Color.fromARGB(19, 0, 0, 0),
      backgroundColor: const Color(0xFF000000).withValues(alpha: 0.074),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(
            Icons.shopping_cart,
            color: Color.fromARGB(255, 69, 151, 229),
          ),
          if (itemCount > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(
                  itemCount > 99 ? '99+' : itemCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _addToCartQuick(ProductModel product) async {
    if (product.stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product out of stock'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _addingToCartProductId = product.id);

    final cart = context.read<CartController>();
    await cart.addToCart(
      context,
      productId: product.id,
      name: product.name,
      imageUrl: product.imageUrl.isNotEmpty ? product.imageUrl[0] : '',
      size: 'M', // Default size, can be changed
      quantity: 1,
      price: product.price,
    );

    setState(() => _addingToCartProductId = null);
  }

  Future<void> _handlePaymentStatusNotification() async {
    setState(() => _isCheckingPaymentStatus = true);

    try {
      final orderId = await SecureStorageService.readPendingPaymentOrderId();
      if (!mounted) return;

      if (orderId == null || orderId.isEmpty) {
        await NotificationAlertStorage.saveAlert(
          NotificationAlertModel(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            title: 'Payment Check',
            message: 'No pending payment found',
            type: 'info',
            createdAt: DateTime.now(),
          ),
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No pending payment found')),
        );
        return;
      }

      final paymentController = context.read<PaymentController>();
      final status = await paymentController.checkStatus(
        context,
        orderId: orderId,
      );
      if (!mounted) return;

      if (status == null || status.isEmpty) {
        final errorMessage =
            paymentController.lastError ?? 'Failed to check payment status';
        await NotificationAlertStorage.saveAlert(
          NotificationAlertModel(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            title: 'Payment Check Failed',
            message: errorMessage,
            type: 'error',
            createdAt: DateTime.now(),
          ),
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
        return;
      }

      final normalizedStatus = status.toUpperCase();
      final isPaid = normalizedStatus == 'PAID';
      if (isPaid) {
        await SecureStorageService.deletePendingPaymentOrderId();
      }

      await NotificationAlertStorage.saveAlert(
        NotificationAlertModel(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: isPaid ? 'Payment Success' : 'Payment Status',
          message: isPaid ? 'Order $orderId has been paid successfully.' : 'Order $orderId status: $normalizedStatus',
          type: isPaid ? 'success' : 'info',
          createdAt: DateTime.now(),
        ),
      );

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(isPaid ? 'Payment Success' : 'Payment Status'),
            content: Text(
              isPaid ? 'Order $orderId has been paid successfully.' : 'Order $orderId status: $normalizedStatus',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } finally {
      if (mounted) {
        setState(() => _isCheckingPaymentStatus = false);
      }
    }
  }
}
