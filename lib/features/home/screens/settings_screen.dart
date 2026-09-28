import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/services/theme_service.dart';
import '../../../core/services/localization_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _emailNotifications = true;
  bool _autoLocation = true;
  bool _biometricLogin = false;
  bool _dataSaver = false;
  String _language = 'en';
  String _currency = 'TZS';
  bool _isLoading = false;

  @override    
  void initState() {
    super.initState();
    _loadSettings();
    ThemeService().addListener(_onThemeChanged);
    LocalizationService().setLanguage(_language); // Hook language change
  }

  @override
  void dispose() {
    ThemeService().removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    try {
      final settings = await SettingsService.getSettings();
      setState(() {
        _emailNotifications = settings['emailNotifications'] ?? true;
        _autoLocation = settings['autoLocation'] ?? true;
        _biometricLogin = settings['biometricLogin'] ?? false;
        _dataSaver = settings['dataSaver'] ?? false;
        _language = settings['language'] ?? 'en';
        _currency = settings['currency'] ?? 'TZS';
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load settings: $e');
    }
  }

  Future<void> _updateSetting(String key, dynamic value) async {
    try {
      await SettingsService.updateSetting(key, value);
      setState(() {
        switch (key) {
          case 'dark_mode':
            ThemeService().toggleTheme();
            break;
          case 'push_notifications':
            break;
          case 'email_notifications':
            _emailNotifications = value;
            break;
          case 'auto_location':
            _autoLocation = value;
            break;
          case 'biometric_login':
            _biometricLogin = value;
            break;
          case 'data_saver':
            _dataSaver = value;
            break;
          case 'language':
            _language = value;
            break;
          case 'currency':
            _currency = value;
            break;
        }
      });
      _showSuccessSnackBar('Setting updated successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to update setting: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successColor,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeService().backgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: _showResetDialog,
            tooltip: 'Reset to defaults',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSection('Appearance', [
                    _buildSwitchTile(
                      'Dark Mode',
                      'Use light-only design (enforced)',
                      Icons.dark_mode,
                      ThemeService().isDarkMode,
                      (value) => _updateSetting('dark_mode', value),
                    ),
                  ]),
                  _buildSection('Preferences', [
                    _buildSimpleDropdownTile(
                      'Language',
                      'Choose your preferred language',
                      Icons.language,
                      _language,
                      ['English', 'Swahili'],
                      ['en', 'sw'],
                      (value) {
                        _updateSetting('language', value);
                        LocalizationService().setLanguage(value);
                      },
                    ),
                    _buildSimpleDropdownTile(
                      'Currency',
                      'Choose your preferred currency',
                      Icons.attach_money,
                      _currency,
                      ['TZS', 'USD', 'EUR'],
                      ['TZS', 'USD', 'EUR'],
                      (value) => _updateSetting('currency', value),
                    ),
                  ]),
                  _buildSection('Privacy & Security', [
                    _buildSwitchTile(
                      'Auto Location',
                      'Automatically use your current location',
                      Icons.location_on,
                      _autoLocation,
                      (value) => _updateSetting('auto_location', value),
                    ),
                    _buildSwitchTile(
                      'Biometric Login',
                      'Use fingerprint or face recognition',
                      Icons.fingerprint,
                      _biometricLogin,
                      (value) => _updateSetting('biometric_login', value),
                    ),
                  ]),
                  _buildSection('Data & Storage', [
                    _buildSwitchTile(
                      'Data Saver',
                      'Reduce data usage by loading lower quality images',
                      Icons.savings,
                      _dataSaver,
                      (value) => _updateSetting('data_saver', value),
                    ),
                  ]),
                  _buildSection('About', [
                    _buildNavigationTile(
                      'About',
                      'Version 1.0.0',
                      Icons.info,
                      _showAboutDialog,
                    ),
                    _buildNavigationTile(
                      'Privacy Policy',
                      'Learn how we protect your data',
                      Icons.privacy_tip,
                      _showPrivacyDialog,
                    ),
                    _buildNavigationTile(
                      'Terms of Service',
                      'Read our terms and conditions',
                      Icons.description,
                      _showTermsDialog,
                    ),
                    _buildNavigationTile(
                      'Help & Support',
                      'Get help with the app',
                      Icons.help,
                      _showHelpDialog,
                    ),
                  ]),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: ThemeService().cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: ThemeService().textColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: ThemeService().textColor,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildSimpleDropdownTile(
    String title,
    String subtitle,
    IconData icon,
    String currentValue,
    List<String> displayValues,
    List<String> actualValues,
    Function(String) onChanged,
  ) {
    // Find the correct display value for the current value
    // displayValue not needed; Dropdown shows currentValue directly

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: ThemeService().cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: ThemeService().textColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: ThemeService().textColor,
          ),
        ),
        trailing: DropdownButton<String>(
          value: currentValue,
          isExpanded: false,
          underline: const SizedBox(),
          items: List.generate(
            displayValues.length,
            (index) => DropdownMenuItem(
              value: actualValues[index],
              child: Text(displayValues[index]),
            ),
          ),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ),
    );
  }

  Widget _buildNavigationTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: ThemeService().cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: ThemeService().textColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: ThemeService().secondaryTextColor,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SmartCARrent - Version 1.0.0'),
            SizedBox(height: 16),
            Text('Tanzania\'s leading car rental platform.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'At SmartCARrent, we take your privacy seriously. This policy explains how we collect, use, and protect your personal information.\n\n'
            'We collect information you provide directly, such as when you create an account, book a car, or contact support.\n\n'
            'We use this information to provide and improve our services.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'By using SmartCARrent, you agree to these terms:\n\n'
            '1. You must be at least 18 years old\n'
            '2. You must provide accurate information\n'
            '3. You are responsible for your account security\n'
            '4. You must not use our service for illegal purposes',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.phone, color: AppTheme.primaryColor),
              title: const Text('Call Support'),
              subtitle: const Text('0783614233'),
              onTap: () {
                Navigator.of(context).pop();
                _showSuccessSnackBar('Call support feature coming soon!');
              },
            ),
            ListTile(
              leading: const Icon(Icons.email, color: AppTheme.primaryColor),
              title: const Text('Email Support'),
              subtitle: const Text('support@smartcarrent.tz'),
              onTap: () {
                Navigator.of(context).pop();
                _showSuccessSnackBar('Email support feature coming soon!');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Reset all settings to their default values?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetSettings();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetSettings() async {
    try {
      await SettingsService.resetSettings();
      _loadSettings();
      _showSuccessSnackBar('Settings reset to defaults');
    } catch (e) {
      _showErrorSnackBar('Failed to reset settings: $e');
    }
  }
}
