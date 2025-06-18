import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/haptic_service.dart';

/// Animated cocktail shaker widget that performs shaking motion with rotation,
/// optional ice sound effects, and condensation appearance
class CocktailShakerAnimation extends StatefulWidget {
  final int shakeCount;
  final Duration shakeDuration;
  final bool enableHaptics;
  final bool enableSoundEffects;
  final Widget? child;
  final double shakeIntensity;
  final VoidCallback? onShakeComplete;
  
  const CocktailShakerAnimation({
    super.key,
    this.shakeCount = 12,
    this.shakeDuration = const Duration(milliseconds: 2000),
    this.enableHaptics = true,
    this.enableSoundEffects = false,
    this.child,
    this.shakeIntensity = 8.0,
    this.onShakeComplete,
  });

  @override
  State<CocktailShakerAnimation> createState() => _CocktailShakerAnimationState();
}

class _CocktailShakerAnimationState extends State<CocktailShakerAnimation>
    with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late AnimationController _rotationController;
  late AnimationController _condensationController;
  
  late Animation<double> _shakeAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _condensationOpacity;
  late Animation<double> _condensationScale;
  
  bool _isShaking = false;
  
  @override
  void initState() {
    super.initState();
    
    // Main shake animation controller
    _shakeController = AnimationController(
      duration: widget.shakeDuration,
      vsync: this,
    );
    
    // Rotation animation controller (faster than shake)
    _rotationController = AnimationController(
      duration: Duration(milliseconds: widget.shakeDuration.inMilliseconds ~/ 3),
      vsync: this,
    );
    
    // Condensation animation controller
    _condensationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Shake animation with oscillation
    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: widget.shakeCount.toDouble(),
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.linear,
    ));
    
    // Rotation animation
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 4.0, // 4 full rotations
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));
    
    // Condensation opacity
    _condensationOpacity = Tween<double>(
      begin: 0.0,
      end: 0.6,
    ).animate(CurvedAnimation(
      parent: _condensationController,
      curve: Curves.easeIn,
    ));
    
    // Condensation scale
    _condensationScale = Tween<double>(
      begin: 0.8,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _condensationController,
      curve: Curves.easeOut,
    ));
    
    // Listen for animation completion
    _shakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onShakeComplete();
      }
    });
    
    // Add haptic feedback during shaking
    if (widget.enableHaptics) {
      _shakeController.addListener(_handleHapticFeedback);
    }
  }
  
  void _handleHapticFeedback() {
    // Trigger haptic feedback at specific intervals during shake
    final progress = _shakeController.value;
    final shakePhase = (_shakeAnimation.value % 1.0);
    
    // Trigger haptic on each shake peak
    if (shakePhase < 0.1 && progress > 0.1) {
      HapticService.instance.selection();
    }
  }
  
  void _onShakeComplete() {
    setState(() {
      _isShaking = false;
    });
    
    if (widget.enableHaptics) {
      HapticService.instance.stepComplete();
    }
    
    widget.onShakeComplete?.call();
  }
  
  /// Start the shaking animation
  void startShaking() {
    if (_isShaking) return;
    
    setState(() {
      _isShaking = true;
    });
    
    // Start all animations
    _shakeController.forward(from: 0);
    _rotationController.repeat();
    _condensationController.forward(from: 0);
    
    // Play haptic pattern for shaking
    if (widget.enableHaptics) {
      HapticService.instance.cocktailShake();
    }
  }
  
  /// Stop the shaking animation
  void stopShaking() {
    _shakeController.stop();
    _rotationController.stop();
    _condensationController.reverse();
    
    setState(() {
      _isShaking = false;
    });
  }
  
  /// Reset the animation to initial state
  void reset() {
    _shakeController.reset();
    _rotationController.reset();
    _condensationController.reset();
    
    setState(() {
      _isShaking = false;
    });
  }
  
  @override
  void dispose() {
    _shakeController.dispose();
    _rotationController.dispose();
    _condensationController.dispose();
    super.dispose();
  }
  
  /// Calculate shake offset based on animation value
  Offset _calculateShakeOffset() {
    if (!_isShaking) return Offset.zero;
    
    final shakeValue = _shakeAnimation.value;
    final intensity = widget.shakeIntensity;
    
    // Create figure-8 shake pattern
    final x = sin(shakeValue * 2 * pi) * intensity;
    final y = sin(shakeValue * pi) * intensity * 0.5;
    
    return Offset(x, y);
  }
  
  /// Calculate rotation angle
  double _calculateRotation() {
    if (!_isShaking) return 0.0;
    return _rotationAnimation.value * 2 * pi;
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _shakeController,
        _rotationController,
        _condensationController,
      ]),
      builder: (context, child) {
        return Transform.translate(
          offset: _calculateShakeOffset(),
          child: Transform.rotate(
            angle: _calculateRotation(),
            child: Stack(
              children: [
                // Main shaker content
                widget.child ?? _buildDefaultShaker(),
                
                // Condensation effect overlay
                if (_isShaking)
                  Positioned.fill(
                    child: Opacity(
                      opacity: _condensationOpacity.value,
                      child: Transform.scale(
                        scale: _condensationScale.value,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: RadialGradient(
                              center: const Alignment(0.3, -0.5),
                              colors: [
                                Colors.white.withOpacity(0.1),
                                Colors.white.withOpacity(0.05),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.7, 1.0],
                            ),
                          ),
                          child: _buildCondensationDroplets(),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  /// Build default shaker appearance if no child provided
  Widget _buildDefaultShaker() {
    return Container(
      width: 80,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFE8E8E8),
            const Color(0xFFC0C0C0),
            const Color(0xFF888888),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Shaker body details
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFF666666),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          ),
          
          // Shaker top cap
          Positioned(
            top: 5,
            left: 15,
            right: 15,
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF999999),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          
          // Shaker strainer holes (visual detail)
          Positioned(
            top: 25,
            left: 20,
            right: 20,
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: List.generate(12, (index) {
                return Container(
                  width: 3,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFF666666),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build condensation droplets effect
  Widget _buildCondensationDroplets() {
    return Stack(
      children: List.generate(8, (index) {
        final random = Random(index);
        final left = random.nextDouble() * 0.8 + 0.1;
        final top = random.nextDouble() * 0.8 + 0.1;
        final size = random.nextDouble() * 4 + 2;
        
        return Positioned(
          left: left * 80,
          top: top * 120,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}

/// Interactive shaker widget that starts shaking on tap
class InteractiveCocktailShaker extends StatefulWidget {
  final Widget? child;
  final int shakeCount;
  final Duration shakeDuration;
  final bool enableHaptics;
  final VoidCallback? onShakeStart;
  final VoidCallback? onShakeComplete;
  
  const InteractiveCocktailShaker({
    super.key,
    this.child,
    this.shakeCount = 12,
    this.shakeDuration = const Duration(milliseconds: 2000),
    this.enableHaptics = true,
    this.onShakeStart,
    this.onShakeComplete,
  });

  @override
  State<InteractiveCocktailShaker> createState() => _InteractiveCocktailShakerState();
}

class _InteractiveCocktailShakerState extends State<InteractiveCocktailShaker> {
  final GlobalKey<_CocktailShakerAnimationState> _shakerKey = GlobalKey();
  bool _isShaking = false;
  
  void _handleTap() {
    if (_isShaking) return;
    
    setState(() {
      _isShaking = true;
    });
    
    widget.onShakeStart?.call();
    _shakerKey.currentState?.startShaking();
  }
  
  void _onShakeComplete() {
    setState(() {
      _isShaking = false;
    });
    
    widget.onShakeComplete?.call();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: CocktailShakerAnimation(
        key: _shakerKey,
        shakeCount: widget.shakeCount,
        shakeDuration: widget.shakeDuration,
        enableHaptics: widget.enableHaptics,
        onShakeComplete: _onShakeComplete,
        child: widget.child,
      ),
    );
  }
}