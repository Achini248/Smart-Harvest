import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app.dart';
import 'config/dependency_injection/injection_container.dart' as di;
import 'config/localization/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await di.init();

  runApp(const SmartHarvestApp());
}
