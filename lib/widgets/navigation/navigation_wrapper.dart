import 'package:flutter/material.dart';
import '../../core/design_system/design_system.dart';
import '../candy_navigation_bar.dart';

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

class _NavigationWrapperState extends State<NavigationWrapper> {
  // Removed unused swipe fields; keeping gestures minimal

  @override
  Widget build(BuildContext context) {
  // Follow the app's active theme (not the device setting) to avoid mismatched background
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return Scaffold(
  // Allow content and nav to extend under system gesture area without reserving padding
  resizeToAvoidBottomInset: false,
    backgroundColor: isDarkMode
      ? DesignSystem.darkBackground
      : DesignSystem.background,
      body: Stack(
        children: [
          // Let content extend under the floating nav bar
          widget.child,
          // Navigation bar at bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: CandyNavigationBar(
              onNavTap: widget.onNavTap ?? (index) {},
            ),
          ),
        ],
      ),
    );
  }
}
