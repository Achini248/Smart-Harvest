import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_harvest_app/app.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SmartHarvestApp());

    // Verify that the app loads (splash screen should be shown)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
