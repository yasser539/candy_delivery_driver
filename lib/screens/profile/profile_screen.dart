import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/design_system/design_system.dart';
import '../../core/design_system/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Consistent height for stat tiles
  static const double _statTileHeight = 112;
  // Mock profile data - no backend needed
  final Map<String, dynamic> _captain = {
    'name': 'عبد الرحمن الحطامي',
    'phone': '+966501234567',
    'email': 'abdulrahman@example.com',
    'city': 'الرياض',
    'region': 'المنطقة الوسطى',
    'vehicle_type': 'دراجة نارية',
    'license_number': 'ABC123456',
    'join_date': '2024-01-15',
    'total_deliveries': 156,
    'rating': 4.8,
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark
            ? DesignSystem.darkBackground
            : DesignSystem.surface,
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
                  const SizedBox(height: 12),
                  _buildDriverInfoSection(isDark),
                  const SizedBox(height: 28),
                  _buildDeliveryStatsSection(isDark),
                  const SizedBox(height: 28),
                  _buildFinancialSection(isDark),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _iconColorFor(String title, bool isDark) {
    switch (title) {
      case 'رقم الموصل':
        return AppColors.info;
      case 'رقم الهوية':
        return AppColors.accent;
      case 'تاريخ الميلاد':
        return AppColors.warning;
      case 'رقم الرخصة':
        return AppColors.success;
      case 'تاريخ الانضمام':
        return AppColors.waterBlue;
      case 'الحالة':
        return AppColors.success;
      case 'الموقع':
        return AppColors.waterAccent;
      case 'نوع السيارة':
        return AppColors.accentVibrant;
      case 'رقم اللوحة':
        return AppColors.warning;
      default:
        return isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    }
  }

  Future<void> _refreshProfile() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  String _formatDate(dynamic value) {
    if (value == null) return '-';
    try {
      var raw = value.toString().trim();
      raw = raw.replaceAll('UTC', '').replaceAll('utc', '').trim();
      if (raw.endsWith('Z')) raw = raw.substring(0, raw.length - 1);
      DateTime d;
      final epoch = int.tryParse(raw);
      if (epoch != null) {
        if (epoch > 1000000000000) {
          d = DateTime.fromMillisecondsSinceEpoch(epoch, isUtc: true).toLocal();
        } else if (epoch > 1000000000) {
          d = DateTime.fromMillisecondsSinceEpoch(
            epoch * 1000,
            isUtc: true,
          ).toLocal();
        } else {
          d = DateTime.fromMillisecondsSinceEpoch(epoch, isUtc: true).toLocal();
        }
      } else {
        d = DateTime.parse(raw);
      }
      final dd = d.day.toString().padLeft(2, '0');
      final mm = d.month.toString().padLeft(2, '0');
      final yyyy = d.year.toString();
      return '$dd/$mm/$yyyy';
    } catch (_) {
      final cleaned = value
          .toString()
          .replaceAll('UTC', '')
          .replaceAll('utc', '')
          .trim();
      return cleaned.isEmpty ? '-' : cleaned;
    }
  }

  String _formatLocation(dynamic value) {
    try {
      if (value == null) {
        final city = _captain['city']?.toString();
        final region = _captain['region']?.toString();
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

  Widget _buildProfileHeader(bool isDark) {
    final String name = _captain['name'] ?? 'الموصل';
    final String subtitle = 'موصل مياه';
    final String? imageUrl = null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildGradientAvatar(isDark: isDark, imageUrl: imageUrl),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: DesignSystem.titleLarge.copyWith(
                    color: isDark ? Colors.white : DesignSystem.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: DesignSystem.labelSmall.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.solidStar,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _captain['rating'] != null
                          ? '${(_captain['rating']).toString()} (تقييم)'
                          : 'بدون تقييم',
                      style: DesignSystem.labelSmall.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                        height: 1.2,
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

  Widget _buildGradientAvatar({required bool isDark, String? imageUrl}) {
    const double size = 76; // larger than name section
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: DesignSystem.primaryGradient, // filled gradient
        boxShadow: [
          BoxShadow(
            color: DesignSystem.primary.withOpacity(0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: imageUrl == null
            ? const FaIcon(FontAwesomeIcons.user, color: Colors.white, size: 36)
            : ClipOval(
                child: Image.network(
                  imageUrl,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                ),
              ),
      ),
    );
  }

  Widget _buildFinancialSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
          child: Text(
            'المالية',
            style: DesignSystem.titleMedium.copyWith(
              color: isDark ? Colors.white : DesignSystem.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildFinancialItemFilledGradient(
                      'النقدي',
                      '2,450 ريال',
                      FontAwesomeIcons.moneyBill,
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFinancialItemFilledGradient(
                      'الدفع الالكترونية',
                      '1,800 ريال',
                      FontAwesomeIcons.creditCard,
                      isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildFinancialItemOutlinedGradient(
                      'الإجمالي',
                      '4,250 ريال',
                      FontAwesomeIcons.wallet,
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFinancialItemOutlinedGradient(
                      'هذا الشهر',
                      '850 ريال',
                      FontAwesomeIcons.calendar,
                      isDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // _buildFinancialItem removed (using gradient variants instead)

  Widget _buildFinancialItemFilledGradient(
    String title,
    String value,
    IconData icon,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: DesignSystem.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          FaIcon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 8),
          Text(
            title,
            style: DesignSystem.bodySmall.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: DesignSystem.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialItemOutlinedGradient(
    String title,
    String value,
    IconData icon,
    bool isDark,
  ) {
    final bg = isDark ? DesignSystem.darkBackground : DesignSystem.surface;
    return Container(
      decoration: BoxDecoration(
        gradient: DesignSystem.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(1.2),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            FaIcon(icon, color: DesignSystem.primary, size: 20),
            const SizedBox(height: 8),
            Text(
              title,
              style: DesignSystem.bodySmall.copyWith(
                color: isDark ? Colors.white : DesignSystem.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: DesignSystem.titleMedium.copyWith(
                color: isDark ? Colors.white : DesignSystem.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryStatsSection(bool isDark) {
    final int delivered = (() {
      final d1 = _captain['total_deliveries'];
      final d2 = _captain['completed'];
      if (d1 is num) return d1.toInt();
      if (d2 is num) return d2.toInt();
      return 0;
    })();
    final String ratingText = (() {
      final r = _captain['rating'];
      if (r == null) return '0/5';
      if (r is num) return '${r.toStringAsFixed(1)}/5';
      final parsed = double.tryParse(r.toString());
      return parsed != null ? '${parsed.toStringAsFixed(1)}/5' : '0/5';
    })();
    final String daysWorked = (() {
      final raw = _captain['join_date'] ?? _captain['created_at'];
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          child: Text(
            'إحصائيات التوصيل',
            style: DesignSystem.titleMedium.copyWith(
              color: isDark ? Colors.white : DesignSystem.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              // Right-most in RTL: filled gradient
              Expanded(
                child: _buildStatItemFilledGradient(
                  'تم التوصيل',
                  '$delivered طلب',
                  FontAwesomeIcons.checkCircle,
                  isDark,
                ),
              ),
              const SizedBox(width: 8),
              // Center: outlined with gradient
              Expanded(
                child: _buildStatItemOutlinedGradient(
                  'متوسط التقييم',
                  ratingText,
                  FontAwesomeIcons.star,
                  isDark,
                ),
              ),
              const SizedBox(width: 8),
              // Left-most in RTL: filled gradient
              Expanded(
                child: _buildStatItemFilledGradient(
                  'أيام العمل',
                  daysWorked,
                  FontAwesomeIcons.calendarDays,
                  isDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // _buildStatItem removed (replaced by gradient variants)

  Widget _buildStatItemFilledGradient(
    String title,
    String value,
    IconData icon,
    bool isDark,
  ) {
    return SizedBox(
      height: _statTileHeight,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: DesignSystem.primaryGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 8),
            Text(
              title,
              style: DesignSystem.bodySmall.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: DesignSystem.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItemOutlinedGradient(
    String title,
    String value,
    IconData icon,
    bool isDark,
  ) {
    final bg = isDark ? DesignSystem.darkBackground : DesignSystem.surface;
    return SizedBox(
      height: _statTileHeight,
      child: Container(
        decoration: BoxDecoration(
          gradient: DesignSystem.primaryGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(1.2),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(icon, color: DesignSystem.primary, size: 20),
              const SizedBox(height: 8),
              Text(
                title,
                style: DesignSystem.bodySmall.copyWith(
                  color: isDark ? Colors.white : DesignSystem.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: DesignSystem.titleMedium.copyWith(
                  color: isDark ? Colors.white : DesignSystem.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDriverInfoSection(bool isDark) {
    final items = <({String title, String value, IconData icon})>[
      (
        title: 'رقم الموصل',
        value: _captain['phone']?.toString() ?? '-',
        icon: FontAwesomeIcons.idCard,
      ),
      (
        title: 'رقم الهوية',
        value: _captain['id_number']?.toString() ?? '-',
        icon: FontAwesomeIcons.addressCard,
      ),
      (
        title: 'تاريخ الميلاد',
        value: _formatDate(_captain['birth_date'] ?? _captain['date_of_birth']),
        icon: FontAwesomeIcons.cakeCandles,
      ),
      (
        title: 'رقم الرخصة',
        value: _captain['license_number']?.toString() ?? '-',
        icon: FontAwesomeIcons.car,
      ),
      (
        title: 'رقم اللوحة',
        value: _captain['vehicle_plate']?.toString() ?? '-',
        icon: FontAwesomeIcons.hashtag,
      ),
      (
        title: 'الحالة',
        value: _captain['status']?.toString() ?? '-',
        icon: FontAwesomeIcons.circleCheck,
      ),
      (
        title: 'الموقع',
        value: _formatLocation(_captain['location']),
        icon: FontAwesomeIcons.locationDot,
      ),
      (
        title: 'نوع السيارة',
        value: _captain['vehicle_type']?.toString() ?? '-',
        icon: FontAwesomeIcons.truck,
      ),
      (
        title: 'تاريخ الانضمام',
        value: _formatDate(_captain['join_date'] ?? _captain['created_at']),
        icon: FontAwesomeIcons.calendarPlus,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 4, 24),
          child: Text(
            'معلومات الموصل',
            style: DesignSystem.titleLarge.copyWith(
              color: isDark ? Colors.white : DesignSystem.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Remove extra horizontal padding so dividers stretch wider (closer to screen edges)
        ListView.separated(
          shrinkWrap: true,
          primary: false,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final it = items[index];
            return _buildInfoItem(it.title, it.value, it.icon, isDark);
          },
          separatorBuilder: (ctx, __) {
            final dark = Theme.of(ctx).brightness == Brightness.dark;
            final Color dividerColor = dark
                ? Colors.white24
                : Colors.grey.shade300;
            return Column(
              children: [
                const SizedBox(height: 16),
                Divider(color: dividerColor, thickness: 0.6, height: 0.6),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildInfoItem(
    String title,
    String value,
    IconData icon,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Builder(
                  builder: (_) {
                    final baseText = Text(
                      title,
                      textAlign: TextAlign
                          .right, // keep Arabic title aligned to visual right
                      style: DesignSystem.bodySmall.copyWith(
                        color: isDark
                            ? Colors.white
                            : DesignSystem.textSecondary,
                      ),
                      maxLines: title == 'تاريخ الانضمام' ? 1 : null,
                      overflow: title == 'تاريخ الانضمام'
                          ? TextOverflow.clip
                          : null,
                      softWrap: title == 'تاريخ الانضمام' ? false : true,
                    );
                    if (title == 'تاريخ الانضمام') {
                      return FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: baseText,
                      );
                    }
                    return baseText;
                  },
                ),
              ),
              const SizedBox(width: 12),
              FaIcon(icon, color: _iconColorFor(title, isDark), size: 16),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: DesignSystem.bodySmall.copyWith(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
      ],
    );
  }
}
