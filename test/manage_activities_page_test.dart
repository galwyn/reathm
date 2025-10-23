import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:reathm/manage_activities_page.dart';
import 'package:reathm/models/activity.dart';

import 'mock.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  setupFirebaseMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });
  group('ManageActivitiesPage', () {
    final mockUser = MockUser(uid: 'test_uid');
    final initialActivities = [
      const Activity(id: '1', name: 'Existing Activity', emoji: '📝'),
    ];

    testWidgets('dialog shows error for duplicate activity name', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        MaterialApp(
          home: ManageActivitiesPage(
            dailyActivities: initialActivities,
            user: mockUser,
          ),
        ),
      );

      // Tap the floating action button to open the dialog.
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle(); // Wait for dialog animation

      // Verify the dialog is open.
      expect(find.byType(AlertDialog), findsOneWidget);

      // Enter the name of an existing activity.
      await tester.enterText(find.byType(TextField), 'Existing Activity');

      // Tap the 'Add' button.
      await tester.tap(find.widgetWithText(TextButton, 'Add'));
      await tester.pump(); // Rebuild the widget to show the error.

      // Verify that the error message is displayed.
      expect(find.text('This activity already exists.'), findsOneWidget);

      // Verify that the dialog is still on the screen.
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('dialog closes and adds activity for new name', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        MaterialApp(
          home: ManageActivitiesPage(
            dailyActivities: initialActivities,
            user: mockUser,
          ),
        ),
      );

      // Tap the floating action button to open the dialog.
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Enter a new activity name.
      await tester.enterText(find.byType(TextField), 'New Unique Activity');

      // Tap the 'Add' button.
      await tester.tap(find.widgetWithText(TextButton, 'Add'));
      await tester.pumpAndSettle(); // Wait for dialog to close and page to rebuild.

      // Verify that the dialog is closed.
      expect(find.byType(AlertDialog), findsNothing);

      // Verify that the new activity is now in the list.
      expect(find.text('New Unique Activity'), findsOneWidget);
    });
  });
}
