import 'package:flutter/material.dart';
import '../core/design_system/design_system.dart';

class ModernNavItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
                  if (badge != null && badge! > 0)
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
        // Selected label uses gradient in light mode; in dark mode use solid white
        if (isActive && !isDark)
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return DesignSystem.primaryGradient.createShader(bounds);
                  },
                  blendMode: BlendMode.srcIn,
                  child: Text(
                    label,
                    style: TextStyle(
                      // White text becomes the mask for the gradient
                      color: Colors.white,
                      fontSize: labelFontSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                Text(
                  label,
                  style: TextStyle(
          color: isDark
            ? Colors.white
            : (isActive ? DesignSystem.primary : inactiveColor),
                    fontSize: labelFontSize,
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
