// import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bookitnow/main.dart';

void main() {
  testWidgets('Basic app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(BookItNowApp());

    // Verify that the login screen is shown.
    expect(find.text("Login (skip for now)"), findsOneWidget);
  });
}
