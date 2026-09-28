import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _settingsKey = 'app_settings';

  // Default settings
  static final Map<String, dynamic> _defaultSettings = {
    'dark_mode': false,
    'push_notifications': true,
    'email_notifications': true,
    'language': 'en',
    'currency': 'TZS',
    'auto_location': true,
    'biometric_login': false,
    'data_saver': false,
  };

  // Get all settings
  static Future<Map<String, dynamic>> getSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);
      
      if (settingsJson != null) {
        final settings = jsonDecode(settingsJson);
        // Merge with defaults to ensure all settings exist
        return {..._defaultSettings, ...settings};
      }
      
      return _defaultSettings;
    } catch (e) {
      return _defaultSettings;
    }
  }

  // Get specific setting
  static Future<T> getSetting<T>(String key) async {
    final settings = await getSettings();
    return settings[key] as T;
  }

  // Update specific setting
  static Future<void> updateSetting(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settings = await getSettings();
      
      settings[key] = value;
      await prefs.setString(_settingsKey, jsonEncode(settings));
    } catch (e) {
      throw Exception('Failed to update setting: $e');
    }
  }

  // Update multiple settings
  static Future<void> updateSettings(Map<String, dynamic> newSettings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settings = await getSettings();
      
      settings.addAll(newSettings);
      await prefs.setString(_settingsKey, jsonEncode(settings));
    } catch (e) {
      throw Exception('Failed to update settings: $e');
    }
  }

  // Reset settings to default
  static Future<void> resetSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_settingsKey, jsonEncode(_defaultSettings));
    } catch (e) {
      throw Exception('Failed to reset settings: $e');
    }
  }

  // Dark mode
  static Future<bool> isDarkMode() async {
    return await getSetting<bool>('dark_mode');
  }

  static Future<void> setDarkMode(bool value) async {
    await updateSetting('dark_mode', value);
  }

  // Push notifications
  static Future<bool> isPushNotificationsEnabled() async {
    return await getSetting<bool>('push_notifications');
  }

  static Future<void> setPushNotifications(bool value) async {
    await updateSetting('push_notifications', value);
  }

  // Email notifications
  static Future<bool> isEmailNotificationsEnabled() async {
    return await getSetting<bool>('email_notifications');
  }

  static Future<void> setEmailNotifications(bool value) async {
    await updateSetting('email_notifications', value);
  }

  // Language
  static Future<String> getLanguage() async {
    return await getSetting<String>('language');
  }

  static Future<void> setLanguage(String value) async {
    await updateSetting('language', value);
  }

  // Currency
  static Future<String> getCurrency() async {
    return await getSetting<String>('currency');
  }

  static Future<void> setCurrency(String value) async {
    await updateSetting('currency', value);
  }

  // Auto location
  static Future<bool> isAutoLocationEnabled() async {
    return await getSetting<bool>('auto_location');
  }

  static Future<void> setAutoLocation(bool value) async {
    await updateSetting('auto_location', value);
  }

  // Biometric login
  static Future<bool> isBiometricLoginEnabled() async {
    return await getSetting<bool>('biometric_login');
  }

  static Future<void> setBiometricLogin(bool value) async {
    await updateSetting('biometric_login', value);
  }

  // Data saver
  static Future<bool> isDataSaverEnabled() async {
    return await getSetting<bool>('data_saver');
  }

  static Future<void> setDataSaver(bool value) async {
    await updateSetting('data_saver', value);
  }
}
