import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../models/product_model.dart';
import '../../utils/router/app_router.dart';
import '../../services/secure_storage_service.dart';
import '../../widgets/base_modal.dart';
import '../../widgets/not_found_widget.dart';
import '../../widgets/profile_drawer.dart';
import '../cart/cart_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedCategoryIndex = -1;
  String? _addingToCartProductId;
  int? _hoveredProductIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductController>().getAllProducts();
      context.read<CategoryController>().getCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProv = context.watch<ProductController>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      drawer: const ProfileDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
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
              Expanded(
                child: productProv.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildProductGrid(productProv.products),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildCartFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
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
          onPressed: () {},
          icon: const Icon(Icons.notifications_none, color: Colors.black),
        ),
        IconButton(
          onPressed: () async {
            final confirmed = await BaseModal.confirm(
              context,
              title: 'Logout',
              message: 'Do you want to logout?',
              confirmText: 'Logout',
              cancelText: 'Cancel',
              confirmButtonColor: Colors.red,
            );
            if (!confirmed) return;
            await SecureStorageService.deleteToken();
            await SecureStorageService.deleteUser();
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRouter.login,
              (route) => false,
            );
          },
          icon: const Icon(Icons.logout, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search fashion & lifestyle",
        prefixIcon: const Icon(Icons.search),
        suffixIcon: const Icon(Icons.qr_code_scanner),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildCategories() {
    final catProv = context.watch<CategoryController>();
    if (catProv.isLoading)
      return const SizedBox(
        height: 115,
        child: Center(child: CircularProgressIndicator()),
      );
    final cats = catProv.categories;

    return SizedBox(
      height: 115,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cats.length,
        itemBuilder: (context, index) {
          final c = cats[index];
          final isSelected = index == _selectedCategoryIndex;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedCategoryIndex = index);
              context.read<ProductController>().getProductsByCategory(c.id);
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: isSelected ? Colors.black : Colors.white,
                      child: Text(
                        c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    c.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected ? Colors.black : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid(List<ProductModel> products) {
    if (products.isEmpty) {
      return const NotFoundWidget(
        message: 'No Products Found',
        subtitle: 'Try adjusting your filters or check back later',
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
                  onEnter: (_) => setState(() => _hoveredProductIndex = index),
                  onExit: (_) => setState(() => _hoveredProductIndex = null),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Hero(
                          tag: product.id,
                          child: Image.network(
                            product.imageUrl.isNotEmpty
                                ? product.imageUrl[0]
                                : "",
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
                            color: product.stock > 10
                                ? Colors.green
                                : (product.stock > 0
                                      ? Colors.orange
                                      : Colors.red),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            product.stock > 0
                                ? 'Stock: ${product.stock}'
                                : 'Out of Stock',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
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
                              onTap: product.stock > 0 && !isAdding
                                  ? () => _addToCartQuick(product)
                                  : null,
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

  Widget _buildCartFAB() {
    final cart = context.watch<CartController>();
    final itemCount = cart.items.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );

    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CartView()),
        );
      },
      backgroundColor: const Color.fromARGB(32, 0, 0, 0),
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
}
