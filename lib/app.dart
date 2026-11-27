import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_routes.dart';
import 'providers/auth_provider.dart';
import 'providers/profile_provider.dart';
import 'ui/screens/splash/splash_screen.dart';
import 'ui/screens/auth/login_screen.dart';
import 'ui/screens/auth/register_screen.dart';
import 'ui/screens/home/home_screen.dart';
import 'ui/screens/session/start_session_screen.dart';
import 'ui/screens/session/focus_active_screen.dart';
import 'ui/screens/forest/forest_screen.dart';
import 'ui/screens/stats/stats_screen.dart';
import 'ui/screens/shop/shop_screen.dart';
import 'ui/screens/profile/profile_screen.dart';

class ForrestApp extends StatelessWidget {
  const ForrestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Forrest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash:        (_) => const SplashScreen(),
        AppRoutes.login:         (_) => const LoginScreen(),
        AppRoutes.register:      (_) => const RegisterScreen(),
        AppRoutes.home:          (_) => const HomeScreen(),
        AppRoutes.startSession:  (_) => const StartSessionScreen(),
        AppRoutes.focusActive:   (_) => const FocusActiveScreen(),
        AppRoutes.forest:        (_) => const ForestScreen(),
        AppRoutes.stats:         (_) => const StatsScreen(),
        AppRoutes.shop:          (_) => const ShopScreen(),
        AppRoutes.profile:       (_) => const ProfileScreen(),
      },
    );
  }
}
