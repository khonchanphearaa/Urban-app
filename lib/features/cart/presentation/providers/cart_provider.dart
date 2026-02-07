import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/cart_item_model.dart';

// 1. State class to hold the list and the discount logic
class CartState {
  final List<CartItem> items;
  final double discountPercentage;

  CartState({required this.items, this.discountPercentage = 0.0});

  CartState copyWith({List<CartItem>? items, double? discountPercentage}) {
    return CartState(
      items: items ?? this.items,
      discountPercentage: discountPercentage ?? this.discountPercentage,
    );
  }
}

// 2. The Main Cart Provider
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

// 3. Helper Provider for the Badge (used in main_navigation_page.dart)
final cartCountProvider = Provider<int>((ref) {
  final cartState = ref.watch(cartProvider);
  // This sums up all quantities (e.g., 2 shirts + 1 hat = 3)
  return cartState.items.fold(0, (sum, item) => sum + item.quantity);
});

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(CartState(items: []));

  /// Adds an item or increases quantity if it already exists
  void addToCart(CartItem newItem) {
    final existingIndex = state.items.indexWhere((item) => 
      item.product.id == newItem.product.id && 
      item.selectedSize == newItem.selectedSize
    );

    if (existingIndex != -1) {
      updateQuantity(existingIndex, state.items[existingIndex].quantity + 1);
    } else {
      state = state.copyWith(items: [...state.items, newItem]);
    }
  }

  /// Updates quantity and handles API sync
  Future<void> updateQuantity(int index, int newQty) async {
    // Prevent quantity from going below 1
    if (newQty < 1) return;
    
    // Create a new list for immutability
    final List<CartItem> updatedList = state.items.map((item) => item).toList();
    
    // Update the specific item at the index
    final currentItem = updatedList[index];
    updatedList[index] = CartItem(
      product: currentItem.product,
      selectedSize: currentItem.selectedSize,
      quantity: newQty,
    );

    // Update the state (Optimistic Update)
    state = state.copyWith(items: updatedList);

    try {
      // API call placeholder:
      // await dio.post('/cart/update', data: {'id': currentItem.product.id, 'qty': newQty});
    } catch (e) {
      // Handle error (optionally revert state)
    }
  }

  /// Applies a discount percentage (e.g., 30.0 for 30%)
  void applyPromoCode(double percentage) {
    state = state.copyWith(discountPercentage: percentage);
  }

  /// Removes an item entirely from the cart
  void removeItem(int index) {
    final updatedList = [...state.items];
    updatedList.removeAt(index);
    state = state.copyWith(items: updatedList);
  }
}