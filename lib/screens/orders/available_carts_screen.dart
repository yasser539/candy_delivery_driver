import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/design_system/design_system.dart';
import '../../core/design_system/platform_ui_standards.dart';
import '../../models/cart.dart';
import '../../models/location.dart';
import '../../models/cart_item.dart';
import '../../widgets/cart_card.dart';

class AvailableCartsScreen extends StatefulWidget {
  const AvailableCartsScreen({super.key});

  @override
  State<AvailableCartsScreen> createState() => _AvailableCartsScreenState();
}

class _AvailableCartsScreenState extends State<AvailableCartsScreen> {
  // Local mock cart list - no backend/service calls
  List<Cart> _availableCarts = [];

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  void _loadMockData() {
    _availableCarts = [
      Cart(
        id: 'mock-001',
        customerId: 'customer-001',
        customerName: 'أحمد محمد',
        customerPhone: '+966501234567',
        totalAmount: 45.0,
        status: CartStatus.pending,
        pickupLocation: Location(
          latitude: 24.7136,
          longitude: 46.6753,
          address: 'شارع الملك فهد، الرياض',
          timestamp: DateTime.now(),
        ),
        deliveryLocation: Location(
          latitude: 24.7136,
          longitude: 46.6753,
          address: 'شارع التحلية، الرياض',
          timestamp: DateTime.now(),
        ),
        items: [
          CartItem(
            id: 'item-001',
            cartId: 'mock-001',
            productId: 'product-001',
            productName: 'مياه عذبة 5 لتر',
            productPrice: 15.0,
            quantity: 3,
            totalPrice: 45.0,
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final appBloc = Provider.of<AppBloc>(context, listen: false);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? DesignSystem.darkBackground
            : DesignSystem.background,
        appBar: AppBar(
          title: Text(
            'الطلبات المتاحة',
            style: DesignSystem.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              // ====== عداد الطلبات المتاحة ======
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: DesignSystem.primaryGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: DesignSystem.getBrandShadow('medium'),
                      ),
                      child: FaIcon(
                        FontAwesomeIcons.bell,
                        color: DesignSystem.textInverse,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'الطلبات المتاحة: ',
                      style: DesignSystem.bodyMedium.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.grey[700],
                      ),
                    ),
                    Text(
                      '${_availableCarts.length}',
                      style: DesignSystem.titleMedium.copyWith(
                        color: DesignSystem.primaryGradient.colors.last,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // ======= قائمة الطلبات المتاحة ======
              Expanded(
                child: _availableCarts.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _availableCarts.length,
                        itemBuilder: (context, index) {
                          final cart = _availableCarts[index];
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? DesignSystem.darkSurface
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(
                                PlatformUIStandards.cardRadius,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: CartCard(
                              cart: cart,
                              isActive: false,
                              onAccept: () => _acceptCart(cart),
                              onReject: () => _rejectCart(cart),
                              onUpdateStatus: null,
                              onCallCustomer: null,
                              onNavigate: null,
                            ),
                          );
                        },
                      ),
              ),

              // ======= مساحة أسفل الشاشة ======
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: DesignSystem.primaryGradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: DesignSystem.getBrandShadow('medium'),
            ),
            child: FaIcon(
              FontAwesomeIcons.bell,
              size: 48,
              color: DesignSystem.textInverse,
            ),
          ),
          const SizedBox(height: 22),
          Builder(
            builder: (ctx) {
              final isDark = Theme.of(ctx).brightness == Brightness.dark;
              return Text(
                'لا توجد طلبات متاحة حالياً',
                textAlign: TextAlign.center,
                style: DesignSystem.headlineMedium.copyWith(
                  color: isDark ? Colors.white : Colors.grey[800],
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Builder(
            builder: (ctx) {
              final isDark = Theme.of(ctx).brightness == Brightness.dark;
              return Text(
                'ستظهر الطلبات الجديدة هنا عند توفرها',
                textAlign: TextAlign.center,
                style: DesignSystem.bodyMedium.copyWith(
                  color: isDark ? Colors.white : Colors.grey[600],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _acceptCart(Cart cart) async {
    // Mock accept: remove from list and notify (no backend)
    if (!mounted) return;
    setState(() => _availableCarts.removeWhere((c) => c.id == cart.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم قبول الطلب #${cart.id.substring(0, 8)} (Mock)'),
        backgroundColor: DesignSystem.success,
      ),
    );
  }

  void _rejectCart(Cart cart) async {
    // Mock reject: remove from list and notify
    if (!mounted) return;
    setState(() => _availableCarts.removeWhere((c) => c.id == cart.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم رفض الطلب #${cart.id.substring(0, 8)} (Mock)'),
        backgroundColor: DesignSystem.error,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
