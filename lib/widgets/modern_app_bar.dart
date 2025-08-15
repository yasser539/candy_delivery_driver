import 'package:flutter/material.dart';
import '../core/design_system/design_system.dart';

class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  const ModernAppBar({Key? key, required this.title, this.actions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      backgroundColor: isDark ? DesignSystem.darkSurface : DesignSystem.surface,
      elevation: 1.0,
      centerTitle: true,
      title: Text(
        title,
        style: TextStyle(
          color:
              isDark ? DesignSystem.textInverse : DesignSystem.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      iconTheme: IconThemeData(
        color: isDark ? DesignSystem.textInverse : DesignSystem.textPrimary,
        size: 26,
      ),
      actions: actions,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(22),
        ),
      ),
      toolbarHeight: 70,
      // يشتغل مع SafeArea تلقائي
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}
