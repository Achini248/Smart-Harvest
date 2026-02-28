import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'config/routes/app_router.dart';
import 'config/localization/app_localizations.dart';
import 'config/dependency_injection/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';

class SmartHarvestApp extends StatefulWidget {
  const SmartHarvestApp({super.key});

  @override
  State<SmartHarvestApp> createState() => _SmartHarvestAppState();
}

class _SmartHarvestAppState extends State<SmartHarvestApp> {
  final AppRouter _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Example: global AuthBloc; add more global blocs if needed.
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>()..add(const AuthCheckRequested()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Smart Harvest',
        theme: AppTheme.lightTheme,
        localeResolutionCallback: (locale, supportedLocales) {
          if (locale == null) return supportedLocales.first;
          for (final supported in supportedLocales) {
            if (supported.languageCode == locale.languageCode) {
              return supported;
            }
          }
          return supportedLocales.first;
        },
        // Localization
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('si'),
          Locale('ta'),
        ],
        onGenerateTitle: (context) =>
            AppLocalizations.of(context)?.appTitle ?? 'Smart Harvest',
        // Routing
        initialRoute: RouteNames.splash,
        onGenerateRoute: _appRouter.onGenerateRoute,
      ),
    );
  }
}
