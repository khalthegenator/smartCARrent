import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/home/bloc/home_bloc.dart';
import 'core/services/theme_service.dart';
import 'core/services/audio_service.dart';
import 'theme/app_theme.dart';
import 'routes/app_router.dart' as app_router;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await SharedPreferences.getInstance();
  await AudioService.initialize();
  await ThemeService().loadTheme();

  runApp(const SmartCarRentApp());
}

class SmartCarRentApp extends StatefulWidget {
  const SmartCarRentApp({super.key});

  @override
  State<SmartCarRentApp> createState() => _SmartCarRentAppState();
}

class _SmartCarRentAppState extends State<SmartCarRentApp> {
  @override
  void initState() {
    super.initState();
    ThemeService().addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    ThemeService().removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService();

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => AuthBloc()),
        BlocProvider<HomeBloc>(create: (context) => HomeBloc()),
      ],
      child: MaterialApp.router(
        title: 'SmartCar Rent - Tanzania',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        routerConfig: app_router.AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
