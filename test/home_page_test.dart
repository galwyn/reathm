import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:reathm/cloud_function_service.dart';
import 'package:reathm/firestore_service.dart';
import 'package:reathm/home_page.dart';
import 'package:reathm/models/activity.dart';
import 'package:mockito/annotations.dart';
import 'package:reathm/notification_service.dart';
import 'home_page_test.mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'mock.dart';

@GenerateMocks([FirestoreService, User, CloudFunctionService, NotificationService])
void main() {
  late MockFirestoreService mockFirestoreService;
  late MockUser mockUser;
  late MockCloudFunctionService mockCloudFunctionService;
  late MockNotificationService mockNotificationService;

  setupFirebaseMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  setUp(() {
    mockFirestoreService = MockFirestoreService();
    mockUser = MockUser();
    when(mockUser.uid).thenReturn('test_uid');
    when(mockUser.displayName).thenReturn('Test User');
    mockCloudFunctionService = MockCloudFunctionService();
    mockNotificationService = MockNotificationService();
  });

  testWidgets('HomePage shows active activities with correct completion state', (WidgetTester tester) async {
    final activities = [
      const Activity(id: '1', name: 'Test Activity 1', emoji: '✅', isActive: true),
      const Activity(id: '2', name: 'Test Activity 2', emoji: '🎉', isActive: true),
      const Activity(id: '3', name: 'Test Activity 3', emoji: '🚀', isActive: false),
    ];
    final accomplishments = ['Test Activity 1'];

    when(mockFirestoreService.getActiveActivities(any)).thenAnswer((_) async => activities.where((a) => a.isActive).toList());
    when(mockFirestoreService.getAccomplishmentsForDay(any, any)).thenAnswer((_) async => accomplishments);
    when(mockFirestoreService.getRandomSeededAffirmation()).thenAnswer((_) async => "Test Affirmation");
    when(mockCloudFunctionService.generateEncouragement(any)).thenAnswer((_) async => "Good job!");

    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(
          user: mockUser,
          firestoreService: mockFirestoreService,
          cloudFunctionService: mockCloudFunctionService,
          notificationService: mockNotificationService,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(CheckboxListTile), findsNWidgets(2)); // Only active activities should be shown

    final checkbox1 = tester.widget<CheckboxListTile>(find.widgetWithText(CheckboxListTile, 'Test Activity 1'));
    expect(checkbox1.value, isTrue); // Completed

    final checkbox2 = tester.widget<CheckboxListTile>(find.widgetWithText(CheckboxListTile, 'Test Activity 2'));
    expect(checkbox2.value, isFalse); // Not completed
  });
}
