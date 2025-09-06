import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/design_system/design_system.dart';
import '../../core/theme/theme_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // legacy flag removed; rely on _themeMode and Theme.of(context)
  String _themeMode = 'system'; // 'system' | 'light' | 'dark'

  @override
  void initState() {
    super.initState();
    // Mock settings - no backend needed
    // initialize from controller
    final current = ThemeController.instance.mode.value;
    _themeMode = _stringFromMode(current);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final scheme = theme.colorScheme; // not needed after simplification
    final isDark = theme.brightness == Brightness.dark;
    final dividerColor = isDark ? Colors.white12 : Colors.black12;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? DesignSystem.darkBackground : Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (simple title, no icon, no gradient container)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'الإعدادات',
                    style: DesignSystem.headlineLarge.copyWith(
                      color: isDark
                          ? DesignSystem.textInverse
                          : DesignSystem.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                // Appearance: only title row (no subtitles/labels)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 2,
                  ),
                  leading: _coloredIcon(
                    FontAwesomeIcons.circleHalfStroke,
                    gradient: DesignSystem.accentGradient,
                  ),
                  title: Text(
                    'وضع التطبيق',
                    style: DesignSystem.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? DesignSystem.textInverse
                          : DesignSystem.textPrimary,
                    ),
                  ),
                  // No trailing arrow; tap anywhere to open picker
                  onTap: () => _showThemeModePicker(context),
                ),

                Divider(height: 14, thickness: 1, color: dividerColor),

                // (Notifications removed)

                // Language: only title row
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 2,
                  ),
                  leading: _coloredIcon(
                    FontAwesomeIcons.language,
                    gradient: DesignSystem.secondaryGradient,
                  ),
                  title: Text(
                    'اللغة',
                    style: DesignSystem.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? DesignSystem.textInverse
                          : DesignSystem.textPrimary,
                    ),
                  ),
                  // No trailing arrow
                  onTap: () => _showLanguageDialog(context),
                ),

                Divider(height: 14, thickness: 1, color: dividerColor),

                // Removed Privacy & Security

                // (Data Saver removed)

                // (Clear cache removed)

                // Help & Support
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 2,
                  ),
                  leading: _coloredIcon(
                    FontAwesomeIcons.lifeRing,
                    gradient: DesignSystem.secondaryGradient,
                  ),
                  title: Text(
                    'المساعدة والدعم',
                    style: DesignSystem.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? DesignSystem.textInverse
                          : DesignSystem.textPrimary,
                    ),
                  ),
                  onTap: () => _showComingSoon('المساعدة والدعم'),
                ),

                Divider(height: 14, thickness: 1, color: dividerColor),

                // (Rate app removed)

                // (Share app removed)

                // Removed Terms & Policies

                // App version
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 2,
                  ),
                  leading: _coloredIcon(
                    FontAwesomeIcons.circleInfo,
                    gradient: DesignSystem.secondaryGradient,
                  ),
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'إصدار التطبيق',
                        style: DesignSystem.bodySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? DesignSystem.textInverse
                              : DesignSystem.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          '1.0.0+1',
                          style: DesignSystem.bodySmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? DesignSystem.textInverse
                                : DesignSystem.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(height: 14, thickness: 1, color: dividerColor),

                // Account: Logout should be last
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 2,
                  ),
                  leading: const FaIcon(
                    FontAwesomeIcons.rightFromBracket,
                    color: Colors.red,
                  ),
                  title: Text(
                    'تسجيل الخروج',
                    style: DesignSystem.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: DesignSystem.error,
                    ),
                  ),
                  // No trailing arrow
                  onTap: () => _showLogoutDialog(context),
                ),

                const SizedBox(height: 56),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // (removed chips UI in favor of a single mode picker)

  Future<void> _setThemeMode(String mode) async {
    // apply to controller and update UI
    switch (mode) {
      case 'system':
        ThemeController.instance.setMode(ThemeMode.system);
        break;
      case 'dark':
        ThemeController.instance.setMode(ThemeMode.dark);
        break;
      default:
        ThemeController.instance.setMode(ThemeMode.light);
        break;
    }
    if (mounted) {
      setState(() {
        _themeMode = mode;
      });
    }
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

  String _stringFromMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.light:
        return 'light';
      case ThemeMode.system:
        return 'system';
    }
    // Fallback (shouldn't reach here)
    // ignore: dead_code
    return 'system';
  }

  // Render a FontAwesome icon with a gradient fill
  Widget _coloredIcon(IconData icon, {Gradient? gradient, double size = 20}) {
    final g = gradient ?? DesignSystem.primaryGradient;
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return g.createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
      },
      blendMode: BlendMode.srcIn,
      child: FaIcon(icon, size: size),
    );
  }

  // ========================

  // No labels or subtitles required per design simplification

  void _showThemeModePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: _coloredIcon(
                    FontAwesomeIcons.mobileScreen,
                    gradient: DesignSystem.accentGradient,
                  ),
                  title: const Text('حسب النظام'),
                  onTap: () {
                    _setThemeMode('system');
                    Navigator.pop(ctx);
                  },
                  trailing: _themeMode == 'system'
                      ? const FaIcon(FontAwesomeIcons.check)
                      : null,
                ),
                ListTile(
                  leading: _coloredIcon(
                    FontAwesomeIcons.sun,
                    gradient: DesignSystem.warningGradient,
                  ),
                  title: const Text('فاتح'),
                  onTap: () {
                    _setThemeMode('light');
                    Navigator.pop(ctx);
                  },
                  trailing: _themeMode == 'light'
                      ? const FaIcon(FontAwesomeIcons.check)
                      : null,
                ),
                ListTile(
                  leading: _coloredIcon(
                    FontAwesomeIcons.moon,
                    gradient: DesignSystem.primaryGradient,
                  ),
                  title: const Text('داكن'),
                  onTap: () {
                    _setThemeMode('dark');
                    Navigator.pop(ctx);
                  },
                  trailing: _themeMode == 'dark'
                      ? const FaIcon(FontAwesomeIcons.check)
                      : null,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark
              ? DesignSystem.darkBackground
              : DesignSystem.surface,
          title: Text(
            'اختر اللغة',
            style: TextStyle(
              color: isDark ? Colors.white : DesignSystem.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  'العربية',
                  style: TextStyle(
                    color: isDark ? Colors.white : DesignSystem.textPrimary,
                  ),
                ),
                onTap: () {
                  if (!mounted) return;
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
                  style: TextStyle(
                    color: isDark ? Colors.white : DesignSystem.textPrimary,
                  ),
                ),
                onTap: () {
                  if (!mounted) return;
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
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark
              ? DesignSystem.darkBackground
              : DesignSystem.surface,
          title: Text(
            'تسجيل الخروج',
            style: TextStyle(
              color: isDark ? Colors.white : DesignSystem.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'هل أنت متأكد من تسجيل الخروج؟',
            style: TextStyle(
              color: isDark ? Colors.white : DesignSystem.textPrimary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'إلغاء',
                style: TextStyle(
                  color: isDark ? Colors.white70 : DesignSystem.textSecondary,
                ),
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
        );
      },
    );
  }
}

extension _SettingsHelpers on _SettingsScreenState {
  void _showComingSoon(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title: قريبًا'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
