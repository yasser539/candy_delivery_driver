import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/design_system/design_system.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // legacy flag removed; rely on _themeMode and Theme.of(context)
  String _selectedLanguage = 'العربية';
  String _themeMode = 'system'; // 'system' | 'light' | 'dark'

  @override
  void initState() {
    super.initState();
    // Mock settings - no backend needed
    _themeMode = 'system';
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ======= الهيدر الرئيسي =======
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 22),
                  padding: const EdgeInsets.symmetric(
                    vertical: 22,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: DesignSystem.primaryGradient,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: DesignSystem.primaryGradient.colors.first
                            .withOpacity(0.11),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.16),
                          shape: BoxShape.circle,
                        ),
                        child: FaIcon(
                          FontAwesomeIcons.gear,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'الإعدادات',
                        style: DesignSystem.titleLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // ======= إعدادات المظهر =======
                _buildSettingsCard(
                  title: 'المظهر',
                  isDark: isDark,
                  child: Column(
                    children: [
                      _buildThemeChips(isDark),
                      SwitchListTile.adaptive(
                        value: false, // Mock dark mode setting
                        onChanged: (v) async {
                          // Mock dark mode change - no backend needed
                          setState(() {
                            _themeMode = v ? 'dark' : 'light';
                          });
                        },
                        title: Text(
                          'الوضع الداكن',
                          style: DesignSystem.bodyMedium.copyWith(
                            color: isDark
                                ? DesignSystem.textInverse
                                : DesignSystem.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        secondary: FaIcon(
                          FontAwesomeIcons.moon,
                          color: DesignSystem.primary,
                        ),
                        activeColor: DesignSystem.primary,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ======= إعدادات اللغة =======
                _buildSettingsCard(
                  title: 'اللغة',
                  isDark: isDark,
                  child: _buildListTile(
                    'اللغة',
                    FontAwesomeIcons.language,
                    _selectedLanguage,
                    () => _showLanguageDialog(context),
                    isDark,
                  ),
                ),

                const SizedBox(height: 18),

                // ======= إعدادات الحساب =======
                _buildSettingsCard(
                  title: 'الحساب',
                  isDark: isDark,
                  child: _buildListTile(
                    'تسجيل الخروج',
                    FontAwesomeIcons.arrowRightFromBracket,
                    'تسجيل الخروج من التطبيق',
                    () => _showLogoutDialog(context),
                    isDark,
                    color: DesignSystem.error,
                  ),
                ),

                const SizedBox(height: 18),

                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ======= بطاقة إعدادات مع عنوان =======
  Widget _buildSettingsCard({
    required String title,
    required Widget child,
    bool isDark = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? DesignSystem.darkSurface : DesignSystem.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 9,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 14,
              right: 16,
              left: 16,
              bottom: 4,
            ),
            child: Text(
              title,
              style: DesignSystem.titleMedium.copyWith(
                color: isDark
                    ? DesignSystem.textInverse
                    : DesignSystem.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }

  // (أُزيلت الدالة القديمة الخاصة بالسويتش لأنها لم تعد مستخدمة)

  // ======= اختيار المظهر (Chips) =======
  Widget _buildThemeChips(bool isDark) {
    final options = [
      {
        'label': 'النظام',
        'value': 'system',
        'icon': FontAwesomeIcons.mobileScreen,
      },
      {'label': 'فاتح', 'value': 'light', 'icon': FontAwesomeIcons.sun},
      {'label': 'داكن', 'value': 'dark', 'icon': FontAwesomeIcons.moon},
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options.map((opt) {
          final selected = _themeMode == opt['value'];
          return ChoiceChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(
                  opt['icon'] as IconData,
                  size: 14,
                  color: selected ? Colors.white : DesignSystem.primary,
                ),
                const SizedBox(width: 6),
                Text(opt['label'] as String),
              ],
            ),
            selected: selected,
            onSelected: (_) => _setThemeMode(opt['value'] as String),
            selectedColor: DesignSystem.primary,
            backgroundColor: DesignSystem.primary.withOpacity(0.08),
            labelStyle: DesignSystem.labelMedium.copyWith(
              color: selected ? Colors.white : DesignSystem.primary,
              fontWeight: FontWeight.w700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _setThemeMode(String mode) async {
    // Mock theme mode change - no backend needed
    setState(() {
      _themeMode = mode;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mode == 'system'
              ? 'تم تفعيل الوضع حسب النظام'
              : mode == 'dark'
              ? 'تم تفعيل الوضع الداكن'
              : 'تم تفعيل الوضع الفاتح',
        ),
        backgroundColor: DesignSystem.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ======= عنصر القائمة =======
  Widget _buildListTile(
    String title,
    IconData icon,
    String subtitle,
    VoidCallback? onTap,
    bool isDark, {
    Color? color,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: (color ?? DesignSystem.primary).withOpacity(0.13),
          borderRadius: BorderRadius.circular(10),
        ),
        child: FaIcon(icon, color: color ?? DesignSystem.primary, size: 22),
      ),
      title: Text(
        title,
        style: DesignSystem.bodyMedium.copyWith(
          fontWeight: FontWeight.w700,
          color: color ?? DesignSystem.textPrimary,
        ),
      ),
      subtitle: subtitle.isNotEmpty
          ? Text(
              subtitle,
              style: DesignSystem.bodySmall.copyWith(
                color: DesignSystem.textSecondary,
              ),
            )
          : null,
      trailing: onTap != null
          ? FaIcon(
              FontAwesomeIcons.chevronLeft,
              color: DesignSystem.textSecondary,
              size: 18,
            )
          : null,
      onTap: onTap,
    );
  }

  // ========================

  // (أُزيلت دالة التبديل المباشر لأنها استبدلت بخيار وضع النظام/فاتح/داكن)

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: DesignSystem.surface,
        title: Text(
          'اختر اللغة',
          style: TextStyle(
            color: DesignSystem.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                'العربية',
                style: TextStyle(color: DesignSystem.textPrimary),
              ),
              onTap: () {
                if (!mounted) return;
                setState(() => _selectedLanguage = 'العربية');
                Navigator.pop(dialogContext);
                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text('تم تغيير اللغة إلى العربية'),
                    backgroundColor: DesignSystem.primary,
                  ),
                );
              },
            ),
            ListTile(
              title: Text(
                'English',
                style: TextStyle(color: DesignSystem.textPrimary),
              ),
              onTap: () {
                if (!mounted) return;
                setState(() => _selectedLanguage = 'English');
                Navigator.pop(dialogContext);
                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text('تم تغيير اللغة إلى الإنجليزية'),
                    backgroundColor: DesignSystem.primary,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: DesignSystem.surface,
        title: Text(
          'تسجيل الخروج',
          style: TextStyle(
            color: DesignSystem.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'هل أنت متأكد من تسجيل الخروج؟',
          style: TextStyle(color: DesignSystem.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'إلغاء',
              style: TextStyle(color: DesignSystem.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              // Mock logout - no backend needed
              ScaffoldMessenger.of(this.context).showSnackBar(
                SnackBar(
                  content: Text('تم تسجيل الخروج بنجاح'),
                  backgroundColor: DesignSystem.success,
                ),
              );
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }
}
