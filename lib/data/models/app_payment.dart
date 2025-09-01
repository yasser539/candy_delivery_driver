import 'db_enums.dart';

class AppPayment {
  final String id;
  final String orderId;
  final String provider;
  final String? providerRef;
  final int amountCents;
  final String currency;
  final PaymentStatus status;
  final DateTime createdAt;

  AppPayment({
    required this.id,
    required this.orderId,
    required this.provider,
    required this.providerRef,
    required this.amountCents,
    required this.currency,
    required this.status,
    required this.createdAt,
  });

  factory AppPayment.fromMap(Map<String, dynamic> m) => AppPayment(
        id: m['id'] as String,
        orderId: m['order_id'] as String,
        provider: m['provider'] as String,
        providerRef: m['provider_ref'] as String?,
        amountCents: (m['amount_cents'] as num).toInt(),
        currency: (m['currency'] as String?) ?? 'USD',
        status: PaymentStatus.values.firstWhere((e) => e.name == m['status']),
        createdAt: DateTime.parse(m['created_at'] as String),
      );
}
