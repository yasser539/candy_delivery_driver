import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../core/design_system/design_system.dart';
import '../core/design_system/platform_ui_standards.dart';
import '../models/order.dart';
import 'currency_icon.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final bool isActive;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final Function(OrderStatus)? onUpdateStatus;
  final VoidCallback? onCallCustomer;
  final VoidCallback? onNavigate;

  const OrderCard({
    super.key,
    required this.order,
    required this.isActive,
    this.onAccept,
    this.onReject,
    this.onUpdateStatus,
    this.onCallCustomer,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ أسود في الوضع الفاتح / نص داكن مناسب في الوضع الداكن
    final Color textColor = isDark
        ? DesignSystem.darkTextPrimary
        : Colors.black;

    // لون نص شارة الحالة: أسود في الفاتح حسب طلبك، وملوّن في الداكن
    final Color statusTextColor = isDark ? _getStatusColor() : Colors.black;

    return Container(
      padding: PlatformUIStandards.paddingM,
      decoration: BoxDecoration(
        color: isDark ? DesignSystem.darkSurface : DesignSystem.surface,
        borderRadius: BorderRadius.circular(PlatformUIStandards.cardRadius),
        boxShadow: DesignSystem.getBrandShadow('light'),
      ),
      child: DefaultTextStyle.merge(
        style: DesignSystem.bodySmall.copyWith(color: textColor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: PlatformUIStandards.spacingS,
                    vertical: PlatformUIStandards.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      PlatformUIStandards.smallRadius,
                    ),
                  ),
                  child: Text(
                    order.statusText,
                    style: DesignSystem.labelSmall.copyWith(
                      color: statusTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'طلب #${order.id}',
                  style: DesignSystem.bodySmall.copyWith(color: textColor),
                ),
              ],
            ),
            SizedBox(height: PlatformUIStandards.spacingS),

            // Customer info
            Row(
              children: [
                // User icon
                ShaderMask(
                  shaderCallback: (bounds) => DesignSystem.getBrandGradient(
                    'primary',
                  ).createShader(bounds),
                  child: const FaIcon(
                    FontAwesomeIcons.user,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.customerName,
                    style: DesignSystem.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Phone number row with gradient phone icon and right-aligned number
            Row(
              children: [
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: onCallCustomer,
                          child: ShaderMask(
                            shaderCallback: (bounds) =>
                                DesignSystem.getBrandGradient(
                                  'primary',
                                ).createShader(bounds),
                            child: const FaIcon(
                              FontAwesomeIcons.phone,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            order.customerPhone,
                            style: DesignSystem.bodySmall.copyWith(
                              color: textColor,
                            ),
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Products row
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      'المنتجات: ${order.productDescription ?? ''}',
                      style: DesignSystem.bodySmall.copyWith(color: textColor),
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ShaderMask(
                    shaderCallback: (bounds) => DesignSystem.getBrandGradient(
                      'primary',
                    ).createShader(bounds),
                    child: const FaIcon(
                      FontAwesomeIcons.boxOpen,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Order details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? DesignSystem.darkSurface : DesignSystem.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تفاصيل الطلب:',
                    style: DesignSystem.labelMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    order.productDescription ?? 'لا توجد تفاصيل',
                    style: DesignSystem.bodySmall.copyWith(color: textColor),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'المبلغ: ',
                        style: DesignSystem.bodySmall.copyWith(
                          color: textColor,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${order.amount} ',
                            style: DesignSystem.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: DesignSystem.primary,
                            ),
                          ),
                          CurrencyIcon(
                            width: 16,
                            height: 16,
                            color: DesignSystem.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Action buttons
            if (!isActive) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onAccept,
                      icon: const FaIcon(FontAwesomeIcons.check, size: 16),
                      label: const Text('قبول الطلب'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignSystem.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onReject,
                      icon: const FaIcon(FontAwesomeIcons.xmark, size: 16),
                      label: Text('رفض', style: TextStyle(color: textColor)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: DesignSystem.error,
                        side: BorderSide(color: DesignSystem.error),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onCallCustomer,
                      icon: ShaderMask(
                        shaderCallback: (bounds) =>
                            DesignSystem.getBrandGradient(
                              'primary',
                            ).createShader(bounds),
                        child: const FaIcon(
                          FontAwesomeIcons.phone,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      label: const Text('اتصال'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignSystem.info,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onNavigate,
                      icon: const FaIcon(
                        FontAwesomeIcons.locationArrow,
                        size: 16,
                      ),
                      label: const Text('تتبع'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignSystem.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (order.status == OrderStatus.pending) ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            onUpdateStatus?.call(OrderStatus.onTheWay),
                        icon: const FaIcon(FontAwesomeIcons.truck, size: 16),
                        label: const Text('في الطريق إليك'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DesignSystem.warning,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else if (order.status == OrderStatus.onTheWay) ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            onUpdateStatus?.call(OrderStatus.delivered),
                        icon: const FaIcon(
                          FontAwesomeIcons.checkCircle,
                          size: 16,
                        ),
                        label: const Text('تم التوصيل'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DesignSystem.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (order.status) {
      case OrderStatus.underReview:
        return DesignSystem.warning;
      case OrderStatus.approvedSearching:
        return DesignSystem.info;
      case OrderStatus.pending:
        return DesignSystem.primary;
      case OrderStatus.onTheWay:
        return DesignSystem.warning;
      case OrderStatus.delivered:
        return DesignSystem.success;
      case OrderStatus.cancelled:
        return DesignSystem.error;
      case OrderStatus.failed:
        return DesignSystem.error;
    }
  }
}
