import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'app.dart';

/// Entry point for the Mixologist Flutter application
/// 
/// This file is kept minimal and only handles:
/// - Flutter framework initialization
/// - Firebase initialization 
/// - Running the main app widget
/// 
/// All app configuration, themes, and routing are handled in app.dart
void main() async {
  // Ensure Flutter framework is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with platform-specific configuration
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Run the main application
  runApp(const MixologistApp());
}