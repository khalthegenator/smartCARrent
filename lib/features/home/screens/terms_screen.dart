import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Terms & Conditions'),
          backgroundColor: AppTheme.primaryColor),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Terms & Conditions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text('Last updated: 2026-07-06'),
            SizedBox(height: 12),
            Text(
              'Welcome to SmartCARrent. By using this app you agree to the following terms and conditions which govern your access and use of our service.\n\n'
              '1. Eligibility: You must be 18 years or older and legally able to enter contracts to use our services.\n\n'
              '2. Account Responsibility: You are responsible for maintaining the confidentiality of your account and password. All activity under your account is your responsibility.\n\n'
              '3. Bookings and Payments: Booking a vehicle may require a payment or deposit. The payment terms (including refund and cancellation policies) are stated at checkout for each listing and must be followed.\n\n'
              '4. User Conduct: Do not post fraudulent content or attempt to manipulate listings. Respect property and dealers’ rules.\n\n'
              '5. Liability and Disclaimers: SmartCARrent acts as a marketplace connecting customers with dealers. We are not the owner of listed vehicles. We make reasonable efforts to ensure listings are accurate, but cannot guarantee every detail.\n\n'
              '6. Changes to Service: We reserve the right to modify or discontinue features at any time.\n\n'
              '7. Governing Law: These terms are governed by the applicable laws of the user’s jurisdiction.\n\n'
              'For detailed policy matters and dispute resolution, please contact support or review our Privacy Policy and additional notices in the app.',
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
