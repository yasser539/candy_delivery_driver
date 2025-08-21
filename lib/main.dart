import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/design_system/design_system.dart';
import 'core/services/app_settings.dart';
import 'core/services/order_service.dart';
import 'core/services/cart_service.dart';
import 'core/services/supabase_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/attendance_service.dart';
import 'blocs/app_bloc.dart';
import 'screens/main_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/orders/available_carts_screen.dart';
import 'core/theme/app_theme.dart';
import 'screens/admin/captains_management_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Supabase
  await SupabaseService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppSettings()),
        ChangeNotifierProvider(create: (_) => AppBloc()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider<OrderService>(create: (_) => OrderService()),
        Provider<CartService>(create: (_) => CartService()),
        Provider<AttendanceService>(create: (_) => AttendanceService()),
      ],
      child: Consumer2<AppSettings, AuthService>(
        builder: (context, appSettings, authService, child) {
          // Use AppTheme, selecting light/dark versions based on language
          final language = appSettings.language == 'العربية' ? 'ar' : 'en';
          return MaterialApp(
            title: 'Candy Water Delivery',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightFor(language),
            darkTheme: AppTheme.darkFor(language),
            // Use saved theme mode from settings
            themeMode: appSettings.themeMode,
            home: authService.isAuthenticated
                ? const MainScreen()
                : const LoginScreen(),
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/orders':
                  return MaterialPageRoute(
                    builder: (context) => const OrdersScreen(),
                  );
                case '/captains':
                  return MaterialPageRoute(
                    builder: (context) => const CaptainsManagementScreen(),
                  );
                case '/available-carts':
                  return MaterialPageRoute(
                    builder: (context) => const AvailableCartsScreen(),
                  );
                default:
                  return MaterialPageRoute(
                    builder: (context) => const MainScreen(),
                  );
              }
            },
          );
        },
      ),
    );
  }
}
