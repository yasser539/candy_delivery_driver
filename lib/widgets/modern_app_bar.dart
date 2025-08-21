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
    return SafeArea(
      bottom: false,
      child: AppBar(
        backgroundColor:
            isDark ? DesignSystem.darkSurface : DesignSystem.surface,
        elevation: 1.0,
        centerTitle: true,
        title: Text(
          title,
          style: TextStyle(
            color: isDark ? DesignSystem.textInverse : DesignSystem.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.25,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        iconTheme: IconThemeData(
          color: isDark ? DesignSystem.textInverse : DesignSystem.textPrimary,
          size: 24,
        ),
        actions: actions,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(18),
          ),
        ),
        toolbarHeight: 64,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}
