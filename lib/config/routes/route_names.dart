class RouteNames {
  RouteNames._();

  // Core
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';

  // Authentication
  static const String login = '/login';
  static const String signup = '/signup';
  static const String otpVerification = '/otp-verification';
  static const String profileSettings = '/profile-settings';

  // Crop management (AppRouter එකේ තියෙන නම් වලට ගැලපෙන්න හැදුවා)
  static const String myCrops = '/my-crops';      // 'cropsList' වෙනුවට
  static const String addCrop = '/add-crop';      // අලුතින් එක් කළා
  static const String cropDetails = '/crop-detail'; // 'cropDetail' වෙනුවට
  static const String editCrop = '/edit-crop';

  // Marketplace & prices
  static const String marketplaceHome = '/marketplace';
  static const String myOrders = '/my-orders';
  static const String orderInbox = '/order-inbox';
  static const String dailyMarketPrices = '/market-prices'; // 'marketPrices' වෙනුවට

  // Weather
  static const String weatherOverview = '/weather'; // 'weather' වෙනුවට

  // Notifications
  static const String notifications = '/notifications';

  // Messaging
  static const String messagesList = '/messages';
  static const String chat = '/chat';

  // Account / help
  static const String accountSettings = '/account-settings';
  static const String helpSupport = '/help-support';

  // Government dashboard & analytics
  static const String governmentDashboard = '/government-dashboard';
  static const String analytics = '/analytics';
}