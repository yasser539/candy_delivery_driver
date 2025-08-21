import 'package:flutter/material.dart';
import '../core/design_system/design_system.dart';
import 'package:provider/provider.dart';
import '../blocs/app_bloc.dart';
import 'dart:ui';

class CandyNavigationBar extends StatefulWidget {
  const CandyNavigationBar({super.key});

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
    final appBloc = Provider.of<AppBloc>(context);
    final isDark = appBloc.isDarkMode;

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
                            icon: Icons.person,
                            label: 'حسابي',
                            isActive: appBloc.currentIndex == 0,
                            onTap: () => appBloc.setCurrentIndex(0),
                          ),
                          _buildModernNavItem(
                            icon: Icons.map,
                            label: 'الخريطة',
                            isActive: appBloc.currentIndex == 1,
                            onTap: () => appBloc.setCurrentIndex(1),
                          ),
                          _buildModernNavItem(
                            icon: Icons.home,
                            label: 'الرئيسية',
                            isActive: appBloc.currentIndex == 2,
                            onTap: () => appBloc.setCurrentIndex(2),
                            isHome: true,
                          ),
                          _buildModernNavItem(
                            icon: Icons.local_shipping,
                            label: 'الطلبات',
                            isActive: appBloc.currentIndex == 3,
                            onTap: () => appBloc.setCurrentIndex(3),
                            badge: appBloc.pendingOrdersCount > 0
                                ? appBloc.pendingOrdersCount
                                : null,
                          ),
                          _buildModernNavItem(
                            icon: Icons.settings,
                            label: 'الإعدادات',
                            isActive: appBloc.currentIndex == 4,
                            onTap: () => appBloc.setCurrentIndex(4),
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
                              child: ShaderMask(
                                shaderCallback: (Rect bounds) {
                                  return DesignSystem.primaryGradient
                                      .createShader(bounds);
                                },
                                blendMode: BlendMode.srcIn,
                                child:
                                    Icon(icon, color: Colors.white, size: 20),
                              ),
                            )
                          : AnimatedScale(
                              scale: isActive ? 1.05 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOutCubic,
                              child: Icon(
                                icon,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[500]
                                    : Colors.grey[600],
                                size: 24,
                              ),
                            ),
                  if (badge != null)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red[500],
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red[500]!.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Center(
                          child: Text(
                            badge.toString(),
                            style: const TextStyle(
                              fontFamily: 'Rubik',
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 10,
                  color: isActive
                      ? DesignSystem.primary
                      : Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[500]
                          : Colors.grey[600],
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
