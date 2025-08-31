import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:ui';
import 'modern_nav_item.dart';

class CandyNavigationBar extends StatefulWidget {
  final Function(int)? onNavTap;
  
  const CandyNavigationBar({super.key, this.onNavTap});

  @override
  State<CandyNavigationBar> createState() => _CandyNavigationBarState();
}

class _CandyNavigationBarState extends State<CandyNavigationBar>
    with TickerProviderStateMixin {
  late AnimationController _slideAnimationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOutCubic,
    );
    _slideAnimationController.forward();
  }

  @override
  void dispose() {
    _slideAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _slideAnimation.value)),
          child: Opacity(
            opacity: _slideAnimation.value,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                top: false,
                left: false,
                right: false,
                bottom: false,
                // No extra bottom inset to avoid a visible strip under the bar
                minimum: EdgeInsets.zero,
                child: Container(
                  margin: const EdgeInsets.only(
                    bottom: 12,
                    left: 12,
                    right: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                      child: Container(
                        decoration: BoxDecoration(
                          // Dark mode: light-black via semi-transparent white to lift off pitch black
                          color: isDark
                              ? Colors.white.withOpacity(0.10)
                              : Colors.white.withOpacity(0.62),
                          borderRadius: BorderRadius.circular(32),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ModernNavItem(
                              icon: FontAwesomeIcons.user,
                              label: 'حسابي',
                              isActive: false,
                              onTap: () => widget.onNavTap?.call(0),
                            ),
                            ModernNavItem(
                              icon: FontAwesomeIcons.mapLocationDot,
                              label: 'الخريطة',
                              isActive: false,
                              onTap: () => widget.onNavTap?.call(1),
                            ),
                            ModernNavItem(
                              icon: FontAwesomeIcons.house,
                              label: 'الرئيسية',
                              isActive: true,
                              onTap: () => widget.onNavTap?.call(2),
                              isHome: true,
                            ),
                            ModernNavItem(
                              icon: FontAwesomeIcons.truck,
                              label: 'الطلبات',
                              isActive: false,
                              onTap: () => widget.onNavTap?.call(3),
                            ),
                            ModernNavItem(
                              icon: FontAwesomeIcons.gear,
                              label: 'الإعدادات',
                              isActive: false,
                              onTap: () => widget.onNavTap?.call(4),
                              labelFontSize: 9,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}