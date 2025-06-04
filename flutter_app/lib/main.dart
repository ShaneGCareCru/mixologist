import 'package:flutter/material.dart';

void main() {
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
          onPressed: () {
            // TODO: implement sign in flow
          },
          child: const Text('Sign In'),
        ),
      ),
    );
  }
}
