import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, Map<String, dynamic>>> getDailyActivities(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists && doc.data()!.containsKey('daily_activities')) {
      return Map<String, Map<String, dynamic>>.from(doc.data()!['daily_activities']);
    }
    return {};
  }

  Future<void> saveDailyActivities(String userId, Map<String, Map<String, dynamic>> activities) async {
    await _firestore.collection('users').doc(userId).set({
      'daily_activities': activities,
    }, SetOptions(merge: true));
  }

  Future<void> addAccomplishment(String userId, String activity) async {
    await _firestore.collection('users').doc(userId).collection('accomplishments').add({
      'activity': activity,
      'timestamp': FieldValue.serverTimestamp(),
    });
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
      'lastLogin': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}