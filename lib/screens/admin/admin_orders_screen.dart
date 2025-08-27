import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/design_system/design_system.dart';
import '../../models/order.dart';
import '../../models/location.dart';
import '../../widgets/currency_icon.dart';
import '../../widgets/modern_app_bar.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  // Local mock orders for admin review (no backend)
  List<Order> _pendingReviewOrders = [
    Order(
      id: 'admin-mock-001',
      customerName: 'محمد صالح',
      customerPhone: '+966500000001',
      pickupLocation: Location(
        latitude: 24.71,
        longitude: 46.67,
        address: 'الرياض',
        timestamp: DateTime.now(),
      ),
      deliveryLocation: Location(
        latitude: 24.72,
        longitude: 46.68,
        address: 'التحلية',
        timestamp: DateTime.now(),
      ),
      amount: 30.0,
      paymentMethod: PaymentMethod.cash,
      status: OrderStatus.underReview,
      createdAt: DateTime.now(),
    ),
  ];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? DesignSystem.darkBackground
            : DesignSystem.background,
        appBar: ModernAppBar(title: 'إدارة الطلبات'),
        body: _pendingReviewOrders.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _pendingReviewOrders.length,
                itemBuilder: (context, index) {
                  final order = _pendingReviewOrders[index];
                  return _buildOrderCard(order);
                },
              ),
        bottomNavigationBar: const SizedBox(
          height: 100,
        ), // إضافة مساحة للناف بار
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
              Text(
                'طلب #${order.id}',
                style: DesignSystem.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: DesignSystem.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.statusText,
                  style: DesignSystem.labelSmall.copyWith(
                    color: DesignSystem.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('العميل: ${order.customerName}'),
          Text('الهاتف: ${order.customerPhone}'),
          Row(
            children: [
              Text('المبلغ: ${order.amount} '),
              CurrencyIcon(width: 16, height: 16, color: DesignSystem.primary),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _approveOrder(order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignSystem.success,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('موافقة'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _rejectOrder(order),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DesignSystem.error,
                    side: BorderSide(color: DesignSystem.error),
                  ),
                  child: Text('رفض'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.checkCircle,
            size: 64,
            color: DesignSystem.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد طلبات قيد المراجعة',
            style: DesignSystem.bodyLarge.copyWith(
              color: DesignSystem.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _approveOrder(Order order) async {
    // Mock approve: remove from pending list and show feedback
    if (!mounted) return;
    setState(() => _pendingReviewOrders.removeWhere((o) => o.id == order.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تمت الموافقة على الطلب #${order.id} (Mock)'),
        backgroundColor: DesignSystem.success,
      ),
    );
  }

  void _rejectOrder(Order order) async {
    // Mock reject: remove from pending list and show feedback
    if (!mounted) return;
    setState(() => _pendingReviewOrders.removeWhere((o) => o.id == order.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم رفض الطلب #${order.id} (Mock)'),
        backgroundColor: DesignSystem.error,
      ),
    );
  }
}
