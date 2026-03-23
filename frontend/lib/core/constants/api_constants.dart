// lib/core/constants/api_constants.dart
// Smart Harvest — All backend API endpoint definitions
// MODIFIED: added news, surplus-status, /auth/me, /prices/current, /prices/forecast list

class ApiConstants {
  ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000',
  );

  static const Duration timeout = Duration(seconds: 15);

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String authProfile = '/api/auth/profile';
  static const String authMe      = '/api/auth/me';
  static const String fcmToken    = '/api/auth/fcm-token';

  // ── Market Prices ─────────────────────────────────────────────────────────
  static const String todayPrices    = '/api/prices/today';
  static const String currentPrices  = '/api/prices/current';
  static const String supplyStatus   = '/api/prices/supply-status';
  static const String forecastList   = '/api/prices/forecast';
  static const String surplusStatus  = '/api/surplus-status';

  static String priceHistory(String cropName) =>
      '/api/prices/history/${Uri.encodeComponent(cropName)}';

  static String forecast(String cropName) =>
      '/api/prices/forecast/${Uri.encodeComponent(cropName)}';

  static const String governmentSummary = '/api/prices/government-summary';

  // ── News ──────────────────────────────────────────────────────────────────
  static const String news = '/api/news';

  // ── Weather ───────────────────────────────────────────────────────────────
  static const String weather = '/api/weather';

  // ── Analytics ─────────────────────────────────────────────────────────────
  static const String userAnalytics     = '/api/analytics';
  static const String analyticsSummary  = '/api/analytics/summary';
  static const String regionAnalytics   = '/api/analytics/region';
  static const String platformAnalytics = '/api/analytics/platform';

  // ── Crops ─────────────────────────────────────────────────────────────────
  static const String cropsAll = '/api/crops/all';
  static const String cropsAdd = '/api/crops/add';

  // ── Dashboard (government) ────────────────────────────────────────────────
  static const String dashboard = '/api/dashboard';

  // ── Health ────────────────────────────────────────────────────────────────
  static const String health = '/health';
}
