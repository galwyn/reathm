import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

Future<void> wipeAndSeedDatabase(String userId) async {
  print('Wiping and seeding database for user: $userId');
  final firestore = FirebaseFirestore.instance;

  // Wipe daily_activities subcollection for the user
  final dailyActivitiesCollection =
      firestore.collection('users').doc(userId).collection('daily_activities');
  await _deleteCollection(dailyActivitiesCollection);

  // Wipe seeded affirmations to ensure a fresh start
  final affirmationsCollection = firestore.collection('seeded_affirmations');
  await _deleteCollection(affirmationsCollection);

  // Seed new data
  await seedDailyActivities(userId);
  await seedAffirmations();

  print('Database wiped and seeded.');
}

Future<void> _deleteCollection(CollectionReference collection) async {
  final snapshot = await collection.get();
  for (final doc in snapshot.docs) {
    await doc.reference.delete();
  }
}

Future<void> seedDailyActivities(String userId) async {
  print('Seeding daily activities for user: $userId');
  final firestore = FirebaseFirestore.instance;
  final userRef = firestore.collection('users').doc(userId);

  final now = DateTime.now();

  // Seed data for today
  final todayDate = DateFormat('yyyy-MM-dd').format(now);
  await userRef.collection('daily_activities').doc(todayDate).set({
    'activities': {
      'I am capable of achieving my goals.': true,
      'Went for a 30-minute walk in the park.': false,
      'Practiced mindfulness for 10 minutes.': true,
    }
  });

  // Seed data for yesterday
  final yesterday = now.subtract(const Duration(days: 1));
  final yesterdayDate = DateFormat('yyyy-MM-dd').format(yesterday);
  await userRef.collection('daily_activities').doc(yesterdayDate).set({
    'activities': {
      'I am confident in my abilities.': true,
      'I learned a new skill today.': true,
    }
  });

  // Seed data for two days ago
  final twoDaysAgo = now.subtract(const Duration(days: 2));
  final twoDaysAgoDate = DateFormat('yyyy-MM-dd').format(twoDaysAgo);
  await userRef.collection('daily_activities').doc(twoDaysAgoDate).set({
    'activities': {
      'Read a chapter of a book.': true,
      'Drank 8 glasses of water.': true,
    }
  });

  print('Daily activities seeded.');
}

Future<void> seedAffirmations() async {
  final firestore = FirebaseFirestore.instance;
  final affirmationsCollection = firestore.collection('seeded_affirmations');

  final affirmations = [
    'I am strong and resilient.',
    'I believe in myself and my abilities.',
    'I am worthy of happiness and success.',
    'I attract positivity into my life.',
    'I am grateful for all that I have.',
    'I am confident and capable.',
    'I am in control of my thoughts and emotions.',
    'I am proud of the person I am becoming.',
    'I am open to new opportunities and experiences.',
    'I am surrounded by love and support.',
  ];

  for (final affirmation in affirmations) {
    await affirmationsCollection.add({'text': affirmation});
  }
  print('Affirmations seeded.');
}