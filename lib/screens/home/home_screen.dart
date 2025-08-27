import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/design_system/design_system.dart';
import '../../models/cart.dart';
import '../../models/location.dart';
import '../../models/cart_item.dart';
import '../../widgets/currency_icon.dart';

// Mock data manager - no backend needed

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Cart> _availableCarts = [];
  bool _isOnline = true;
  bool _isUpdatingStatus = false;
  DateTime? _statusTimestamp;
  Position? _statusPosition;
  String? _statusError;
  int _monthlyDays = 0;

  @override
  void initState() {
    super.initState();

    // Load mock data instead of backend
    _loadMockData();
    _monthlyDays = 15; // Mock working days

    _captureStatusIfOnline();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _loadMockData() {
    // Mock available carts data
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
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
        deliveryLocation: Location(
          latitude: 24.7136,
          longitude: 46.6753,
          address: 'شارع التحلية، الرياض',
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
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
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        driverId: null,
      ),
      Cart(
        id: 'mock-002',
        customerId: 'customer-002',
        customerName: 'فاطمة علي',
        customerPhone: '+966507654321',
        totalAmount: 60.0,
        status: CartStatus.pending,
        pickupLocation: Location(
          latitude: 24.7136,
          longitude: 46.6753,
          address: 'شارع العليا، الرياض',
          timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
        deliveryLocation: Location(
          latitude: 24.7136,
          longitude: 46.6753,
          address: 'شارع الملك عبدالله، الرياض',
          timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
        items: [
          CartItem(
            id: 'item-002',
            cartId: 'mock-002',
            productId: 'product-002',
            productName: 'مياه معدنية 1.5 لتر',
            productPrice: 15.0,
            quantity: 4,
            totalPrice: 60.0,
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 15)),
        driverId: null,
      ),
    ];
  }

  Future<void> _refresh() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Reload mock data
    _loadMockData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark
            ? DesignSystem.darkBackground
            : DesignSystem.background,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refresh,
            color: DesignSystem.primaryGradient.colors.last,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(isDark),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatusCardModern(
                            title: 'الطلبات المتاحة',
                            count: _availableCarts.length,
                            icon: FontAwesomeIcons.bell,
                            gradient: DesignSystem.primaryGradient,
                            outlined: false,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatusCardModern(
                            title: 'أيام العمل هذا الشهر',
                            count: _monthlyDays,
                            icon: FontAwesomeIcons.calendarCheck,
                            gradient: DesignSystem.primaryGradient,
                            outlined: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'الطلبات المتاحة',
                            style: DesignSystem.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : DesignSystem.textPrimary,
                              fontSize: 18,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_availableCarts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 26,
                      ),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark
                              ? DesignSystem.darkSurface
                              : DesignSystem.surface,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Column(
                          children: [
                            Icon(
                              FontAwesomeIcons.boxOpen,
                              color: DesignSystem.textSecondary,
                              size: 36,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'لا توجد طلبات متاحة حالياً',
                              style: DesignSystem.bodyMedium.copyWith(
                                color: DesignSystem.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Column(
                      children: _availableCarts
                          .map(
                            (cart) => CartCard(
                              cart: cart,
                              isActive: false,
                              // keep button but no functionality
                              onAccept: () => _acceptCart(cart),
                              onReject: () => _rejectCart(cart),
                            ),
                          )
                          .toList(),
                    ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    // Mock user profile - no backend needed
    final displayName = 'عبد الرحمن الحطامي';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (rect) => DesignSystem.primaryGradient.createShader(
              Rect.fromLTWH(0, 0, rect.width, rect.height),
            ),
            blendMode: BlendMode.srcIn,
            child: FaIcon(
              FontAwesomeIcons.truck,
              size: 35,
              color: DesignSystem.getPlatformTextColor(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: DesignSystem.titleMedium.copyWith(
                    color: isDark ? Colors.white : DesignSystem.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 6),
                if (_statusPosition != null || _statusError != null)
                  Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.locationDot,
                        color: DesignSystem.getPlatformTextColor(context),
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _statusPosition != null
                              ? '${_statusPosition!.latitude.toStringAsFixed(4)}, ${_statusPosition!.longitude.toStringAsFixed(4)}'
                              : (_statusError ?? ''),
                          textAlign: TextAlign.right,
                          style: DesignSystem.labelSmall.copyWith(
                            color: DesignSystem.getPlatformTextColor(context),
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _acceptCart(Cart cart) {
    // Intentionally disabled — keep button with no behavior
    // If you prefer a message, uncomment next 3 lines:
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(content: Text('ميزة قبول الطلب غير مفعّلة في وضع العرض')),
    // );
  }

  void _rejectCart(Cart cart) {
    // Mock functionality - show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم رفض الطلب #${cart.id.substring(0, 8)} (Mock)'),
        backgroundColor: DesignSystem.error,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ====== حضور/انصراف وموقع ======
  void _onOnlineToggled(bool value) async {
    setState(() {
      _isOnline = value;
      _isUpdatingStatus = true;
      _statusTimestamp = DateTime.now();
      _statusError = null;
    });

    if (value) {
      await _captureLocation();
      // Mock check-in - no backend needed
    } else {
      // Mock check-out - no backend needed
    }

    if (mounted) {
      setState(() => _isUpdatingStatus = false);
    }
  }

  Future<void> _captureStatusIfOnline() async {
    if (_isOnline) {
      setState(() => _statusTimestamp = DateTime.now());
      await _captureLocation();
    }
  }

  Future<void> _captureLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _statusError = 'خدمة الموقع غير مفعلة');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        setState(() => _statusError = 'صلاحية الموقع مرفوضة');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      if (!mounted) return;
      setState(() {
        _statusPosition = position;
        _statusError = null;
      });
      try {
        // Mock location update - no backend needed
      } catch (_) {}
    } catch (e) {
      if (!mounted) return;
      setState(() => _statusError = 'تعذر تحديد الموقع');
    }
  }
}

// ======= UI widgets below (unchanged) =======

class _StatusCardModern extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color? color;
  final LinearGradient? gradient;
  final bool outlined;

  const _StatusCardModern({
    required this.title,
    required this.count,
    required this.icon,
    this.color,
    this.gradient,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    if (outlined) {
      return Container(
        height: 64,
        decoration: BoxDecoration(
          gradient:
              gradient ??
              LinearGradient(
                colors: [DesignSystem.primary, DesignSystem.primary],
              ),
          borderRadius: BorderRadius.circular(17),
          boxShadow: DesignSystem.getBrandShadow('light'),
        ),
        padding: const EdgeInsets.all(2),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? DesignSystem.darkBackground
                : DesignSystem.surface,
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: gradient,
                  boxShadow: [
                    BoxShadow(
                      color: (gradient?.colors.last ?? DesignSystem.primary)
                          .withOpacity(0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(4),
                child: FaIcon(icon, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Builder(
                  builder: (ctx) {
                    final bool dark =
                        Theme.of(ctx).brightness == Brightness.dark;
                    final Color contentColor = dark
                        ? Colors.white
                        : Colors.black;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            color: contentColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$count',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: contentColor,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 64,
      decoration: BoxDecoration(
        gradient:
            gradient ??
            LinearGradient(
              colors: [
                (color ?? DesignSystem.primary),
                (color ?? DesignSystem.primary),
              ],
            ),
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: (gradient?.colors.last ?? (color ?? DesignSystem.primary))
                .withOpacity(0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(8),
            child: FaIcon(icon, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'الطلبات المتاحة',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            '$count',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class CartCard extends StatelessWidget {
  final Cart cart;
  final bool isActive;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const CartCard({
    super.key,
    required this.cart,
    required this.isActive,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDark
        ? DesignSystem.darkSurface
        : DesignSystem.surface;
    final Color textColor = isDark
        ? DesignSystem.darkTextPrimary
        : DesignSystem.textPrimary;
    final Color secondaryColor = isDark
        ? Colors.white70
        : DesignSystem.textSecondary;

    const double baseTextSize = 12.0;
    const double orderTextSize = 16.0;
    const double cartIconSize = 18.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              textDirection: TextDirection.ltr,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    'طلب #${cart.id}',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w800,
                      fontSize: orderTextSize,
                      letterSpacing: 0.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 8),
                ShaderMask(
                  shaderCallback: (rect) =>
                      DesignSystem.primaryGradient.createShader(
                        Rect.fromLTWH(0, 0, rect.width, rect.height),
                      ),
                  blendMode: BlendMode.srcIn,
                  child: const FaIcon(
                    FontAwesomeIcons.box,
                    size: 22,
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 19),

            Row(
              children: [
                Expanded(
                  child: Row(
                    textDirection: TextDirection.ltr,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ShaderMask(
                              shaderCallback: (rect) =>
                                  DesignSystem.primaryGradient.createShader(
                                    Rect.fromLTWH(
                                      0,
                                      0,
                                      rect.width,
                                      rect.height,
                                    ),
                                  ),
                              blendMode: BlendMode.srcIn,
                              child: const Icon(
                                FontAwesomeIcons.phone,
                                size: cartIconSize,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              cart.customerPhone ?? '',
                              style: TextStyle(
                                color: secondaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: baseTextSize,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          textDirection: TextDirection.ltr,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Flexible(
                              child: Text(
                                cart.customerName ?? '',
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: baseTextSize,
                                ),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                              ),
                            ),
                            const SizedBox(width: 12),
                            ShaderMask(
                              shaderCallback: (rect) =>
                                  DesignSystem.primaryGradient.createShader(
                                    Rect.fromLTWH(
                                      0,
                                      0,
                                      rect.width,
                                      rect.height,
                                    ),
                                  ),
                              blendMode: BlendMode.srcIn,
                              child: const FaIcon(
                                FontAwesomeIcons.user,
                                size: cartIconSize,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),

            const SizedBox(height: 12),
            Divider(
              color: isDark ? Colors.white12 : Colors.black12,
              thickness: 0.5,
              height: 16,
            ),
            const SizedBox(height: 8),

            Row(
              textDirection: TextDirection.rtl,
              children: [
                ShaderMask(
                  shaderCallback: (rect) =>
                      DesignSystem.primaryGradient.createShader(
                        Rect.fromLTWH(0, 0, rect.width, rect.height),
                      ),
                  blendMode: BlendMode.srcIn,
                  child: const FaIcon(
                    FontAwesomeIcons.boxOpen,
                    size: cartIconSize,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'المنتجات:',
                  style: TextStyle(
                    color: secondaryColor,
                    fontWeight: FontWeight.w700,
                    fontSize: baseTextSize,
                  ),
                  textAlign: TextAlign.right,
                ),
                if (cart.items.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Text(
                        cart.items.first.productName ?? '',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w500,
                          fontSize: baseTextSize,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 4),

            ...cart.items
                .skip(1)
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      textDirection: TextDirection.ltr,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.productName ?? '',
                            style: TextStyle(
                              fontSize: baseTextSize,
                              color: textColor,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

            const SizedBox(height: 12),
            Divider(
              color: isDark ? Colors.white12 : Colors.black12,
              thickness: 0.5,
              height: 16,
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShaderMask(
                      shaderCallback: (rect) =>
                          DesignSystem.primaryGradient.createShader(
                            Rect.fromLTWH(0, 0, rect.width, rect.height),
                          ),
                      blendMode: BlendMode.srcIn,
                      child: const FaIcon(
                        FontAwesomeIcons.moneyBillWave,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'المجموع:',
                      style: TextStyle(
                        color: secondaryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: baseTextSize,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${cart.totalAmount}',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w800,
                        fontSize: baseTextSize,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: CurrencyIcon(
                        width: 16,
                        height: 16,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _GradientOutlineFillButton(
                    onPressed: onReject,
                    gradient: DesignSystem.primaryGradient,
                    cardColor: cardColor,
                    label: 'رفض',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _GradientButton(
                    onPressed: onAccept, // stays visible; does nothing
                    gradient: DesignSystem.primaryGradient,
                    label: 'قبول الطلب',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final LinearGradient gradient;
  final String label;

  const _GradientButton({
    required this.onPressed,
    required this.gradient,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.last.withOpacity(0.22),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed:
              onPressed, // if null => disabled style; else tap with no-op
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientOutlineFillButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final LinearGradient gradient;
  final Color cardColor;
  final String label;

  const _GradientOutlineFillButton({
    required this.onPressed,
    required this.gradient,
    required this.cardColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(2),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: ShaderMask(
              shaderCallback: (rect) => gradient.createShader(
                Rect.fromLTWH(0, 0, rect.width, rect.height),
              ),
              blendMode: BlendMode.srcIn,
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
