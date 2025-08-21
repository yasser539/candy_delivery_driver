import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../blocs/app_bloc.dart';
import '../../core/services/auth_service.dart';
import '../../core/design_system/design_system.dart';
// import '../../core/design_system/platform_ui_standards.dart';
import '../../core/services/cart_service.dart';
import '../../models/cart.dart';
// Removed unused imports
import '../../widgets/cart_card.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with TickerProviderStateMixin {
  late CartService _cartService;
  String _selectedFilter = 'الكل';
  final List<String> _filters = [
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

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeCartService();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  void _initializeCartService() {
    _cartService = Provider.of<CartService>(context, listen: false);
    _cartService.initialize('driver_001');

    _myCartsSubscription = _cartService.myCartsStream.listen((carts) {
      print('OrdersScreen: My carts updated: ${carts.length}');
      if (mounted) setState(() => _myCarts = carts);
    });

    // We no longer show available carts in this screen; rely on my carts only
    _availableCartsSubscription = _cartService.availableCartsStream.listen(
      (_) {},
    );

    _unpaidInvoicesSubscription = _cartService.unpaidInvoicesStream.listen((
      invoices,
    ) {
      if (mounted) setState(() => _unpaidInvoices = invoices);
    });

    // Don't add mock data here - let CartService handle it
    // Timer(const Duration(seconds: 3), () {
    //   if (mounted && _myCarts.isEmpty) {
    //     print('OrdersScreen: Adding mock assigned carts for testing');
    //     _addMockAssignedCarts();
    //   }
    // });
  }

  // No tabs; single list view

  // Removed legacy mock helper _addMockAssignedCarts()

  Future<void> _refreshData() async {
    if (!mounted) return;
    setState(() {
      _isRefreshing = true;
    });

    // Simulate refresh delay
    await Future.delayed(const Duration(seconds: 1));

    // Reload data by reinitializing the service
    if (!mounted) return;
    _cartService.initialize('driver_001');

    if (!mounted) return;
    setState(() {
      _isRefreshing = false;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تحديث البيانات'),
        backgroundColor: DesignSystem.success,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  void dispose() {
    _myCartsSubscription?.cancel();
    _availableCartsSubscription?.cancel();
    _unpaidInvoicesSubscription?.cancel();
    _animationController.dispose();
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

  @override
  Widget build(BuildContext context) {
    // Access theme state if needed later (kept for potential future UI tweaks)
    // ignore: unused_local_variable
    final appBloc = Provider.of<AppBloc>(context, listen: false);

    final auth = Provider.of<AuthService>(context, listen: false);
    final profile = auth.captainProfile;
    final String? position = (profile?['position'] as String?)?.trim();
    final bool isDelegate =
        position != null && position.isNotEmpty && position == 'مندوب';

    // Build dynamic filters list (add 'الفواتير' only for delegates)
    final List<String> filters = isDelegate
        ? [..._filters, 'الفواتير']
        : List.of(_filters);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? DesignSystem.darkBackground
            : DesignSystem.background,
        // No AppBar – screen starts with the total header
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // ====== ترويسة حديثة مع عداد وإعادة تحميل ======
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

                // ====== فلاتر بسيطة بشكل شرائح ======
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

                // ======= قائمة الطلبات المحسنة ======
                Expanded(
                  child: _filteredCarts.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _refreshData,
                          color: DesignSystem.primary,
                          child: ListView.separated(
                            key: ValueKey(_selectedFilter),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filteredCarts.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final cart = _filteredCarts[index];
                              if (_selectedFilter == 'الفواتير') {
                                final due = cart.amountDue ?? cart.totalAmount;
                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.outline.withOpacity(0.15),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.receipt_long,
                                        color: Colors.orange,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'فاتورة #${cart.id.substring(0, 8)}',
                                              style: DesignSystem.bodyMedium
                                                  .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              cart.customerName ?? 'عميل',
                                              style: DesignSystem.bodySmall,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'مستحق',
                                            style: DesignSystem.bodySmall
                                                .copyWith(
                                                  color: Colors.grey[700],
                                                ),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                due.toStringAsFixed(2),
                                                style: DesignSystem.titleSmall
                                                    .copyWith(
                                                      color: DesignSystem.error,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                              ),
                                            ],
                                          ),
                                          TextButton(
                                            onPressed: () => _openInvoice(cart),
                                            child: const Text('تفاصيل'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return CartCard(
                                cart: cart,
                                isActive: cart.isActive,
                                onAccept: () => _acceptCart(cart),
                                onReject: () => _rejectCart(cart),
                                onUpdateStatus: (status) =>
                                    _updateCartStatus(cart, status),
                                onCallCustomer: () => _callCustomer(cart),
                                onNavigate: () => _navigateToCart(cart),
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
    return _myCarts.where((cart) => cart.status == status).length;
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
            icon: FaIcon(FontAwesomeIcons.refresh, size: 16),
            label: Text('تحديث البيانات'),
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
    try {
      final success = await _cartService.acceptCart(cart.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'تم قبول الطلب #${cart.id.substring(0, 8)}'
                : 'فشل في قبول الطلب #${cart.id.substring(0, 8)}',
          ),
          backgroundColor: success ? DesignSystem.success : DesignSystem.error,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء قبول الطلب'),
          backgroundColor: DesignSystem.error,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _rejectCart(Cart cart) async {
    try {
      final success = await _cartService.updateCartStatus(
        cart.id,
        CartStatus.cancelled,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'تم رفض الطلب #${cart.id.substring(0, 8)}'
                : 'فشل في رفض الطلب #${cart.id.substring(0, 8)}',
          ),
          backgroundColor: DesignSystem.error,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء رفض الطلب'),
          backgroundColor: DesignSystem.error,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _updateCartStatus(Cart cart, CartStatus status) async {
    try {
      final success = await _cartService.updateCartStatus(cart.id, status);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'تم تحديث حالة الطلب إلى ${_getStatusText(status)}'
                : 'فشل في تحديث حالة الطلب #${cart.id.substring(0, 8)}',
          ),
          backgroundColor: success ? DesignSystem.info : DesignSystem.error,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء تحديث حالة الطلب'),
          backgroundColor: DesignSystem.error,
          duration: const Duration(seconds: 2),
        ),
      );
    }
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
          content: Text('لا يوجد رقم هاتف للعميل'),
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'تم نسخ رقم ${cart.customerName ?? 'العميل'} إلى الحافظة وفتح تطبيق الاتصال',
              ),
              backgroundColor: DesignSystem.success,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
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
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء الاتصال: $e'),
            backgroundColor: DesignSystem.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
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

  void _openInvoice(Cart cart) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (dialogContext) {
        final due = cart.amountDue ?? cart.totalAmount;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt_long),
                  const SizedBox(width: 8),
                  Text(
                    'فاتورة #${cart.id}',
                    style: DesignSystem.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('العميل: ${cart.customerName ?? '-'}'),
              Text('الإجمالي: ${cart.totalAmount.toStringAsFixed(2)}'),
              Text(
                'المستحق: ${due.toStringAsFixed(2)}',
                style: TextStyle(color: DesignSystem.error),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('إغلاق'),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('سيتم دعم تحصيل الفاتورة لاحقًا'),
                          backgroundColor: DesignSystem.info,
                        ),
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('تحصيل/تنزيل'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
