import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    return Container(
      padding: PlatformUIStandards.paddingM,
      decoration: BoxDecoration(
        color: DesignSystem.surface,
        borderRadius: BorderRadius.circular(PlatformUIStandards.cardRadius),
        boxShadow: DesignSystem.getBrandShadow('light'),
      ),
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
                    color: _getStatusColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'طلب #${order.id}',
                style: DesignSystem.bodySmall.copyWith(
                  color: DesignSystem.getPlatformTextColor(context),
                ),
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
                child: FaIcon(
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
                    color: DesignSystem.getPlatformTextColor(context),
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
                  // Force RTL so the icon appears at the rightmost side
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
                          child: FaIcon(
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
                            color: DesignSystem.getPlatformTextColor(context),
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

          // Products row with product text on the right and icon next to it
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    'المنتجات: ${order.productDescription ?? ''}',
                    style: DesignSystem.bodySmall.copyWith(
                      color: DesignSystem.getPlatformTextColor(context),
                    ),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                ShaderMask(
                  shaderCallback: (bounds) => DesignSystem.getBrandGradient(
                    'primary',
                  ).createShader(bounds),
                  child: FaIcon(
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
                    color: DesignSystem.getPlatformTextColor(context),
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 8),
                Text(
                  order.productDescription ?? 'لا توجد تفاصيل',
                  style: DesignSystem.bodySmall.copyWith(
                    color: DesignSystem.getPlatformTextColor(context),
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'المبلغ: ',
                      style: DesignSystem.bodySmall.copyWith(
                        color: DesignSystem.getPlatformTextColor(context),
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
            // Available order actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onAccept,
                    icon: FaIcon(FontAwesomeIcons.check, size: 16),
                    label: Text('قبول الطلب'),
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
                    icon: FaIcon(FontAwesomeIcons.xmark, size: 16),
                    label: Text('رفض'),
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
            // Active order actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onCallCustomer,
                    icon: ShaderMask(
                      shaderCallback: (bounds) => DesignSystem.getBrandGradient(
                        'primary',
                      ).createShader(bounds),
                      child: FaIcon(
                        FontAwesomeIcons.phone,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    label: Text('اتصال'),
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
                    icon: FaIcon(FontAwesomeIcons.locationArrow, size: 16),
                    label: Text('خريطة'),
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

            // Status update buttons
            if (order.status == OrderStatus.pending) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          onUpdateStatus?.call(OrderStatus.onTheWay),
                      icon: FaIcon(FontAwesomeIcons.truck, size: 16),
                      label: Text('في الطريق إليك'),
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
                      icon: FaIcon(FontAwesomeIcons.checkCircle, size: 16),
                      label: Text('تم التوصيل'),
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
