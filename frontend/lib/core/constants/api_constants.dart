// lib/core/constants/api_constants.dart
// Smart Harvest — All backend API endpoint definitions

import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:shared_preferences/shared_preferences.dart';

class ApiConstants {
  ApiConstants._();

  // ── Runtime server URL override (set by user in Settings → Server URL) ──
  // This is the fix for real-device connectivity. On a real phone,
  // 'localhost' resolves to the phone itself, not your computer.
  // The user must enter their machine's LAN IP (e.g. http://192.168.1.45:5000).
  static String? _savedUrl;

  /// Call this once at startup in main() before runApp().
  static Future<void> loadSavedUrl() async {
    final prefs = await SharedPreferences.getInstance();
    _savedUrl = prefs.getString('server_base_url');
  }

  /// Persist a new base URL and use it immediately.
  static Future<void> setSavedUrl(String url) async {
    _savedUrl = url.trim().isEmpty ? null : url.trim();
    final prefs = await SharedPreferences.getInstance();
    if (_savedUrl == null) {
      await prefs.remove('server_base_url');
    } else {
      await prefs.setString('server_base_url', _savedUrl!);
    }
  }

  /// Returns the saved URL so the settings screen can pre-populate the field.
  static String? get savedUrl => _savedUrl;

  /// Base URL resolved in priority order:
  ///   1. --dart-define=API_BASE_URL=…  (CI / release builds)
  ///   2. User-saved URL from Settings  (real device fix)
  ///   3. Web browser                  → http://localhost:5000
  ///   4. Android emulator             → http://10.0.2.2:5000
  ///   5. Fallback                     → http://localhost:5000
  static String get baseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (envUrl.isNotEmpty) return envUrl;

    if (_savedUrl != null && _savedUrl!.isNotEmpty) return _savedUrl!;

    if (kIsWeb) return 'http://localhost:5000';

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000';
    }

    return 'http://localhost:5000';
  }

  // Increased from 8 s → 30 s.
  // Mobile networks (3G/LTE/WiFi handoff) are far slower than localhost Chrome,
  // and the original 8-second budget caused every feature to time-out on device.
  static const Duration timeout = Duration(seconds: 30);

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String authProfile = '/api/auth/profile';
  static const String authMe      = '/api/auth/me';
  static const String fcmToken    = '/api/auth/fcm-token';

  // ── OTP (Registration verification) ───────────────────────────────────────
  static const String otpSend   = '/api/auth/otp/send';
  static const String otpVerify = '/api/auth/otp/verify';

  // ── Market Prices ─────────────────────────────────────────────────────────
  static const String todayPrices    = '/api/prices/today';
  static const String currentPrices  = '/api/prices/current';
  static const String supplyStatus   = '/api/prices/supply-status';
  static const String forecastList   = '/api/prices/forecast';
  static const String surplusStatus  = '/api/surplus-status';
  static const String priceForecast  = '/api/prices/forecast';

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

  static String cropById(String id)    => '/api/crops/$id';
  static String deleteCrop(String id)  => '/api/crops/$id';
  static String updateCrop(String id)  => '/api/crops/$id';

  // ── Marketplace products ───────────────────────────────────────────────────
  static const String marketplaceProducts = '/api/marketplace/products';
  static String productById(String id)    => '/api/marketplace/products/$id';
  static String updateProduct(String id)  => '/api/marketplace/products/$id';
  static String deleteProduct(String id)  => '/api/marketplace/products/$id';

  // ── Marketplace orders ─────────────────────────────────────────────────────
  static const String placeOrder        = '/api/marketplace/orders';
  static const String myOrders          = '/api/marketplace/orders/my';
  static const String incomingOrders    = '/api/marketplace/orders/incoming';
  static String orderStatus(String id)  => '/api/marketplace/orders/$id/status';

  // ── Dashboard (government) ────────────────────────────────────────────────
  static const String dashboard = '/api/dashboard';

  // ── Health ────────────────────────────────────────────────────────────────
  static const String health = '/health';
}
