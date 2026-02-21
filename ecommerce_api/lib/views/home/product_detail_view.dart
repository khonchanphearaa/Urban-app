import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart'; 
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../controllers/cart_controller.dart';
import '../cart/cart_view.dart';

class ProductDetailView extends StatelessWidget {
  final ProductModel product;

  const ProductDetailView({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [

          /* Immersive atuo-playing swiper header on image  */
          _buildSliverAppBar(context),

          /* Product Information Section */
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.categoryName.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPriceSection(),
                  const SizedBox(height: 6),
                  Text(
                    "Stock: ${product.stock}",
                    /* Color stock if inStock is color green, If unStock is red */
                    style: TextStyle(color: product.stock > 0 ? Colors.green[700] : Colors.red[700]),
                  ),
                  const SizedBox(height: 15),
                  _buildRatingSection(),
                  const SizedBox(height: 25),
                  
                  // Size Selection
                  const Text("Size", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildSizeSelector(),
                  
                  const SizedBox(height: 25),
                  
                  /* detail for description this dynamic from api */
                  _buildExpandableSection("Product Description", product.description),

                  /* This data static for Shipping & Retrun */
                  _buildExpandableSection("Shipping & Returns", "Free standard shipping on orders over \$50. Returns accepted within 30 days."),
                  const SizedBox(height: 100), 
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  // --- Sub-Widgets ---
  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 450,
      pinned: true,
      backgroundColor: Colors.white,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.white.withValues(alpha: 0.8),
          child: const BackButton(color: Colors.black),
        ),
      ),
      actions: [
        CircleAvatar(
          backgroundColor: Colors.white.withValues(alpha: 0.8),
          child: IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black),
            onPressed: () {},
          ),
        ),
        const SizedBox(width: 10),
        CircleAvatar(
          backgroundColor: Colors.white.withValues(alpha: 0.8),
          child: IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ),
        const SizedBox(width: 15),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: product.id,
          child: Swiper(
            itemBuilder: (BuildContext context, int index) {
              return Image.network(
                product.imageUrl[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => 
                    const Center(child: Icon(Icons.broken_image, size: 50)),
              );
            },
            itemCount: product.imageUrl.length,
            autoplay: true, // Auto delay enabled
            autoplayDelay: 4000, // 4 seconds
            duration: 800,
            pagination: const SwiperPagination(
              builder: DotSwiperPaginationBuilder(
                activeColor: Colors.red,
                color: Colors.white70,
                size: 8,
                activeSize: 10,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceSection() {
    return Row(
      children: [
        Text(
          "\$${product.price}",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 10),
        Text(
          "\$${(product.price * 1.2).toStringAsFixed(2)}",
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
            decoration: TextDecoration.lineThrough,
          ),
        ),
      ],
    );
  }

/* This rating star and static */
  Widget _buildRatingSection() {
    return Row(
      children: [
        ...List.generate(4, (index) => const Icon(Icons.star, color: Colors.orange, size: 20)),
        const Icon(Icons.star_half, color: Colors.orange, size: 20),
        const SizedBox(width: 8),
        Text("4.8 (124 Reviews)", style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  /* This size is static can't changed */
  Widget _buildSizeSelector() {
    List<String> sizes = ['XS', 'S', 'M', 'L', 'XL'];
    return Row(
      children: sizes.map((size) {
        bool isSelected = size == 'S'; 
        return Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: isSelected ? Colors.red : Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
            color: isSelected ? Colors.red.withValues(alpha: 0.05) : Colors.transparent,
          ),
          child: Text(size, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        );
      }).toList(),
    );
  }

  Widget _buildExpandableSection(String title, String content) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Text(content, style: TextStyle(color: Colors.grey[700], height: 1.5)),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.chat_bubble_outline),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: product.stock > 0 ? () async {
                      final cart = Provider.of<CartController>(context, listen: false);
                      final success = await cart.addToCart(
                        context,
                        productId: product.id,
                        name: product.name,
                        imageUrl: product.imageUrl.isNotEmpty ? product.imageUrl[0] : '',
                        size: 'M',
                        quantity: 1,
                        price: product.price,
                      );
                      // Only navigate when addToCart succeeded
                      if (success && context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CartView()),
                        );
                      }
                    }
                  : null,
              icon: const Icon(Icons.shopping_bag_outlined),
              label: Text(product.stock > 0 ? "Add to Cart" : "Out of Stock"),
            ),
          ),
        ],
      ),
    );
  }
}