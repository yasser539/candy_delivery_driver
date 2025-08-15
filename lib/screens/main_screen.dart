import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../blocs/app_bloc.dart';
import '../core/services/app_settings.dart';
import '../core/services/supabase_service.dart';
import '../widgets/navigation/navigation_wrapper.dart';
import 'home/home_screen.dart';
import 'orders/orders_screen.dart';
import 'profile/profile_screen.dart';
import 'map/map_screen.dart';
import 'settings/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  // Removed custom transition animations to prefer native PageView behavior

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 2); // Start with home screen
    // No custom animations

    // Initialize app settings
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final appSettings = context.read<AppSettings>();
      await appSettings.initialize();
      // Backend health check (best-effort, non-blocking UI)
      try {
        final health = await SupabaseService.healthCheck();
        if (!mounted) return;
        final missingCols = (health['has_columns'] as Map<String, bool>)
            .entries
            .where((e) => e.value == false)
            .map((e) => e.key)
            .toList();
        final hasRpc = health['has_accept_cart_rpc'] == true;
        if (missingCols.isNotEmpty || !hasRpc) {
          final msg = !hasRpc
              ? 'تنبيه: دالة accept_cart غير موجودة. يُفضّل إنشاءها لتحسين الأمان.'
              : 'تنبيه: أعمدة مفقودة في carts: ${missingCols.join(', ')}';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    final appBloc = context.read<AppBloc>();
    if (appBloc.currentIndex != index) {
      appBloc.add(SetCurrentIndexEvent(index));
    }
  }

  void _onNavTap(int index) {
    if (_pageController.page?.round() != index) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppBloc>(
      builder: (context, appBloc, child) {
        // Update page controller when current index changes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || !_pageController.hasClients) return;
          if (_pageController.page?.round() != appBloc.currentIndex) {
            _pageController.animateToPage(
              appBloc.currentIndex,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
            );
          }
        });

        return NavigationWrapper(
          child: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            physics: const BouncingScrollPhysics(),
            children: const [
              ProfileScreen(),
              MapScreen(),
              HomeScreen(),
              OrdersScreen(),
              SettingsScreen(),
            ],
          ),
          onNavTap: _onNavTap,
        );
      },
    );
  }
}
