import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../core/design_system/design_system.dart';
import 'currency_icon.dart';

class EarningsCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final Color color;
  final bool isDark;
  final bool showCurrencyIcon;

  const EarningsCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    required this.isDark,
    this.showCurrencyIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkTheme ? DesignSystem.darkSurface : DesignSystem.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: FaIcon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: DesignSystem.bodyMedium.copyWith(
                    color: isDarkTheme
                        ? Colors.white
                        : DesignSystem.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                showCurrencyIcon
                    ? Row(
                        children: [
                          Text(
                            amount,
                            style: DesignSystem.titleLarge.copyWith(
                              color: isDarkTheme
                                  ? Colors.white
                                  : DesignSystem.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          CurrencyIcon(
                            width: 20,
                            height: 20,
                            color: isDarkTheme
                                ? Colors.white
                                : DesignSystem.textPrimary,
                          ),
                        ],
                      )
                    : Text(
                        amount,
                        style: DesignSystem.titleLarge.copyWith(
                          color: isDarkTheme
                              ? Colors.white
                              : DesignSystem.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
