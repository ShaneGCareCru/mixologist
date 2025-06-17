import 'package:flutter/material.dart';
import 'package:particles_flutter/particles_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'drink_theme_engine.dart';
import 'drink_theme_provider.dart';
import 'dart:math' as math;

/// Overlay that creates ambient gradients based on drink theme
class DrinkContextOverlay extends StatelessWidget {
  const DrinkContextOverlay({
    Key? key,
    required this.child,
    this.enableGradients = true,
    this.enableParticles = true,
    this.enableEdgeGlow = true,
    this.scrollPosition = 0.0,
    this.intensity = 1.0,
  }) : super(key: key);

  final Widget child;
  final bool enableGradients;
  final bool enableParticles;
  final bool enableEdgeGlow;
  final double scrollPosition;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    final theme = DrinkThemeProvider.of(context);
    
    return Stack(
      children: [
        // Background ambient gradient
        if (enableGradients) _buildAmbientGradient(theme),
        
        // Main content
        child,
        
        // Particle effects
        if (enableParticles) _buildParticleSystem(theme),
        
        // Edge glow effects
        if (enableEdgeGlow) _buildEdgeGlow(theme),
        
        // Scroll-based overlay
        _buildScrollOverlay(theme),
      ],
    );
  }

  Widget _buildAmbientGradient(DrinkThemeData theme) {
    final gradientOpacity = (intensity * 0.1).clamp(0.0, 0.2);
    
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              theme.primary.withOpacity(gradientOpacity),
              theme.accent.withOpacity(gradientOpacity * 0.5),
              Colors.transparent,
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
      ).animate(
        effects: [
          FadeEffect(
            duration: 2.seconds,
            curve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }

  Widget _buildParticleSystem(DrinkThemeData theme) {
    return Positioned.fill(
      child: _DrinkParticleSystem(
        theme: theme,
        intensity: intensity,
        scrollPosition: scrollPosition,
      ),
    );
  }

  Widget _buildEdgeGlow(DrinkThemeData theme) {
    return Positioned.fill(
      child: _EdgeGlowEffect(
        theme: theme,
        intensity: intensity,
      ),
    );
  }

  Widget _buildScrollOverlay(DrinkThemeData theme) {
    final scrollOpacity = (scrollPosition / 1000.0 * intensity * 0.1).clamp(0.0, 0.15);
    
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.accent.withOpacity(scrollOpacity),
              Colors.transparent,
              theme.primary.withOpacity(scrollOpacity * 0.5),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }
}

/// Particle system that matches the drink theme
class _DrinkParticleSystem extends StatefulWidget {
  const _DrinkParticleSystem({
    required this.theme,
    required this.intensity,
    required this.scrollPosition,
  });

  final DrinkThemeData theme;
  final double intensity;
  final double scrollPosition;

  @override
  State<_DrinkParticleSystem> createState() => _DrinkParticleSystemState();
}

class _DrinkParticleSystemState extends State<_DrinkParticleSystem>
    with TickerProviderStateMixin {
  late List<_Particle> particles;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    
    _initializeParticles();
  }

  void _initializeParticles() {
    final particleCount = (widget.intensity * 15).round();
    particles = List.generate(particleCount, (index) {
      return _Particle(
        color: widget.theme.gradientColors[index % widget.theme.gradientColors.length],
        position: Offset(
          math.Random().nextDouble(),
          math.Random().nextDouble(),
        ),
        velocity: Offset(
          (math.Random().nextDouble() - 0.5) * 0.02,
          (math.Random().nextDouble() - 0.5) * 0.01,
        ),
        size: math.Random().nextDouble() * 3 + 1,
        opacity: math.Random().nextDouble() * 0.6 + 0.2,
        life: 1.0,
      );
    });
  }

  @override
  void didUpdateWidget(_DrinkParticleSystem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.theme != oldWidget.theme) {
      _initializeParticles();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        _updateParticles();
        return CustomPaint(
          painter: _ParticlePainter(particles: particles),
          size: Size.infinite,
        );
      },
    );
  }

  void _updateParticles() {
    for (var particle in particles) {
      particle.position += particle.velocity;
      
      // Wrap around screen edges
      if (particle.position.dx < 0 || particle.position.dx > 1) {
        particle.velocity = Offset(-particle.velocity.dx, particle.velocity.dy);
      }
      if (particle.position.dy < 0 || particle.position.dy > 1) {
        particle.velocity = Offset(particle.velocity.dx, -particle.velocity.dy);
      }
      
      particle.position = Offset(
        particle.position.dx.clamp(0.0, 1.0),
        particle.position.dy.clamp(0.0, 1.0),
      );
    }
  }
}

/// Edge glow effect that responds to theme
class _EdgeGlowEffect extends StatelessWidget {
  const _EdgeGlowEffect({
    required this.theme,
    required this.intensity,
  });

  final DrinkThemeData theme;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _EdgeGlowPainter(
        color: theme.accent,
        intensity: intensity,
      ),
      size: Size.infinite,
    );
  }
}

