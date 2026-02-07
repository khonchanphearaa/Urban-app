import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_swiper/card_swiper.dart';
import '../../../../common/theme/app_colors.dart';
import '../../domain/entities/prodcut_entity.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../cart/data/models/cart_item_model.dart';
import '../../../cart/presentation/pages/cart_page.dart'; // Ensure this path is correct

class ProductDetailPage extends ConsumerStatefulWidget {
  final ProductEntity product;
  const ProductDetailPage({super.key, required this.product});

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  String selectedSize = 'S'; // Default selected size

  /// Handles the Add to Cart logic and Navigation
  void _handleAddToCart() {
    // 1. Create the Cart Item with the dynamic data
    final cartItem = CartItem(
      product: widget.product,
      selectedSize: selectedSize,
      quantity: 1,
    );

    // 2. Add to Riverpod State
    ref.read(cartProvider.notifier).addToCart(cartItem);

    // 3. Navigate immediately to the Cart Page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CartPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic image list (supporting multiple images for the Swiper)
    final List<String> productImages = [
      widget.product.imageUrl,
      widget.product.imageUrl,
      widget.product.imageUrl,
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Dynamic Image Swiper
            SizedBox(
              height: 450,
              width: double.infinity,
              child: Swiper(
                itemBuilder: (BuildContext context, int index) {
                  return index == 0
                      ? Hero(
                          tag: 'product_image_${widget.product.id}',
                          child: Image.network(
                            productImages[index],
                            fit: BoxFit.contain,
                          ),
                        )
                      : Image.network(
                          productImages[index],
                          fit: BoxFit.contain,
                        );
                },
                itemCount: productImages.length,
                autoplay: true,
                autoplayDelay: 3000,
                duration: 800,
                loop: true,
                pagination: const SwiperPagination(
                  margin: EdgeInsets.all(10),
                  builder: DotSwiperPaginationBuilder(
                    activeColor: AppColors.accentRed,
                    color: Colors.grey,
                    size: 8,
                    activeSize: 10,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Brand and Title
                  Text(
                    widget.product.brandName.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.accentRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.productName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 3. Price and Rating
                  Row(
                    children: [
                      Text(
                        '\$${widget.product.price}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.product.originalPrice != null) ...[
                        const SizedBox(width: 10),
                        Text(
                          '\$${widget.product.originalPrice}',
                          style: const TextStyle(
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                            fontSize: 18,
                          ),
                        ),
                      ],
                      const Spacer(),
                      ...List.generate(
                        4,
                        (_) => const Icon(Icons.star, color: Colors.amber, size: 20),
                      ),
                      const Text(
                        " 4.8",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        " (124 Review)",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const Divider(height: 40),

                  // 4. Size Selection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Size",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          "Size Guide",
                          style: TextStyle(color: AppColors.accentRed),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ['XS', 'S', 'M', 'L', 'XL']
                        .map((size) => _buildSizeChip(size))
                        .toList(),
                  ),
                  const SizedBox(height: 30),

                  // 5. Expandable Info Sections
                  _buildExpansionTile("Product Description"),
                  _buildExpansionTile("Shipping & Returns"),
                  
                  // Bottom Padding to prevent content from being hidden by bottomSheet
                  const SizedBox(height: 100),
                ],
              ),
            )
          ],
        ),
      ),
      // Fixed Bottom Action Bar
      bottomSheet: _buildBottomActionBar(),
    );
  }

  Widget _buildSizeChip(String size) {
    final bool isSelected = selectedSize == size;
    return GestureDetector(
      onTap: () => setState(() => selectedSize = size),
      child: Container(
        width: 55,
        height: 45,
        decoration: BoxDecoration(
          color: isSelected ? Colors.red.withOpacity(0.05) : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.accentRed : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            size,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.accentRed : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpansionTile(String title) {
    return ExpansionTile(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.black,
        ),
      ),
      tilePadding: EdgeInsets.zero,
      children: const [
        Padding(
          padding: EdgeInsets.only(bottom: 15),
          child: Text(
            "This premium essential is crafted for comfort and style, featuring high-quality fabrics and a timeless silhouette.",
          ),
        )
      ],
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.chat_bubble_outline),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _handleAddToCart, // Calls the dynamic logic + navigation
              icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
              label: const Text(
                "Add to Cart",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentRed,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}