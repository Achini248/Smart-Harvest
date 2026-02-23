//app_router.dart
import 'package:flutter/material.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/signup_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/onboarding_page.dart';
import '../../features/home/presentation/pages/splash_screen.dart';
import 'route_names.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      
      case RouteNames.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingPage());
      
      case RouteNames.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      
      case RouteNames.signup:
        return MaterialPageRoute(builder: (_) => const SignupPage());
      
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
