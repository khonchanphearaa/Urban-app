class CartModel {
  final String productId;
  final int quantity;
  final String? size;

  CartModel({required this.productId, required this.quantity, this.size});

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      productId: json['productId'] as String,
      quantity: (json['quantity'] is int)
          ? json['quantity'] as int
          : int.parse(json['quantity'].toString()),
      size: json.containsKey('size') && json['size'] != null
          ? json['size'] as String
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'productId': productId, 'quantity': quantity};
    if (size != null) map['size'] = size;
    return map;
  }
}
