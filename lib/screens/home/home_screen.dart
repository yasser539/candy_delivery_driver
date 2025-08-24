import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../blocs/app_bloc.dart';
import '../../core/design_system/design_system.dart';
import '../../core/services/cart_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/supabase_test.dart';
import '../../core/services/attendance_service.dart';
import '../../core/services/supabase_service.dart';
import '../../models/cart.dart';
import '../../widgets/currency_icon.dart';
// removed unused imports

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late CartService _cartService;
  late AttendanceService _attendanceService;
  List<Cart> _availableCarts = [];
  bool _isOnline = true;
  bool _isUpdatingStatus = false;
  DateTime? _statusTimestamp;
  Position? _statusPosition;
  String? _statusError;
  StreamSubscription? _availableCartsSubscription;
  StreamSubscription<int>? _attendanceSubscription;
  int _monthlyDays = 0;

  @override
  void initState() {
    super.initState();
    _cartService = Provider.of<CartService>(context, listen: false);
    _attendanceService = Provider.of<AttendanceService>(context, listen: false);
    // استخدم معرف السائق الحقيقي إن وجد، وإلا استخدم قيمة افتراضية للتجربة
    final auth = Provider.of<AuthService>(context, listen: false);
    final supabaseUserId = SupabaseService.getCurrentUser()?.id;
    final driverId =
        supabaseUserId ??
        auth.captainProfile?['auth_user_id']?.toString() ??
        auth.captainProfile?['id']?.toString() ??
        'driver_001';
    _cartService.initialize(driverId);
    _attendanceService.initialize('driver_001');
    SupabaseTest.testConnection();
    SupabaseTest.testCartsTable();

    _availableCartsSubscription = _cartService.availableCartsStream.listen((
      carts,
    ) {
      if (mounted) setState(() => _availableCarts = carts);
    });

    _attendanceSubscription = _attendanceService.monthlyDaysStream.listen((
      days,
    ) {
      if (mounted) setState(() => _monthlyDays = days);
    });

    // التقاط الحالة الأولية إذا كان متصلاً
    _captureStatusIfOnline();

    // Don't add mock data here - let CartService handle it
    // Timer(const Duration(seconds: 3), () {
    //   if (mounted && _availableCarts.isEmpty) {
    //     _addMockData();
    //   }
    // });
  }

  // Removed unused _addMockData helper

  @override
  void dispose() {
    _availableCartsSubscription?.cancel();
    _attendanceSubscription?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    await Future.delayed(const Duration(milliseconds: 600));
    // Reload data from Supabase
    _cartService.initialize('driver_001');
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth changes to rebuild header (name/photo)
    context.watch<AuthService>();
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
                            // filled with gradient
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
                            // outlined with gradient stroke
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
                        // Title without icon, colored white per request
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
    final auth = context.read<AuthService>();
    final profile = auth.captainProfile;
    final displayName = (profile?['name'] as String?)?.trim().isNotEmpty == true
        ? profile!['name']
        : 'سائق التوصيل';
    // Restore avatar; remove online/time/switch, keep location under name
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          // Truck icon on the right side (appears visually right because parent Directionality is RTL)
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
                // Location only
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

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: DesignSystem.primaryGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: DesignSystem.getBrandShadow('light'),
          ),
          child: FaIcon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: DesignSystem.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: DesignSystem.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _acceptCart(Cart cart) async {
    final success = await _cartService.acceptCart(cart.id);
    if (!mounted) return;
    if (success) {
      // إزالة الطلب فوراً من القائمة
      setState(() {
        _availableCarts.removeWhere((c) => c.id == cart.id);
      });

      // الانتقال إلى تبويب الطلبات
      try {
        final appBloc = context.read<AppBloc>();
        appBloc.add(SetCurrentIndexEvent(3));
      } catch (_) {}

      // تنبيه بسيط بالنجاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم قبول الطلب #${cart.id.substring(0, 8)}'),
          backgroundColor: DesignSystem.success,
        ),
      );
    } else {
      // تحقق من حالة الطلب الحالية وقم بتحديث الواجهة وفقًا لذلك
      try {
        final latest = await _cartService.getCartById(cart.id);
        if (!mounted) return;
        if (latest != null) {
          final myDriverId = Provider.of<AuthService>(
            context,
            listen: false,
          ).captainProfile?['id']?.toString();
          if (latest.driverId == myDriverId) {
            // تم تعيين الطلب لي مسبقًا – اعتبره نجاحًا محليًا
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
          if (latest.driverId != null && latest.driverId != myDriverId) {
            // الطلب محجوز لسائق آخر – أزله من القائمة وبيّن السبب
            setState(() {
              _availableCarts.removeWhere((c) => c.id == cart.id);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'تم حجز الطلب #${cart.id.substring(0, 8)} بواسطة موصل آخر',
                ),
                backgroundColor: DesignSystem.error,
              ),
            );
            return;
          }
        }
      } catch (_) {}

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في قبول الطلب #${cart.id.substring(0, 8)}'),
          backgroundColor: DesignSystem.error,
        ),
      );
    }
  }

  void _rejectCart(Cart cart) async {
    final success = await _cartService.updateCartStatus(
      cart.id,
      CartStatus.cancelled,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'تم رفض الطلب #${cart.id.substring(0, 8)}'
              : 'فشل في رفض الطلب #${cart.id.substring(0, 8)}',
        ),
        backgroundColor: DesignSystem.error,
      ),
    );
  }

  // ====== حضور/انصراف (متصل/غير متصل) مع تحديد الموقع والوقت ======
  void _onOnlineToggled(bool value) async {
    setState(() {
      _isOnline = value;
      _isUpdatingStatus = true;
      _statusTimestamp = DateTime.now();
      _statusError = null;
    });

    if (value) {
      await _captureLocation();
      // تسجيل حضور
      await _attendanceService.checkIn(
        lat: _statusPosition?.latitude,
        lng: _statusPosition?.longitude,
      );
    } else {
      // تسجيل انصراف
      await _attendanceService.checkOut(
        lat: _statusPosition?.latitude,
        lng: _statusPosition?.longitude,
      );
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
      // تحديث موقع حي
      try {
        await _attendanceService.updateLiveLocation(
          lat: position.latitude,
          lng: position.longitude,
        );
      } catch (_) {}
    } catch (e) {
      if (!mounted) return;
      setState(() => _statusError = 'تعذر تحديد الموقع');
    }
  }

  String _formatTime(DateTime time) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(time.hour)}:${two(time.minute)}';
  }
}

