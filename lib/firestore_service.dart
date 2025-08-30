import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db;

  FirestoreService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  // Setter for testing
  set db(FirebaseFirestore instance) {
    // This setter is now redundant but kept for compatibility with existing tests.
  }

  Future<void> saveUser(User user) {
    return _db.collection('users').doc(user.uid).set({
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
    }, SetOptions(merge: true));
  }

  Future<void> saveDailyActivities(String uid, Map<String, bool> dailyActivities) {
    print('Saving daily activities for user $uid: $dailyActivities');
    return _db.collection('user_activities').doc(uid).set({'activities': dailyActivities});
  }

  Future<Map<String, bool>> getDailyActivities(String uid) async {
    final doc = await _db.collection('user_activities').doc(uid).get();
    if (doc.exists && doc.data()!['activities'] != null) {
      return Map<String, bool>.from(doc.data()!['activities']);
    }
    return {};
  }

  Future<void> addAccomplishment(String uid, String activity) {
    return _db.collection('users').doc(uid).collection('accomplishments').add({
      'activity': activity,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<QuerySnapshot> getAccomplishments(String uid) {
    return _db.collection('users').doc(uid).collection('accomplishments').orderBy('timestamp', descending: true).get();
  }

  Future<void> addAffirmationFeedback(String uid, String affirmation, bool liked) {
    return _db.collection('users').doc(uid).collection('affirmation_feedback').add({
      'affirmation': affirmation,
      'liked': liked,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<String?> getRandomSeededAffirmation() async {
    final snapshot = await _db.collection('seeded_affirmations').get();
    if (snapshot.docs.isNotEmpty) {
      final randomIndex = DateTime.now().millisecondsSinceEpoch % snapshot.docs.length;
      return snapshot.docs[randomIndex].data()['text'] as String?;
    }
    return null;
  }
}
