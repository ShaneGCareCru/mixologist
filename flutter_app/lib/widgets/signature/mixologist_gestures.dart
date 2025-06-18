import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../../../services/haptic_service.dart';

/// Signature gesture library for mixologist-specific interactions
/// Includes stir, shake, muddle, and pour gestures with tutorials
class MixologistGestures {
  /// Create a stir gesture detector with circular motion recognition
  static Widget stirGesture(
    Widget child, {
    required VoidCallback onStirComplete,
    VoidCallback? onStirStart,
    ValueChanged<double>? onStirProgress,
    double sensitivity = 50.0,
    int requiredRotations = 2,
    bool enableHaptics = true,
    bool showTutorial = false,
  }) {
    return _StirGestureDetector(
      onStirComplete: onStirComplete,
      onStirStart: onStirStart,
      onStirProgress: onStirProgress,
      sensitivity: sensitivity,
      requiredRotations: requiredRotations,
      enableHaptics: enableHaptics,
      showTutorial: showTutorial,
      child: child,
    );
  }

  /// Create a shake gesture detector with device motion recognition
  static Widget shakeGesture(
    Widget child, {
    required VoidCallback onShakeComplete,
    VoidCallback? onShakeStart,
    ValueChanged<double>? onShakeProgress,
    double intensity = 15.0,
    Duration requiredDuration = const Duration(seconds: 3),
    bool enableHaptics = true,
    bool showTutorial = false,
  }) {
    return _ShakeGestureDetector(
      onShakeComplete: onShakeComplete,
      onShakeStart: onShakeStart,
      onShakeProgress: onShakeProgress,
      intensity: intensity,
      requiredDuration: requiredDuration,
      enableHaptics: enableHaptics,
      showTutorial: showTutorial,
      child: child,
    );
  }

  /// Create a muddle gesture detector with press and twist motion
  static Widget muddleGesture(
    Widget child, {
    required VoidCallback onMuddleComplete,
    VoidCallback? onMuddleStart,
    ValueChanged<double>? onMuddleProgress,
    int requiredPresses = 5,
    bool enableHaptics = true,
    bool showTutorial = false,
  }) {
    return _MuddleGestureDetector(
      onMuddleComplete: onMuddleComplete,
      onMuddleStart: onMuddleStart,
      onMuddleProgress: onMuddleProgress,
      requiredPresses: requiredPresses,
      enableHaptics: enableHaptics,
      showTutorial: showTutorial,
      child: child,
    );
  }

  /// Create a pour gesture detector with tilt motion
  static Widget pourGesture(
    Widget child, {
    required VoidCallback onPourComplete,
    VoidCallback? onPourStart,
    ValueChanged<double>? onPourProgress,
    Duration requiredDuration = const Duration(seconds: 2),
    bool enableHaptics = true,
    bool showTutorial = false,
  }) {
    return _PourGestureDetector(
      onPourComplete: onPourComplete,
      onPourStart: onPourStart,
      onPourProgress: onPourProgress,
      requiredDuration: requiredDuration,
      enableHaptics: enableHaptics,
      showTutorial: showTutorial,
      child: child,
    );
  }
}

/// Stir gesture detector implementation
class _StirGestureDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback onStirComplete;
  final VoidCallback? onStirStart;
  final ValueChanged<double>? onStirProgress;
  final double sensitivity;
  final int requiredRotations;
  final bool enableHaptics;
  final bool showTutorial;

  const _StirGestureDetector({
    required this.child,
    required this.onStirComplete,
    this.onStirStart,
    this.onStirProgress,
    required this.sensitivity,
    required this.requiredRotations,
    required this.enableHaptics,
    required this.showTutorial,
  });

  @override
  State<_StirGestureDetector> createState() => _StirGestureDetectorState();
}

