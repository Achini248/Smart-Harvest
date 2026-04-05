import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'config/routes/app_router.dart';
import 'config/routes/route_names.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';

class SmartHarvestApp extends StatelessWidget {
  const SmartHarvestApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AppRouter appRouter = AppRouter();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(create: (_) => ThemeCubit()),
      ],
      // BlocBuilder<ThemeCubit> only updates themeMode — it does NOT re-evaluate
      // initialRoute on rebuild, so the Navigator is never reset after login.
      // Auth-based routing is handled inside SplashScreen (BlocListener).
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Smart Harvest',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('si'),
              Locale('ta'),
            ],
            // Always start at splash — SplashScreen's BlocListener handles
            // routing to home or authSelection based on auth state.
            initialRoute: RouteNames.splash,
            onGenerateRoute: appRouter.onGenerateRoute,
          );
        },
      ),
    );
  }
}