import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../core/services/theme_service.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/localization_service.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  @override
  void initState() {
    super.initState();
    LocalizationService().addListener(_onLocaleChanged);
  }

  void _onLocaleChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    LocalizationService().removeListener(_onLocaleChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationService().t('drawer.help_center')),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Getting Started',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              '1. Create an account by registering with your name, phone number and email.\n'
              '2. Verify your account if prompted (OTP).\n'
              '3. Browse available cars on the Home tab, or use Search to filter by location, price, brand, or type.\n'
              '4. Tap a listing to view details, then choose Rent or Buy where available.',
            ),
            const SizedBox(height: 16),
            const Text('Payments & Fees',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'We support common payment methods depending on your region (card, mobile money). Payments are handled securely and confirmed before booking is finalized.\n\n'
              'If a payment fails: check your card or mobile money balance, ensure your payment method is verified, and retry. For persistent failures, use Contact Support with details (transaction id, time).',
            ),
            const SizedBox(height: 16),
            const Text('Navigation & Common Tasks',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              '- Home: Latest and recommended listings from dealerships.\n'
              '- Search: Filter listings and find vehicles by location/price/model.\n'
              '- Profile: Manage account, documents, and contact support.\n'
              '- Saved Cars: View vehicles you saved.\n'
              '- My Bookings: See upcoming and past bookings.',
            ),
            const SizedBox(height: 16),
            const Text('Troubleshooting',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'If the app is unresponsive: try closing and reopening the app, check your Internet connection, and ensure you have the latest app version.\n\n'
              'If an action fails (booking, login, upload): note any error messages and send them via Contact Support with screenshots where possible.\n\n'
              'For urgent issues involving payments or misuse, contact our support immediately with transaction details.',
            ),
            const SizedBox(height: 24),
            Text('Still need help?',
                style: TextStyle(
                    fontSize: 16, color: ThemeService().secondaryTextColor)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => GoRouter.of(context).go('/contact'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor),
              child: Text(LocalizationService().t('help.contact_support')),
            ),
          ],
        ),
      ),
    );
  }
}
