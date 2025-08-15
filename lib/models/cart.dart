import 'location.dart';
import 'cart_item.dart';

class Cart {
  final String id;
  final String customerId;
  final String? customerName;
  final String? customerPhone;
  final Location? pickupLocation;
  final Location? deliveryLocation;
  final CartStatus status;
  final String? driverId;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? acceptedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final String? notes;
  final List<CartItem> items;
  // Payment fields (optional, depend on backend schema)
  final bool? isPaid;
  final double? amountDue;
  final DateTime? paidAt;

  Cart({
    required this.id,
    required this.customerId,
    this.customerName,
    this.customerPhone,
    this.pickupLocation,
    this.deliveryLocation,
    required this.status,
    this.driverId,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
    this.acceptedAt,
    this.pickedUpAt,
    this.deliveredAt,
    this.notes,
    required this.items,
    this.isPaid,
    this.amountDue,
    this.paidAt,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'],
      customerId: json['customer_id'],
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      pickupLocation: json['pickup_location'] != null
          ? Location.fromJson(json['pickup_location'])
          : null,
      deliveryLocation: json['delivery_location'] != null
          ? Location.fromJson(json['delivery_location'])
          : null,
      status: CartStatus.values.firstWhere(
        (e) => e.toString() == 'CartStatus.${json['status']}',
        orElse: () => CartStatus.pending,
      ),
      driverId: json['driver_id'],
      totalAmount: (json['total_amount'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      acceptedAt: json['accepted_at'] != null
          ? DateTime.parse(json['accepted_at'])
          : null,
      pickedUpAt: json['picked_up_at'] != null
          ? DateTime.parse(json['picked_up_at'])
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'])
          : null,
      notes: json['notes'],
      items: json['items'] != null
          ? List<CartItem>.from(
              json['items'].map((item) => CartItem.fromJson(item)))
          : [],
      isPaid: json.containsKey('is_paid')
          ? (json['is_paid'] == true)
          : (json.containsKey('payment_status')
              ? (json['payment_status']?.toString().toLowerCase() == 'paid')
              : null),
      amountDue: json['amount_due'] != null
          ? (json['amount_due'] as num).toDouble()
          : (json['remaining_amount'] != null
              ? (json['remaining_amount'] as num).toDouble()
              : null),
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'pickup_location': pickupLocation?.toJson(),
      'delivery_location': deliveryLocation?.toJson(),
      'status': status.toString().split('.').last,
      'driver_id': driverId,
      'total_amount': totalAmount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'accepted_at': acceptedAt?.toIso8601String(),
      'picked_up_at': pickedUpAt?.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
      'notes': notes,
      'items': items.map((item) => item.toJson()).toList(),
      if (isPaid != null) 'is_paid': isPaid,
      if (amountDue != null) 'amount_due': amountDue,
      if (paidAt != null) 'paid_at': paidAt!.toIso8601String(),
    };
  }

  Cart copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerPhone,
    Location? pickupLocation,
    Location? deliveryLocation,
    CartStatus? status,
    String? driverId,
    double? totalAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? acceptedAt,
    DateTime? pickedUpAt,
    DateTime? deliveredAt,
    String? notes,
    List<CartItem>? items,
    bool? isPaid,
    double? amountDue,
    DateTime? paidAt,
  }) {
    return Cart(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      status: status ?? this.status,
      driverId: driverId ?? this.driverId,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      pickedUpAt: pickedUpAt ?? this.pickedUpAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      notes: notes ?? this.notes,
      items: items ?? this.items,
      isPaid: isPaid ?? this.isPaid,
      amountDue: amountDue ?? this.amountDue,
      paidAt: paidAt ?? this.paidAt,
    );
  }

  // Helper methods
  bool get isPending => status == CartStatus.pending;
  bool get isAssigned => status == CartStatus.assigned;
  bool get isOnTheWay => status == CartStatus.onTheWay;
  bool get isDelivered => status == CartStatus.delivered;
  bool get isCancelled => status == CartStatus.cancelled;
  bool get isCompleted =>
      status == CartStatus.delivered || status == CartStatus.cancelled;
  bool get isActive =>
      status == CartStatus.pending || status == CartStatus.onTheWay;

  String get statusText {
    switch (status) {
      case CartStatus.pending:
        return 'قيد الانتظار';
      case CartStatus.assigned:
        return 'تم التعيين';
      case CartStatus.onTheWay:
        return 'في الطريق';
      case CartStatus.delivered:
        return 'تم التوصيل';
      case CartStatus.cancelled:
        return 'ملغي';
    }
  }

  String get itemsDescription {
    if (items.isEmpty) return 'لا توجد منتجات';
    return items
        .map((item) => '${item.productName} (${item.quantity})')
        .join(', ');
  }

  // Invoice helper
  bool get isInvoiceUnpaid {
    if (status != CartStatus.delivered) return false;
    if (isPaid == false) return true;
    if (amountDue != null && amountDue! > 0) return true;
    return false;
  }
}

enum CartStatus {
  pending, // قيد الانتظار - متاح للموصّلين
  assigned, // تم التعيين - مخصص لموصّل معين
  onTheWay, // في الطريق
  delivered, // تم التوصيل
  cancelled, // ملغي
}
