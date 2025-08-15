import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String _supabaseUrl = 'https://zzmqxporppazopgxfbwj.supabase.co';
  static const String _supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp6bXF4cG9ycHBhem9wZ3hmYndqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQwODM2NDQsImV4cCI6MjA2OTY1OTY0NH0.XTId7-p_aSIiLQT0XRUaoAfXecNdj3zbWMKC3tNbqmk';

  static SupabaseClient get client => Supabase.instance.client;

  // تهيئة Supabase
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: _supabaseUrl,
        anonKey: _supabaseAnonKey,
      );
      print('Supabase initialized successfully');
    } catch (e) {
      print('Error initializing Supabase: $e');
      // يمكن إضافة معالجة إضافية للأخطاء هنا
    }
  }

  // تسجيل الدخول
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // تسجيل الدخول برقم الجوال
  static Future<AuthResponse> signInWithPhone({
    required String phone,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      phone: phone,
      password: password,
    );
  }

  // تسجيل الخروج
  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  // الحصول على المستخدم الحالي
  static User? getCurrentUser() {
    return client.auth.currentUser;
  }

  // التحقق من حالة تسجيل الدخول
  static bool isAuthenticated() {
    return client.auth.currentUser != null;
  }

  // الحصول على بيانات المستخدم
  static Future<UserResponse> getUser() async {
    return await client.auth.getUser();
  }

  // تحديث بيانات المستخدم
  static Future<UserResponse> updateUser({
    String? email,
    String? password,
  }) async {
    return await client.auth.updateUser(
      UserAttributes(
        email: email,
        password: password,
      ),
    );
  }

  // إرسال رابط إعادة تعيين كلمة المرور
  static Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(email);
  }

  // الحصول على بيانات من جدول
  static Future<List<Map<String, dynamic>>> getData({
    required String table,
    String? select,
    Map<String, dynamic>? filters,
  }) async {
    var query = client.from(table).select(select ?? '*');

    if (filters != null) {
      for (var entry in filters.entries) {
        query = query.eq(entry.key, entry.value);
      }
    }

    final response = await query;
    return List<Map<String, dynamic>>.from(response);
  }

  // RPC: login via delivery_captains table (SECURITY DEFINER function in DB)
  static Future<Map<String, dynamic>?> loginCaptain({
    required String phone,
    required String password,
  }) async {
    try {
      final res = await client.rpc(
        'login_captain',
        params: {
          'p_phone': phone,
          'p_password': password,
        },
      ).single();
      return Map<String, dynamic>.from(res);
    } catch (e) {
      return null;
    }
  }

  // إضافة بيانات إلى جدول
  static Future<Map<String, dynamic>> insertData({
    required String table,
    required Map<String, dynamic> data,
  }) async {
    final response = await client.from(table).insert(data).select().single();
    return response;
  }

  // تحديث بيانات في جدول
  static Future<Map<String, dynamic>> updateData({
    required String table,
    required Map<String, dynamic> data,
    required String column,
    required dynamic value,
  }) async {
    final response = await client
        .from(table)
        .update(data)
        .eq(column, value)
        .select()
        .single();
    return response;
  }

  // حذف بيانات من جدول
  static Future<void> deleteData({
    required String table,
    required String column,
    required dynamic value,
  }) async {
    await client.from(table).delete().eq(column, value);
  }

  // الاستماع للتغييرات في الجدول
  static RealtimeChannel subscribeToTable(String table) {
    return client.channel('public:$table').onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: table,
          callback: (payload) {
            // يمكن إضافة منطق معالجة التغييرات هنا
            print('Table change: $payload');
          },
        );
  }

  // Health checks for required backend features (RPC/columns)
  static Future<Map<String, dynamic>> healthCheck() async {
    final Map<String, dynamic> result = {
      'has_accept_cart_rpc': false,
      'has_columns': <String, bool>{
        'accepted_at': false,
        'picked_up_at': false,
        'delivered_at': false,
        'driver_id': false,
        'status': false,
      },
    };

    // 1) Check if accept_cart RPC exists (best-effort)
    try {
      await client.rpc('accept_cart', params: {
        'p_cart_id': '00000000-0000-0000-0000-000000000000',
      });
      result['has_accept_cart_rpc'] = true;
    } catch (_) {
      result['has_accept_cart_rpc'] = false;
    }

    // 2) Check columns presence with zero-row selects
    final cols = [
      'accepted_at',
      'picked_up_at',
      'delivered_at',
      'driver_id',
      'status'
    ];
    for (final c in cols) {
      try {
        await client.from('carts').select(c).limit(0);
        (result['has_columns'] as Map<String, bool>)[c] = true;
      } catch (_) {
        (result['has_columns'] as Map<String, bool>)[c] = false;
      }
    }

    return result;
  }
}
