import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_logo.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            // Hero Section
            _buildHeroSection(),

            // Features Section
            _buildFeaturesSection(),

            // Account Roles Section
            _buildRoleSection(),

            // About Section
            _buildAboutSection(),

            // Stats Section
            _buildStatsSection(),

            // CTA Section
            _buildCTASection(),

            // Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 700;

    return Container(
      constraints: BoxConstraints(minHeight: screenHeight * 0.68),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.9),
            AppTheme.primaryColor.withOpacity(0.7),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 72 : 24,
            vertical: isWide ? 36 : 24,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppLogo(
                size: isWide ? 140 : 110,
                showText: false,
              ),
              const SizedBox(height: 18),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Smart',
                      style: TextStyle(
                        fontSize: isWide ? 42 : 32,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
                    TextSpan(
                      text: 'CAR',
                      style: TextStyle(
                        fontSize: isWide ? 52 : 42,
                        fontWeight: FontWeight.w900,
                        color: Colors.amberAccent,
                        letterSpacing: 1.4,
                      ),
                    ),
                    TextSpan(
                      text: 'rent',
                      style: TextStyle(
                        fontSize: isWide ? 42 : 32,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Everything for smart car rentals in one place',
                style: TextStyle(
                  fontSize: isWide ? 26 : 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isWide ? 20 : 16),
              Text(
                'SmartCARrent connects customers and dealers across Tanzania with a modern booking experience, reliable support, and flexible accounts for every user.',
                style: TextStyle(
                  fontSize: isWide ? 18 : 16,
                  color: Colors.white.withOpacity(0.95),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isWide ? 40 : 30),
              Wrap(
                spacing: 20,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  _buildProfessionalButton(
                    'Get Started',
                    Colors.white,
                    AppTheme.primaryColor,
                    () {
                      context.go('/register');
                    },
                    isPrimary: true,
                    screenWidth: screenWidth,
                  ),
                  _buildProfessionalButton(
                    'Log In',
                    Colors.transparent,
                    Colors.white,
                    () {
                      context.go('/login');
                    },
                    isPrimary: false,
                    screenWidth: screenWidth,
                  ),
                ],
              ),
              SizedBox(height: isWide ? 28 : 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 22,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  'Two account types for better rental management: Customers book vehicles quickly, while Dealers list cars, manage bookings, and grow their revenue through SmartCARrent.',
                  style: TextStyle(
                    fontSize: isWide ? 16 : 15,
                    color: Colors.white.withOpacity(0.92),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfessionalButton(
    String text,
    Color backgroundColor,
    Color textColor,
    VoidCallback onPressed, {
    required bool isPrimary,
    required double screenWidth,
  }) {
    final buttonWidth = screenWidth > 600 ? 170.0 : 140.0;
    final buttonHeight = screenWidth > 600 ? 60.0 : 50.0;

    return Container(
      width: buttonWidth,
      height: buttonHeight,
      decoration: BoxDecoration(
        color: isPrimary ? backgroundColor : Colors.transparent,
        border: isPrimary ? null : Border.all(color: textColor, width: 2),
        borderRadius: BorderRadius.circular(buttonHeight / 2),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(buttonHeight / 2),
          splashColor: isPrimary
              ? Colors.white.withOpacity(0.2)
              : Colors.white.withOpacity(0.1),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: screenWidth > 600 ? 17 : 15,
                fontWeight: FontWeight.w600,
                color: textColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: MediaQuery.of(context).size.width > 600 ? 60 : 40,
      ),
      child: Column(
        children: [
          Text(
            'Why Choose SmartCARrent?',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width > 600 ? 40 : 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Experience the best car rental service in Tanzania with our modern fleet and exceptional customer service.',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width > 600 ? 20 : 18,
              color: Colors.grey[600],
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),

          // Feature Cards - Responsive
          MediaQuery.of(context).size.width > 900
              ? Row(
                  children: [
                    Expanded(
                        child: _buildFeatureCard(
                            Icons.speed_rounded,
                            'Fast & Easy',
                            'Quick booking process with instant confirmation')),
                    const SizedBox(width: 25),
                    Expanded(
                        child: _buildFeatureCard(Icons.security_rounded,
                            'Secure', 'Safe and secure payment methods')),
                    const SizedBox(width: 25),
                    Expanded(
                        child: _buildFeatureCard(
                            Icons.support_agent_rounded,
                            '24/7 Support',
                            'Round-the-clock customer assistance')),
                  ],
                )
              : Column(
                  children: [
                    _buildFeatureCard(Icons.speed_rounded, 'Fast & Easy',
                        'Quick booking process with instant confirmation'),
                    const SizedBox(height: 20),
                    _buildFeatureCard(Icons.security_rounded, 'Secure',
                        'Safe and secure payment methods'),
                    const SizedBox(height: 20),
                    _buildFeatureCard(Icons.support_agent_rounded,
                        '24/7 Support', 'Round-the-clock customer assistance'),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 45,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 25),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: screenWidth > 600 ? 60 : 40,
      ),
      child: Column(
        children: [
          Text(
            'Customer & Dealer Accounts',
            style: TextStyle(
              fontSize: screenWidth > 600 ? 40 : 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            'Choose the account that fits your needs and access the right tools for booking, listing, and managing vehicles.',
            style: TextStyle(
              fontSize: screenWidth > 600 ? 20 : 18,
              color: Colors.grey[600],
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          isWide
              ? Row(
                  children: [
                    Expanded(
                      child: _buildRoleCard(
                        'Customer',
                        'Browse and book cars in seconds',
                        'Search available vehicles, compare prices, and manage bookings from your account.',
                        Icons.person_outline,
                        AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 25),
                    Expanded(
                      child: _buildRoleCard(
                        'Dealer',
                        'List cars and track bookings',
                        'Add vehicles, approve reservations, and receive payments securely through SmartCARrent.',
                        Icons.business_outlined,
                        Colors.blueAccent,
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _buildRoleCard(
                      'Customer',
                      'Browse and book cars in seconds',
                      'Search available vehicles, compare prices, and manage bookings from your account.',
                      Icons.person_outline,
                      AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 20),
                    _buildRoleCard(
                      'Dealer',
                      'List cars and track bookings',
                      'Add vehicles, approve reservations, and receive payments securely through SmartCARrent.',
                      Icons.business_outlined,
                      Colors.blueAccent,
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(
    String title,
    String subtitle,
    String description,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 36,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
              height: 1.75,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: MediaQuery.of(context).size.width > 600 ? 60 : 40,
      ),
      color: Colors.grey[50],
      child: Column(
        children: [
          Text(
            'About SmartCARrent',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width > 600 ? 40 : 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 25),
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width > 600 ? 900 : 600),
            child: Text(
              'SmartCARrent is Tanzania\'s modern car rental marketplace for both customers and dealers. '
              'Customers can browse vehicles, book instantly, and manage trips with ease. '
              'Dealers can list cars, review bookings, and grow revenue through a trusted local platform. '
              'We make shared mobility simple, safe, and affordable across Tanzania.',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width > 600 ? 17 : 16,
                color: Colors.grey[700],
                height: 1.7,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 50),

          // About Cards - Responsive
          MediaQuery.of(context).size.width > 900
              ? Row(
                  children: [
                    Expanded(
                        child: _buildAboutCard(
                            '100+', 'Cars Available', Icons.directions_car)),
                    const SizedBox(width: 25),
                    Expanded(
                        child: _buildAboutCard(
                            '50K+', 'Happy Customers', Icons.people)),
                    const SizedBox(width: 25),
                    Expanded(
                        child: _buildAboutCard(
                            '24/7', 'Customer Support', Icons.support_agent)),
                  ],
                )
              : Column(
                  children: [
                    _buildAboutCard(
                        '100+', 'Cars Available', Icons.directions_car),
                    const SizedBox(height: 20),
                    _buildAboutCard('50K+', 'Happy Customers', Icons.people),
                    const SizedBox(height: 20),
                    _buildAboutCard(
                        '24/7', 'Customer Support', Icons.support_agent),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(String number, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            number,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 10),
          Icon(icon, color: AppTheme.primaryColor, size: 35),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: MediaQuery.of(context).size.width > 600 ? 60 : 40,
      ),
      child: Column(
        children: [
          Text(
            'Our Impact',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width > 600 ? 40 : 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 60),

          // Stats Cards - Responsive
          MediaQuery.of(context).size.width > 900
              ? Row(
                  children: [
                    Expanded(
                        child: _buildStatCard(
                            'Cities Covered', '20+', Icons.location_city)),
                    const SizedBox(width: 25),
                    Expanded(
                        child: _buildStatCard(
                            'Years in Service', '5+', Icons.history)),
                    const SizedBox(width: 25),
                    Expanded(
                        child: _buildStatCard(
                            'Satisfaction Rate', '98%', Icons.thumb_up)),
                  ],
                )
              : Column(
                  children: [
                    _buildStatCard(
                        'Cities Covered', '20+', Icons.location_city),
                    const SizedBox(height: 20),
                    _buildStatCard('Years in Service', '5+', Icons.history),
                    const SizedBox(height: 20),
                    _buildStatCard('Satisfaction Rate', '98%', Icons.thumb_up),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 45),
          const SizedBox(height: 20),
          Text(
            value,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCTASection() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: screenWidth > 600 ? 60 : 40,
      ),
      child: Column(
        children: [
          Text(
            'Ready to Start Your Journey?',
            style: TextStyle(
              fontSize: screenWidth > 600 ? 40 : 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 25),
          Text(
            'Join thousands of satisfied customers and dealers who trust SmartCARrent for seamless vehicle rental and listing.',
            style: TextStyle(
              fontSize: screenWidth > 600 ? 20 : 18,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 50),
          Wrap(
            spacing: 20,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              _buildProfessionalButton(
                'Register Now',
                AppTheme.primaryColor,
                Colors.white,
                () {
                  context.go('/register');
                },
                isPrimary: true,
                screenWidth: screenWidth,
              ),
              _buildProfessionalButton(
                'Log In',
                Colors.white,
                AppTheme.primaryColor,
                () {
                  context.go('/login');
                },
                isPrimary: false,
                screenWidth: screenWidth,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 50,
        horizontal: MediaQuery.of(context).size.width > 600 ? 60 : 40,
      ),
      color: Colors.grey[900],
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppLogo(size: 40, showText: false),
              SizedBox(width: 15),
              Text(
                'SmartCARrent',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Text(
            '© 2024 SmartCARrent. All rights reserved.',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 15),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 25,
            runSpacing: 12,
            children: [
              _buildFooterLink('Privacy Policy', () {
                print('Privacy Policy pressed');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Privacy Policy page coming soon!')),
                );
              }),
              _buildFooterLink('Terms of Service', () {
                print('Terms of Service pressed');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Terms of Service page coming soon!')),
                );
              }),
              _buildFooterLink('Contact Us', () {
                print('Contact Us pressed');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Contact page coming soon!')),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.primaryColor,
          fontSize: 15,
          decoration: TextDecoration.underline,
          decorationColor: AppTheme.primaryColor,
        ),
      ),
    );
  }
}
