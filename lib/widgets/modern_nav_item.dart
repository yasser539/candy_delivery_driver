import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../core/design_system/design_system.dart';

class ModernNavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final int? badge;
  final bool isHome;
  final double labelFontSize;

  const ModernNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.badge,
    this.isHome = false,
    this.labelFontSize = 10,
  });

  @override
  State<ModernNavItem> createState() => _ModernNavItemState();
}

class _ModernNavItemState extends State<ModernNavItem> {
  bool _pressed = false;

  void _handleTapDown(TapDownDetails _) {
    setState(() => _pressed = true);
  }

  void _handleTapCancel() {
    setState(() => _pressed = false);
  }

  void _handleTapUp(TapUpDetails _) {
    setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color inactiveColor = isDark ? Colors.white70 : Colors.grey.shade600;

    final bool showGradient = !widget.isHome && (widget.isActive || _pressed);

    Widget nonHomeIcon() {
      final baseIcon = FaIcon(widget.icon, size: 20, color: Colors.white);
      if (showGradient) {
        return AnimatedScale(
          scale: widget.isActive || _pressed ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          child: SizedBox(
    width: 20,
    height: 20,
            child: ShaderMask(
              shaderCallback: (Rect bounds) =>
                  DesignSystem.primaryGradient.createShader(bounds),
              blendMode: BlendMode.srcIn,
        child: baseIcon,
            ),
          ),
        );
      }
      return FaIcon(widget.icon, color: inactiveColor, size: 20);
    }

    return RepaintBoundary(
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: _handleTapDown,
        onTapCancel: _handleTapCancel,
        onTapUp: _handleTapUp,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  if (widget.isHome)
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
                  widget.isHome
                      ? Container(
                          width: 56,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: DesignSystem.primaryGradient,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: AnimatedScale(
                              scale: widget.isActive ? 1.05 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOutCubic,
                              child: FaIcon(widget.icon, color: Colors.white, size: 20),
                            ),
                          ),
                        )
                      : nonHomeIcon(),
                  if (widget.badge != null && widget.badge! > 0)
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
                          widget.badge.toString(),
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
              // Keep label logic; we can extend to gradient on dark later if needed
              if (widget.isActive && !isDark)
                ShaderMask(
                  shaderCallback: (Rect bounds) =>
                      DesignSystem.primaryGradient.createShader(bounds),
                  blendMode: BlendMode.srcIn,
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: widget.labelFontSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                Text(
                  widget.label,
                  style: TextStyle(
                    color: isDark
                        ? Colors.white
                        : (widget.isActive
                            ? DesignSystem.primary
                            : inactiveColor),
                    fontSize: widget.labelFontSize,
                    fontWeight:
                        widget.isActive ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
