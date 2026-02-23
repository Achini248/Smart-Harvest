// lib/app.dart

class SmartHarvestApp extends StatelessWidget {
  final AppRouter appRouter;

  const SmartHarvestApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    // ...
    return MultiBlocProvider(
      providers: [
        // AuthBloc etc.
      ],
      child: MaterialApp(
        title: 'Smart Harvest',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme, // if you have AppTheme
        onGenerateRoute: appRouter.onGenerateRoute,
        initialRoute: RouteNames.splash,
      ),
    );
  }
}
