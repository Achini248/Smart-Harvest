// lib/config/routes/app_router.dart

class AppRouter {
  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // your real routes...

      // Example:
      // case RouteNames.accountSettings:
      //   return _comingSoonRoute('Account Settings');

      default:
        return _comingSoonRoute('Coming soon');
    }
  }

  Route<dynamic> _comingSoonRoute(String title) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Center(
          child: Text(
            '$title is coming soon',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
