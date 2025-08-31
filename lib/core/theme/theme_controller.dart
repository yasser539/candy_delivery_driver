import 'package:flutter/material.dart';

/// Central controller for app theme mode using ValueNotifier.
class ThemeController {
  ThemeController._();
  static final ThemeController instance = ThemeController._();

  /// Current theme mode; defaults to system.
  final ValueNotifier<ThemeMode> mode = ValueNotifier<ThemeMode>(
    ThemeMode.system,
  );

  void setMode(ThemeMode newMode) {
    if (mode.value != newMode) {
      mode.value = newMode;
    }
  }
}
