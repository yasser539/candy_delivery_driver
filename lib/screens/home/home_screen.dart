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
    final driverId = supabaseUserId ??
        auth.captainProfile?['auth_user_id']?.toString() ??
        auth.captainProfile?['id']?.toString() ??
        'driver_001';
    _cartService.initialize(driverId);
    _attendanceService.initialize('driver_001');
    SupabaseTest.testConnection();
    SupabaseTest.testCartsTable();

    _availableCartsSubscription =
        _cartService.availableCartsStream.listen((carts) {
      if (mounted) setState(() => _availableCarts = carts);
    });

    _attendanceSubscription =
        _attendanceService.monthlyDaysStream.listen((days) {
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
        backgroundColor:
            isDark ? DesignSystem.darkBackground : DesignSystem.background,
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
                            color: DesignSystem.warning,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatusCardModern(
                            title: 'أيام العمل هذا الشهر',
                            count: _monthlyDays,
                            icon: FontAwesomeIcons.calendarCheck,
                            color: DesignSystem.primaryGradient.colors.last,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: _buildSectionHeader(
                        'الطلبات المتاحة', FontAwesomeIcons.bell, isDark),
                  ),
                  const SizedBox(height: 10),
                  if (_availableCarts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 26),
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
                          .map((cart) => CartCard(
                                cart: cart,
                                isActive: false,
                                onAccept: () => _acceptCart(cart),
                                onReject: () => _rejectCart(cart),
                              ))
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        gradient: DesignSystem.primaryGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: DesignSystem.getBrandShadow('medium'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Builder(builder: (context) {
                final String? imageUrl =
                    (profile?['profile_image'] as String?)?.trim().isNotEmpty ==
                            true
                        ? profile!['profile_image']
                        : null;
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.22),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundImage:
                        imageUrl != null ? NetworkImage(imageUrl) : null,
                    backgroundColor: Colors.transparent,
                    child: imageUrl == null
                        ? const FaIcon(FontAwesomeIcons.userTie,
                            color: Colors.white, size: 23)
                        : null,
                  ),
                );
              }),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرحباً بك 👋',
                      style: DesignSystem.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.87),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayName,
                      style: DesignSystem.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isOnline,
                onChanged: _onOnlineToggled,
                activeColor: Colors.greenAccent,
                activeTrackColor: Colors.white.withOpacity(0.36),
                inactiveThumbColor: Colors.grey[200],
                inactiveTrackColor: Colors.white.withOpacity(0.1),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.19),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isOnline
                      ? FontAwesomeIcons.solidCircleCheck
                      : FontAwesomeIcons.circleExclamation,
                  color: _isOnline ? Colors.greenAccent : Colors.orangeAccent,
                  size: 13,
                ),
                const SizedBox(width: 7),
                Text(
                  _isOnline ? 'متصل الآن' : 'غير متصل',
                  style: DesignSystem.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                if (_isUpdatingStatus) ...[
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_statusTimestamp != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.16),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(FontAwesomeIcons.clock,
                      color: Colors.white, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    _formatTime(_statusTimestamp!),
                    style: DesignSystem.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('·', style: TextStyle(color: Colors.white70)),
                  const SizedBox(width: 12),
                  const Icon(FontAwesomeIcons.locationDot,
                      color: Colors.white, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _statusPosition != null
                          ? '${_statusPosition!.latitude.toStringAsFixed(4)}, ${_statusPosition!.longitude.toStringAsFixed(4)}'
                          : (_statusError != null
                              ? _statusError!
                              : 'جاري تحديد الموقع...'),
                      style: DesignSystem.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
          final myDriverId = Provider.of<AuthService>(context, listen: false)
              .captainProfile?['id']
              ?.toString();
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
                    'تم حجز الطلب #${cart.id.substring(0, 8)} بواسطة موصل آخر'),
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
    final success =
        await _cartService.updateCartStatus(cart.id, CartStatus.cancelled);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'تم رفض الطلب #${cart.id.substring(0, 8)}'
            : 'فشل في رفض الطلب #${cart.id.substring(0, 8)}'),
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
  final Color color;
  const _StatusCardModern({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.13),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.27),
                  blurRadius: 13,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(8),
            child: FaIcon(icon, color: Colors.white, size: 18),
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
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  '$count',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: color,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// كارد الطلبات (CartCard) كامل ومنسق ومافيه أي قص أو مشاكل
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: DesignSystem.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'طلب #${cart.id}',
              style: TextStyle(
                color: DesignSystem.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    cart.customerName ?? '',
                    style: TextStyle(
                      color: DesignSystem.primaryGradient.colors.last,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(FontAwesomeIcons.user,
                    color: DesignSystem.primary, size: 14),
                const Spacer(),
                Expanded(
                  child: Text(
                    cart.customerPhone ?? '',
                    style: TextStyle(
                      color: DesignSystem.textSecondary,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
                const SizedBox(width: 5),
                Icon(FontAwesomeIcons.phone, color: Colors.grey[500], size: 12),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'المنتجات:',
              style: TextStyle(
                color: DesignSystem.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            ...cart.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  child: Text(
                    '${item.productName} (${item.quantity})',
                    style: TextStyle(
                      fontSize: 13,
                      color: DesignSystem.textPrimary,
                    ),
                  ),
                )),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  'المجموع:',
                  style: TextStyle(
                    color: DesignSystem.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${cart.totalAmount} ر.س',
                  style: TextStyle(
                    color: DesignSystem.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.close, color: Colors.red, size: 16),
                    label: const Text('رفض',
                        style: TextStyle(color: Colors.red, fontSize: 13)),
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle,
                        color: Colors.white, size: 16),
                    label: const Text('قبول الطلب',
                        style: TextStyle(color: Colors.white, fontSize: 13)),
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignSystem.success,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
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
