import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_test/flutter_test.dart';

void setupFirebaseMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
  // You might need to initialize a default app here if your tests expect it
  // For example:
  // Firebase.initializeApp(
  //   options: const FirebaseOptions(
  //     apiKey: 'test',
  //     appId: 'test',
  //     messagingSenderId: 'test',
  //     projectId: 'test',
  //   ),
  // );
}