/// Particle data class
class _Particle {
  Offset position;
  Offset velocity;
  final Color color;
  final double size;
  final double opacity;
  double life;

  _Particle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    required this.opacity,
    required this.life,
  });
}

/// Custom painter for particle effects
class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;

  _ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;

      final position = Offset(
        particle.position.dx * size.width,
        particle.position.dy * size.height,
      );

      canvas.drawCircle(position, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) {
    return oldDelegate.particles != particles;
  }
}

/// Custom painter for edge glow effects
class _EdgeGlowPainter extends CustomPainter {
  final Color color;
  final double intensity;

  _EdgeGlowPainter({required this.color, required this.intensity});

  @override
  void paint(Canvas canvas, Size size) {
    final glowOpacity = (intensity * 0.3).clamp(0.0, 0.5);
    
    // Top edge glow
    final topPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.center,
        colors: [
          color.withOpacity(glowOpacity),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.2));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.2),
      topPaint,
    );

    // Bottom edge glow
    final bottomPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.center,
        colors: [
          color.withOpacity(glowOpacity),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, size.height * 0.8, size.width, size.height * 0.2));

    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.8, size.width, size.height * 0.2),
      bottomPaint,
    );
  }

  @override
  bool shouldRepaint(_EdgeGlowPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.intensity != intensity;
  }
}

/// Scroll-responsive overlay widget
class ScrollReactiveOverlay extends StatefulWidget {
  const ScrollReactiveOverlay({
    Key? key,
    required this.child,
    required this.scrollController,
    this.maxScrollExtent = 1000.0,
    this.enableParallax = true,
  }) : super(key: key);

  final Widget child;
  final ScrollController scrollController;
  final double maxScrollExtent;
  final bool enableParallax;

  @override
  State<ScrollReactiveOverlay> createState() => _ScrollReactiveOverlayState();
}

class _ScrollReactiveOverlayState extends State<ScrollReactiveOverlay> {
  double _scrollProgress = 0.0;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_updateScrollPosition);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_updateScrollPosition);
    super.dispose();
  }

  void _updateScrollPosition() {
    final progress = (widget.scrollController.offset / widget.maxScrollExtent).clamp(0.0, 1.0);
    if (mounted) {
      setState(() {
        _scrollProgress = progress;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DrinkContextOverlay(
      scrollPosition: widget.scrollController.offset,
      intensity: 1.0 - (_scrollProgress * 0.5), // Reduce intensity as user scrolls
      child: widget.child,
    );
  }
}

/// Ambient light widget that pulses based on theme
class AmbientLightPulse extends StatefulWidget {
  const AmbientLightPulse({
    Key? key,
    required this.child,
    this.pulseSpeed = 3.0,
    this.minIntensity = 0.3,
    this.maxIntensity = 0.8,
  }) : super(key: key);

  final Widget child;
  final double pulseSpeed;
  final double minIntensity;
  final double maxIntensity;

  @override
  State<AmbientLightPulse> createState() => _AmbientLightPulseState();
}

class _AmbientLightPulseState extends State<AmbientLightPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: Duration(seconds: widget.pulseSpeed.round()),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: widget.minIntensity,
      end: widget.maxIntensity,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return DrinkContextOverlay(
          intensity: _pulseAnimation.value,
          child: widget.child,
        );
      },
    );
  }
}

/// Temperature-based environmental effects
class TemperatureEnvironmentOverlay extends StatelessWidget {
  const TemperatureEnvironmentOverlay({
    Key? key,
    required this.child,
    this.temperature = ColorTemperature.neutral,
  }) : super(key: key);

  final Widget child;
  final ColorTemperature temperature;

  @override
  Widget build(BuildContext context) {
    Widget environmentalEffect = Container();

    switch (temperature) {
      case ColorTemperature.cool:
        environmentalEffect = _buildCoolEffects();
        break;
      case ColorTemperature.warm:
        environmentalEffect = _buildWarmEffects();
        break;
      case ColorTemperature.neutral:
        environmentalEffect = _buildNeutralEffects();
        break;
    }

    return Stack(
      children: [
        child,
        environmentalEffect,
      ],
    );
  }

  Widget _buildCoolEffects() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [
              Colors.blue.withOpacity(0.05),
              Colors.cyan.withOpacity(0.03),
              Colors.transparent,
            ],
          ),
        ),
      ).animate(
        effects: [
          ShimmerEffect(
            duration: 4.seconds,
            color: Colors.white.withOpacity(0.1),
          ),
        ],
      ),
    );
  }

  Widget _buildWarmEffects() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.bottomLeft,
            radius: 1.2,
            colors: [
              Colors.orange.withOpacity(0.08),
              Colors.red.withOpacity(0.04),
              Colors.transparent,
            ],
          ),
        ),
      ).animate(
        effects: [
          ShimmerEffect(
            duration: 3.seconds,
            color: Colors.yellow.withOpacity(0.1),
          ),
        ],
      ),
    );
  }

  Widget _buildNeutralEffects() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withOpacity(0.02),
              Colors.transparent,
              Colors.grey.withOpacity(0.01),
            ],
          ),
        ),
      ),
    );
  }
}