// كارد الإحصائيات
class _StatusCardModern extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color?
  color; // optional when using gradient (kept for backward compatibility)
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
    // Determine visuals based on outlined/filled and available gradient
    // final useGradient = gradient != null; // not used
    if (outlined) {
      // Gradient border with white inner background
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
                        : (gradient?.colors.last ??
                              (color ?? DesignSystem.primary));
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

    // Filled card with gradient background
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
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  '$count',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: Colors.white,
                  ),
                ),
              ],
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
    // Text colors: black in light mode, readable in dark mode
    final Color textColor = isDark
        ? DesignSystem.darkTextPrimary
        : DesignSystem.textPrimary;
    final Color secondaryColor = isDark
        ? Colors.white70
        : DesignSystem.textSecondary;

    // sizes: orderTextSize remains large; other text reduced
    final double baseTextSize = 12.0;
    final double orderTextSize = 16.0;
    final double cartIconSize = 18.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22), // 🔥 كرت بزوايا أكثر نعومة
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== رقم الطلب =====
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
                  child: FaIcon(
                    FontAwesomeIcons.box,
                    size: cartIconSize,
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ===== بيانات العميل =====
            Row(
              children: [
                Expanded(
                  child: Row(
                    textDirection: TextDirection.ltr,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left: phone icon + number (moved to visual left)
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
                              child: Icon(
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

                      // Right: customer name + user icon
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
                              child: FaIcon(
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

            // ===== عنوان المنتجات (الأيقونة يمين والنص يسارها) =====
            Row(
              textDirection: TextDirection.rtl,
              children: [
                ShaderMask(
                  shaderCallback: (rect) =>
                      DesignSystem.primaryGradient.createShader(
                        Rect.fromLTWH(0, 0, rect.width, rect.height),
                      ),
                  blendMode: BlendMode.srcIn,
                  child: FaIcon(
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
                // show first product on same line if exists
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

            const SizedBox(height: 8),

            // ===== قائمة المنتجات (نص فقط) =====
            // start from second item because first is shown inline with title
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

            const SizedBox(height: 8),
            Divider(
              color: isDark ? Colors.white12 : Colors.black12,
              thickness: 0.5,
              height: 16,
            ),
            const SizedBox(height: 8),

            // ===== المجموع =====
            // ===== المجموع: اللابل يمين، القيمة يسار + rsak.svg + أيقونة المجموع =====
            // ===== المجموع: الأيقونة + اللابل يمين / القيمة + رمز العملة يسار =====
            Row(
              children: [
                // يمين: أيقونة المجموع مع اللابل
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

                // يسار: القيمة + أيقونة العملة
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

                    // استخدم أي واحد من الخيارين حسب تفضيلك:

                    // (أ) الويدجت الحالي عندك:
                    CurrencyIcon(width: 16, height: 16, color: textColor),

                    // (ب) أو مباشرة من المسار (لو استخدمت flutter_svg):
                    // SvgPicture.asset(
                    //   'assets/icons/rsak.svg',
                    //   width: 16,
                    //   height: 16,
                    //   colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
                    // ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ===== الأزرار =====
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
                    onPressed: onAccept,
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

// ===== زر بتدرّج (قبول) =====
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
          borderRadius: BorderRadius.circular(18), // 🔥 زر بزوايا أنعم
          boxShadow: [
            BoxShadow(
              color: gradient.colors.last.withOpacity(0.22),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18), // نفس نصف القطر
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

// ===== زر إطار متدرّج + تعبئة بلون الكارد (رفض) =====
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
          borderRadius: BorderRadius.circular(18), // 🔥 زر بزوايا أنعم
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
