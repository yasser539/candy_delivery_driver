import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  static const String _darkModeKey = 'dark_mode';
  static const String _themeModeKey =
      'theme_mode'; // 'system' | 'light' | 'dark'
  static const String _languageKey = 'language';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _locationTrackingKey = 'location_tracking';

  bool _isDarkMode = false;
  String _rawThemeMode = 'system';
  String _language = 'العربية';
  bool _notificationsEnabled = true;
  bool _locationTracking = true;

  // Getters
  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode {
    switch (_rawThemeMode) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  String get language => _language;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get locationTracking => _locationTracking;

  // Initialize settings
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    // Backward compatibility: prefer theme_mode; fallback to dark_mode
    _rawThemeMode = prefs.getString(_themeModeKey) ?? 'system';
    _isDarkMode = prefs.getBool(_darkModeKey) ?? false;
    _language = prefs.getString(_languageKey) ?? 'العربية';
    _notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
    _locationTracking = prefs.getBool(_locationTrackingKey) ?? true;
    // If legacy dark_mode was set explicitly and theme_mode not saved, map it
    if ((prefs.getString(_themeModeKey) == null) &&
        prefs.containsKey(_darkModeKey)) {
      _rawThemeMode = _isDarkMode ? 'dark' : 'light';
    }
    notifyListeners();
  }

  // Save settings
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, _isDarkMode);
    await prefs.setString(_themeModeKey, _rawThemeMode);
    await prefs.setString(_languageKey, _language);
    await prefs.setBool(_notificationsKey, _notificationsEnabled);
    await prefs.setBool(_locationTrackingKey, _locationTracking);
  }

  // Update dark mode
  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    // Keep theme mode in sync for new API
    _rawThemeMode = value ? 'dark' : 'light';
    await _saveSettings();
    notifyListeners();
  }

  // New: set theme mode using system/light/dark
  Future<void> setThemeMode(String mode) async {
    // mode should be one of: 'system' | 'light' | 'dark'
    if (mode != 'system' && mode != 'light' && mode != 'dark') return;
    _rawThemeMode = mode;
    _isDarkMode = mode == 'dark'
        ? true
        : mode == 'light'
            ? false
            : _isDarkMode;
    await _saveSettings();
    notifyListeners();
  }

  // Update language
  Future<void> setLanguage(String value) async {
    _language = value;
    await _saveSettings();
    notifyListeners();
  }

  // Update notifications
  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    await _saveSettings();
    notifyListeners();
  }

  // Update location tracking
  Future<void> setLocationTracking(bool value) async {
    _locationTracking = value;
    await _saveSettings();
    notifyListeners();
  }

  // Toggle dark mode
  Future<void> toggleDarkMode() async {
    await setDarkMode(!_isDarkMode);
  }

  // Toggle notifications
  Future<void> toggleNotifications() async {
    await setNotificationsEnabled(!_notificationsEnabled);
  }

  // Toggle location tracking
  Future<void> toggleLocationTracking() async {
    await setLocationTracking(!_locationTracking);
  }
}
