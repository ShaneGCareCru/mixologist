import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // or match your theme
      body: Center(
        child: SizedBox(
          height: 200,
          width: 200,
          child: const RiveAnimation.asset(
            'assets/animations/placeholder.riv',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}