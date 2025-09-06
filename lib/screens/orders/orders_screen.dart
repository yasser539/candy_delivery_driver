// lib/screens/orders/orders_screen.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/design_system/design_system.dart';
import '../../widgets/live_order_card.dart';
import '../map/map_screen.dart';
import '../../data/repositories/orders_repository.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with AutomaticKeepAliveClientMixin {
  final _repo = OrdersRepository();
  List<Map<String, dynamic>> _orders = const [];
  bool _loading = true;
  String? _error;
  @override
  bool get wantKeepAlive => true; // Keep alive to avoid rebuild jank when switching tabs

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _repo.getMyAssignedOrders(limit: 50);
      if (!mounted) return;
      setState(() {
        _orders = data;
        _loading = false;
      });
  } catch (e) {
      if (!mounted) return;
      setState(() {
    _error = 'تعذر تحميل الطلبات: ${e.toString()}';
        _loading = false;
      });
    }
  }

  Future<void> _refresh() async => _load();

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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false, // align to the start (right in RTL)
          titleSpacing: 16,
          title: Text(
            'الطلبات',
            textAlign: TextAlign.right,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refresh,
            color: DesignSystem.primary,
            child: Builder(builder: (context) {
              if (_loading) {
                return const Center(child: Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: CircularProgressIndicator(),
                ));
              }
              if (_error != null) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.2)),
                      ),
                      child: Text(_error!, style: const TextStyle(color: Colors.red)),
                    ),
                  ],
                );
              }
              if (_orders.isEmpty) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      decoration: BoxDecoration(
                        color: isDark ? DesignSystem.darkSurface : DesignSystem.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Icon(FontAwesomeIcons.boxOpen, color: DesignSystem.textSecondary, size: 36),
                          const SizedBox(height: 10),
                          Text('لا توجد طلبات حالياً', style: DesignSystem.bodyMedium.copyWith(color: DesignSystem.textSecondary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _orders.length,
                addAutomaticKeepAlives: true,
                addRepaintBoundaries: true,
                prototypeItem: const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: SizedBox(height: 280),
                ),
                physics: const ClampingScrollPhysics(),
                itemBuilder: (context, index) {
                  final order = _orders[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index < _orders.length - 1 ? 12 : 0,
                    ),
                    child: RepaintBoundary(
                      child: LiveOrderCard(
                        order: order,
                        onTrack: (orderId) {
                          final phone = order['customerPhone']?.toString();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => MapScreen(
                                customerPhone: phone,
                                orderId: orderId,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ),
      ),
    );
  }
}

// Removed _LightweightOrderCard - keeping your exact LiveOrderCard design
