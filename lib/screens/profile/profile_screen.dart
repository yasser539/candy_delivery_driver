import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/design_system/design_system.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _captain;
  RealtimeChannel? _profileChannel;

  String _formatDate(dynamic value) {
    if (value == null) return '-';
    try {
      final d = DateTime.parse(value.toString());
      final dd = d.day.toString().padLeft(2, '0');
      final mm = d.month.toString().padLeft(2, '0');
      final yyyy = d.year.toString();
      return '$dd/$mm/$yyyy';
    } catch (_) {
      return value.toString();
    }
  }

  String _formatLocation(dynamic value) {
    try {
      if (value == null) {
        final city = _captain?['city']?.toString();
        final region = _captain?['region']?.toString();
        if (city != null &&
            city.isNotEmpty &&
            region != null &&
            region.isNotEmpty) {
          return '$city، $region';
        }
        if (city != null && city.isNotEmpty) return city;
        if (region != null && region.isNotEmpty) return region;
        return '-';
      }
      if (value is Map) {
        final address = value['address']?.toString();
        if (address != null && address.isNotEmpty) return address;
        final lat = value['latitude']?.toString();
        final lng = value['longitude']?.toString();
        if (lat != null && lng != null) return '$lat, $lng';
      }
      if (value is String && value.trim().isNotEmpty) {
        return value;
      }
    } catch (_) {}
    return '-';
  }

  @override
  void initState() {
    super.initState();
    // Listen to AuthService changes to auto-refresh
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = context.read<AuthService>();
      setState(() => _captain = auth.captainProfile);
      auth.addListener(_onAuthChanged);
      _subscribeToCaptainRealtime();
    });
  }

  void _onAuthChanged() {
    if (!mounted) return;
    final auth = context.read<AuthService>();
    setState(() => _captain = auth.captainProfile);
    // Ensure subscription follows the current captain id
    _subscribeToCaptainRealtime();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? DesignSystem.darkBackground : DesignSystem.background,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshProfile,
            color: DesignSystem.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(isDark),
                  const SizedBox(height: 22),
                  _buildFinancialSection(isDark),
                  const SizedBox(height: 12),
                  _buildDeliveryStatsSection(isDark),
                  const SizedBox(height: 12),
                  _buildDriverInfoSection(isDark),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    try {
      context.read<AuthService>().removeListener(_onAuthChanged);
    } catch (_) {}
    try {
      _profileChannel?.unsubscribe();
    } catch (_) {}
    super.dispose();
  }

  Future<void> _refreshProfile() async {
    final id = _captain?['id']?.toString();
    if (id == null || id.isEmpty) return;
    try {
      final data = await SupabaseService.client
          .from('delivery_captains')
          .select('*')
          .eq('id', id)
          .single();
      if (!mounted) return;
      setState(() {
        _captain = Map<String, dynamic>.from(data);
      });
    } catch (_) {}
  }

  void _subscribeToCaptainRealtime() {
    final id = _captain?['id']?.toString();
    if (id == null || id.isEmpty) return;
    try {
      _profileChannel?.unsubscribe();
      _profileChannel = SupabaseService.client
          .channel('public:delivery_captains')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'delivery_captains',
            callback: (payload) async {
              try {
                final data = await SupabaseService.client
                    .from('delivery_captains')
                    .select('*')
                    .eq('id', id)
                    .single();
                if (!mounted) return;
                setState(() {
                  _captain = Map<String, dynamic>.from(data);
                });
              } catch (_) {}
            },
          )
          .subscribe();
    } catch (_) {}
  }

  Widget _buildProfileHeader(bool isDark) {
    final String name =
        (_captain?['name'] as String?)?.trim().isNotEmpty == true
            ? _captain!['name']
            : 'الموصل';
    final String subtitle =
        (_captain?['position'] as String?)?.trim().isNotEmpty == true
            ? _captain!['position']
            : 'موصل مياه';
    final String? imageUrl =
        (_captain?['profile_image'] as String?)?.trim().isNotEmpty == true
            ? _captain!['profile_image']
            : null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: DesignSystem.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: DesignSystem.primary.withOpacity(0.10),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // المعلومات (يسار)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: DesignSystem.titleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: DesignSystem.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.93),
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      FontAwesomeIcons.solidStar,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _captain != null && _captain!['rating'] != null
                          ? '${(_captain!['rating']).toString()} (تقييم)'
                          : 'بدون تقييم',
                      style: DesignSystem.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.87),
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // الصورة الشخصية (يمين)
          CircleAvatar(
            radius: 27,
            backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
            backgroundColor: Colors.white.withOpacity(0.18),
            child: imageUrl == null
                ? const FaIcon(
                    FontAwesomeIcons.user,
                    color: Colors.white,
                    size: 28,
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSection(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: DesignSystem.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'المالية',
              style: DesignSystem.titleMedium.copyWith(
                color: DesignSystem.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildFinancialItem(
                        'النقدي',
                        '2,450',
                        FontAwesomeIcons.moneyBill,
                        DesignSystem.success,
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFinancialItem(
                        'فيزا',
                        '1,800',
                        FontAwesomeIcons.creditCard,
                        DesignSystem.info,
                        isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildFinancialItem(
                        'الإجمالي',
                        '4,250',
                        FontAwesomeIcons.wallet,
                        DesignSystem.primary,
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFinancialItem(
                        'هذا الشهر',
                        '850',
                        FontAwesomeIcons.calendar,
                        DesignSystem.warning,
                        isDark,
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

  Widget _buildFinancialItem(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? DesignSystem.darkSurface : DesignSystem.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          FaIcon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: DesignSystem.bodySmall.copyWith(
              color: DesignSystem.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          // Replace occurrences of the word 'ريال' with the currency SVG icon
          _buildCurrencyWidget(
            value,
            style: DesignSystem.titleMedium.copyWith(
              color: DesignSystem.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyWidget(String rawValue, {TextStyle? style}) {
    // Remove common Arabic currency words and trim
    final cleaned =
        rawValue.replaceAll('الريال', '').replaceAll('ريال', '').trim();

    // Just return the cleaned amount as text (no currency icon)
    return Text(
      cleaned,
      style: style,
    );
  }

  Widget _buildDeliveryStatsSection(bool isDark) {
    final int delivered = (() {
      final d1 = _captain?['total_deliveries'];
      final d2 = _captain?['completed'];
      if (d1 is num) return d1.toInt();
      if (d2 is num) return d2.toInt();
      return 0;
    })();
    final String ratingText = (() {
      final r = _captain?['rating'];
      if (r == null) return '0/5';
      if (r is num) return '${r.toStringAsFixed(1)}/5';
      final parsed = double.tryParse(r.toString());
      return parsed != null ? '${parsed.toStringAsFixed(1)}/5' : '0/5';
    })();
    final String daysWorked = (() {
      final raw = _captain?['join_date'] ?? _captain?['created_at'];
      try {
        final d = DateTime.parse(raw.toString());
        final now = DateTime.now();
        final diff = now.difference(d).inDays;
        final days = diff < 0 ? 0 : diff;
        return '$days يوم';
      } catch (_) {
        return '-';
      }
    })();

    return Container(
      decoration: BoxDecoration(
        color: DesignSystem.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'إحصائيات التوصيل',
              style: DesignSystem.titleMedium.copyWith(
                color: DesignSystem.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'تم التوصيل',
                    '$delivered طلب',
                    FontAwesomeIcons.checkCircle,
                    DesignSystem.success,
                    isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    'متوسط التقييم',
                    ratingText,
                    FontAwesomeIcons.star,
                    DesignSystem.primary,
                    isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    'أيام العمل',
                    daysWorked,
                    FontAwesomeIcons.calendarDays,
                    DesignSystem.info,
                    isDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? DesignSystem.darkSurface : DesignSystem.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          FaIcon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: DesignSystem.bodySmall.copyWith(
              color: DesignSystem.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: DesignSystem.titleMedium.copyWith(
              color: DesignSystem.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverInfoSection(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: DesignSystem.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'معلومات الموصل',
              style: DesignSystem.titleMedium.copyWith(
                color: DesignSystem.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoItem(
                  'رقم الموصل',
                  _captain?['phone']?.toString() ?? '-',
                  FontAwesomeIcons.idCard,
                  isDark,
                ),
                const SizedBox(height: 12),
                _buildInfoItem(
                  'رقم الهوية',
                  _captain?['id_number']?.toString() ?? '-',
                  FontAwesomeIcons.addressCard,
                  isDark,
                ),
                const SizedBox(height: 12),
                _buildInfoItem(
                  'تاريخ الميلاد',
                  _formatDate(
                      _captain?['birth_date'] ?? _captain?['date_of_birth']),
                  FontAwesomeIcons.cakeCandles,
                  isDark,
                ),
                const SizedBox(height: 12),
                _buildInfoItem(
                  'رقم الرخصة',
                  _captain?['license_number']?.toString() ?? '-',
                  FontAwesomeIcons.car,
                  isDark,
                ),
                const SizedBox(height: 12),
                _buildInfoItem(
                  'تاريخ الانضمام',
                  _formatDate(
                      _captain?['join_date'] ?? _captain?['created_at']),
                  FontAwesomeIcons.calendarPlus,
                  isDark,
                ),
                const SizedBox(height: 12),
                _buildInfoItem(
                  'الحالة',
                  _captain?['status']?.toString() ?? '-',
                  FontAwesomeIcons.circleCheck,
                  isDark,
                ),
                const SizedBox(height: 12),
                _buildInfoItem(
                  'الموقع',
                  _formatLocation(_captain?['location']),
                  FontAwesomeIcons.locationDot,
                  isDark,
                ),
                const SizedBox(height: 12),
                _buildInfoItem(
                  'نوع السيارة',
                  _captain?['vehicle_type']?.toString() ?? '-',
                  FontAwesomeIcons.truck,
                  isDark,
                ),
                const SizedBox(height: 12),
                _buildInfoItem(
                  'رقم اللوحة',
                  _captain?['vehicle_plate']?.toString() ?? '-',
                  FontAwesomeIcons.hashtag,
                  isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    String title,
    String value,
    IconData icon,
    bool isDark,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: DesignSystem.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: FaIcon(
            icon,
            color: DesignSystem.primary,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: DesignSystem.bodySmall.copyWith(
                  color: DesignSystem.textSecondary,
                ),
              ),
              Text(
                value,
                style: DesignSystem.bodyMedium.copyWith(
                  color: DesignSystem.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
