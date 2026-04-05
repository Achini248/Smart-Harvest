// lib/config/routes/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'route_names.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/signup_page.dart';
import '../../features/authentication/presentation/pages/profile_settings_page.dart';
import '../../features/authentication/presentation/pages/auth_selection_page.dart';
import '../../features/authentication/presentation/pages/otp_verification_page.dart';
import '../../features/home/presentation/pages/splash_screen.dart';
import '../../features/home/presentation/pages/onboarding_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/crop_management/presentation/pages/add_crop_page.dart';
import '../../features/crop_management/presentation/pages/crops_list_page.dart';
import '../../features/crop_management/presentation/pages/crop_detail_page.dart';
import '../../features/crop_management/presentation/bloc/crop_bloc.dart';
import '../../features/crop_management/domain/entities/crop.dart';
import '../../features/marketplace/presentation/pages/marketplace_home_page.dart';
import '../../features/marketplace/presentation/pages/my_orders_page.dart';
import '../../features/marketplace/presentation/pages/order_inbox_page.dart';
import '../../features/marketplace/presentation/bloc/marketplace_bloc.dart';
import '../../features/market_prices/presentation/pages/daily_market_prices_page.dart';
import '../../features/weather/presentation/pages/weather_page.dart';
import '../../features/weather/presentation/bloc/weather_bloc.dart';
import '../../features/messaging/presentation/pages/messages_list_page.dart';
import '../../features/messaging/presentation/pages/chat_page.dart';
import '../../features/messaging/presentation/bloc/message_bloc.dart';
import '../../features/messaging/domain/entities/message.dart';
import '../../features/analytics/presentation/pages/analytics_page.dart';
import '../../features/government_dashboard/presentation/pages/government_dashboard_page.dart';
import '../../features/government_dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/notifications/presentation/bloc/notification_bloc.dart';
import '../../features/help_support/presentation/pages/help_support_page.dart';
import '../../features/authentication/presentation/pages/server_settings_page.dart';
import '../../config/dependency_injection/injection_container.dart' as di;

class AppRouter {
  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return _fade(const SplashScreen(), settings);
      case RouteNames.onboarding:
        return _slide(const OnboardingPage(), settings);
      case RouteNames.authSelection:
        return _fade(const AuthSelectionPage(), settings);
      case RouteNames.home:
        return _fade(const HomePage(), settings);
      case RouteNames.login:
        return _slide(const LoginPage(), settings);
      case RouteNames.signup:
        return _slide(const SignupPage(), settings);
      case RouteNames.otpVerification:
        return _slide(const OtpVerificationPage(), settings);
      case RouteNames.profileSettings:
        return _slide(const ProfileSettingsPage(), settings);

      // Crops
      case RouteNames.myCrops:
        return MaterialPageRoute(builder: (_) => BlocProvider(
            create: (_) => di.sl<CropBloc>(), child: const CropsListPage()));
      case RouteNames.addCrop:
        return MaterialPageRoute(builder: (_) => BlocProvider(
            create: (_) => di.sl<CropBloc>(), child: const AddCropPage()));
      case RouteNames.cropDetail:
        final crop = settings.arguments as Crop;
        return MaterialPageRoute(builder: (_) => BlocProvider(
            create: (_) => di.sl<CropBloc>(), child: CropDetailPage(crop: crop)));
      case RouteNames.editCrop:
        final crop = settings.arguments as Crop;
        return MaterialPageRoute(builder: (_) => BlocProvider(
            create: (_) => di.sl<CropBloc>(), child: AddCropPage(existingCrop: crop)));

      // Marketplace
      case RouteNames.marketplaceHome:
        return MaterialPageRoute(builder: (_) => BlocProvider(
            create: (_) => di.sl<MarketplaceBloc>(), child: const MarketplaceHomePage()));
      case RouteNames.myOrders:
        return MaterialPageRoute(builder: (_) => BlocProvider(
            create: (_) => di.sl<MarketplaceBloc>(), child: const MyOrdersPage()));
      case RouteNames.orderInbox:
        return MaterialPageRoute(builder: (_) => BlocProvider(
            create: (_) => di.sl<MarketplaceBloc>(), child: const OrderInboxPage()));

      case RouteNames.dailyMarketPrices:
        return MaterialPageRoute(builder: (_) => const DailyMarketPricesPage());

      case RouteNames.weatherOverview:
        return _slide(BlocProvider(
            create: (_) => di.sl<WeatherBloc>(), child: const WeatherPage()), settings);

      case RouteNames.messagesList:
        return MaterialPageRoute(builder: (_) => BlocProvider(
            create: (_) => di.sl<MessageBloc>(), child: const MessagesListPage()));
      case RouteNames.chat:
        final conv = settings.arguments as ConversationEntity;
        return MaterialPageRoute(builder: (_) => BlocProvider(
            create: (_) => di.sl<MessageBloc>(), child: ChatPage(conversation: conv)));

      case RouteNames.notifications:
        return MaterialPageRoute(builder: (_) => BlocProvider(
            create: (_) => di.sl<NotificationBloc>(), child: const NotificationsPage()));
      case RouteNames.analytics:
        return _slide(const AnalyticsPage(), settings);
      case RouteNames.governmentDashboard:
        return MaterialPageRoute(builder: (_) => BlocProvider(
            create: (_) => di.sl<DashboardBloc>(), child: const GovernmentDashboardPage()));

      // ── Help & Support — fully implemented ──
      case RouteNames.helpSupport:
        return _slide(const HelpSupportPage(), settings);

      // ── Server / network settings ──
      case RouteNames.serverSettings:
        return _slide(const ServerSettingsPage(), settings);

      default:
        return _unknownRoute(settings);
    }
  }

  Route<dynamic> _fade(Widget page, RouteSettings settings) => PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c));

  Route<dynamic> _slide(Widget page, RouteSettings settings) => PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, a, __, c) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(a),
          child: c));

  Route<dynamic> _unknownRoute(RouteSettings settings) => MaterialPageRoute(
      builder: (_) => const Scaffold(body: Center(child: Text('Route not found'))));
}
