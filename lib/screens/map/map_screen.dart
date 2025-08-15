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
                        Icon(Icons.map,
                            size: 80, color: DesignSystem.primary),
                        const SizedBox(height: 14),
                        Text('خريطة توصيل الماء',
                            style: DesignSystem.headlineMedium.copyWith(
                              color: DesignSystem.textPrimary,
                              fontWeight: FontWeight.bold,
                            )),
                        const SizedBox(height: 6),
                        Text('سيتم إضافة الخريطة هنا قريباً',
                            style: DesignSystem.bodyMedium.copyWith(
                              color: DesignSystem.textSecondary,
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

              // ========== Header Card ==========
              Positioned(
                top: 20,
                left: 16,
                right: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: DesignSystem.primaryGradient,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: DesignSystem.primary.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.white, size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'خريطة توصيل الماء',
                          style: DesignSystem.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('متصل',
                            style: DesignSystem.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
              ),

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
                      color: DesignSystem.primary,
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
                      iconColor: DesignSystem.primary,
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
                      iconColor: DesignSystem.primary,
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
  }) {
    return Material(
      shape: const CircleBorder(),
      color: color ?? DesignSystem.surface,
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(icon, color: iconColor ?? DesignSystem.primary, size: 24),
        ),
      ),
    );
  }
}
