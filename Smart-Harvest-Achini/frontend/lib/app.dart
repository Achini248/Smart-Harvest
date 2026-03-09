import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'config/routes/app_router.dart';
import 'config/routes/route_names.dart';
import 'core/theme/app_theme.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/authentication/presentation/bloc/auth_state.dart';

class SmartHarvestApp extends StatelessWidget {
  const SmartHarvestApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AppRouter appRouter = AppRouter();

    return BlocProvider(
      create: (_) => AuthBloc(),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          String initialRoute;

          if (state is Authenticated) {
            initialRoute = RouteNames.home;
          } else if (state is Unauthenticated) {
            initialRoute = RouteNames.login;
          } else {
            initialRoute = RouteNames.splash;
          }

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Smart Harvest',
            theme: AppTheme.lightTheme,
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
            initialRoute: initialRoute,
            onGenerateRoute: appRouter.onGenerateRoute,
          );
        },
      ),
    );
  }
}