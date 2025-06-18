import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Haptic feedback service that provides cocktail-themed haptic patterns
/// with user preference controls and platform-specific implementations
class HapticService {
  static HapticService? _instance;
  static HapticService get instance => _instance ??= HapticService._();
  
  HapticService._();
  
  static const String _hapticEnabledKey = 'haptic_feedback_enabled';
  bool _isEnabled = true;
  bool _isInitialized = false;
  
  /// Initialize the service and load user preferences
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      _isEnabled = prefs.getBool(_hapticEnabledKey) ?? true;
      _isInitialized = true;
    } catch (e) {
      debugPrint('HapticService: Failed to load preferences: $e');
      _isEnabled = true;
      _isInitialized = true;
    }
  }
  
  /// Enable or disable haptic feedback
  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_hapticEnabledKey, enabled);
    } catch (e) {
      debugPrint('HapticService: Failed to save preference: $e');
    }
  }
  
  /// Check if haptic feedback is enabled
  bool get isEnabled => _isEnabled;
  
  /// Ensure service is initialized before use
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }
  
  /// Medium impact haptic for ingredient checking
  /// Simulates the satisfying "plop" of adding an ingredient
  Future<void> ingredientCheck() async {
    await _ensureInitialized();
    if (!_isEnabled) return;
    
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await HapticFeedback.mediumImpact();
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        // Custom pattern for Android: medium vibration
        await Vibration.vibrate(duration: 100, amplitude: 128);
      }
    } catch (e) {
      debugPrint('HapticService: ingredientCheck failed: $e');
    }
  }
  
  /// Light impact haptic for step completion
  /// Gentle feedback for each completed step
  Future<void> stepComplete() async {
    await _ensureInitialized();
    if (!_isEnabled) return;
    
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await HapticFeedback.lightImpact();
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        // Light vibration pattern
        await Vibration.vibrate(duration: 50, amplitude: 64);
      }
    } catch (e) {
      debugPrint('HapticService: stepComplete failed: $e');
    }
  }
  
  /// Success pattern haptic for recipe completion
  /// Celebratory feedback when cocktail is finished
  Future<void> recipeFinish() async {
    await _ensureInitialized();
    if (!_isEnabled) return;
    
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        // iOS has built-in success pattern
        await HapticFeedback.heavyImpact();
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        // Custom success pattern: three ascending pulses
        await Vibration.vibrate(duration: 100, amplitude: 100);
        await Future.delayed(const Duration(milliseconds: 50));
        await Vibration.vibrate(duration: 100, amplitude: 150);
        await Future.delayed(const Duration(milliseconds: 50));
        await Vibration.vibrate(duration: 150, amplitude: 200);
      }
    } catch (e) {
      debugPrint('HapticService: recipeFinish failed: $e');
    }
  }
  
  /// Heavy impact haptic for significant actions
  /// Used for major interactions like recipe favorites
  Future<void> heavyImpact() async {
    await _ensureInitialized();
    if (!_isEnabled) return;
    
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await HapticFeedback.heavyImpact();
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        // Heavy vibration
        await Vibration.vibrate(duration: 200, amplitude: 255);
      }
    } catch (e) {
      debugPrint('HapticService: heavyImpact failed: $e');
    }
  }
  
  /// Selection haptic for UI interactions
  /// Subtle feedback for button presses and selections
  Future<void> selection() async {
    await _ensureInitialized();
    if (!_isEnabled) return;
    
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await HapticFeedback.selectionClick();
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        // Very light vibration for selection
        await Vibration.vibrate(duration: 25, amplitude: 50);
      }
    } catch (e) {
      debugPrint('HapticService: selection failed: $e');
    }
  }
  
  /// Error haptic for failed actions
  /// Provides feedback when something goes wrong
  Future<void> error() async {
    await _ensureInitialized();
    if (!_isEnabled) return;
    
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await HapticFeedback.heavyImpact();
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        // Error pattern: two quick pulses
        await Vibration.vibrate(duration: 100, amplitude: 150);
        await Future.delayed(const Duration(milliseconds: 100));
        await Vibration.vibrate(duration: 100, amplitude: 150);
      }
    } catch (e) {
      debugPrint('HapticService: error failed: $e');
    }
  }
  
  /// Custom cocktail shaker haptic pattern
  /// Simulates the rhythm of shaking a cocktail
  Future<void> cocktailShake() async {
    await _ensureInitialized();
    if (!_isEnabled) return;
    
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        // Simulate shaking rhythm with alternating impacts
        for (int i = 0; i < 6; i++) {
          await HapticFeedback.lightImpact();
          await Future.delayed(const Duration(milliseconds: 150));
        }
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        // Android shaking pattern
        const pattern = [0, 100, 50, 100, 50, 100, 50, 100, 50, 100, 50, 100];
        await Vibration.vibrate(pattern: pattern, intensities: [0, 100, 0, 100, 0, 100, 0, 100, 0, 100, 0, 100]);
      }
    } catch (e) {
      debugPrint('HapticService: cocktailShake failed: $e');
    }
  }
  
  /// Glass clink haptic for sharing
  /// Simulates two glasses touching
  Future<void> glassClink() async {
    await _ensureInitialized();
    if (!_isEnabled) return;
    
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.lightImpact();
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        // Glass clink: sharp tap followed by light resonance
        await Vibration.vibrate(duration: 50, amplitude: 200);
        await Future.delayed(const Duration(milliseconds: 100));
        await Vibration.vibrate(duration: 30, amplitude: 80);
      }
    } catch (e) {
      debugPrint('HapticService: glassClink failed: $e');
    }
  }
  
  /// Check if device supports vibration
  static Future<bool> hasVibrator() async {
    try {
      return await Vibration.hasVibrator() ?? false;
    } catch (e) {
      debugPrint('HapticService: hasVibrator check failed: $e');
      return false;
    }
  }
  
  /// Check if device supports custom vibration patterns
  static Future<bool> hasCustomVibrationsSupport() async {
    try {
      return await Vibration.hasCustomVibrationsSupport() ?? false;
    } catch (e) {
      debugPrint('HapticService: hasCustomVibrationsSupport check failed: $e');
      return false;
    }
  }
}