// lib/services/notification_service.dart
// Smart Harvest — Push notification service with platform guards.
// FCM works on Android and iOS. On web, browser Notifications API is used.

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  /// Call once at startup (after Firebase.initializeApp).
  Future<void> init() async {
    // Request permission — on web this shows the browser permission prompt
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    // Web requires a VAPID key. Set via --dart-define=VAPID_KEY=...
    // or replace the empty string with your actual key.
    String? token;
    if (kIsWeb) {
      const vapidKey = String.fromEnvironment('VAPID_KEY', defaultValue: '');
      if (vapidKey.isNotEmpty) {
        token = await _fcm.getToken(vapidKey: vapidKey);
      }
    } else {
      token = await _fcm.getToken();
    }

    if (token != null) {
      _onTokenRefresh(token);
    }

    // Listen for token refreshes
    _fcm.onTokenRefresh.listen(_onTokenRefresh);

    // Foreground messages
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
  }

  void _onTokenRefresh(String token) {
    // Token is synced to backend in auth_bloc after login.
    // Store it locally so AuthBloc can read it.
    _latestToken = token;
  }

  String? _latestToken;
  String? get latestToken => _latestToken;

  void _onForegroundMessage(RemoteMessage message) {
    // App is open — you can emit a local notification or update UI via BLoC.
    // For now we just log it; wire up flutter_local_notifications if needed.
    // ignore: avoid_print
    print('[FCM] Foreground message: ${message.notification?.title}');
  }
}
