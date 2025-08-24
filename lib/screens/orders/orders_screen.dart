import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

import '../../blocs/app_bloc.dart';
import '../../core/services/auth_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/services/cart_service.dart';
import '../../models/cart.dart';
// لو عندك CartCard بديل يمكنك استيراده؛ حالياً بنستخدم CartCard الافتراضي عندك
import '../../widgets/cart_card.dart';
import '../../widgets/live_order_card.dart';
import '../home/home_screen.dart'
    as home; // Import to access AcceptedCartsManager
import 'dart:math' as math;

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with TickerProviderStateMixin {
  late CartService _cartService;

  String _selectedFilter = 'الكل';
  final List<String> _filters = const [
    'الكل',
    'قيد الانتظار',
    'تم التعيين',
    'في الطريق',
    'مكتمل',
    'ملغي',
  ];

  List<Cart> _myCarts = [];
  List<Cart> _unpaidInvoices = [];
  StreamSubscription? _myCartsSubscription;
  StreamSubscription? _availableCartsSubscription;
  StreamSubscription? _unpaidInvoicesSubscription;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _isRefreshing = false;

  // (اختياري) لدعم التركيز على عنصر بعد قدومك من Home
  final _listCtrl = ScrollController();
  String? _highlightCartId;
  int? _highlightIndex;
  bool _didScrollToHighlight = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    _cartService = Provider.of<CartService>(context, listen: false);
    _cartService.initialize('driver_001');

    _myCartsSubscription = _cartService.myCartsStream.listen((carts) {
      if (!mounted) return;
      setState(() => _myCarts = carts);

      // Scroll-to-highlight (لو مرّرنا cartId عبر arguments)
      if (_highlightCartId != null && !_didScrollToHighlight) {
        final idx = _myCarts.indexWhere((c) => c.id == _highlightCartId);
        if (idx != -1) {
          _highlightIndex = idx;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!_listCtrl.hasClients) return;
            final target = (idx * 140).toDouble();
            await _listCtrl.animateTo(
              target.clamp(0, _listCtrl.position.maxScrollExtent),
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOut,
            );
            setState(() => _didScrollToHighlight = true);
            await Future.delayed(const Duration(seconds: 2));
            if (mounted) setState(() => _highlightIndex = null);
          });
        }
      }
    });

    _availableCartsSubscription = _cartService.availableCartsStream.listen(
      (_) {},
    );
    _unpaidInvoicesSubscription = _cartService.unpaidInvoicesStream.listen((
      invoices,
    ) {
      if (mounted) setState(() => _unpaidInvoices = invoices);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // استقبل cartId لو فتحت الشاشة بـ pushNamed(arguments: cartId)
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && args.isNotEmpty && _highlightCartId == null) {
      _highlightCartId = args;
    }
  }

  @override
  void dispose() {
    _myCartsSubscription?.cancel();
    _availableCartsSubscription?.cancel();
    _unpaidInvoicesSubscription?.cancel();
    _animationController.dispose();
    _listCtrl.dispose();
    super.dispose();
  }

  List<Cart> get _filteredCarts {
    if (_selectedFilter == 'الكل') return _myCarts;
    if (_selectedFilter == 'الفواتير') return _unpaidInvoices;
    CartStatus status;
    switch (_selectedFilter) {
      case 'قيد الانتظار':
        status = CartStatus.pending;
        break;
      case 'تم التعيين':
        status = CartStatus.assigned;
        break;
      case 'في الطريق':
        status = CartStatus.onTheWay;
        break;
      case 'مكتمل':
        status = CartStatus.delivered;
        break;
      case 'ملغي':
        status = CartStatus.cancelled;
        break;
      default:
        return _myCarts;
    }
    return _myCarts.where((cart) => cart.status == status).toList();
  }

  Future<void> _refreshData() async {
    if (!mounted) return;
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 800));
    _cartService.initialize('driver_001');
    if (!mounted) return;
    setState(() => _isRefreshing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم تحديث البيانات'),
        backgroundColor: DesignSystem.success,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    final profile = auth.captainProfile;
    final String? position = (profile?['position'] as String?)?.trim();
    final bool isDelegate =
        position != null && position.isNotEmpty && position == 'مندوب';

    final List<String> filters = isDelegate
        ? [..._filters, 'الفواتير']
        : List.of(_filters);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? DesignSystem.darkBackground
            : DesignSystem.background,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Header total + refresh
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: DesignSystem.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: DesignSystem.getBrandShadow('medium'),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const FaIcon(
                            FontAwesomeIcons.truckFast,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'إجمالي الطلبات',
                                style: DesignSystem.bodySmall.copyWith(
                                  color: Colors.white.withOpacity(0.88),
                                ),
                              ),
                              Text(
                                '${_filteredCarts.length}',
                                style: DesignSystem.titleMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _isRefreshing ? null : _refreshData,
                          icon: _isRefreshing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const FaIcon(
                                  FontAwesomeIcons.rotateRight,
                                  color: Colors.white,
                                  size: 18,
                                ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Filters as pills
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (context, index) {
                      final filter = filters[index];
                      final isSelected = _selectedFilter == filter;
                      final count = _getCartCountForFilter(filter);
                      return GestureDetector(
                        onTap: () => setState(() => _selectedFilter = filter),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? DesignSystem.primary
                                : DesignSystem.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : DesignSystem.primary.withOpacity(0.30),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                filter,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : DesignSystem.primary,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                              if (count > 0) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white.withOpacity(0.25)
                                        : DesignSystem.primary.withOpacity(
                                            0.12,
                                          ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$count',
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : DesignSystem.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),

                // ===== الطلبات المقبولة =====
                if (home.AcceptedCartsManager.getAcceptedCarts()
                    .isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.checkCircle,
                          color: DesignSystem.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'الطلبات المقبولة',
                          style: DesignSystem.titleSmall.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...home.AcceptedCartsManager.getAcceptedCarts().map(
                    (cartData) => Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: _AcceptedCartCard(cartData: cartData),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Orders list
                Expanded(
                  child: _filteredCarts.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _refreshData,
                          color: DesignSystem.primary,
                          child: ListView.separated(
                            controller: _listCtrl,
                            key: ValueKey(_selectedFilter),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filteredCarts.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final cart = _filteredCarts[index];
                              final isHighlighted = _highlightIndex == index;

                              // استخدم CartCard الحالية لديك
                              final tile = CartCard(
                                cart: cart,
                                isActive: cart.isActive,
                                onAccept: () => _acceptCart(cart),
                                onReject: () => _rejectCart(cart),
                                onUpdateStatus: (status) =>
                                    _updateCartStatus(cart, status),
                                onCallCustomer: () => _callCustomer(cart),
                                onNavigate: () => _navigateToCart(cart),
                              );

                              if (!isHighlighted) return tile;
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: DesignSystem.primary,
                                    width: 2,
                                  ),
                                ),
                                child: tile,
                              );
                            },
                          ),
                        ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _getCartCountForFilter(String filter) {
    if (filter == 'الكل') return _myCarts.length;
    if (filter == 'الفواتير') return _unpaidInvoices.length;
    CartStatus status;
    switch (filter) {
      case 'قيد الانتظار':
        status = CartStatus.pending;
        break;
      case 'تم التعيين':
        status = CartStatus.assigned;
        break;
      case 'في الطريق':
        status = CartStatus.onTheWay;
        break;
      case 'مكتمل':
        status = CartStatus.delivered;
        break;
      case 'ملغي':
        status = CartStatus.cancelled;
        break;
      default:
        return 0;
    }
    return _myCarts.where((c) => c.status == status).length;
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
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: DesignSystem.primaryGradient,
              borderRadius: BorderRadius.circular(32),
              boxShadow: DesignSystem.getBrandShadow('medium'),
            ),
            child: FaIcon(
              FontAwesomeIcons.boxOpen,
              size: 56,
              color: DesignSystem.textInverse,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد طلبات حالياً',
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
            style: DesignSystem.bodyMedium.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _refreshData,
            icon: const FaIcon(FontAwesomeIcons.refresh, size: 16),
            label: const Text('تحديث البيانات'),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignSystem.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _acceptCart(Cart cart) async {
    // واجهة فقط (لا نعتمد على نجاح API)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم قبول الطلب #${cart.id.substring(0, 8)}'),
        backgroundColor: DesignSystem.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _rejectCart(Cart cart) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم رفض الطلب #${cart.id.substring(0, 8)}'),
        backgroundColor: DesignSystem.error,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _updateCartStatus(Cart cart, CartStatus status) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تحديث حالة الطلب إلى ${_getStatusText(status)}'),
        backgroundColor: DesignSystem.info,
      ),
    );
  }

  String _getStatusText(CartStatus status) {
    switch (status) {
      case CartStatus.pending:
        return 'قيد الانتظار';
      case CartStatus.assigned:
        return 'تم التعيين';
      case CartStatus.onTheWay:
        return 'في الطريق';
      case CartStatus.delivered:
        return 'تم التوصيل';
      case CartStatus.cancelled:
        return 'ملغي';
    }
  }

  Future<void> _callCustomer(Cart cart) async {
    if (cart.customerPhone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('لا يوجد رقم هاتف للعميل'),
          backgroundColor: DesignSystem.error,
        ),
      );
      return;
    }
    try {
      String phoneNumber = cart.customerPhone!.replaceAll(
        RegExp(r'[^\d+]'),
        '',
      );
      if (!phoneNumber.startsWith('+')) {
        phoneNumber = '+$phoneNumber';
      }
      await Clipboard.setData(ClipboardData(text: phoneNumber));
      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم نسخ رقم ${cart.customerName ?? 'العميل'} وفتح تطبيق الاتصال',
            ),
            backgroundColor: DesignSystem.success,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم نسخ رقم ${cart.customerName ?? 'العميل'} إلى الحافظة',
            ),
            backgroundColor: DesignSystem.info,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء الاتصال: $e'),
          backgroundColor: DesignSystem.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _navigateToCart(Cart cart) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('جاري فتح الخريطة للطلب ${cart.id.substring(0, 8)}'),
        backgroundColor: DesignSystem.info,
      ),
    );
  }
}

// ===== Accepted Cart Card Widget =====
class _AcceptedCartCard extends StatelessWidget {
  final Map<String, dynamic> cartData;

  const _AcceptedCartCard({required this.cartData});

  @override
  Widget build(BuildContext context) {
    return LiveOrderCard(
      order: cartData,
      onTrack: (id) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('فتح تتبع الطلب $id')));
      },
      onCallDriver: (id) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('فتح الاتصال للطلب $id')));
      },
    );
  }
}

// _OrderProgressRow removed in favor of `OrderTimeline` in `lib/widgets/order_timeline.dart`.
