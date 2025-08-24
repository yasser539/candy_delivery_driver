import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../blocs/app_bloc.dart';
import '../../core/design_system/design_system.dart';
// removed unused app_colors import
import 'dart:ui';

class CandyNavigationBar extends StatefulWidget {
  final Function(int) onNavTap;

  const CandyNavigationBar({super.key, required this.onNavTap});

  @override
  State<CandyNavigationBar> createState() => _CandyNavigationBarState();
}

class _CandyNavigationBarState extends State<CandyNavigationBar>
    with TickerProviderStateMixin {
  // Remove fancy animations for a simpler, more native feel

  // Swipe detection
  // removed unused _dragStartX
  double _dragDistance = 0.0;
  static const double _swipeThreshold = 50.0;

  @override
  void initState() {
    super.initState();
    // No-op
  }

  @override
  void dispose() {
    // Nothing to dispose
    super.dispose();
  }

  void _onNavTap(int index) {
    widget.onNavTap(index);
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
        widget.onNavTap(newIndex);
      }
    }

    setState(() {
      _dragDistance = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppBloc>(
      builder: (context, appBloc, child) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onHorizontalDragUpdate: _handleSwipe,
            onHorizontalDragEnd: _handleSwipeEnd,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16, left: 12, right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xCC1E293B)
                    : const Color(0xCCFFFFFF),
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
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
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
                          isActive: appBloc.currentIndex == 0,
                          onTap: () => _onNavTap(0),
                        ),
                        _buildModernNavItem(
                          icon: FontAwesomeIcons.mapLocationDot,
                          label: 'الخريطة',
                          isActive: appBloc.currentIndex == 1,
                          onTap: () => _onNavTap(1),
                        ),
                        _buildModernNavItem(
                          icon: FontAwesomeIcons.house,
                          label: 'الرئيسية',
                          isActive: appBloc.currentIndex == 2,
                          onTap: () => _onNavTap(2),
                          isHome: true,
                        ),
                        _buildModernNavItem(
                          icon: FontAwesomeIcons.truck,
                          label: 'الطلبات',
                          isActive: appBloc.currentIndex == 3,
                          onTap: () => _onNavTap(3),
                          badge: appBloc.pendingOrdersCount > 0
                              ? appBloc.pendingOrdersCount
                              : null,
                        ),
                        _buildModernNavItem(
                          icon: FontAwesomeIcons.gear,
                          label: 'الإعدادات',
                          isActive: appBloc.currentIndex == 4,
                          onTap: () => _onNavTap(4),
                        ),
                      ],
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
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  if (isHome)
                    Container(
                      width: 56,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: DesignSystem.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: DesignSystem.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
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
                            child: FaIcon(icon, color: Colors.white, size: 20),
                          ),
                        )
                      : isActive
                      ? ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return DesignSystem.primaryGradient.createShader(
                              bounds,
                            );
                          },
                          blendMode: BlendMode.srcIn,
                          child: FaIcon(icon, color: Colors.white, size: 20),
                        )
                      : FaIcon(
                          icon,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[500]
                              : Colors.grey[600],
                          size: 24,
                        ),
                  if (badge != null)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.elasticOut,
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
                          child: AnimatedScale(
                            scale: 1.0,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.elasticOut,
                            child: Text(
                              badge.toString(),
                              style: DesignSystem.labelSmall.copyWith(
                                fontFamily: 'Rubik',
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
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
                style: DesignSystem.labelSmall.copyWith(
                  fontFamily: 'Rubik',
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
