import 'package:flutter/material.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/signup_page.dart';
import '../../features/authentication/presentation/pages/profile_settings_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/onboarding_page.dart';
import '../../features/home/presentation/pages/splash_screen.dart';
import 'route_names.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Authentication Routes
      case RouteNames.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      
      case RouteNames.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingPage());
      
      case RouteNames.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      
      case RouteNames.signup:
        return MaterialPageRoute(builder: (_) => const SignupPage());
      
      // Home Routes
      case RouteNames.home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      
      // Profile Routes
      // case RouteNames.profileSettings:
      //   return MaterialPageRoute(builder: (_) => const ProfileSettingsPage());
      
      case RouteNames.accountSettings:
        return _comingSoonRoute('Account Settings');
      
      case RouteNames.helpSupport:
        return _comingSoonRoute('Help & Support');
      
      // Crop Routes (Coming Soon)
      case RouteNames.cropsList:
        return _comingSoonRoute('My Crops');
      
      case RouteNames.addCrop:
        return _comingSoonRoute('Add Crop');
      
      case RouteNames.cropDetail:
        return _comingSoonRoute('Crop Details');
      
      // Marketplace Routes
      case RouteNames.marketplace:
        return _comingSoonRoute('Marketplace');
      
      case RouteNames.myOrders:
        return _comingSoonRoute('My Orders');
      
      case RouteNames.orderInbox:
        return _comingSoonRoute('Order Inbox');
      
      // Market Prices Routes
      case RouteNames.marketPrices:
        return _comingSoonRoute('Market Prices');
      
      // Weather Routes
      case RouteNames.weather:
        return _comingSoonRoute('Weather');
      
      // Notifications Routes
      case RouteNames.notifications:
        return _comingSoonRoute('Notifications');
      
      // Messaging Routes
      case RouteNames.messagesList:
        return _comingSoonRoute('Messages');
      
      case RouteNames.chat:
        return _comingSoonRoute('Chat');
      
      // Government Dashboard Routes
      case RouteNames.governmentDashboard:
        return _comingSoonRoute('Government Dashboard');
      
      case RouteNames.surplusShortageMap:
        return _comingSoonRoute('Surplus/Shortage Map');
      
      // Analytics Routes
      case RouteNames.analytics:
        return _comingSoonRoute('Analytics');
      
      default:
        return _errorRoute('No route defined for ${settings.name}');
    }
  }

  // Error Route
  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 80,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Route Error',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Coming Soon Route
  static Route<dynamic> _comingSoonRoute(String featureName) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: Text(featureName),
          backgroundColor: const Color(0xFF4CAF50),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.construction,
                  color: Colors.orange,
                  size: 100,
                ),
                const SizedBox(height: 32),
                Text(
                  featureName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Coming Soon!',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This feature is under development',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
