import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../core/design_system/design_system.dart';
import '../core/design_system/platform_ui_standards.dart';
import '../models/cart.dart';
import 'currency_icon.dart';

class CartCard extends StatelessWidget {
  final Cart cart;
  final bool isActive;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final Function(CartStatus)? onUpdateStatus;
  final VoidCallback? onCallCustomer;
  final VoidCallback? onNavigate;

  const CartCard({
    super.key,
    required this.cart,
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
                  cart.statusText,
                  style: DesignSystem.labelSmall.copyWith(
                    color: _getStatusColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'طلب #${cart.id.substring(0, 8)}',
                style: DesignSystem.bodySmall.copyWith(
                  color: DesignSystem.textSecondary,
                ),
              ),
            ],
          ),

          // زيادة الفراغ بين رقم الطلب ومعلومات العميل
          const SizedBox(height: 64),

          // Customer info
          if (cart.customerName != null) ...[
            Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.user,
                  color: DesignSystem.primary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    cart.customerName!,
                    style: DesignSystem.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
          if (cart.customerPhone != null) ...[
            Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.phone,
                  color: DesignSystem.primary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    cart.customerPhone!,
                    style: DesignSystem.bodySmall.copyWith(
                      color: DesignSystem.textSecondary,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 29),
          ],

          // Cart items
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
                  'المنتجات:',
                  style: DesignSystem.labelMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 8),
                if (cart.items.isEmpty)
                  Text(
                    'لا توجد منتجات',
                    style: DesignSystem.bodySmall.copyWith(
                      color: DesignSystem.textSecondary,
                    ),
                    textAlign: TextAlign.right,
                  )
                else
                  ...cart.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${item.productName} (${item.quantity})',
                              style: DesignSystem.bodySmall,
                              textAlign: TextAlign.right,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${item.totalPrice} ',
                            style: DesignSystem.bodySmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: DesignSystem.primary,
                            ),
                          ),
                          CurrencyIcon(
                            width: 12,
                            height: 12,
                            color: DesignSystem.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'المجموع: ',
                      style: DesignSystem.bodySmall.copyWith(
                        color: DesignSystem.textSecondary,
                      ),
                    ),
                    // Total icon next to the total text
                    FaIcon(
                      FontAwesomeIcons.calculator,
                      size: 12,
                      color: DesignSystem.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${cart.totalAmount} ',
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
            // Available cart actions
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
                    label: const Text('رفض'),
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
            // Active cart actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onCallCustomer,
                    icon: const FaIcon(FontAwesomeIcons.phone, size: 16),
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

            // Status update buttons
            if (cart.status == CartStatus.assigned) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          onUpdateStatus?.call(CartStatus.onTheWay),
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
            ] else if (cart.status == CartStatus.onTheWay) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          onUpdateStatus?.call(CartStatus.delivered),
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
    );
  }

  Color _getStatusColor() {
    switch (cart.status) {
      case CartStatus.pending:
        return DesignSystem.info;
      case CartStatus.assigned:
        return DesignSystem.primary;
      case CartStatus.onTheWay:
        return DesignSystem.warning;
      case CartStatus.delivered:
        return DesignSystem.success;
      case CartStatus.cancelled:
        return DesignSystem.error;
    }
  }
}
