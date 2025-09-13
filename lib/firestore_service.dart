import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:reathm/models/activity.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? db}) : _firestore = db ?? FirebaseFirestore.instance;

  Future<List<Activity>> getActiveActivities(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists && doc.data()!.containsKey('daily_activities')) {
      final Map<String, dynamic> activitiesMap = Map<String, dynamic>.from(doc.data()!['daily_activities']);
      return activitiesMap.entries
          .map((entry) => Activity.fromMap(Map<String, dynamic>.from(entry.value)))
          .where((activity) => activity.isActive)
          .toList();
    }
    return [];
  }

  Future<void> saveDailyActivities(String userId, List<Activity> activities) async {
    final Map<String, Map<String, dynamic>> activitiesToSave = {};
    for (var activity in activities) {
      activitiesToSave[activity.id] = activity.toMap();
    }
    await _firestore.collection('users').doc(userId).set({
      'daily_activities': activitiesToSave,
    }, SetOptions(merge: true));
  }

  Future<void> addDailyActivity(String userId, Activity activity) async {
    await _firestore.collection('users').doc(userId).set({
      'daily_activities': {
        activity.id: activity.toMap(),
      },
    }, SetOptions(merge: true));
  }

  Future<void> updateDailyActivity(String userId, Activity activity) async {
    await _firestore.collection('users').doc(userId).set({
      'daily_activities': {
        activity.id: activity.toMap(),
      },
    }, SetOptions(merge: true));
  }

  Future<void> deleteDailyActivity(String userId, String activityId) async {
    await _firestore.collection('users').doc(userId).update({
      'daily_activities.$activityId': FieldValue.delete(),
    });
  }

  Future<void> setActivityCompletedStatus(String userId, String activityName, bool isCompleted) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    if (isCompleted) {
      await _firestore.collection('users').doc(userId).collection('accomplishments').add({
        'activity': activityName,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      final query = await _firestore
          .collection('users')
          .doc(userId)
          .collection('accomplishments')
          .where('activity', isEqualTo: activityName)
          .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
          .get();
      for (final doc in query.docs) {
        await doc.reference.delete();
      }
    }
  }

  Future<List<String>> getAccomplishedActivities(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('accomplishments')
        .orderBy('timestamp', descending: true)
        .get();
    final activities = snapshot.docs.map((doc) => doc['activity'] as String).toList();
    return activities.toSet().toList(); // Return unique activities
  }

  Future<List<DateTime>> getActivityHistory(String userId, String activityName) async {
    final QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('accomplishments')
        .where('activity', isEqualTo: activityName)
        .get();

    return snapshot.docs.map((doc) {
      final timestamp = doc['timestamp'] as Timestamp;
      return timestamp.toDate();
    }).toList();
  }

  Future<void> addAffirmationFeedback(String userId, String affirmation, bool liked) async {
    await _firestore.collection('users').doc(userId).collection('affirmation_feedback').add({
      'affirmation': affirmation,
      'liked': liked,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<String?> getRandomSeededAffirmation() async {
    final snapshot = await _firestore.collection('seeded_affirmations').get();
    if (snapshot.docs.isNotEmpty) {
      final randomIndex = Random().nextInt(snapshot.docs.length);
      return snapshot.docs[randomIndex]['text'] as String?;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getAllAccomplishments(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('accomplishments')
        .orderBy('timestamp', descending: true)
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<String>> getAccomplishmentsForDay(String userId, DateTime day) async {
    final startOfDay = DateTime(day.year, day.month, day.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('accomplishments')
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThan: endOfDay)
        .get();

    return snapshot.docs.map((doc) => doc['activity'] as String).toList();
  }

  Future<void> saveUser(User user) async {
    await _firestore.collection('users').doc(user.uid).set({
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'lastLogin': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
