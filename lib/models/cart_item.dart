class CartItem {
  final String id;
  final String cartId;
  final String productId;
  final String productName;
  final double productPrice;
  final int quantity;
  final double totalPrice;

  CartItem({
    required this.id,
    required this.cartId,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.quantity,
    required this.totalPrice,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      cartId: json['cart_id'],
      productId: json['product_id'],
      productName: json['product_name'] ?? '',
      productPrice: (json['product_price'] ?? 0.0).toDouble(),
      quantity: json['quantity'] ?? 0,
      totalPrice: (json['total_price'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cart_id': cartId,
      'product_id': productId,
      'product_name': productName,
      'product_price': productPrice,
      'quantity': quantity,
      'total_price': totalPrice,
    };
  }

  CartItem copyWith({
    String? id,
    String? cartId,
    String? productId,
    String? productName,
    double? productPrice,
    int? quantity,
    double? totalPrice,
  }) {
    return CartItem(
      id: id ?? this.id,
      cartId: cartId ?? this.cartId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productPrice: productPrice ?? this.productPrice,
      quantity: quantity ?? this.quantity,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}
