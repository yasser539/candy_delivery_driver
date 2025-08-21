import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../blocs/app_bloc.dart';
import '../../core/services/app_settings.dart';
import '../../core/design_system/design_system.dart';
import 'candy_navigation_bar.dart';

class NavigationWrapper extends StatefulWidget {
  final Widget child;
  final bool showBackButton;
  final Function(int)? onNavTap;

  const NavigationWrapper({
    super.key,
    required this.child,
    this.showBackButton = true,
    this.onNavTap,
  });

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper>
    with TickerProviderStateMixin {
  // Swipe detection
  // removed unused _dragStartX
  double _dragDistance = 0.0;
  static const double _swipeThreshold = 100.0;

  @override
  void initState() {
    super.initState();
  }

  void _handleSwipe(DragUpdateDetails details) {
    setState(() {
      _dragDistance += details.delta.dx;
    });
  }

  void _handleSwipeEnd(DragEndDetails details) {
    final appBloc = context.read<AppBloc>();
    final currentIndex = appBloc.currentIndex;

    if (_dragDistance.abs() > _swipeThreshold) {
      int newIndex = currentIndex;

      if (_dragDistance > 0) {
        // Swipe right - go to previous tab
        newIndex = (currentIndex - 1).clamp(0, 4);
      } else {
        // Swipe left - go to next tab
        newIndex = (currentIndex + 1).clamp(0, 4);
      }

      if (newIndex != currentIndex) {
        appBloc.add(SetCurrentIndexEvent(newIndex));
      }
    }

    setState(() {
      _dragDistance = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppSettings, AppBloc>(
      builder: (context, appSettings, appBloc, _) {
        final isDarkMode =
            appSettings.themeMode == ThemeMode.dark ||
            (appSettings.themeMode == ThemeMode.system &&
                MediaQuery.of(context).platformBrightness == Brightness.dark);
        return Scaffold(
          backgroundColor: isDarkMode
              ? DesignSystem.darkBackground
              : DesignSystem.background,
          body: GestureDetector(
            onHorizontalDragUpdate: _handleSwipe,
            onHorizontalDragEnd: _handleSwipeEnd,
            child: Stack(
              children: [
                // Main content with animation
                widget.child,
                // Navigation bar at bottom
                Align(
                  alignment: Alignment.bottomCenter,
                  child: CandyNavigationBar(
                    onNavTap:
                        widget.onNavTap ??
                        (index) {
                          final appBloc = context.read<AppBloc>();
                          if (appBloc.currentIndex != index) {
                            appBloc.add(SetCurrentIndexEvent(index));
                          }
                        },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
