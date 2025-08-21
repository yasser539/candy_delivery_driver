import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase/supabase.dart';
import 'supabase_service.dart';

class AttendanceService {
  static final AttendanceService _instance = AttendanceService._internal();
  factory AttendanceService() => _instance;
  AttendanceService._internal();

  String? _driverId;
  RealtimeChannel? _channel;
  final StreamController<int> _monthlyDaysController =
      StreamController<int>.broadcast();

  Stream<int> get monthlyDaysStream => _monthlyDaysController.stream;

  void initialize(String driverId) {
    _driverId = driverId;
    _subscribe();
    refreshCurrentMonthDays();
  }

  Future<void> dispose() async {
    try {
      await _channel?.unsubscribe();
    } catch (_) {}
    _channel = null;
    await _monthlyDaysController.close();
  }

  void _subscribe() {
    try {
      _channel?.unsubscribe();
      final channel = SupabaseService.client.channel(
        'public:driver_attendance',
      );
      channel.on(
        RealtimeListenTypes.postgresChanges,
        ChannelFilter(event: '*', schema: 'public', table: 'driver_attendance'),
        (payload, [ref]) {
          // fire-and-forget refresh (BindingCallback must be synchronous)
          refreshCurrentMonthDays();
        },
      );
      channel.subscribe();
      _channel = channel;
    } catch (_) {}
  }

  Future<void> checkIn({double? lat, double? lng}) async {
    if (_driverId == null) return;
    final now = DateTime.now().toUtc();
    final location = (lat != null && lng != null)
        ? {'latitude': lat, 'longitude': lng}
        : null;
    try {
      // If there's already an open record today, skip creating a new one
      final startOfDay = DateTime(now.year, now.month, now.day).toUtc();
      final existing = await SupabaseService.client
          .from('driver_attendance')
          .select('*')
          .eq('driver_id', _driverId!)
          .gte('check_in_at', startOfDay.toIso8601String())
          .filter('check_out_at', 'is', null)
          .limit(1);

      if (existing.isNotEmpty) {
        return;
      }

      await SupabaseService.client.from('driver_attendance').insert({
        'driver_id': _driverId!,
        'check_in_at': now.toIso8601String(),
        if (location != null) 'check_in_location': location,
        'created_at': now.toIso8601String(),
      });
      await refreshCurrentMonthDays();
    } catch (e) {
      // If table missing, log hint
      if (e is PostgrestException && e.code == '42P01') {
        // undefined_table
        // ignore log only
      }
    }
  }

  Future<void> checkOut({double? lat, double? lng}) async {
    if (_driverId == null) return;
    final now = DateTime.now().toUtc();
    final location = (lat != null && lng != null)
        ? {'latitude': lat, 'longitude': lng}
        : null;
    try {
      final startOfDay = DateTime(now.year, now.month, now.day).toUtc();
      final open = await SupabaseService.client
          .from('driver_attendance')
          .select('*')
          .eq('driver_id', _driverId!)
          .gte('check_in_at', startOfDay.toIso8601String())
          .filter('check_out_at', 'is', null)
          .order('check_in_at', ascending: false)
          .limit(1);

      if (open.isEmpty) {
        return;
      }

      final record = open.first;
      final checkIn = DateTime.tryParse(record['check_in_at'] ?? '') ?? now;
      final minutes = now.difference(checkIn).inMinutes;

      await SupabaseService.client
          .from('driver_attendance')
          .update({
            'check_out_at': now.toIso8601String(),
            if (location != null) 'check_out_location': location,
            'duration_minutes': minutes,
            'updated_at': now.toIso8601String(),
          })
          .eq('id', record['id']);
      await refreshCurrentMonthDays();
    } catch (e) {
      if (e is PostgrestException && e.code == '42P01') {
        // table missing
      }
    }
  }

  // Live location upsert to driver_live_locations
  Future<void> updateLiveLocation({
    required double lat,
    required double lng,
  }) async {
    if (_driverId == null) return;
    try {
      await SupabaseService.client.from('driver_live_locations').upsert({
        'driver_id': _driverId!,
        'location': {'latitude': lat, 'longitude': lng},
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'driver_id');
    } catch (_) {}
  }

  Future<int> getMonthlyDays({DateTime? month}) async {
    if (_driverId == null) return 0;
    final now = month ?? DateTime.now();
    final start = DateTime(now.year, now.month, 1).toUtc();
    final end = DateTime(now.year, now.month + 1, 1).toUtc();
    try {
      final rows = await SupabaseService.client
          .from('driver_attendance')
          .select('check_in_at')
          .eq('driver_id', _driverId!)
          .gte('check_in_at', start.toIso8601String())
          .lt('check_in_at', end.toIso8601String());
      // Count unique days with a check-in
      final days = <String>{};
      for (final r in rows) {
        final dt = DateTime.tryParse(r['check_in_at'] ?? '');
        if (dt != null) {
          days.add('${dt.year}-${dt.month}-${dt.day}');
        }
      }
      return days.length;
    } catch (e) {
      return 0;
    }
  }

  Future<void> refreshCurrentMonthDays() async {
    final days = await getMonthlyDays();
    if (!_monthlyDaysController.isClosed) {
      _monthlyDaysController.add(days);
    }
  }
}
