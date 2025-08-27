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
  // Simplified without backend dependencies
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
    // Simplified swipe handling - no backend state management
    setState(() {
      _dragDistance = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

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
                onNavTap: widget.onNavTap ?? (index) {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
