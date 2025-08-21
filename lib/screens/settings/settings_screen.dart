import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/design_system/design_system.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/app_settings.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'العربية';

  Widget _buildDarkModeToggle(AppSettings appSettings) {
    final isDark = appSettings.themeMode == ThemeMode.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            FaIcon(FontAwesomeIcons.moon, color: DesignSystem.primary, size: 18),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'وضع الداكن',
                  style: DesignSystem.bodyMedium.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  isDark ? 'مفعل' : 'غير مفعل',
                  style: DesignSystem.bodySmall.copyWith(color: DesignSystem.textSecondary),
                ),
              ],
            ),
          ],
        ),
        Switch.adaptive(
          value: isDark,
          activeColor: Colors.white,
          activeTrackColor: DesignSystem.primary,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: Colors.grey[300],
          onChanged: (v) async {
            // نربط السويتش مباشرة بـ ThemeMode لتفادي عدم الاتساق
            await context.read<AppSettings>().setThemeMode(v ? 'dark' : 'light');
            if (!mounted) return;
            setState(() {});
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appSettings = context.watch<AppSettings>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? DesignSystem.darkBackground : DesignSystem.background,
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
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: DesignSystem.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: DesignSystem.getBrandShadow('medium'),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.16),
                          shape: BoxShape.circle,
                        ),
                        child: const FaIcon(
                          FontAwesomeIcons.gear,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الإعدادات',
                            style: DesignSystem.headlineSmall.copyWith(
                              color: DesignSystem.textInverse,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'تحكم بالتفضيلات لتجربة سلسة وآمنة',
                            style: DesignSystem.bodySmall.copyWith(
                              color: DesignSystem.textInverse.withOpacity(0.9),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                // ======= إعدادات المظهر =======
                _buildSettingsCard(
                  title: 'المظهر',
                  isDark: isDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDarkModeToggle(appSettings),
                      const SizedBox(height: 8),
                      Text(
                        'الوضع الحالي: '
                        '${appSettings.themeMode == ThemeMode.system ? 'حسب النظام' : appSettings.themeMode == ThemeMode.dark ? 'داكن' : 'فاتح'}',
                        style: DesignSystem.bodySmall.copyWith(color: DesignSystem.textSecondary),
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
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.18 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 14, right: 16, left: 16, bottom: 8),
            child: Text(
              title,
              style: DesignSystem.titleMedium.copyWith(
                color: isDark ? DesignSystem.textInverse : DesignSystem.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: child,
          ),
        ],
      ),
    );
  }

  Future<void> _setThemeMode(String mode) async {
    await context.read<AppSettings>().setThemeMode(mode);
    if (!mounted) return;
    setState(() {});
    _showSnack('''
${mode == 'system' ? 'تم تفعيل الوضع حسب النظام' : mode == 'dark' ? 'تم تفعيل الوضع الداكن' : 'تم تفعيل الوضع الفاتح'}
''');
  }

  Widget _buildListTile(
    String title,
    IconData icon,
    String subtitle,
    VoidCallback? onTap,
    bool isDark, {
    Color? color,
  }) {
    final subtitleWidget = subtitle.isNotEmpty
        ? Text(
            subtitle,
            style: DesignSystem.bodySmall.copyWith(color: DesignSystem.textSecondary),
          )
        : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (color ?? DesignSystem.primary).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FaIcon(icon, color: color ?? DesignSystem.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: DesignSystem.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: color ?? DesignSystem.textPrimary,
                      ),
                    ),
                    if (subtitleWidget != null) ...[
                      const SizedBox(height: 4),
                      subtitleWidget,
                    ]
                  ],
                ),
              ),
              if (onTap != null)
                FaIcon(
                  FontAwesomeIcons.chevronLeft,
                  color: DesignSystem.textSecondary,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'اختر اللغة',
          style: DesignSystem.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          // لتفادي مشاكل قص المحتوى على شاشات صغيرة
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('العربية', style: DesignSystem.bodyMedium),
                onTap: () {
                  if (!mounted) return;
                  setState(() => _selectedLanguage = 'العربية');
                  Navigator.pop(dialogContext);
                  if (!mounted) return;
                  _showSnack('تم تغيير اللغة إلى العربية');
                },
              ),
              ListTile(
                title: Text('English', style: DesignSystem.bodyMedium),
                onTap: () {
                  if (!mounted) return;
                  setState(() => _selectedLanguage = 'English');
                  Navigator.pop(dialogContext);
                  if (!mounted) return;
                  _showSnack('تم تغيير اللغة إلى الإنجليزية');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'تسجيل الخروج',
          style: DesignSystem.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Text('هل أنت متأكد من تسجيل الخروج؟', style: DesignSystem.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'إلغاء',
              style: DesignSystem.bodyMedium.copyWith(color: DesignSystem.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignSystem.error,
              foregroundColor: Colors.white, // وضوح النص
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await context.read<AuthService>().signOut();

                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );

                if (!context.mounted) return;
                _showSnack('تم تسجيل الخروج بنجاح', success: true);
              } catch (e) {
                if (!context.mounted) return;
                _showSnack('خطأ في تسجيل الخروج: ${e.toString()}', error: true);
              }
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg, {bool success = false, bool error = false}) {
    final bg = error
        ? DesignSystem.error
        : success
            ? DesignSystem.success
            : DesignSystem.primary;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: bg, duration: const Duration(seconds: 2)),
    );
  }
}
