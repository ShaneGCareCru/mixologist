import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Added Firebase Auth import
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MixologistApp());
}

class MixologistApp extends StatelessWidget {
  const MixologistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mixologist',
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mixologist Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              final userCredential =
                  await FirebaseAuth.instance.signInAnonymously();
              print("Signed in anonymously: ${userCredential.user?.uid}");
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              }
            } catch (e) {
              print("Error signing in anonymously: $e");
              // TODO: Show error to the user
            }
          },
          child: const Text('Sign In Anonymously'), // Changed button text
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current user
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mixologist Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              user?.isAnonymous ?? false
                  ? 'Welcome, Anonymous User!'
                  : 'Welcome!',
            ),
            if (user != null) Text('User ID: ${user.uid}'),
          ],
        ),
      ),
    );
  }
}
