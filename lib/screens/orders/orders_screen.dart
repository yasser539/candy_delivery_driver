// lib/screens/orders/orders_screen.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/design_system/design_system.dart';
import '../../widgets/live_order_card.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with AutomaticKeepAliveClientMixin {
  bool _isRefreshing = false;

  @override
  bool get wantKeepAlive => false; // Disable keep alive for better performance

  // Single order for maximum performance while keeping your exact design
  static final List<Map<String, dynamic>> _mockOrders = [
    {
      'id': '100231',
      'items': ['مياه معدنية 1.5 لتر'],
      'step': 1,
      'status': 'قيد الانتظار',
      'statusColor': Colors.blue,
      'customerName': 'أحمد محمد',
      'customerPhone': '+966501234567',
    },
  ];

  Future<void> _refresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 150)); // Minimal delay
    if (!mounted) return;
    setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark
            ? DesignSystem.darkBackground
            : DesignSystem.background,
        appBar: AppBar(title: const Text('الطلبات'), centerTitle: true),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refresh,
            color: DesignSystem.primary,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _mockOrders.length,
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: false,
              cacheExtent: 500,
              physics: const ClampingScrollPhysics(),
              itemBuilder: (context, index) {
                final order = _mockOrders[index];
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < _mockOrders.length - 1 ? 12 : 0,
                  ),
                  child: RepaintBoundary(child: LiveOrderCard(order: order)),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// Removed _LightweightOrderCard - keeping your exact LiveOrderCard design
