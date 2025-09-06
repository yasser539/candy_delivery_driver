import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../models/customer.dart';

import '../../core/session/current_captain.dart';

class OrdersRepository {
  final SupabaseClient _db;
  OrdersRepository({SupabaseClient? client})
      : _db = client ?? Supabase.instance.client;

  /// Fetch recent orders assigned to the current deliverer (captain)
  /// from public.orders. Returns a list of simple maps tailored for LiveOrderCard.
  Future<List<Map<String, dynamic>>> getMyAssignedOrders({int limit = 50}) async {
    final captain = CurrentCaptain.value;
    if (captain == null) return [];

    // Build robust phone variants to tolerate different formats stored in DB
  final variants = _phoneVariants(captain.phone.toString());

    // Primary path: match by driver_phone (FK) using multiple common formats
    List<Map<String, dynamic>> rows = [];
    if (variants.isNotEmpty) {
      final res = await _db
          .from('orders')
          .select()
          .in_('driver_phone', variants.toList())
          .order('created_at', ascending: false)
          .limit(limit);
      rows = (res as List).cast<Map<String, dynamic>>();
    } else {
      final res = await _db
          .from('orders')
          .select()
          .eq('driver_phone', captain.phone)
          .order('created_at', ascending: false)
          .limit(limit);
      rows = (res as List).cast<Map<String, dynamic>>();
    }

    if (kDebugMode) {
      // ignore: avoid_print
  print('OrdersRepository.getMyAssignedOrders: phoneVariants=${variants.length}, results=${rows.length}');
    }
    // Enrich with customers data (name, phone normalization, address, coordinates)
    final enriched = <Map<String, dynamic>>[];
    for (final r in rows) {
      final m = _rowToCardData(r);
      final customerId = (m['customerId']?.toString() ?? '').trim();
      String customerPhone = m['customerPhone']?.toString() ?? '';
      try {
        Map<String, dynamic>? row;
        if (customerId.isNotEmpty) {
          final resById = await Supabase.instance.client
              .from('customers')
              .select(
                  'id,name,phone,address,avatar,is_active,last_login,total_spent,orders_count,rating,lat,lng,created_at,updated_at')
              .eq('id', customerId)
              .limit(1);
          final list = (resById as List).cast<Map<String, dynamic>>();
          if (list.isNotEmpty) row = list.first;
        }
        if (row == null && customerPhone.isNotEmpty) {
          final resByPhone = await Supabase.instance.client
              .from('customers')
              .select(
                  'id,name,phone,address,avatar,is_active,last_login,total_spent,orders_count,rating,lat,lng,created_at,updated_at')
              .in_('phone', _phoneVariants(customerPhone).toList())
              .limit(1);
          final list = (resByPhone as List).cast<Map<String, dynamic>>();
          if (list.isNotEmpty) row = list.first;
        }
        if (row != null) {
          final map = Map<String, dynamic>.from(row);
          // Coordinate & numeric normalization
          map['lat'] = map['lat'] ?? map['latitude'] ?? map['customer_lat'];
          map['lng'] = map['lng'] ?? map['lon'] ?? map['long'] ?? map['longitude'] ?? map['customer_lng'] ?? map['lan'];
          if (map['total_spent'] is int) map['total_spent'] = (map['total_spent'] as int).toDouble();
          if (map['rating'] is int) map['rating'] = (map['rating'] as int).toDouble();
          if (map['lat'] is int) map['lat'] = (map['lat'] as int).toDouble();
          if (map['lng'] is int) map['lng'] = (map['lng'] as int).toDouble();
          final c = Customer.fromJson(map);
          // Prefer customers table for identity/phone when available
          if (c.name.isNotEmpty) m['customerName'] = c.name;
          if (c.phone.isNotEmpty) m['customerPhone'] = c.phone;
          m['customerId'] = c.id;
          m['customerAddress'] = c.address;
          m['customerLat'] = c.lat;
          m['customerLng'] = c.lng;
          m['customer'] = c; // expose typed model for UI if needed
        }
      } catch (_) {
        // ignore enrichment failures
      }
      // Add a shortId for display (last 6 of uuid or numeric)
      final id = m['id']?.toString() ?? '';
      if (id.length > 8) {
        m['shortId'] = id.substring(id.length - 6);
      } else {
        m['shortId'] = id;
      }
      enriched.add(m);
    }
    return enriched;
  }

