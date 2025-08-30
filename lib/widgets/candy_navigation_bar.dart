import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../core/design_system/design_system.dart';
import 'dart:ui';

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
              child: Container(
                margin: const EdgeInsets.only(
                  bottom: 16,
                  left: 12,
                  right: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: isDark
                        ? [
                            Colors.black.withOpacity(0.6),
                            Colors.black.withOpacity(0.95),
                            Colors.black.withOpacity(0.95),
                            Colors.black.withOpacity(0.6),
                          ]
                        : [
                            Colors.white.withOpacity(0.7),
                            Colors.white.withOpacity(1.0),
                            Colors.white.withOpacity(1.0),
                            Colors.white.withOpacity(0.7),
                          ],
                    stops: const [0.0, 0.3, 0.7, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 1,
                      offset: const Offset(0, -1),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 1,
                      offset: const Offset(0, 1),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 1,
                      offset: const Offset(-1, 0),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 1,
                      offset: const Offset(1, 0),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(-3, 0),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(3, 0),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildModernNavItem(
                            icon: FontAwesomeIcons.user,
                            label: 'حسابي',
                            isActive: false,
                            onTap: () => widget.onNavTap?.call(0),
                          ),
                          _buildModernNavItem(
                            icon: FontAwesomeIcons.mapLocationDot,
                            label: 'الخريطة',
                            isActive: false,
                            onTap: () => widget.onNavTap?.call(1),
                          ),
                          _buildModernNavItem(
                            icon: FontAwesomeIcons.house,
                            label: 'الرئيسية',
                            isActive: true,
                            onTap: () => widget.onNavTap?.call(2),
                            isHome: true,
                          ),
                          _buildModernNavItem(
                            icon: FontAwesomeIcons.truck,
                            label: 'الطلبات',
                            isActive: false,
                            onTap: () => widget.onNavTap?.call(3),
                          ),
                          _buildModernNavItem(
                            icon: FontAwesomeIcons.gear,
                            label: 'الإعدادات',
                            isActive: false,
                            onTap: () => widget.onNavTap?.call(4),
                          ),
                        ],
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

  Widget _buildModernNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    int? badge,
    bool isHome = false,
  }) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final Color inactiveColor = isDark
      ? DesignSystem.textInverse
      : Colors.grey.shade600;
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  if (isHome)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      width: 56,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: DesignSystem.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
          isHome
            ? Container(
                          width: 56,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: DesignSystem.primaryGradient,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: AnimatedScale(
                              scale: isActive ? 1.05 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOutCubic,
                child: Icon(icon, color: Colors.white, size: 20),
                            ),
                          ),
                        )
            : isActive
              ? AnimatedScale(
                scale: isActive ? 1.05 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                child: isDark
                  ? Icon(icon, color: Colors.white, size: 20)
                  : ShaderMask(
                    shaderCallback: (Rect bounds) {
                    return DesignSystem.primaryGradient
                      .createShader(bounds);
                    },
                    blendMode: BlendMode.srcIn,
                    child: Icon(icon, size: 20),
                  ),
              )
                          : Icon(
                              icon,
                              color: inactiveColor,
                              size: 20,
                            ),
                  if (badge != null && badge > 0)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: DesignSystem.error,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          badge.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? DesignSystem.primary : inactiveColor,
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
