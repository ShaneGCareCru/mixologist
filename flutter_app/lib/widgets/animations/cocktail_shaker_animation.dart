import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/haptic_service.dart';

/// DISABLED: Static cocktail shaker that triggers haptics without complex animations
/// Previously caused performance issues and curve errors
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

class _CocktailShakerAnimationState extends State<CocktailShakerAnimation> {
  bool _isShaking = false;
  
  @override
  void initState() {
    super.initState();
    // DISABLED: No animation controllers to prevent curve errors
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
  
  /// Start the shaking animation - DISABLED: Just trigger haptics
  void startShaking() {
    if (_isShaking) return;
    
    setState(() {
      _isShaking = true;
    });
    
    // DISABLED: Just play haptics immediately and complete
    if (widget.enableHaptics) {
      HapticService.instance.cocktailShake();
    }
    
    // Complete immediately after haptics
    Future.delayed(const Duration(milliseconds: 100), () {
      _onShakeComplete();
    });
  }
  
  /// Stop the shaking animation - DISABLED: Just set state
  void stopShaking() {
    setState(() {
      _isShaking = false;
    });
  }
  
  /// Reset the animation to initial state - DISABLED: Just set state
  void reset() {
    setState(() {
      _isShaking = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    // DISABLED: Static shaker without animations
    return widget.child ?? _buildDefaultShaker();
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