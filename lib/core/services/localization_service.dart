import 'package:flutter/foundation.dart';
import 'settings_service.dart';

class LocalizationService {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  final List<VoidCallback> _listeners = [];
  String _language = 'en';

  String get currentLanguage => _language;

  Future<void> loadLanguage() async {
    _language = await SettingsService.getLanguage();
    _notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    await SettingsService.setLanguage(lang);
    _notifyListeners();
  }

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final l in _listeners) {
      l();
    }
  }

  String t(String key) {
    final map = _translations[_language] ?? _translations['en']!;
    return map[key] ?? key;
  }

  static final Map<String, Map<String, String>> _translations = {
    'en': {
      'app.title': 'SmartCARrent',
      'menu.main': 'Main Menu',
      'menu.account': 'Account',
      'menu.support': 'Support',
      'menu.settings': 'Settings',
      'welcome.back': 'Welcome back, {name}',
      'customer.features': 'Customer features',
      'latest.listings': 'Latest listings from dealerships',
      'drawer.home': 'Home',
      'drawer.search': 'Search Cars',
      'drawer.saved': 'Saved Cars',
      'drawer.bookings': 'My Bookings',
      'drawer.active_rentals': 'Active Rentals',
      'drawer.purchases': 'Purchase History',
      'drawer.messages': 'Messages',
      'drawer.notifications': 'Notifications',
      'drawer.profile': 'My Profile',
      'drawer.edit_profile': 'Edit Profile',
      'drawer.documents': 'Uploaded Documents',
      'drawer.change_password': 'Change Password',
      'drawer.payment_methods': 'Payment Methods',
      'drawer.help_center': 'Help Center',
      'drawer.contact_support': 'Contact Support',
      'drawer.rate_app': 'Rate App',
      'drawer.terms': 'Terms & Conditions',
      'drawer.privacy': 'Privacy Policy',
      'drawer.settings': 'Settings',
      'drawer.logout': 'Logout',
      'profile.title': 'Customer Profile',
      'profile.quick_links': 'Quick links',
      'action.view_profile': 'View profile',
      'profile.view_profile': 'View profile',
      'profile.my_bookings': 'My bookings',
      'profile.saved_cars': 'Saved cars',
      'help.contact_support': 'Contact Support',
      'settings.call_support': '0783614233',
      'label.home': 'Home',
    },
    'sw': {
      'app.title': 'SmartCARrent',
      'menu.main': 'Menyu Kuu',
      'menu.account': 'Akaunti',
      'menu.support': 'Msaada',
      'menu.settings': 'Mipangilio',
      'welcome.back': 'Karibu tena, {name}',
      'customer.features': 'Vipengele vya mteja',
      'latest.listings': 'Orodha za hivi karibuni kutoka kwa madereva',
      'drawer.home': 'Nyumbani',
      'drawer.search': 'Tafuta Magari',
      'drawer.saved': 'Magari Iliyohifadhiwa',
      'drawer.bookings': 'Mabooking Yangu',
      'drawer.active_rentals': 'Mikusanyiko Inayoendelea',
      'drawer.purchases': 'Historia ya Ununuzi',
      'drawer.messages': 'Ujumbe',
      'drawer.notifications': 'Arifa',
      'drawer.profile': 'Wasifu Wangu',
      'drawer.edit_profile': 'Hariri Wasifu',
      'drawer.documents': 'Nyaraka Zilizopakuliwa',
      'drawer.change_password': 'Badilisha Nenosiri',
      'drawer.payment_methods': 'Njia za Malipo',
      'drawer.help_center': 'Kituo cha Msaada',
      'drawer.contact_support': 'Wasiliana na Msaada',
      'drawer.rate_app': 'Tathmini App',
      'drawer.terms': 'Masharti & Vigezo',
      'drawer.privacy': 'Sera ya Faragha',
      'drawer.settings': 'Mipangilio',
      'drawer.logout': 'Toka',
      'profile.title': 'Wasifu wa Mteja',
      'profile.quick_links': 'Viungo vya haraka',
      'action.view_profile': 'Angalia wasifu',
      'profile.view_profile': 'Angalia wasifu',
      'profile.my_bookings': 'Mabooking Yangu',
      'profile.saved_cars': 'Magari yaliyohifadhiwa',
      'help.contact_support': 'Wasiliana na Msaada',
      'settings.call_support': '0783614233',
      'label.home': 'Nyumbani',
    }
  };
}
