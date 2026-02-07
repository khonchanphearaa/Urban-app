import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/theme/app_colors.dart';
import '../providers/cart_provider.dart';
import '../../data/models/cart_item_model.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the global cart state
    final cartState = ref.watch(cartProvider);
    final cartItems = cartState.items;
    
    // We use a local controller for the Promo Code input
    final TextEditingController promoController = TextEditingController();

    // --- CALCULATIONS ---
    // Calculate subtotal
    final double subtotal = cartItems.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
    
    // Calculate discount based on the percentage in state
    final double discountAmount = subtotal * (cartState.discountPercentage / 100);
    
    const double shipping = 10.00;
    
    // Final total calculation
    final double total = (subtotal - discountAmount) + shipping;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Shopping Cart", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () {
              // Add a clear cart method in your notifier if needed
            }, 
            child: const Text("Clear All", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
      body: cartItems.isEmpty 
      ? const Center(child: Text("Your cart is empty"))
      : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Dynamic Cart Items List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cartItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 15),
              itemBuilder: (context, index) {
                return _buildCartItem(ref, cartItems[index], index);
              },
            ),
            
            const SizedBox(height: 30),
            const Text("Promo Code", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 15),
            
            // 2. Promo Code Input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: promoController,
                    decoration: InputDecoration(
                      hintText: "Enter code (30 for 30%)",
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                ElevatedButton(
                  onPressed: () {
                    if (promoController.text == "30") {
                      ref.read(cartProvider.notifier).applyPromoCode(30.0);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Promo Code Applied! 30% Off"))
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Invalid Code"))
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFDE8E8),
                    foregroundColor: AppColors.accentRed,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Apply", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // 3. Order Summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  _summaryRow("Subtotal", "\$${subtotal.toStringAsFixed(2)}"),
                  if (discountAmount > 0) ...[
                    const SizedBox(height: 12),
                    _summaryRow("Discount (30%)", "-\$${discountAmount.toStringAsFixed(2)}", isDiscount: true),
                  ],
                  const SizedBox(height: 12),
                  _summaryRow("Shipping", "\$${shipping.toStringAsFixed(2)}", hasInfo: true),
                  const Divider(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("\$${total.toStringAsFixed(2)}", 
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.accentRed)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: cartItems.isEmpty ? null : _buildCheckoutButton(),
    );
  }

  Widget _buildCartItem(WidgetRef ref, CartItem item, int index) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              item.product.imageUrl, 
              width: 80, 
              height: 80, 
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 80, height: 80, color: Colors.grey.shade200,
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.productName, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  "SIZE: ${item.selectedSize} | BRAND: ${item.product.brandName}", 
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Text(
                  "\$${item.product.price.toStringAsFixed(2)}", 
                  style: TextStyle(color: AppColors.accentRed, fontWeight: FontWeight.bold, fontSize: 18)
                ),
              ],
            ),
          ),
          // --- UPDATED: Quantity Selector connected to Provider ---
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _qtyBtn(Icons.remove, () {
                  ref.read(cartProvider.notifier).updateQuantity(index, item.quantity - 1);
                }),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text("${item.quantity}", style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                _qtyBtn(Icons.add, () {
                  ref.read(cartProvider.notifier).updateQuantity(index, item.quantity + 1);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, size: 16),
      onPressed: onTap,
      constraints: const BoxConstraints(),
      padding: const EdgeInsets.all(8),
    );
  }

  Widget _summaryRow(String label, String value, {bool hasInfo = false, bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
            if (hasInfo) const Padding(
              padding: EdgeInsets.only(left: 5),
              child: Icon(Icons.info_outline, size: 16, color: Colors.grey),
            ),
          ],
        ),
        Text(value, style: TextStyle(
          fontWeight: FontWeight.bold, 
          fontSize: 16,
          color: isDiscount ? Colors.green : Colors.black
        )),
      ],
    );
  }

  Widget _buildCheckoutButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: ElevatedButton(
        onPressed: () {
          // Add Checkout Navigation logic
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentRed,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Proceed to Checkout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(width: 10),
            Icon(Icons.arrow_forward, color: Colors.white),
          ],
        ),
      ),
    );
  }
}