import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/customer.dart';

class CustomersRepository {
  final SupabaseClient _db;
  CustomersRepository({SupabaseClient? client})
      : _db = client ?? Supabase.instance.client;

  Future<Map<String, dynamic>?> getByPhone(String phone) async {
    final variants = _phoneVariants(phone);
    if (variants.isEmpty) return null;
    final res = await _db
        .from('customers')
        .select('id,name,phone,address,lat,lng,avatar')
        .in_('phone', variants.toList())
        .limit(1);
    final rows = (res as List).cast<Map<String, dynamic>>();
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<Customer?> getModelByPhone(String phone) async {
    final variants = _phoneVariants(phone);
    if (variants.isEmpty) return null;
    final res = await _db
        .from('customers')
    .select()
        .in_('phone', variants.toList())
        .limit(1);
    final rows = (res as List).cast<Map<String, dynamic>>();
    if (rows.isEmpty) return null;
    // Supabase returns num for numeric types sometimes; normalize to double/int expected by model
    final m = Map<String, dynamic>.from(rows.first);
  // Map possible coordinate variants to lat/lng
  m['lat'] = m['lat'] ?? m['latitude'] ?? m['customer_lat'];
  m['lng'] = m['lng'] ?? m['lon'] ?? m['long'] ?? m['longitude'] ?? m['customer_lng'] ?? m['lan'];
    if (m['total_spent'] is int) m['total_spent'] = (m['total_spent'] as int).toDouble();
    if (m['rating'] is int) m['rating'] = (m['rating'] as int).toDouble();
    if (m['lat'] is int) m['lat'] = (m['lat'] as int).toDouble();
    if (m['lng'] is int) m['lng'] = (m['lng'] as int).toDouble();
    return Customer.fromJson(m);
  }

  Set<String> _phoneVariants(String input) {
    final s = input.trim();
    if (s.isEmpty) return {};
    final digits = s.replaceAll(RegExp(r'[^0-9+]'), '');
    var d = digits.startsWith('+') ? digits.substring(1) : digits;
    final variants = <String>{};

    void addAllFromLocal(String local10) {
      final core = local10.startsWith('0') ? local10.substring(1) : local10; // 5XXXXXXXX
      variants.add(local10);
      variants.add(core);
      variants.add('+966$core');
      variants.add('966$core');
      variants.add('00966$core');
    }

    if (d.startsWith('00966')) {
      final rest = d.substring(5);
      final local = rest.isNotEmpty ? '0$rest' : '';
      if (local.length == 10) addAllFromLocal(local);
      variants.add(digits);
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
      final onlyDigits = d.replaceAll(RegExp(r'[^0-9]'), '');
      if (onlyDigits.length == 9 && onlyDigits.startsWith('5')) {
        addAllFromLocal('0$onlyDigits');
      }
      variants.add(digits);
    }

    return variants;
  }
}
