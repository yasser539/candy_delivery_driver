import 'db_enums.dart';

class AppOrder {
  final String id;
  final String? userId;
  final String? addressId;
  final String? cartId;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final int subtotalCents;
  final int deliveryFeeCents;
  final int totalCents;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppOrder({
    required this.id,
    required this.userId,
    required this.addressId,
    required this.cartId,
    required this.status,
    required this.paymentStatus,
    required this.subtotalCents,
    required this.deliveryFeeCents,
    required this.totalCents,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppOrder.fromMap(Map<String, dynamic> m) => AppOrder(
    id: m['id'] as String,
    userId: m['user_id'] as String?,
    addressId: m['address_id'] as String?,
    cartId: m['cart_id'] as String?,
    status: OrderStatus.values.firstWhere((e) => e.name == m['status']),
    paymentStatus: PaymentStatus.values.firstWhere(
      (e) => e.name == m['payment_status'],
    ),
    subtotalCents: (m['subtotal_cents'] as num?)?.toInt() ?? 0,
    deliveryFeeCents: (m['delivery_fee_cents'] as num?)?.toInt() ?? 0,
    totalCents: (m['total_cents'] as num?)?.toInt() ?? 0,
    notes: m['notes'] as String?,
    createdAt: DateTime.parse(m['created_at'] as String),
    updatedAt: DateTime.parse(m['updated_at'] as String),
  );
}
