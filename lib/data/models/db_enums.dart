enum UserRole { customer, driver, admin }

enum OrderStatus { pending, paid, preparing, out_for_delivery, delivered, canceled }

enum DeliveryStatus { pending, assigned, picked_up, in_transit, delivered, failed, returned }

enum PaymentStatus { unpaid, paid, refunded, failed }

extension EnumCodec on Enum {
  String get value => toString().split('.').last;
}
