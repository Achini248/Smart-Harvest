import 'package:flutter/material.dart';
import 'route_names.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/signup_page.dart';
import '../../features/authentication/presentation/pages/profile_settings_page.dart';
import '../../features/home/presentation/pages/splash_screen.dart';
import '../../features/home/presentation/pages/onboarding_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/crop_management/presentation/pages/add_crop_page.dart';
import '../../features/crop_management/presentation/pages/crops_list_page.dart';
import '../../features/crop_management/presentation/pages/crop_detail_page.dart'; 
import '../../features/crop_management/presentation/bloc/crop_bloc.dart';
import '../../features/crop_management/domain/entities/crop.dart';
import '../../features/marketplace/presentation/pages/marketplace_home_page.dart';
import '../../features/market_prices/presentation/pages/daily_market_prices_page.dart';
import 'package:smart_harvest_app/features/weather/presentation/pages/weather_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_harvest_app/features/messaging/presentation/pages/messages_list_page.dart';
import 'package:smart_harvest_app/features/messaging/presentation/bloc/message_bloc.dart';
import '../../features/weather/presentation/bloc/weather_bloc.dart';
import '../../config/dependency_injection/injection_container.dart' as di;

class AppRouter {
  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return _fade(const SplashScreen(), settings);
      case RouteNames.onboarding:
        return _slide(const OnboardingPage(), settings);
      case RouteNames.home:
        return _fade(const HomePage(), settings);
      case RouteNames.login:
        return _slide(const LoginPage(), settings);
      case RouteNames.signup:
        return _slide(const SignupPage(), settings);
      case RouteNames.profileSettings:
        return _slide(const ProfileSettingsPage(), settings);
      case RouteNames.myCrops:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => di.sl<CropBloc>(),
            child: const CropsListPage(),
          ),
        );
      case RouteNames.addCrop:
        return _slide(const AddCropPage(), settings);
      case RouteNames.cropDetail:
        final crop = settings.arguments as Crop;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => di.sl<CropBloc>(),
            child: CropDetailPage(crop: crop),
          ),
        );
      case RouteNames.marketplaceHome:
        return _slide(const MarketplaceHomePage(), settings);
      case RouteNames.dailyMarketPrices:
        return MaterialPageRoute(
          builder: (_) => const DailyMarketPricesPage(),
        );
      case RouteNames.weatherOverview:
        return _slide(
          BlocProvider(
            create: (_) => WeatherBloc(
              getWeather: di.sl(),
            ),
            child: const WeatherPage(),
          ),
          settings,
        );
      case RouteNames.messagesList:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => di.sl<MessageBloc>(),
            child: const MessagesListPage(),
          ),
        );
      default:
        return _unknownRoute(settings);
    }
  }

  Route<dynamic> _fade(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
    );
  }

  Route<dynamic> _slide(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, a, __, c) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(a),
          child: c,
        );
      },
    );
  }

  Route<dynamic> _unknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => const Scaffold(body: Center(child: Text('Route not found'))),
    );
  }
}