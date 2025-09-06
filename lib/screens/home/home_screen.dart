import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/design_system/design_system.dart';
import '../../data/models/app_order.dart';
import '../../data/models/db_enums.dart';
import '../../data/repositories/driver_repository.dart';
import '../../widgets/currency_icon.dart';

// Mock data manager - no backend needed

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DriverRepository _repo = DriverRepository();
  List<AppOrder> _orders = [];
  bool _loading = true;
  String? _error;

  bool _isOnline = true;
  Position? _statusPosition;
  String? _statusError;
  int _monthlyDays = 0;

  @override
  void initState() {
    super.initState();

    // Load orders from Supabase
    _loadOrders();
    _monthlyDays = 15; // TODO: compute real working days if needed

    _captureStatusIfOnline();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await _repo.getMyOrders(limit: 50);
      if (!mounted) return;
      setState(() {
        _orders = results;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'تعذر تحميل الطلبات';
        _loading = false;
      });
    }
  }

  Future<void> _refresh() async {
    await _loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? DesignSystem.darkBackground : Colors.white,
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
                  if (_error != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error!,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : Colors.red.shade800,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatusCardModern(
                            title: 'الطلبات الخاصة بي',
                            count: _orders.length,
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
                            'الطلبات',
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
                  if (_loading)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: DesignSystem.primary,
                        ),
                      ),
                    )
                  else if (_orders.isEmpty)
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
                              'لا توجد طلبات حالياً',
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
                      children: _orders
                          .map(
                            (order) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: OrderCard(order: order),
                            ),
                          )
                          .toList(),
                    ),
                  SizedBox(
                    height: MediaQuery.of(context).viewPadding.bottom + 100,
                  ),
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

  // Removed mock accept/reject actions

  // ====== حضور/انصراف وموقع ======

  Future<void> _captureStatusIfOnline() async {
    if (_isOnline) {
      setState(() {});
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

// ======= UI widgets below =======

class _StatusCardModern extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final LinearGradient? gradient;
  final bool outlined;

  const _StatusCardModern({
    required this.title,
    required this.count,
    required this.icon,
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
              colors: [DesignSystem.primary, DesignSystem.primary],
            ),
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: (gradient?.colors.last ?? DesignSystem.primary).withOpacity(
              0.18,
            ),
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

class OrderCard extends StatelessWidget {
  final AppOrder order;
  const OrderCard({super.key, required this.order});

  String _statusText(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return 'قيد الانتظار';
      case OrderStatus.paid:
        return 'مدفوع';
      case OrderStatus.preparing:
        return 'قيد التحضير';
      case OrderStatus.out_for_delivery:
        return 'في الطريق';
      case OrderStatus.delivered:
        return 'تم التسليم';
      case OrderStatus.canceled:
        return 'ملغي';
    }
  }

  Color _statusColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (order.status) {
      case OrderStatus.pending:
        return (isDark ? Colors.amberAccent : Colors.amber).withOpacity(0.2);
      case OrderStatus.paid:
      case OrderStatus.preparing:
        return (isDark ? Colors.blueAccent : Colors.blue).withOpacity(0.18);
      case OrderStatus.out_for_delivery:
        return (isDark ? Colors.deepPurpleAccent : Colors.deepPurple)
            .withOpacity(0.18);
      case OrderStatus.delivered:
        return (isDark ? Colors.greenAccent : Colors.green).withOpacity(0.18);
      case OrderStatus.canceled:
        return (isDark ? Colors.redAccent : Colors.red).withOpacity(0.18);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : DesignSystem.textPrimary;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? DesignSystem.darkSurface : DesignSystem.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'طلب #${order.id}',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(width: 8),
              ShaderMask(
                shaderCallback: (rect) => DesignSystem.primaryGradient
                    .createShader(Rect.fromLTWH(0, 0, rect.width, rect.height)),
                blendMode: BlendMode.srcIn,
                child: const FaIcon(
                  FontAwesomeIcons.box,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _statusColor(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _statusText(order.status),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Text(
                    (order.totalCents / 100).toStringAsFixed(2),
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 6),
                  CurrencyIcon(width: 16, height: 16, color: textColor),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 14,
                color: isDark ? Colors.white70 : DesignSystem.textSecondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _formatDate(order.createdAt),
                  style: TextStyle(
                    color: isDark ? Colors.white70 : DesignSystem.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    // Simple human-readable date/time
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
