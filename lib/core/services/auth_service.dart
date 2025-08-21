import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  bool _isCustomAuthenticated = false;
  Map<String, dynamic>? _captainProfile;
  RealtimeChannel? _captainChannel;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null || _isCustomAuthenticated;
  Map<String, dynamic>? get captainProfile => _captainProfile;

  AuthService() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _currentUser = SupabaseService.getCurrentUser();

    // الاستماع لتغييرات حالة المصادقة
    SupabaseService.client.auth.onAuthStateChange.listen((data) {
      _currentUser = data.session?.user;
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    try {
      await SupabaseService.signIn(email: email, password: password);
      _currentUser = SupabaseService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithPhone(String phone, String password) async {
    _setLoading(true);
    try {
      await SupabaseService.signInWithPhone(phone: phone, password: password);
      _currentUser = SupabaseService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      // Fallback: إذا كان مزود الهاتف غير مفعّل، جرّب المطابقة عبر البريد المرتبط بنفس الهاتف
      final message = e.toString().toLowerCase();
      final isPhoneProviderDisabled =
          message.contains('phone_provider_disabled') ||
          message.contains('phone logins are disabled') ||
          message.contains('422');

      if (isPhoneProviderDisabled) {
        try {
          final rows = await SupabaseService.getData(
            table: 'delivery_captains',
            filters: {'phone': phone},
          );
          if (rows.isNotEmpty && rows.first['email'] != null) {
            await SupabaseService.signIn(
              email: rows.first['email'],
              password: password,
            );
            _currentUser = SupabaseService.getCurrentUser();
            notifyListeners();
          } else {
            throw AuthException(
              'لم يتم العثور على بريد مرتبط بهذا الجوال. فعّل مزود الهاتف أو اربط بريداً.',
            );
          }
        } catch (fallbackError) {
          throw AuthException(fallbackError.toString());
        }
      } else {
        rethrow;
      }
    } finally {
      _setLoading(false);
    }
  }

  // تسجيل دخول مخصص بمطابقة رقم الجوال وكلمة المرور من جدول delivery_captains فقط
  Future<void> signInByCaptainPhonePassword(
    String phone,
    String password,
  ) async {
    _setLoading(true);
    try {
      // مقارنة مباشرة وبسيطة كما هي في قاعدة البيانات
      final rows = await SupabaseService.getData(
        table: 'delivery_captains',
        filters: {'phone': phone, 'password': password},
      );

      if (rows.isEmpty) {
        throw AuthException('رقم الجوال أو كلمة المرور غير صحيحة');
      }

      _isCustomAuthenticated = true;
      _captainProfile = rows.first;
      // Subscribe to realtime changes for this captain
      final id = _captainProfile?['id']?.toString();
      if (id != null && id.isNotEmpty) {
        _subscribeToCaptainChanges(id);
      }
      notifyListeners();
    } catch (e) {
      _isCustomAuthenticated = false;
      _captainProfile = null;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _subscribeToCaptainChanges(String id) {
    try {
      // Unsubscribe previous channel
      _captainChannel?.unsubscribe();
      final channel = SupabaseService.client.channel(
        'public:delivery_captains',
      );
      channel.on(
        RealtimeListenTypes.postgresChanges,
        ChannelFilter(event: '*', schema: 'public', table: 'delivery_captains'),
        (payload, [ref]) {
          // BindingCallback must be synchronous; delegate async work to a separate
          // unawaited async handler to avoid returning a Future from this callback.
          _handleCaptainChange(id);
        },
      );
      channel.subscribe();
      _captainChannel = channel;
    } catch (_) {}
  }

  // Async handler for captain change events
  Future<void> _handleCaptainChange(String id) async {
    try {
      final data = await SupabaseService.client
          .from('delivery_captains')
          .select('*')
          .eq('id', id)
          .single();
      _captainProfile = Map<String, dynamic>.from(data);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await SupabaseService.signOut();
      _currentUser = null;
      _isCustomAuthenticated = false;
      _captainProfile = null;
      try {
        await _captainChannel?.unsubscribe();
      } catch (_) {}
      _captainChannel = null;
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetPassword(String email) async {
    _setLoading(true);
    try {
      await SupabaseService.resetPassword(email);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // الحصول على بيانات المستخدم من جدول profiles
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (_isCustomAuthenticated) return _captainProfile;
    if (_currentUser == null) return null;

    try {
      final profiles = await SupabaseService.getData(
        table: 'profiles',
        filters: {'id': _currentUser!.id},
      );

      return profiles.isNotEmpty ? profiles.first : null;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  // تحديث بيانات المستخدم
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    if (_currentUser == null) return;

    try {
      await SupabaseService.updateData(
        table: 'profiles',
        data: data,
        column: 'id',
        value: _currentUser!.id,
      );
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
