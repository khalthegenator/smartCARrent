import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/home/screens/admin_dashboard.dart';
import '../features/home/screens/dealer_dashboard.dart';
import '../features/home/screens/user_dashboard.dart';
import '../features/home/screens/landing_screen.dart';
import '../features/home/screens/help_center_screen.dart';
import '../features/home/screens/contact_support_screen.dart';
import '../features/home/screens/terms_screen.dart';
import '../features/home/screens/privacy_policy_screen.dart';
import '../features/home/screens/payment_test_screen.dart';

class AppRouter {
  static List<GoRoute> get routes => [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const LandingScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const UserDashboard(),
        ),
        GoRoute(
          path: '/dealer-dashboard',
          builder: (context, state) => const DealerDashboard(),
        ),
        GoRoute(
          path: '/admin-dashboard',
          builder: (context, state) => const AdminDashboard(),
        ),
        GoRoute(
          path: '/admin-dashboard/customers',
          builder: (context, state) => const AdminCustomersScreen(),
        ),
        GoRoute(
          path: '/admin-dashboard/staff',
          builder: (context, state) => const AdminStaffScreen(),
        ),
        GoRoute(
          path: '/admin-dashboard/dealers',
          builder: (context, state) => const DealerAuthorizationScreen(),
        ),
        GoRoute(
          path: '/admin-dashboard/transactions',
          builder: (context, state) => const AdminTransactionsScreen(),
        ),
        GoRoute(
          path: '/admin-dashboard/payments',
          builder: (context, state) => const AdminFinanceOverviewScreen(),
        ),
        GoRoute(
          path: '/admin-dashboard/vehicles',
          builder: (context, state) => const AdminVehicleModerationScreen(),
        ),
        GoRoute(
          path: '/admin-dashboard/finance',
          builder: (context, state) => const AdminFinanceOverviewScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/help',
          builder: (context, state) => const HelpCenterScreen(),
        ),
        GoRoute(
          path: '/contact',
          builder: (context, state) => const ContactSupportScreen(),
        ),
        GoRoute(
          path: '/terms',
          builder: (context, state) => const TermsScreen(),
        ),
        GoRoute(
          path: '/privacy',
          builder: (context, state) => const PrivacyPolicyScreen(),
        ),
        GoRoute(
          path: '/payments/test',
          builder: (context, state) => const PaymentTestScreen(),
        ),
      ];

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: routes,
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
}
