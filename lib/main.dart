import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/supabase_config.dart';
import 'screens/auth/login_screen.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Supabase client (client-side anon key is expected here)
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final language =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance.mode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Candy Water Delivery',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightFor(language),
          darkTheme: AppTheme.darkFor(language),
          themeMode: mode,
          home: const LoginScreen(),
        );
      },
    );
  }
}
