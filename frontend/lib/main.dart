import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'config/dependency_injection/injection_container.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await di.init();

  runApp(const SmartHarvestApp());
}