import 'supabase_service.dart';

class SupabaseTest {
  static Future<void> testConnection() async {
    try {
      print('Testing Supabase connection...');

      // Test basic connection
      final response =
          await SupabaseService.client.from('carts').select('count').limit(1);

      print('Supabase connection successful');
      print('Response: $response');

      // Test getting carts
      final cartsResponse =
          await SupabaseService.client.from('carts').select('*').limit(5);

      print('Carts in database: ${cartsResponse.length}');
      if (cartsResponse.isNotEmpty) {
        print('Sample cart: ${cartsResponse.first}');
      }
    } catch (e) {
      print('Supabase connection failed: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }

  static Future<void> testCartsTable() async {
    try {
      print('Testing carts table structure...');

      // Check if table exists and has data
      final response = await SupabaseService.client
          .from('carts')
          .select(
              'id, status, created_at, customer_name, customer_phone, driver_id')
          .limit(10);

      print('Carts table test:');
      print('- Total carts found: ${response.length}');

      for (var cart in response) {
        print(
            '- Cart ID: ${cart['id']}, Status: ${cart['status']}, Customer: ${cart['customer_name'] ?? 'N/A'}');
      }
    } catch (e) {
      print('Carts table test failed: $e');
      // 42703: undefined_column
      // Provide actionable hint in logs
      // ignore: unrelated_type_equality_checks
      // runtime type check since PostgrestException type may not be available here
      try {
        if (e.toString().contains('42703')) {
          print(
              'Hint: Missing expected columns on carts (e.g., driver_id, customer_name). Run fix_supabase_database.sql');
        }
      } catch (_) {}
    }
  }
}
