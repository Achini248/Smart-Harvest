import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'config/routes/app_router.dart';
import 'config/routes/route_names.dart';
import 'config/dependency_injection/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/authentication/presentation/bloc/auth_event.dart';
import 'features/authentication/presentation/bloc/auth_state.dart';

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
        BlocProvider<AuthBloc>(
          create: (_) =>
              di.sl<AuthBloc>()..add(const CheckAuthStatusEvent()),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            previous.runtimeType != current.runtimeType,
        listener: (context, state) {
          // Optional: global auth navigation logic
          if (state is Unauthenticated) {
            // You can redirect to login here if needed
            // Navigator.pushNamedAndRemoveUntil(
            //   context,
            //   RouteNames.login,
            //   (_) => false,
            // );
          }
        },
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Smart Harvest',
          theme: AppTheme.lightTheme,
          // Localization
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
          // Routing
          initialRoute: RouteNames.splash,
          onGenerateRoute: _appRouter.onGenerateRoute,
        ),
      ),
    );
  }
}
