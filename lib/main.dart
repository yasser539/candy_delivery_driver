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
          final lightScheme = ColorScheme.fromSeed(
            seedColor: DesignSystem.primary,
            brightness: Brightness.light,
          ).copyWith(
            background: DesignSystem.background,
            surface: DesignSystem.surface,
          );

          final darkScheme = ColorScheme.fromSeed(
            seedColor: DesignSystem.primary,
            brightness: Brightness.dark,
          ).copyWith(
            background: DesignSystem.darkBackground,
            surface: DesignSystem.darkSurface,
          );

          return MaterialApp(
            title: 'Candy Water Delivery',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              fontFamily: 'Rubik',
              colorScheme: lightScheme,
              scaffoldBackgroundColor: DesignSystem.background,
              cardColor: DesignSystem.surface,
              dialogBackgroundColor: DesignSystem.surface,
              canvasColor: DesignSystem.surface,
              listTileTheme: ListTileThemeData(
                iconColor: DesignSystem.primary,
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              fontFamily: 'Rubik',
              colorScheme: darkScheme,
              scaffoldBackgroundColor: DesignSystem.darkBackground,
              cardColor: DesignSystem.darkSurface,
              dialogBackgroundColor: DesignSystem.darkSurface,
              canvasColor: DesignSystem.darkSurface,
              listTileTheme: ListTileThemeData(
                iconColor: DesignSystem.primary,
              ),
            ),
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
