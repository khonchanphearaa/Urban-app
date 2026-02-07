import '../../../product/domain/entities/prodcut_entity.dart';

class CartItem {
  final ProductEntity product;
  final String selectedSize;
  int quantity;

  CartItem({
    required this.product,
    required this.selectedSize,
    this.quantity = 1,
  });
}