class _StirGestureDetectorState extends State<_StirGestureDetector>
    with TickerProviderStateMixin {
  late AnimationController _tutorialController;
  late Animation<double> _tutorialAnimation;
  
  Offset? _center;
  double _totalRotation = 0.0;
  double _lastAngle = 0.0;
  bool _isStirring = false;
  bool _hasStarted = false;
  List<Offset> _recentPoints = [];
  
  @override
  void initState() {
    super.initState();
    
    _tutorialController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _tutorialAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _tutorialController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.showTutorial) {
      _tutorialController.repeat();
    }
  }
  
  @override
  void dispose() {
    _tutorialController.dispose();
    super.dispose();
  }
  
  void _onPanStart(DragStartDetails details) {
    _center = details.localPosition;
    _totalRotation = 0.0;
    _lastAngle = 0.0;
    _isStirring = false;
    _hasStarted = false;
    _recentPoints.clear();
  }
  
  void _onPanUpdate(DragUpdateDetails details) {
    if (_center == null) return;
    
    final currentPoint = details.localPosition;
    _recentPoints.add(currentPoint);
    
    // Keep only recent points for circular detection
    if (_recentPoints.length > 10) {
      _recentPoints.removeAt(0);
    }
    
    // Calculate angle from center
    final dx = currentPoint.dx - _center!.dx;
    final dy = currentPoint.dy - _center!.dy;
    final distance = sqrt(dx * dx + dy * dy);
    
    if (distance < widget.sensitivity) return;
    
    final angle = atan2(dy, dx);
    
    if (!_hasStarted) {
      _hasStarted = true;
      _lastAngle = angle;
      widget.onStirStart?.call();
      return;
    }
    
    // Detect circular motion
    if (_isCircularMotion()) {
      _isStirring = true;
      
      // Calculate rotation delta
      double deltaAngle = angle - _lastAngle;
      
      // Handle angle wrap-around
      if (deltaAngle > pi) {
        deltaAngle -= 2 * pi;
      } else if (deltaAngle < -pi) {
        deltaAngle += 2 * pi;
      }
      
      _totalRotation += deltaAngle.abs();
      _lastAngle = angle;
      
      final progress = min(_totalRotation / (widget.requiredRotations * 2 * pi), 1.0);
      widget.onStirProgress?.call(progress);
      
      // Haptic feedback at quarter rotations
      if (widget.enableHaptics && 
          (_totalRotation / (pi / 2)).floor() > (_totalRotation - deltaAngle.abs()) / (pi / 2).floor()) {
        HapticService.instance.selection();
      }
      
      // Check completion
      if (progress >= 1.0) {
        widget.onStirComplete();
        if (widget.enableHaptics) {
          HapticService.instance.recipeFinish();
        }
      }
    }
  }
  
  bool _isCircularMotion() {
    if (_recentPoints.length < 5) return false;
    
    // Check if recent points form a circular pattern
    double totalAngle = 0.0;
    for (int i = 1; i < _recentPoints.length; i++) {
      final prev = _recentPoints[i - 1];
      final curr = _recentPoints[i];
      
      if (_center != null) {
        final angle1 = atan2(prev.dy - _center!.dy, prev.dx - _center!.dx);
        final angle2 = atan2(curr.dy - _center!.dy, curr.dx - _center!.dx);
        
        double deltaAngle = angle2 - angle1;
        if (deltaAngle > pi) deltaAngle -= 2 * pi;
        if (deltaAngle < -pi) deltaAngle += 2 * pi;
        
        totalAngle += deltaAngle.abs();
      }
    }
    
    return totalAngle > pi / 3; // At least 60 degrees of circular motion
  }
  
  void _onPanEnd(DragEndDetails details) {
    _isStirring = false;
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Stack(
        children: [
          widget.child,
          if (widget.showTutorial)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _tutorialAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _StirTutorialPainter(
                        progress: _tutorialAnimation.value,
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Shake gesture detector implementation
class _ShakeGestureDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback onShakeComplete;
  final VoidCallback? onShakeStart;
  final ValueChanged<double>? onShakeProgress;
  final double intensity;
  final Duration requiredDuration;
  final bool enableHaptics;
  final bool showTutorial;

  const _ShakeGestureDetector({
    required this.child,
    required this.onShakeComplete,
    this.onShakeStart,
    this.onShakeProgress,
    required this.intensity,
    required this.requiredDuration,
    required this.enableHaptics,
    required this.showTutorial,
  });

  @override
  State<_ShakeGestureDetector> createState() => _ShakeGestureDetectorState();
}

class _ShakeGestureDetectorState extends State<_ShakeGestureDetector>
    with TickerProviderStateMixin {
  late AnimationController _tutorialController;
  late AnimationController _shakeController;
  
  DateTime? _shakeStartTime;
  bool _isShaking = false;
  List<Offset> _velocityHistory = [];
  
  @override
  void initState() {
    super.initState();
    
    _tutorialController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    if (widget.showTutorial) {
      _tutorialController.repeat(reverse: true);
    }
  }
  
  @override
  void dispose() {
    _tutorialController.dispose();
    _shakeController.dispose();
    super.dispose();
  }
  
  void _onPanUpdate(DragUpdateDetails details) {
    final velocity = details.delta;
    final speed = sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy);
    
    _velocityHistory.add(velocity);
    if (_velocityHistory.length > 10) {
      _velocityHistory.removeAt(0);
    }
    
    if (speed > widget.intensity) {
      if (!_isShaking) {
        _isShaking = true;
        _shakeStartTime = DateTime.now();
        widget.onShakeStart?.call();
        if (widget.enableHaptics) {
          HapticService.instance.shakeStart();
        }
      }
      
      _shakeController.forward().then((_) => _shakeController.reverse());
      
      if (_shakeStartTime != null) {
        final elapsed = DateTime.now().difference(_shakeStartTime!);
        final progress = min(elapsed.inMilliseconds / widget.requiredDuration.inMilliseconds, 1.0);
        widget.onStirProgress?.call(progress);
        
        if (progress >= 1.0) {
          widget.onShakeComplete();
          if (widget.enableHaptics) {
            HapticService.instance.recipeFinish();
          }
          _isShaking = false;
          _shakeStartTime = null;
        }
      }
    } else if (_isShaking && speed < widget.intensity * 0.5) {
      // Stop shaking if velocity drops significantly
      _isShaking = false;
      _shakeStartTime = null;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      child: AnimatedBuilder(
        animation: _shakeController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              sin(_shakeController.value * pi * 2) * 2,
              cos(_shakeController.value * pi * 2) * 2,
            ),
            child: Stack(
              children: [
                widget.child,
                if (widget.showTutorial)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedBuilder(
                        animation: _tutorialController,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: _ShakeTutorialPainter(
                              progress: _tutorialController.value,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Muddle gesture detector implementation
class _MuddleGestureDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback onMuddleComplete;
  final VoidCallback? onMuddleStart;
  final ValueChanged<double>? onMuddleProgress;
  final int requiredPresses;
  final bool enableHaptics;
  final bool showTutorial;

  const _MuddleGestureDetector({
    required this.child,
    required this.onMuddleComplete,
    this.onMuddleStart,
    this.onMuddleProgress,
    required this.requiredPresses,
    required this.enableHaptics,
    required this.showTutorial,
  });

  @override
  State<_MuddleGestureDetector> createState() => _MuddleGestureDetectorState();
}

class _MuddleGestureDetectorState extends State<_MuddleGestureDetector>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late AnimationController _tutorialController;
  
  int _pressCount = 0;
  bool _hasStarted = false;
  
  @override
  void initState() {
    super.initState();
    
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _tutorialController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    if (widget.showTutorial) {
      _tutorialController.repeat();
    }
  }
  
  @override
  void dispose() {
    _pressController.dispose();
    _tutorialController.dispose();
    super.dispose();
  }
  
  void _onTapDown(TapDownDetails details) {
    if (!_hasStarted) {
      _hasStarted = true;
      widget.onMuddleStart?.call();
    }
    
    _pressController.forward().then((_) => _pressController.reverse());
    
    _pressCount++;
    final progress = min(_pressCount / widget.requiredPresses, 1.0);
    widget.onMuddleProgress?.call(progress);
    
    if (widget.enableHaptics) {
      HapticService.instance.ingredientCheck();
    }
    
    if (_pressCount >= widget.requiredPresses) {
      widget.onMuddleComplete();
      if (widget.enableHaptics) {
        HapticService.instance.recipeFinish();
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      child: AnimatedBuilder(
        animation: _pressController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - (_pressController.value * 0.05),
            child: Stack(
              children: [
                widget.child,
                if (widget.showTutorial)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedBuilder(
                        animation: _tutorialController,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: _MuddleTutorialPainter(
                              progress: _tutorialController.value,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Pour gesture detector implementation
class _PourGestureDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback onPourComplete;
  final VoidCallback? onPourStart;
  final ValueChanged<double>? onPourProgress;
  final Duration requiredDuration;
  final bool enableHaptics;
  final bool showTutorial;

  const _PourGestureDetector({
    required this.child,
    required this.onPourComplete,
    this.onPourStart,
    this.onPourProgress,
    required this.requiredDuration,
    required this.enableHaptics,
    required this.showTutorial,
  });

  @override
  State<_PourGestureDetector> createState() => _PourGestureDetectorState();
}

class _PourGestureDetectorState extends State<_PourGestureDetector> {
  DateTime? _pourStartTime;
  bool _isPouring = false;
  double _tiltAngle = 0.0;
  
  void _onPanUpdate(DragUpdateDetails details) {
    final tilt = details.delta.dy;
    _tiltAngle = tilt;
    
    if (tilt < -5 && !_isPouring) {
      _isPouring = true;
      _pourStartTime = DateTime.now();
      widget.onPourStart?.call();
      
      if (widget.enableHaptics) {
        HapticService.instance.selection();
      }
    } else if (tilt > 5 && _isPouring) {
      _isPouring = false;
      _pourStartTime = null;
    }
    
    if (_isPouring && _pourStartTime != null) {
      final elapsed = DateTime.now().difference(_pourStartTime!);
      final progress = min(elapsed.inMilliseconds / widget.requiredDuration.inMilliseconds, 1.0);
      widget.onPourProgress?.call(progress);
      
      if (progress >= 1.0) {
        widget.onPourComplete();
        if (widget.enableHaptics) {
          HapticService.instance.recipeFinish();
        }
        _isPouring = false;
        _pourStartTime = null;
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      child: Transform.rotate(
        angle: _tiltAngle * 0.01,
        child: widget.child,
      ),
    );
  }
}

/// Tutorial painter for stir gesture
class _StirTutorialPainter extends CustomPainter {
  final double progress;
  
  _StirTutorialPainter({required this.progress});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 3;
    
    final paint = Paint()
      ..color = const Color(0xFFB8860B).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    
    // Draw circular motion path
    canvas.drawCircle(center, radius, paint);
    
    // Draw moving indicator
    final angle = progress * 2 * pi;
    final indicatorPos = Offset(
      center.dx + cos(angle) * radius,
      center.dy + sin(angle) * radius,
    );
    
    final indicatorPaint = Paint()
      ..color = const Color(0xFFB8860B)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(indicatorPos, 8, indicatorPaint);
    
    // Draw arrow showing direction
    final arrowAngle = angle + pi / 2;
    final arrowLength = 15.0;
    final arrowEnd = Offset(
      indicatorPos.dx + cos(arrowAngle) * arrowLength,
      indicatorPos.dy + sin(arrowAngle) * arrowLength,
    );
    
    canvas.drawLine(indicatorPos, arrowEnd, paint);
  }
  
  @override
  bool shouldRepaint(covariant _StirTutorialPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Tutorial painter for shake gesture
class _ShakeTutorialPainter extends CustomPainter {
  final double progress;
  
  _ShakeTutorialPainter({required this.progress});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    final paint = Paint()
      ..color = const Color(0xFFB8860B).withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    // Draw shake motion lines
    final shakeOffset = sin(progress * pi * 8) * 10;
    
    for (int i = 0; i < 5; i++) {
      final y = center.dy - 40 + i * 20;
      canvas.drawLine(
        Offset(center.dx - 30 + shakeOffset, y),
        Offset(center.dx + 30 + shakeOffset, y),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant _ShakeTutorialPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Tutorial painter for muddle gesture
class _MuddleTutorialPainter extends CustomPainter {
  final double progress;
  
  _MuddleTutorialPainter({required this.progress});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    final paint = Paint()
      ..color = const Color(0xFFB8860B).withOpacity(0.8)
      ..style = PaintingStyle.fill;
    
    // Draw pulsing circle to indicate tap
    final pulseRadius = 20 + sin(progress * pi * 4) * 10;
    canvas.drawCircle(center, pulseRadius, paint);
    
    // Draw "TAP" text
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'TAP',
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }
  
  @override
  bool shouldRepaint(covariant _MuddleTutorialPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Extension methods for easy gesture integration
extension GestureExtensions on Widget {
  /// Add stir gesture recognition to any widget
  Widget withStirGesture({
    required VoidCallback onComplete,
    VoidCallback? onStart,
    ValueChanged<double>? onProgress,
    bool showTutorial = false,
  }) {
    return MixologistGestures.stirGesture(
      this,
      onStirComplete: onComplete,
      onStirStart: onStart,
      onStirProgress: onProgress,
      showTutorial: showTutorial,
    );
  }
  
  /// Add shake gesture recognition to any widget
  Widget withShakeGesture({
    required VoidCallback onComplete,
    VoidCallback? onStart,
    ValueChanged<double>? onProgress,
    bool showTutorial = false,
  }) {
    return MixologistGestures.shakeGesture(
      this,
      onShakeComplete: onComplete,
      onShakeStart: onStart,
      onShakeProgress: onProgress,
      showTutorial: showTutorial,
    );
  }
  
  /// Add muddle gesture recognition to any widget
  Widget withMuddleGesture({
    required VoidCallback onComplete,
    VoidCallback? onStart,
    ValueChanged<double>? onProgress,
    bool showTutorial = false,
  }) {
    return MixologistGestures.muddleGesture(
      this,
      onMuddleComplete: onComplete,
      onMuddleStart: onStart,
      onMuddleProgress: onProgress,
      showTutorial: showTutorial,
    );
  }
}