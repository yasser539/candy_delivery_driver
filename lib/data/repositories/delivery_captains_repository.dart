import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/delivery_captain.dart';

class DeliveryCaptainsRepository {
  final SupabaseClient _db;
  DeliveryCaptainsRepository({SupabaseClient? client})
      : _db = client ?? Supabase.instance.client;

  static const String table = 'delivery_captains';

  Future<List<DeliveryCaptain>> list({int limit = 100}) async {
    final res = await _db
        .from(table)
        .select()
        .order('created_at', ascending: false)
        .limit(limit);
    return (res as List)
        .cast<Map<String, dynamic>>()
        .map(DeliveryCaptain.fromMap)
        .toList();
  }

  Future<DeliveryCaptain?> getById(String id) async {
    final res = await _db.from(table).select().eq('id', id).maybeSingle();
    if (res == null) return null;
    return DeliveryCaptain.fromMap(res as Map<String, dynamic>);
  }

  Future<DeliveryCaptain> create(DeliveryCaptain captain) async {
    final payload = captain.toMap()
      ..removeWhere((k, v) => v == null);
    final res = await _db.from(table).insert(payload).select().single();
    return DeliveryCaptain.fromMap(res as Map<String, dynamic>);
  }

  Future<DeliveryCaptain> update(String id, Map<String, dynamic> patch) async {
    final payload = Map<String, dynamic>.from(patch)
      ..removeWhere((k, v) => v == null);
    final res = await _db.from(table).update(payload).eq('id', id).select().single();
    return DeliveryCaptain.fromMap(res as Map<String, dynamic>);
  }

  Future<void> remove(String id) async {
    await _db.from(table).delete().eq('id', id);
  }

  // Simple credential check using phone + password columns in the table.
  // Note: For production, use Supabase Auth or hash passwords client-side before sending.
  Future<DeliveryCaptain?> authenticate({
    required String phone,
    required String password,
  }) async {
  // Try the new driver_phone column first; fallback to legacy phone
  final r1 = await _db
    .from(table)
    .select()
    .eq('driver_phone', phone)
    .eq('password', password)
    .maybeSingle();
  final Map<String, dynamic>? res = r1 as Map<String, dynamic>? ??
    await _db
      .from(table)
      .select()
      .eq('phone', phone)
      .eq('password', password)
      .maybeSingle() as Map<String, dynamic>?;
  if (res == null) return null;
  return DeliveryCaptain.fromMap(res);
  }
}
