import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:reathm/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App start and verify login page or home page', (WidgetTester tester) async {
    // 1. Start the app
    // We cannot mock FirebaseAuth easily in integration tests without a real emulator or real project.
    // However, we can verify that the app at least boots up to a known state.
    app.main();
    await tester.pumpAndSettle();

    // 2. Check for existence of key widgets.
    // Since we don't know if the user is logged in (state persists on device),
    // we check for either the Login Page or the Home Page.

    final loginButtonFinder = find.text('Sign in with Google');
    final homePageFinder = find.text('Daily Activities');

    if (loginButtonFinder.evaluate().isNotEmpty) {
      print('App started on Login Page');
      expect(loginButtonFinder, findsOneWidget);
    } else if (homePageFinder.evaluate().isNotEmpty) {
      print('App started on Home Page');
      expect(homePageFinder, findsOneWidget);
    } else {
      // It might be loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    }
  });
}
