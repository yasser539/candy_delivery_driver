import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../blocs/app_bloc.dart';
import '../../core/design_system/design_system.dart';
import '../../core/design_system/platform_ui_standards.dart';
import '../../core/services/cart_service.dart';
import '../../models/cart.dart';
import '../../widgets/cart_card.dart';
import '../../core/services/supabase_service.dart';
import '../../core/services/auth_service.dart';

class AvailableCartsScreen extends StatefulWidget {
  const AvailableCartsScreen({super.key});

  @override
  State<AvailableCartsScreen> createState() => _AvailableCartsScreenState();
}

class _AvailableCartsScreenState extends State<AvailableCartsScreen> {
  late CartService _cartService;
  List<Cart> _availableCarts = [];
  StreamSubscription? _availableCartsSubscription;

  @override
  void initState() {
    super.initState();
    _initializeCartService();
  }

  void _initializeCartService() {
    _cartService = Provider.of<CartService>(context, listen: false);
    final auth = Provider.of<AuthService>(context, listen: false);
    final supabaseUserId = SupabaseService.getCurrentUser()?.id;
    final driverId = supabaseUserId ??
        auth.captainProfile?['auth_user_id']?.toString() ??
        auth.captainProfile?['id']?.toString() ??
        'driver_001';
    _cartService.initialize(driverId);

    _availableCartsSubscription =
        _cartService.availableCartsStream.listen((carts) {
      if (mounted) setState(() => _availableCarts = carts);
    });
  }

  @override
  void dispose() {
    _availableCartsSubscription?.cancel();
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                            ? Colors.grey[300]
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
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(
                                  PlatformUIStandards.cardRadius),
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
          Text(
            'لا توجد طلبات متاحة حالياً',
            textAlign: TextAlign.center,
            style: DesignSystem.headlineMedium.copyWith(
              color: Colors.grey[800],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ستظهر الطلبات الجديدة هنا عند توفرها',
            textAlign: TextAlign.center,
            style: DesignSystem.bodyMedium.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _acceptCart(Cart cart) async {
    try {
      final success = await _cartService.acceptCart(cart.id);
      if (!mounted) return;
      if (success) {
        setState(() {
          _availableCarts.removeWhere((c) => c.id == cart.id);
        });
        // الذهاب لتبويب الطلبات
        try {
          final appBloc = context.read<AppBloc>();
          appBloc.add(SetCurrentIndexEvent(3));
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم قبول الطلب #${cart.id.substring(0, 8)}'),
            backgroundColor: DesignSystem.success,
          ),
        );
      } else {
        // تحقق من الحالة الفعلية ومعالجة الحالات المتسارعة
        try {
          final latest = await _cartService.getCartById(cart.id);
          if (!mounted) return;
          final myDriverId = Provider.of<AuthService>(context, listen: false)
              .captainProfile?['id']
              ?.toString();
          if (latest != null && latest.driverId == myDriverId) {
            setState(() {
              _availableCarts.removeWhere((c) => c.id == cart.id);
            });
            try {
              final appBloc = context.read<AppBloc>();
              appBloc.add(SetCurrentIndexEvent(3));
            } catch (_) {}
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تم قبول الطلب #${cart.id.substring(0, 8)}'),
                backgroundColor: DesignSystem.success,
              ),
            );
            return;
          }
          if (latest != null &&
              latest.driverId != null &&
              latest.driverId != myDriverId) {
            setState(() {
              _availableCarts.removeWhere((c) => c.id == cart.id);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'تم حجز الطلب #${cart.id.substring(0, 8)} بواسطة موصل آخر'),
                backgroundColor: DesignSystem.error,
              ),
            );
            return;
          }
        } catch (_) {}

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في قبول الطلب #${cart.id.substring(0, 8)}'),
            backgroundColor: DesignSystem.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء قبول الطلب'),
          backgroundColor: DesignSystem.error,
        ),
      );
    }
  }

  void _rejectCart(Cart cart) async {
    final success =
        await _cartService.updateCartStatus(cart.id, CartStatus.cancelled);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'تم رفض الطلب #${cart.id.substring(0, 8)}'
            : 'فشل في رفض الطلب #${cart.id.substring(0, 8)}'),
        backgroundColor: DesignSystem.error,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
