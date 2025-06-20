// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mixologist_flutter/features/auth/login_screen.dart';

void main() {
  testWidgets('Mixologist app smoke test', (WidgetTester tester) async {
    // Build the LoginScreen directly wrapped in MaterialApp to avoid Firebase initialization
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.system,
        home: const LoginScreen(),
      ),
    );

    // Verify that the login screen is displayed
    expect(find.text('AI Mixologist'), findsAtLeast(1));
    expect(find.text('Start Mixing'), findsOneWidget);
  });
}
