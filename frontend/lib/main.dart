// lib/main.dart
// Smart Harvest — App entry point. Runs on Web, iOS, and Android.

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'config/dependency_injection/injection_container.dart' as di;
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'core/constants/api_constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase — works on web, iOS, and Android
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Persistent storage (shared_preferences works on all platforms)
  await StorageService.instance.init();

  // Load the user-saved server URL so ApiConstants.baseUrl is correct
  // on real devices before any network call is made.
  await ApiConstants.loadSavedUrl();

  // Push notifications (skipped on web unless VAPID_KEY is set)
  await NotificationService.instance.init();

  // Dependency injection
  await di.init();

  runApp(const SmartHarvestApp());
}
