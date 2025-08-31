import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedDatabase(String userId) async {
  print('Seeding database for user: $userId');
  final firestore = FirebaseFirestore.instance;
  final activitiesCollection = firestore.collection('users').doc(userId).collection('activities');

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final activities = [
    // Today
    {
      'type': 'affirmation',
      'timestamp': today.add(const Duration(hours: 9)),
      'content': 'I am capable of achieving my goals.',
    },
    {
      'type': 'reflection',
      'timestamp': today.add(const Duration(hours: 12)),
      'content': 'I am grateful for the support of my friends and family.',
    },
    {
      'type': 'activity',
      'timestamp': today.add(const Duration(hours: 18)),
      'content': 'Went for a 30-minute walk in the park.',
    },
    // Yesterday
    {
      'type': 'affirmation',
      'timestamp': today.subtract(const Duration(days: 1)).add(const Duration(hours: 10)),
      'content': 'I am confident in my abilities.',
    },
    {
      'type': 'reflection',
      'timestamp': today.subtract(const Duration(days: 1)).add(const Duration(hours: 14)),
      'content': 'I learned a new skill today.',
    },
    // 2 days ago
    {
      'type': 'activity',
      'timestamp': today.subtract(const Duration(days: 2)).add(const Duration(hours: 17)),
      'content': 'Read a chapter of a book.',
    },
    // 3 days ago
    {
      'type': 'affirmation',
      'timestamp': today.subtract(const Duration(days: 3)).add(const Duration(hours: 8)),
      'content': 'I am worthy of love and respect.',
    },
  ];

  for (final activity in activities) {
    await activitiesCollection.add(activity);
  }
  print('Database seeded.');
}
