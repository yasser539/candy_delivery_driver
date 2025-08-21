import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../blocs/app_bloc.dart';
import 'navigation/candy_navigation_bar.dart';
import '../core/design_system/design_system.dart';
import '../core/services/app_settings.dart';

class NavigationWrapper extends StatelessWidget {
  final Widget child;
  final bool showBackButton;
  final Function(int)? onNavTap;

  const NavigationWrapper({
    super.key,
    required this.child,
    this.showBackButton = true,
    this.onNavTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppSettings, AppBloc>(
      builder: (context, appSettings, appBloc, _) {
        final isDarkMode = appSettings.isDarkMode;

        return Scaffold(
          backgroundColor: isDarkMode
              ? DesignSystem.darkBackground
              : DesignSystem.background,
          body: Stack(
            children: [
              // Main content
              child,

              // Navigation bar at bottom
              CandyNavigationBar(
                onNavTap: onNavTap ??
                    (index) {
                      if (appBloc.currentIndex != index) {
                        appBloc.add(SetCurrentIndexEvent(index));
                      }
                    },
              ),
            ],
          ),
        );
      },
    );
  }
}
