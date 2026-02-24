class OrderRequest {
  final String deliveryAddress;
  final String phoneNumber;
  final String paymentMethod;
  final int discountPercent;

  OrderRequest({
    required this.deliveryAddress,
    required this.phoneNumber,
    required this.paymentMethod,
    required this.discountPercent,
  });

  Map<String, dynamic> toJson() {
    return {
      'deliveryAddress': deliveryAddress,
      'phoneNumber': phoneNumber,
      'paymentMethod': paymentMethod,
      'discountPercent': discountPercent,
    };
  }
}

class OrderResponse {
  final String? orderId;

  OrderResponse({this.orderId});

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> map = json;
    if (json['data'] is Map<String, dynamic>) {
      map = json['data'] as Map<String, dynamic>;
    }

    final orderId = (map['orderId'] ?? map['_id'] ?? map['id'])?.toString();
    return OrderResponse(orderId: orderId);
  }
}

// Admin Order Model
class OrderModel {
  final String id;
  final String userId;
  final String userName;
  final List<OrderItem> items;
  final double totalAmount;
  final String status;
  final String deliveryAddress;
  final String phoneNumber;
  final String paymentMethod;
  final int discountPercent;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.deliveryAddress,
    required this.phoneNumber,
    required this.paymentMethod,
    required this.discountPercent,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    String parseId(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    double parseAmount(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0;
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString()) ?? 0;
    }

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      try {
        if (value is String) return DateTime.parse(value);
        if (value is DateTime) return value;
      } catch (_) {}
      return null;
    }

    String parseUserName(dynamic user) {
      if (user == null) return 'Unknown';
      if (user is Map<String, dynamic>) {
        return user['name']?.toString() ??
            user['username']?.toString() ??
            user['email']?.toString() ??
            'Unknown';
      }
      return 'Unknown';
    }

    String parseUserId(dynamic user) {
      if (user == null) return '';
      if (user is Map<String, dynamic>) {
        return parseId(user['_id'] ?? user['id']);
      }
      return parseId(user);
    }

    List<OrderItem> parseItems(dynamic items) {
      if (items == null) return [];
      if (items is List) {
        return items
            .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    }

    return OrderModel(
      id: parseId(json['_id'] ?? json['id']),
      userId: parseUserId(json['user'] ?? json['userId']),
      userName: parseUserName(json['user']),
      items: parseItems(json['items'] ?? json['products']),
      totalAmount: parseAmount(json['totalAmount'] ?? json['total']),
      status: json['status']?.toString() ?? 'pending',
      deliveryAddress: json['deliveryAddress']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      paymentMethod: json['paymentMethod']?.toString() ?? 'cash',
      discountPercent: parseInt(json['discountPercent'] ?? json['discount']),
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final String? imageUrl;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    this.imageUrl,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    String parseId(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    int parseQuantity(dynamic value) {
      if (value == null) return 1;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString()) ?? 1;
    }

    double parsePrice(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0;
    }

    String parseProductName(dynamic product) {
      if (product == null) return 'Unknown Product';
      if (product is Map<String, dynamic>) {
        return product['name']?.toString() ?? 'Unknown Product';
      }
      return 'Unknown Product';
    }

    String parseProductId(dynamic product) {
      if (product == null) return '';
      if (product is Map<String, dynamic>) {
        return parseId(product['_id'] ?? product['id']);
      }
      return parseId(product);
    }

    String? parseProductImage(dynamic product) {
      if (product == null) return null;
      if (product is Map<String, dynamic>) {
        final images = product['images'];
        if (images is List && images.isNotEmpty) {
          return images.first.toString();
        }
        final image = product['image'];
        if (image != null) return image.toString();
      }
      return null;
    }

    return OrderItem(
      productId: parseProductId(json['product'] ?? json['productId']),
      productName: parseProductName(json['product']),
      quantity: parseQuantity(json['quantity']),
      price: parsePrice(json['price']),
      imageUrl: parseProductImage(json['product']),
    );
  }
}
