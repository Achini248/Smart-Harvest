//
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'config/routes/app_router.dart';
import 'config/routes/route_names.dart';
import 'core/constants/app_strings.dart';

class SmartHarvestApp extends StatelessWidget {
  const SmartHarvestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: RouteNames.splash,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
