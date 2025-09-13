import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:reathm/models/activity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reathm/firestore_service.dart';
import 'package:firebase_core/firebase_core.dart';
import '../mock.dart';

void main() {
  setupFirebaseMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  group('FirestoreService', () {
    late FakeFirebaseFirestore firestore;
    late FirestoreService service;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      service = FirestoreService(db: firestore);
    });

    // Mock User for testing
    final mockUser = MockUser(
      uid: 'test_uid',
      email: 'test@example.com',
      displayName: 'Test User',
      photoURL: 'https://example.com/photo.jpg',
    );

    group('saveUser', () {
      test('should save user data to Firestore', () async {
        final user = mockUser; // Use the mock user directly
        await service.saveUser(user);

        final doc = await firestore.collection('users').doc(user.uid).get();
        expect(doc.exists, isTrue);
        final data = doc.data();
        expect(data, isNotNull);
        expect(data!['email'], 'test@example.com');
        expect(data['displayName'], 'Test User');
        expect(data['photoURL'], 'https://example.com/photo.jpg');
        expect(data['lastLogin'], isA<Timestamp>());
      });
    });

    group('saveDailyActivities', () {
      test('should save daily activities for a user', () async {
        const uid = 'test_uid';
        final activities = [
          const Activity(id: 'activity1', name: 'Activity 1', emoji: 'ðŸ”¥', isActive: true),
          const Activity(id: 'activity2', name: 'Activity 2', emoji: 'ðŸ’ª', isActive: false),
        ];
        await service.saveDailyActivities(uid, activities);

        final doc = await firestore.collection('users').doc(uid).get();
        expect(doc.exists, isTrue);
        final expectedActivities = {
          'activity1': {
            'id': 'activity1',
            'name': 'Activity 1',
            'emoji': 'ðŸ”¥',
            'isActive': true,
          },
          'activity2': {
            'id': 'activity2',
            'name': 'Activity 2',
            'emoji': 'ðŸ’ª',
            'isActive': false,
          },
        };
        expect(doc.data()!['daily_activities'], expectedActivities);
      });
    });

    group('getActiveActivities', () {
      test('should retrieve only active daily activities for a user', () async {
        const uid = 'test_uid';
        final activities = {
          'activity1': {
            'id': 'activity1',
            'name': 'Activity 1',
            'emoji': 'ðŸ”¥',
            'isActive': true,
          },
          'activity2': {
            'id': 'activity2',
            'name': 'Activity 2',
            'emoji': 'ðŸ’ª',
            'isActive': false,
          },
        };
        await firestore.collection('users').doc(uid).set({'daily_activities': activities});

        final fetchedActivities = await service.getActiveActivities(uid);
        expect(fetchedActivities.length, 1);
        expect(fetchedActivities[0].id, 'activity1');
      });

      test('should return empty list if no activities exist', () async {
        const uid = 'non_existent_uid';
        final fetchedActivities = await service.getActiveActivities(uid);
        expect(fetchedActivities, isEmpty);
      });
    });

    group('setActivityCompletedStatus', () {
      test('should add an accomplishment when completed is true', () async {
        const uid = 'test_uid';
        const activityName = 'Completed task';
        await service.setActivityCompletedStatus(uid, activityName, true);

        final query = await firestore.collection('users').doc(uid).collection('accomplishments').get();
        expect(query.docs.length, 1);
        expect(query.docs.first.data()['activity'], activityName);
      });

      test('should remove an accomplishment when completed is false', () async {
        const uid = 'test_uid';
        const activityName = 'Completed task';
        await firestore.collection('users').doc(uid).collection('accomplishments').add({
          'activity': activityName,
          'timestamp': Timestamp.now(),
        });

        await service.setActivityCompletedStatus(uid, activityName, false);

        final query = await firestore.collection('users').doc(uid).collection('accomplishments').get();
        expect(query.docs.isEmpty, isTrue);
      });
    });

    group('getAllAccomplishments', () {
      test('should retrieve all accomplishments for a user', () async {
        const uid = 'test_uid';
        await firestore.collection('users').doc(uid).collection('accomplishments').add({
          'activity': 'Task 1',
          'timestamp': Timestamp.fromDate(DateTime(2023, 1, 1)),
        });
        await firestore.collection('users').doc(uid).collection('accomplishments').add({
          'activity': 'Task 2',
          'timestamp': Timestamp.fromDate(DateTime(2023, 1, 2)),
        });

        final accomplishments = await service.getAllAccomplishments(uid);
        expect(accomplishments.length, 2);
        expect(accomplishments[0]['activity'], 'Task 2');
        expect(accomplishments[1]['activity'], 'Task 1');
      });

      test('should return empty list if no accomplishments exist', () async {
        const uid = 'non_existent_uid';
        final accomplishments = await service.getAllAccomplishments(uid);
        expect(accomplishments, isEmpty);
      });
    });

    group('addAffirmationFeedback', () {
      test('should add affirmation feedback for a user', () async {
        const uid = 'test_uid';
        const affirmation = 'I am strong.';
        const liked = true;
        await service.addAffirmationFeedback(uid, affirmation, liked);

        final query = await firestore.collection('users').doc(uid).collection('affirmation_feedback').get();
        expect(query.docs.length, 1);
        expect(query.docs.first.data()['affirmation'], affirmation);
        expect(query.docs.first.data()['liked'], liked);
        expect(query.docs.first.data()['timestamp'], isA<Timestamp>());
      });
    });

    group('getRandomSeededAffirmation', () {
      test('should return a random seeded affirmation if available', () async {
        await firestore.collection('seeded_affirmations').add({'text': 'Seeded affirmation 1'});
        await firestore.collection('seeded_affirmations').add({'text': 'Seeded affirmation 2'});

        final affirmation = await service.getRandomSeededAffirmation();
        expect(affirmation, anyOf('Seeded affirmation 1', 'Seeded affirmation 2'));
      });

      test('should return null if no seeded affirmations are available', () async {
        final affirmation = await service.getRandomSeededAffirmation();
        expect(affirmation, isNull);
      });
    });
  });
}