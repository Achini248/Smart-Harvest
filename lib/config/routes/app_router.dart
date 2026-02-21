// lib/config/routes/app_router.dart

import 'package:flutter/material.dart';

import '../../features/home/presentation/pages/splash_screen.dart';
import '../../features/home/presentation/pages/onboarding_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/signup_page.dart';
import '../../features/authentication/presentation/pages/otp_verification_page.dart';
import '../../features/authentication/presentation/pages/profile_settings_page.dart';
import 'route_names.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return MaterialPageRoute(
            builder: (_) => const SplashScreen());

      case RouteNames.onboarding:
        return MaterialPageRoute(
            builder: (_) => const OnboardingPage());

      case RouteNames.login:
        return MaterialPageRoute(
            builder: (_) => const LoginPage());

      case RouteNames.signup:
        return MaterialPageRoute(
            builder: (_) => const SignupPage());

      case RouteNames.otp:
        final args =
            settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => OtpVerificationPage(
            phoneNumber: args['phoneNumber'] ?? '',
            verificationId: args['verificationId'],
          ),
        );

      case RouteNames.home:
        return MaterialPageRoute(
            builder: (_) => const HomePage());

      case RouteNames.profile:
        return MaterialPageRoute(
            builder: (_) => const ProfileSettingsPage());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
