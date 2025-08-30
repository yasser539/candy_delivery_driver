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
  String _selectedLanguage = 'العربية';
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
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? DesignSystem.darkBackground : Colors.white,
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

                // Appearance section (plain, no card)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'المظهر',
                    style: DesignSystem.titleLarge.copyWith(
                      color: isDark
                          ? DesignSystem.textInverse
                          : DesignSystem.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildThemeChips(isDark),
                SwitchListTile.adaptive(
                  value: _themeMode == 'dark',
                  onChanged: (v) async {
                    final mode = v ? ThemeMode.dark : ThemeMode.light;
                    ThemeController.instance.setMode(mode);
                    setState(() {
                      _themeMode = v ? 'dark' : 'light';
                    });
                  },
                  title: Text(
                    'الوضع الداكن',
                    style: DesignSystem.bodyMedium.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  secondary: FaIcon(
                    FontAwesomeIcons.moon,
                    color: scheme.primary,
                    size: 18,
                  ),
                  activeColor: scheme.primary,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                ),

                const SizedBox(height: 18),

                // Language section (plain list tile without leading icon)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'اللغة',
                    style: DesignSystem.titleLarge.copyWith(
                      color: isDark
                          ? DesignSystem.textInverse
                          : DesignSystem.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  title: Text(
                    'اللغة',
                    style: DesignSystem.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color:
                          isDark ? DesignSystem.textInverse : DesignSystem.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    _selectedLanguage,
                    style: DesignSystem.bodySmall.copyWith(
                      color: DesignSystem.textSecondary,
                    ),
                  ),
                  trailing: FaIcon(
                    FontAwesomeIcons.chevronLeft,
                    color: DesignSystem.textSecondary,
                    size: 18,
                  ),
                  onTap: () => _showLanguageDialog(context),
                ),

                const SizedBox(height: 18),

                // Account section (plain list tile without leading icon)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'الحساب',
                    style: DesignSystem.titleLarge.copyWith(
                      color: isDark
                          ? DesignSystem.textInverse
                          : DesignSystem.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  title: Text(
                    'تسجيل الخروج',
                    style: DesignSystem.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: DesignSystem.error,
                    ),
                  ),
                  subtitle: Text(
                    'تسجيل الخروج من التطبيق',
                    style: DesignSystem.bodySmall.copyWith(
                      color: DesignSystem.textSecondary,
                    ),
                  ),
                  trailing: FaIcon(
                    FontAwesomeIcons.chevronLeft,
                    color: DesignSystem.textSecondary,
                    size: 18,
                  ),
                  onTap: () => _showLogoutDialog(context),
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

  // ========================

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
