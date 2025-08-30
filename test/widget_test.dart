// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:reathm/main.dart';
import 'mock.dart';

void main() {
  setupFirebaseMocks();

  // Initialize Firebase before running tests
  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('App shows LoginPage when not logged in', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(ReathmApp());

    // The app should initially show a loading indicator while checking auth state.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for the auth state to resolve.
    await tester.pumpAndSettle();

    // Verify that the LoginPage is shown.
    expect(find.text('Sign in with Google'), findsOneWidget);
  });
}