  /// Produce common Saudi phone formats from an input phone string.
  /// Returns a small set including: 05XXXXXXXX, 5XXXXXXXX, +9665XXXXXXXX, 9665XXXXXXXX, 009665XXXXXXXX
  Set<String> _phoneVariants(String input) {
    final s = input.trim();
    if (s.isEmpty) return {};
    final digits = s.replaceAll(RegExp(r'[^0-9+]'), '');
    var d = digits.startsWith('+') ? digits.substring(1) : digits; // strip leading +
    final variants = <String>{};

    void addAllFromLocal(String local10) {
      // expects like 05XXXXXXXX (10 digits)
      final core = local10.startsWith('0') ? local10.substring(1) : local10; // 5XXXXXXXX
      variants.add(local10); // 05XXXXXXXX
      variants.add(core); // 5XXXXXXXX
      variants.add('+966$core');
      variants.add('966$core');
      variants.add('00966$core');
    }

    if (d.startsWith('00966')) {
      final rest = d.substring(5);
      final local = rest.isNotEmpty ? '0$rest' : '';
      if (local.length == 10) addAllFromLocal(local);
      variants.add(digits); // original
    } else if (d.startsWith('966')) {
      final rest = d.substring(3);
      final local = rest.isNotEmpty ? '0$rest' : '';
      if (local.length == 10) addAllFromLocal(local);
      variants.add(digits.startsWith('+') ? digits : '+$digits');
      variants.add(digits);
    } else if (d.length == 9 && d.startsWith('5')) {
      addAllFromLocal('0$d');
      variants.add(digits);
    } else if (d.length >= 10 && d.startsWith('05')) {
      addAllFromLocal(d.substring(0, 10));
      variants.add(digits);
    } else {
      // Fallback: try to coerce to 10-digit local if possible
      final onlyDigits = d.replaceAll(RegExp(r'[^0-9]'), '');
      if (onlyDigits.length == 9 && onlyDigits.startsWith('5')) {
        addAllFromLocal('0$onlyDigits');
      }
      variants.add(digits);
    }

    return variants;
  }

  Map<String, dynamic> _rowToCardData(Map<String, dynamic> r) {
  final id = (r['id'] ?? '').toString();
    final status = (r['status'] ?? 'pending').toString();
    final int step = _statusToStep(status);

    // Items can be a jsonb array, try to extract product names if present
    final itemsField = r['items'];
    final List<String> items = [];
    if (itemsField is List) {
      for (final e in itemsField) {
        if (e == null) continue;
        if (e is String) {
          items.add(e);
        } else if (e is Map) {
          final name = (e['productName'] ??
                  e['product_name'] ??
                  e['name'] ??
                  e['title'] ??
                  e.toString())
              .toString();
          items.add(name);
        } else {
          try {
            final dyn = e as dynamic;
            final name = dyn.productName ?? dyn.name ?? dyn.title;
            items.add((name ?? e.toString()).toString());
          } catch (_) {
            items.add(e.toString());
          }
        }
      }
    }

  // Try to detect customer identity fields across multiple potential schemas
  final String customerId = (r['customer_id'] ?? r['customerId'] ?? r['user_id'] ?? r['userId'] ?? '').toString();
  final String customerPhone = (
        r['customer_phone'] ??
        r['delivery_phone'] ??
        r['recipient_phone'] ??
        r['phone'] ??
        r['mobile'] ??
        r['customerMobile'] ??
        r['recipientMobile'] ??
        ''
      ).toString();
  final String customerName = (
        r['customer_name'] ??
        r['recipient_name'] ??
        r['name'] ??
        ''
      ).toString();

    // LiveOrderCard map shape
  return {
      'id': id,
      'items': items,
      'step': step,
      // Optional: 'statusColor': computed in UI theme if needed
  'customerId': customerId,
  'customerName': customerName,
      'customerPhone': customerPhone,
    };
  }

  int _statusToStep(String s) {
    // Map multiple possible schemas to 4-step timeline (1..4)
    switch (s) {
      case 'pending':
      case 'accepted':
      case 'confirmed':
        return 1;
      case 'driver_assigned':
      case 'preparing':
        return 2;
      case 'delivering':
      case 'out_for_delivery':
        return 3;
      case 'delivered':
        return 4;
      case 'rejected':
      case 'cancelled':
      case 'canceled':
      default:
        // Treat terminal/unknown as last step
        return 4;
    }
  }
}
