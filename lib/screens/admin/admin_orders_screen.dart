import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/design_system/design_system.dart';
import '../../core/services/order_service.dart';
import '../../models/order.dart';
// currency_icon removed — amounts displayed as plain text now
import '../../widgets/modern_app_bar.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  late OrderService _orderService;
  List<Order> _pendingReviewOrders = [];
  StreamSubscription? _adminOrdersSubscription;

  @override
  void initState() {
    super.initState();
    _initializeOrderService();
  }

  void _initializeOrderService() {
    // Get OrderService from Provider
    _orderService = Provider.of<OrderService>(context, listen: false);

    // Initialize with admin role if not already initialized
    if (_orderService.getAdminOrders().isEmpty) {
      _orderService.initialize('admin_001');
    }

    _adminOrdersSubscription = _orderService.adminOrdersStream.listen((orders) {
      if (mounted) {
        setState(() {
          _pendingReviewOrders = orders;
        });
      }
    });
  }

  @override
  void dispose() {
    _adminOrdersSubscription?.cancel();
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
        bottomNavigationBar:
            const SizedBox(height: 100), // إضافة مساحة للناف بار
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
              Text('المبلغ: ${order.amount}'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _approveOrder(order),
                  child: Text('موافقة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignSystem.success,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _rejectOrder(order),
                  child: Text('رفض'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DesignSystem.error,
                    side: BorderSide(color: DesignSystem.error),
                  ),
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
    final success = await _orderService.approveOrder(order.id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تمت الموافقة على الطلب #${order.id}'),
          backgroundColor: DesignSystem.success,
        ),
      );
    }
  }

  void _rejectOrder(Order order) async {
    final success =
        await _orderService.updateOrderStatus(order.id, OrderStatus.cancelled);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم رفض الطلب #${order.id}'),
          backgroundColor: DesignSystem.error,
        ),
      );
    }
  }
}
