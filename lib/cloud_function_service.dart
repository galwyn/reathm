import 'package:cloud_functions/cloud_functions.dart';

class CloudFunctionService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<String> generateAffirmation(String prompt) async {
    try {
      final HttpsCallable callable = _functions.httpsCallable('generateAffirmation');
      final HttpsCallableResult result = await callable.call<Map<String, dynamic>>({'prompt': prompt});
      return result.data['affirmation'];
    } catch (e) {
      print('Error calling generateAffirmation: $e');
      return 'Error generating affirmation.';
    }
  }

  Future<String> generateEncouragement(String completedActivity) async {
    try {
      final HttpsCallable callable = _functions.httpsCallable('generateEncouragement');
      final HttpsCallableResult result = await callable.call<Map<String, dynamic>>({'completedActivity': completedActivity});
      return result.data['encouragement'];
    } catch (e) {
      print('Error calling generateEncouragement: $e');
      return 'Error generating encouragement.';
    }
  }

  Future<String> generateNewAffirmation(String dislikedAffirmation) async {
    try {
      final HttpsCallable callable = _functions.httpsCallable('generateNewAffirmation');
      final HttpsCallableResult result = await callable.call<Map<String, dynamic>>({'dislikedAffirmation': dislikedAffirmation});
      return result.data['affirmation'];
    } catch (e) {
      print('Error calling generateNewAffirmation: $e');
      return 'Error generating new affirmation.';
    }
  }
}