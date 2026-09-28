import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Privacy Policy'),
          backgroundColor: AppTheme.primaryColor),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Privacy Policy',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text('Last updated: 2026-07-06'),
            SizedBox(height: 12),
            Text(
              'SmartCARrent is committed to protecting your privacy. This policy explains how we collect, use, and share your personal information.\n\n'
              '1. Information collected: We collect information you provide directly (registration, bookings), device and usage information, and transactional details.\n\n'
              '2. Use of information: We use data to provide services, process payments, detect fraud, and communicate with you (notifications, support).\n\n'
              '3. Sharing: We may share data with dealers, payment processors, and service providers as necessary to complete bookings. We do not sell personal data.\n\n'
              '4. Security: We take reasonable measures to protect personal data. However, no system is perfectly secure—report any concerns to support immediately.\n\n'
              '5. Rights: You may request access, correction, or deletion of your account data by contacting support.\n\n'
              '6. Changes: We will notify users of major changes to this policy.\n\n'
              'For legal compliance or disputes, applicable local laws will apply. Contact support for privacy-related requests.',
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
