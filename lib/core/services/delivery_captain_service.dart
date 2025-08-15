import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import '../../models/delivery_captain.dart';

class DeliveryCaptainService {
  static final DeliveryCaptainService _instance =
      DeliveryCaptainService._internal();
  factory DeliveryCaptainService() => _instance;
  DeliveryCaptainService._internal();

  final StreamController<List<DeliveryCaptain>> _captainsController =
      StreamController<List<DeliveryCaptain>>.broadcast();
  Stream<List<DeliveryCaptain>> get captainsStream =>
      _captainsController.stream;

  List<DeliveryCaptain> _currentCaptains = [];

  Future<void> loadCaptains(
      {String? city, String? status, String? position, String? query}) async {
    try {
      final queryBuilder =
          SupabaseService.client.from('delivery_captains').select('*');

      if (city != null && city.isNotEmpty) {
        queryBuilder.eq('city', city);
      }
      if (status != null && status.isNotEmpty) {
        queryBuilder.eq('status', status);
      }
      if (position != null && position.isNotEmpty) {
        queryBuilder.eq('position', position);
      }
      if (query != null && query.isNotEmpty) {
        queryBuilder.or(
            'name.ilike.%$query%,phone.ilike.%$query%,email.ilike.%$query%');
      }

      final response =
          await queryBuilder.order('created_at', ascending: false).limit(200);
      _currentCaptains = List<Map<String, dynamic>>.from(response)
          .map((m) => DeliveryCaptain.fromMap(m))
          .toList();
      _captainsController.add(_currentCaptains);
    } catch (e) {
      _captainsController.add(_currentCaptains);
    }
  }

  Future<DeliveryCaptain?> getCaptainById(String id) async {
    try {
      final data = await SupabaseService.client
          .from('delivery_captains')
          .select('*')
          .eq('id', id)
          .single();
      return DeliveryCaptain.fromMap(Map<String, dynamic>.from(data));
    } catch (_) {}
    return null;
  }

  Future<DeliveryCaptain?> createCaptain(Map<String, dynamic> payload) async {
    try {
      final data = await SupabaseService.client
          .from('delivery_captains')
          .insert(payload)
          .select()
          .single();
      return DeliveryCaptain.fromMap(Map<String, dynamic>.from(data));
    } catch (_) {
      return null;
    }
  }

  Future<DeliveryCaptain?> updateCaptain(
      String id, Map<String, dynamic> payload) async {
    try {
      final data = await SupabaseService.client
          .from('delivery_captains')
          .update(payload)
          .eq('id', id)
          .select()
          .single();
      final updated = DeliveryCaptain.fromMap(Map<String, dynamic>.from(data));
      final idx = _currentCaptains.indexWhere((c) => c.id == id);
      if (idx != -1) {
        _currentCaptains[idx] = updated;
        _captainsController.add(_currentCaptains);
      }
      return updated;
    } catch (_) {
      return null;
    }
  }

  Future<bool> deleteCaptain(String id) async {
    try {
      await SupabaseService.client
          .from('delivery_captains')
          .delete()
          .eq('id', id);
      _currentCaptains.removeWhere((c) => c.id == id);
      _captainsController.add(_currentCaptains);
      return true;
    } catch (_) {
      return false;
    }
  }

  RealtimeChannel subscribeToCaptainsChanges() {
    final channel = SupabaseService.client
        .channel('public:delivery_captains')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'delivery_captains',
          callback: (payload) async {
            // Refresh on any change
            await loadCaptains();
          },
        )
        .subscribe();
    return channel;
  }

  void dispose() {
    _captainsController.close();
  }
}
