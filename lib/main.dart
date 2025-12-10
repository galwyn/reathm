import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'auth_service.dart';
import 'firebase_options.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'main_scaffold.dart';
import 'notification_service.dart';
import 'seed_data.dart';

// Toggle this to true if you want to use local emulators.
const bool useEmulators = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kDebugMode && useEmulators) {
    // Connect to Firebase Emulators
    // For Android emulator, use 10.0.2.2. For iOS/Web, use localhost.
    final String emulatorHost =
        defaultTargetPlatform == TargetPlatform.android ? '10.0.2.2' : 'localhost';

    print('Connecting to Firebase Emulators at $emulatorHost');

    try {
      FirebaseFirestore.instance.useFirestoreEmulator(emulatorHost, 8080);
      await FirebaseAuth.instance.useAuthEmulator(emulatorHost, 9099);
      FirebaseFunctions.instance.useFunctionsEmulator(emulatorHost, 5001);

      // Seed data only if explicitly requested or needed, not on every reload.
      // await wipeAndSeedDatabase('nXT0qdPYkbYBPyaVUByzKo7MCRt2');
    } catch (e) {
      print('Error connecting to emulators: $e');
    }
  }
  // await NotificationService().init();
  runApp(ReathmApp());
}

class ReathmApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reathm',
      theme: ThemeData(
        primaryColor: const Color(0xFF4285F4),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFFFFA726),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          print('Auth state changed: ${snapshot.data}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return MainScreen(user: snapshot.data!);
          }
          return LoginPage();
        },
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  final User user;

  const MainScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainScaffold(user: user);
  }
}
