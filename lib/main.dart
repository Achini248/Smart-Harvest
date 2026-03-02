import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // මේ file එක රතු වෙලා පෙන්වනවා නම් පියවර 2 බලන්න
import 'app.dart';
import 'config/dependency_injection/injection_container.dart' as di;

Future<void> main() async {
  // 1. Flutter Engine එක සූදානම් කිරීම
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Firebase සම්බන්ධ කිරීම (අනිවාර්යයෙන්ම මුලින්ම තිබිය යුතුයි)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Dependency Injection සකස් කිරීම
  await di.init();

  runApp(const SmartHarvestApp());
}