import 'package:flutter/material.dart';
import 'route_names.dart';

// Authentication feature
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/signup_page.dart';
import '../../features/authentication/presentation/pages/otp_verification_page.dart';
import '../../features/authentication/presentation/pages/profile_settings_page.dart';

// Home feature
import '../../features/home/presentation/pages/splash_screen.dart';
import '../../features/home/presentation/pages/onboarding_page.dart';
import '../../features/home/presentation/pages/home_page.dart';

// Crop management feature
import '../../features/crop_management/presentation/pages/add_crop_page.dart';
import '../../features/crop_management/presentation/pages/crops_list_page.dart';
import '../../features/crop_management/presentation/pages/crop_detail_page.dart'; // මෙතන නම 'details' විය යුතුයි

// Marketplace feature
import '../../features/marketplace/presentation/pages/marketplace_home_page.dart';
import '../../features/marketplace/presentation/pages/my_orders_page.dart';
import '../../features/marketplace/presentation/pages/order_inbox_page.dart';

// Market prices feature
import '../../features/market_prices/presentation/pages/daily_market_prices_page.dart';

// Weather feature
import '../../features/weather/presentation/pages/weather_page.dart';

// Notifications feature
import '../../features/notifications/presentation/pages/notifications_page.dart';

// Messaging feature
import '../../features/messaging/presentation/pages/messages_list_page.dart';
import '../../features/messaging/presentation/pages/chat_page.dart';

// Government dashboard feature
import '../../features/government_dashboard/presentation/pages/government_dashboard_page.dart';

// Analytics feature
import '../../features/analytics/presentation/pages/analytics_page.dart';

class AppRouter {
  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Core
      case RouteNames.splash:
        return _fade(const SplashScreen(), settings);
      case RouteNames.onboarding:
        return _slide(const OnboardingPage(), settings);
      case RouteNames.home:
        return _fade(const HomePage(), settings);

      // Authentication
      case RouteNames.login:
        return _slide(const LoginPage(), settings);
      case RouteNames.signup:
        return _slide(const SignupPage(), settings);
      case RouteNames.otpVerification:
        return _slide(const OtpVerificationPage(), settings);
      case RouteNames.profileSettings:
        return _slide(const ProfileSettingsPage(), settings);

      // Crop management
      case RouteNames.myCrops:
        // const අයින් කළා මොකද MyCropsPage එකේ const ගැටළු එන නිසා
        return _slide(MyCropsPage(), settings); 
      case RouteNames.addCrop:
        return _slide(const AddCropPage(), settings);
      case RouteNames.cropDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        return _slide(
          CropDetailsPage(
            cropId: args?['cropId'] as String?,
          ),
          settings,
        );

      // Marketplace & prices
      case RouteNames.marketplaceHome:
        return _slide(const MarketplaceHomePage(), settings);
      case RouteNames.myOrders:
        return _slide(const MyOrdersPage(), settings);
      case RouteNames.orderInbox:
        return _slide(const OrderInboxPage(), settings);
      case RouteNames.dailyMarketPrices:
        return _slide(const DailyMarketPricesPage(), settings);

      // Weather
      case RouteNames.weatherOverview:
        return _slide(const WeatherPage(), settings);

      // Notifications
      case RouteNames.notifications:
        return _slide(const NotificationsPage(), settings);

      // Messaging
      case RouteNames.messagesList:
        return _slide(const MessagesListPage(), settings);
      case RouteNames.chat:
        final args = settings.arguments as Map<String, dynamic>?;
        return _slide(
          ChatPage(
            // ChatPage එකේ ඉල්ලන්නේ 'conversation' object එකයි
            conversation: args?['conversation'], 
          ),
          settings,
        );

      // Government dashboard & analytics
      case RouteNames.governmentDashboard:
        return _slide(const GovernmentDashboardPage(), settings);
      case RouteNames.analytics:
        return _slide(const AnalyticsPage(), settings);

      default:
        return _unknownRoute(settings);
    }
  }

  // Transitions (Fade & Slide)
  Route<dynamic> _fade(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  Route<dynamic> _slide(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0.0, 0.05),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }

  Route<dynamic> _unknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Page not found')),
        body: Center(child: Text('No route defined for "${settings.name}"')),
      ),
    );
  }
}