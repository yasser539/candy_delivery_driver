import 'package:flutter/material.dart';
// provider and app-bloc removed (no backend)
import '../core/design_system/design_system.dart';
import 'candy_navigation_bar.dart';

class NavigationWrapper extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? DesignSystem.darkBackground
          : DesignSystem.background,
      body: Stack(
        children: [
          // Main content
          child,

          // Navigation bar at bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: CandyNavigationBar(onNavTap: onNavTap ?? (index) {}),
          ),
        ],
      ),
    );
  }
}
