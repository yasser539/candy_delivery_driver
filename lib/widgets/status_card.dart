import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../core/design_system/design_system.dart';

class StatusCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const StatusCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? DesignSystem.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: FaIcon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Text(
                  count.toString(),
                  style: DesignSystem.headlineSmall.copyWith(
                    color: isDark ? Colors.white : DesignSystem.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: DesignSystem.titleMedium.copyWith(
                color: isDark ? Colors.white : DesignSystem.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getSubtitle(),
              style: DesignSystem.bodySmall.copyWith(
                color: isDark ? Colors.white : DesignSystem.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSubtitle() {
    switch (title) {
      case 'الطلبات الجديدة':
        return 'في انتظار القبول';
      case 'الطلبات النشطة':
        return 'قيد التوصيل';
      case 'التوصيلات المكتملة':
        return 'تم التسليم';
      case 'التوصيلات الملغية':
        return 'تم الإلغاء';
      default:
        return 'إجمالي الطلبات';
    }
  }
}
