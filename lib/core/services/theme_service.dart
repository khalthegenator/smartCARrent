import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';

class ThemeService {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  bool _isDarkMode = false;
  final List<VoidCallback> _listeners = [];

  bool get isDarkMode => _isDarkMode;

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    // Force light-only UI: ignore stored dark mode preference
    _isDarkMode = false;
    _notifyListeners();
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    // Theme toggling disabled to enforce white/green design
    _isDarkMode = false;
    await prefs.setBool('dark_mode', _isDarkMode);
    _notifyListeners();
  }

  Future<void> setTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    // Ignore requests to set dark theme; keep light theme
    _isDarkMode = false;
    await prefs.setBool('dark_mode', _isDarkMode);
    _notifyListeners();
  }

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  Color get primaryColor => AppTheme.primaryColor;
  Color get backgroundColor => _isDarkMode
      ? AppTheme.darkScaffoldBackground
      : AppTheme.lightScaffoldBackground;
  Color get surfaceColor =>
      _isDarkMode ? AppTheme.darkSurfaceColor : AppTheme.lightSurfaceColor;
  Color get cardColor =>
      _isDarkMode ? AppTheme.darkCardBackground : AppTheme.lightCardBackground;
  Color get textColor =>
      _isDarkMode ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
  Color get secondaryTextColor =>
      _isDarkMode ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;
  Color get borderColor =>
      _isDarkMode ? const Color(0xFF404040) : const Color(0xFFE0E0E0);
}
