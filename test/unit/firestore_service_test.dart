
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
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
    late MockFirebaseAuth auth;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      auth = MockFirebaseAuth();
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
        expect(doc.data(), {
          'email': 'test@example.com',
          'displayName': 'Test User',
          'photoURL': 'https://example.com/photo.jpg',
        });
      });
    });

    group('saveDailyActivities', () {
      test('should save daily activities for a user', () async {
        const uid = 'test_uid';
        final activities = {'activity1': true, 'activity2': false};
        await service.saveDailyActivities(uid, activities);

        final doc = await firestore.collection('user_activities').doc(uid).get();
        expect(doc.exists, isTrue);
        expect(doc.data(), {'activities': activities});
      });
    });

    group('getDailyActivities', () {
      test('should retrieve daily activities for a user', () async {
        const uid = 'test_uid';
        final activities = {'activity1': true, 'activity2': false};
        await firestore.collection('user_activities').doc(uid).set({'activities': activities});

        final fetchedActivities = await service.getDailyActivities(uid);
        expect(fetchedActivities, activities);
      });

      test('should return empty map if no activities exist', () async {
        const uid = 'non_existent_uid';
        final fetchedActivities = await service.getDailyActivities(uid);
        expect(fetchedActivities, isEmpty);
      });
    });

    group('addAccomplishment', () {
      test('should add an accomplishment for a user', () async {
        const uid = 'test_uid';
        const activity = 'Completed task';
        await service.addAccomplishment(uid, activity);

        final query = await firestore.collection('users').doc(uid).collection('accomplishments').get();
        expect(query.docs.length, 1);
        expect((query.docs.first.data() as Map<String, dynamic>)['activity'], activity); // Cast data()
        expect((query.docs.first.data() as Map<String, dynamic>)['timestamp'], isA<Timestamp>()); // Cast data()
      });
    });

    group('getAccomplishments', () {
      test('should retrieve accomplishments for a user', () async {
        const uid = 'test_uid';
        await firestore.collection('users').doc(uid).collection('accomplishments').add({
          'activity': 'Task 1',
          'timestamp': FieldValue.serverTimestamp(),
        });
        await firestore.collection('users').doc(uid).collection('accomplishments').add({
          'activity': 'Task 2',
          'timestamp': FieldValue.serverTimestamp(),
        });

        final snapshot = await service.getAccomplishments(uid);
        final accomplishments = snapshot.docs;
        accomplishments.sort((a, b) => (b.data() as Map<String, dynamic>)['timestamp'].compareTo((a.data() as Map<String, dynamic>)['timestamp']));
        expect(accomplishments.length, 2);
        expect((accomplishments.first.data() as Map<String, dynamic>)['activity'], 'Task 2'); // Ordered by descending timestamp, cast data()
      });

      test('should return empty snapshot if no accomplishments exist', () async {
        const uid = 'non_existent_uid';
        final snapshot = await service.getAccomplishments(uid);
        expect(snapshot.docs, isEmpty);
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
        expect((query.docs.first.data() as Map<String, dynamic>)['affirmation'], affirmation); // Cast data()
        expect((query.docs.first.data() as Map<String, dynamic>)['liked'], liked); // Cast data()
        expect((query.docs.first.data() as Map<String, dynamic>)['timestamp'], isA<Timestamp>()); // Cast data()
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
