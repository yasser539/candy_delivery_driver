import 'db_enums.dart';

class DeliveryEvent {
  final String id;
  final String deliveryId;
  final DeliveryStatus status;
  final String? note;
  final Map<String, dynamic>? location;
  final DateTime createdAt;

  DeliveryEvent({
    required this.id,
    required this.deliveryId,
    required this.status,
    required this.note,
    required this.location,
    required this.createdAt,
  });

  factory DeliveryEvent.fromMap(Map<String, dynamic> m) => DeliveryEvent(
        id: m['id'] as String,
        deliveryId: m['delivery_id'] as String,
        status: DeliveryStatus.values.firstWhere((e) => e.name == m['status']),
        note: m['note'] as String?,
        location: (m['location'] as Map?)?.cast<String, dynamic>(),
        createdAt: DateTime.parse(m['created_at'] as String),
      );
}
