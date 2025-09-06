import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../models/user_address.dart';
import '../models/app_order.dart';
import '../models/delivery_tracking.dart';
import '../models/delivery_event.dart';
import '../models/app_payment.dart';

class DriverRepository {
  final SupabaseClient _db;

  DriverRepository({SupabaseClient? client})
    : _db = client ?? Supabase.instance.client;

  // Profiles
  Future<UserProfile?> getMyProfile() async {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) return null;
    final res = await _db
        .from('user_profiles')
        .select()
        .eq('user_id', uid)
        .maybeSingle();
    if (res == null) return null;
    return UserProfile.fromMap(res as Map<String, dynamic>);
  }

  // Addresses
  Future<List<UserAddress>> getMyAddresses() async {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) return [];
    final res = await _db.from('user_addresses').select().eq('user_id', uid);
    return (res as List)
        .cast<Map<String, dynamic>>()
        .map(UserAddress.fromMap)
        .toList();
  }

  // Assigned deliveries for current driver
  Future<List<DeliveryTracking>> getAssignedDeliveries() async {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) return [];
    final res = await _db
        .from('app_delivery_tracking')
        .select()
        .eq('driver_id', uid)
        .in_('status', ['assigned', 'picked_up', 'in_transit']);
    return (res as List)
        .cast<Map<String, dynamic>>()
        .map(DeliveryTracking.fromMap)
        .toList();
  }

  // Fetch order details for a delivery
  Future<AppOrder?> getOrder(String orderId) async {
    final res = await _db
        .from('app_orders')
        .select()
        .eq('id', orderId)
        .maybeSingle();
    if (res == null) return null;
    return AppOrder.fromMap(res as Map<String, dynamic>);
  }

  // Update delivery status with optional timestamps
  Future<void> updateDeliveryStatus({
    required String deliveryId,
    required String status,
    DateTime? pickedUpAt,
    DateTime? deliveredAt,
    String? notes,
  }) async {
    final payload = <String, dynamic>{'status': status};
    if (pickedUpAt != null)
      payload['picked_up_at'] = pickedUpAt.toIso8601String();
    if (deliveredAt != null)
      payload['delivered_at'] = deliveredAt.toIso8601String();
    if (notes != null) payload['notes'] = notes;
    await _db
        .from('app_delivery_tracking')
        .update(payload)
        .eq('id', deliveryId);
  }

  // Delivery events for a specific delivery
  Future<List<DeliveryEvent>> getDeliveryEvents(String deliveryId) async {
    final res = await _db
        .from('app_delivery_events')
        .select()
        .eq('delivery_id', deliveryId)
        .order('created_at');
    return (res as List)
        .cast<Map<String, dynamic>>()
        .map(DeliveryEvent.fromMap)
        .toList();
  }

  // Payment details for a specific order
  Future<List<AppPayment>> getOrderPayments(String orderId) async {
    final res = await _db
        .from('app_payments')
        .select()
        .eq('order_id', orderId)
        .order('created_at');
    return (res as List)
        .cast<Map<String, dynamic>>()
        .map(AppPayment.fromMap)
        .toList();
  }

  // Fetch current user's orders (uses app_orders; falls back to orders if needed)
  Future<List<AppOrder>> getMyOrders({int limit = 50}) async {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) return [];

    Future<List<AppOrder>> _query(String table) async {
      final res = await _db
          .from(table)
          .select()
          .eq('user_id', uid)
          .order('created_at', ascending: false)
          .limit(limit);
      return (res as List)
          .cast<Map<String, dynamic>>()
          .map(AppOrder.fromMap)
          .toList();
    }

    try {
      return await _query('app_orders');
    } catch (_) {
      // fallback if your schema uses base name
      return await _query('orders');
    }
  }
}
