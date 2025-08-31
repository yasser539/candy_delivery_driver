import 'package:flutter/material.dart';
import '../../core/design_system/design_system.dart';
// removed unused imports

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? DesignSystem.darkBackground : DesignSystem.background,
        body: SafeArea(
          child: Stack(
            children: [
              // ========== Placeholder UI ==========
              Positioned.fill(
                child: Container(
                  color: isDark
                      ? DesignSystem.darkBackground
                      : DesignSystem.background,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
            _gradientIcon(Icons.map,
              size: 80, gradient: DesignSystem.primaryGradient),
                        const SizedBox(height: 14),
                        Text('تتبع الطلب',
                            style: DesignSystem.headlineMedium.copyWith(
                              color: isDark ? Colors.white : DesignSystem.textPrimary,
                              fontWeight: FontWeight.bold,
                            )),
                        const SizedBox(height: 6),
                        Text('سيتم إضافة التتبع هنا قريباً',
                            style: DesignSystem.bodyMedium.copyWith(
                              color: isDark ? Colors.white : DesignSystem.textSecondary,
                            )),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark
                                ? DesignSystem.darkSurface
                                : DesignSystem.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: DesignSystem.getBrandShadow('light'),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.location_on,
                                  color: DesignSystem.success, size: 18),
                              const SizedBox(width: 6),
                              Text('موقعك الحالي',
                                  style: DesignSystem.labelMedium.copyWith(
                                      color: DesignSystem.success,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

      // Simple top-right title
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Align(
                  alignment: Alignment.topRight,
                  child: Text(
        'تتبع الطلب',
                    style: DesignSystem.headlineLarge.copyWith(
                      color: isDark
                          ? DesignSystem.textInverse
                          : DesignSystem.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              // Header removed per request (no gradient, no location icon, no online chip)

              // ========== Floating Controls ==========
              Positioned(
                bottom: 100,
                right: 16,
                child: Column(
                  children: [
                    _mapActionButton(
                      icon: Icons.my_location,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('تم تحديد موقعك'),
                              duration: Duration(seconds: 2)),
                        );
                      },
                      backgroundGradient: DesignSystem.primaryGradient,
                      iconColor: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    _mapActionButton(
                      icon: Icons.add,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('تم تكبير الخريطة'),
                              duration: Duration(seconds: 1)),
                        );
                      },
                      color: isDark
                          ? DesignSystem.darkSurface
                          : DesignSystem.surface,
                      iconGradient: DesignSystem.primaryGradient,
                    ),
                    const SizedBox(height: 16),
                    _mapActionButton(
                      icon: Icons.remove,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('تم تصغير الخريطة'),
                              duration: Duration(seconds: 1)),
                        );
                      },
                      color: isDark
                          ? DesignSystem.darkSurface
                          : DesignSystem.surface,
                      iconGradient: DesignSystem.primaryGradient,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mapActionButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
    Color? iconColor,
    Gradient? backgroundGradient,
    Gradient? iconGradient,
  }) {
    return Material(
      shape: const CircleBorder(),
      color: Colors.transparent,
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: backgroundGradient,
            color: backgroundGradient == null
                ? (color ?? DesignSystem.surface)
                : null,
          ),
          child: Center(
            child: iconGradient != null
                ? ShaderMask(
                    shaderCallback: (Rect bounds) => iconGradient.createShader(
                      Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                    ),
                    blendMode: BlendMode.srcIn,
                    child: Icon(icon, size: 24),
                  )
                : Icon(
                    icon,
                    color: iconColor ?? DesignSystem.primary,
                    size: 24,
                  ),
          ),
        ),
      ),
    );
  }

  // Helper to render a gradient icon for placeholder header
  Widget _gradientIcon(IconData icon, {Gradient? gradient, double size = 24}) {
    final g = gradient ?? DesignSystem.primaryGradient;
    return ShaderMask(
      shaderCallback: (Rect bounds) => g.createShader(
        Rect.fromLTWH(0, 0, size, size),
      ),
      blendMode: BlendMode.srcIn,
      child: Icon(icon, size: size),
    );
  }
}
