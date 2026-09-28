import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';

class AuthWrapper extends StatefulWidget {
  final Widget child;

  const AuthWrapper({super.key, required this.child});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInitialized = false;
  Map<String, dynamic>? _currentUser;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final user = await AuthService.getCurrentUser();
      final token = await AuthService.getAuthToken();

      setState(() {
        _currentUser = user;
        _isInitialized = true;
      });

      // If user is not authenticated, navigate to landing page
      if (user == null || token == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          try {
            GoRouter.of(context).go('/');
          } catch (e) {
            // Retry once next frame if router not yet available
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                try {
                  GoRouter.of(context).go('/');
                } catch (_) {}
              }
            });
          }
        });
      }
    } catch (e) {
      setState(() {
        _isInitialized = true;
      });
      // Navigate to landing page on error
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        try {
          GoRouter.of(context).go('/');
        } catch (e) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              try {
                GoRouter.of(context).go('/');
              } catch (_) {}
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          backgroundColor: ThemeService().backgroundColor,
          body: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return widget.child;
  }
}
