import 'db_enums.dart';

class DeliveryTracking {
  final String id;
  final String orderId;
  final String? driverId;
  final DeliveryStatus status;
  final DateTime? scheduledAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  DeliveryTracking({
    required this.id,
    required this.orderId,
    required this.driverId,
    required this.status,
    required this.scheduledAt,
    required this.pickedUpAt,
    required this.deliveredAt,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeliveryTracking.fromMap(Map<String, dynamic> m) => DeliveryTracking(
    id: m['id'] as String,
    orderId: m['order_id'] as String,
    driverId: m['driver_id'] as String?,
    status: DeliveryStatus.values.firstWhere((e) => e.name == m['status']),
    scheduledAt: (m['scheduled_at'] as String?) != null
        ? DateTime.parse(m['scheduled_at'] as String)
        : null,
    pickedUpAt: (m['picked_up_at'] as String?) != null
        ? DateTime.parse(m['picked_up_at'] as String)
        : null,
    deliveredAt: (m['delivered_at'] as String?) != null
        ? DateTime.parse(m['delivered_at'] as String)
        : null,
    notes: m['notes'] as String?,
    createdAt: DateTime.parse(m['created_at'] as String),
    updatedAt: DateTime.parse(m['updated_at'] as String),
  );
}
