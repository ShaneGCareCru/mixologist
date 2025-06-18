import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'drink_theme_engine.dart';
import 'drink_theme_provider.dart';

/// Animated container that smoothly transitions between drink themes
class AnimatedDrinkTheme extends StatefulWidget {
  const AnimatedDrinkTheme({
    Key? key,
    required this.theme,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.curve = Curves.easeInOutCubic,
    this.enableHaptics = true,
    this.staggerDelay = const Duration(milliseconds: 50),
  }) : super(key: key);

  final DrinkThemeData theme;
  final Widget child;
  final Duration duration;
  final Curve curve;
  final bool enableHaptics;
  final Duration staggerDelay;

  @override
  State<AnimatedDrinkTheme> createState() => _AnimatedDrinkThemeState();
}

class _AnimatedDrinkThemeState extends State<AnimatedDrinkTheme>
    with TickerProviderStateMixin {
  late AnimationController _primaryController;
  late AnimationController _accentController;
  late AnimationController _gradientController;
  
  late Animation<Color?> _primaryAnimation;
  late Animation<Color?> _accentAnimation;
  late List<Animation<Color?>> _gradientAnimations;
  
  DrinkThemeData? _previousTheme;
  DrinkThemeData _currentTheme = const DrinkThemeData(
    primary: Colors.grey,
    accent: Colors.grey,
    temperature: ColorTemperature.neutral,
    gradientColors: [Colors.grey],
  );

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _currentTheme = widget.theme;
    _updateAnimations();
  }

  void _initializeControllers() {
    _primaryController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _accentController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _gradientController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
  }

  void _updateAnimations() {
    final previousTheme = _previousTheme ?? _currentTheme;
    
    _primaryAnimation = ColorTween(
      begin: previousTheme.primary,
      end: _currentTheme.primary,
    ).animate(CurvedAnimation(
      parent: _primaryController,
      curve: widget.curve,
    ));
    
    _accentAnimation = ColorTween(
      begin: previousTheme.accent,
      end: _currentTheme.accent,
    ).animate(CurvedAnimation(
      parent: _accentController,
      curve: widget.curve,
    ));
    
    // Create animations for each gradient color
    _gradientAnimations = List.generate(
      _currentTheme.gradientColors.length,
      (index) {
        final beginColor = index < previousTheme.gradientColors.length
            ? previousTheme.gradientColors[index]
            : previousTheme.gradientColors.last;
        
        return ColorTween(
          begin: beginColor,
          end: _currentTheme.gradientColors[index],
        ).animate(CurvedAnimation(
          parent: _gradientController,
          curve: widget.curve,
        ));
      },
    );
  }

  @override
  void didUpdateWidget(AnimatedDrinkTheme oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.theme != oldWidget.theme) {
      _previousTheme = _currentTheme;
      _currentTheme = widget.theme;
      
      if (widget.enableHaptics) {
        HapticFeedback.lightImpact();
      }
      
      _updateAnimations();
      _startStaggeredAnimations();
    }
  }

  void _startStaggeredAnimations() {
    // Reset all controllers
    _primaryController.reset();
    _accentController.reset();
    _gradientController.reset();
    
    // Start primary animation immediately
    _primaryController.forward();
    
    // Start accent animation with delay
    Future.delayed(widget.staggerDelay, () {
      if (mounted) {
        _accentController.forward();
      }
    });
    
    // Start gradient animation with double delay
    Future.delayed(widget.staggerDelay * 2, () {
      if (mounted) {
        _gradientController.forward();
      }
    });
  }

  @override
  void dispose() {
    _primaryController.dispose();
    _accentController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _primaryController,
        _accentController,
        _gradientController,
      ]),
      builder: (context, child) {
        final animatedGradientColors = _gradientAnimations
            .map((animation) => animation.value ?? Colors.grey)
            .toList();
        
        final animatedTheme = DrinkThemeData(
          primary: _primaryAnimation.value ?? _currentTheme.primary,
          accent: _accentAnimation.value ?? _currentTheme.accent,
          temperature: _currentTheme.temperature,
          gradientColors: animatedGradientColors,
          shadowColor: _currentTheme.shadowColor,
          highlightColor: _currentTheme.highlightColor,
        );
        
        return DrinkThemeProvider(
          theme: animatedTheme,
          child: widget.child,
        );
      },
    );
  }
}

/// Widget that provides staggered color transitions for individual elements
class StaggeredColorTransition extends StatelessWidget {
  const StaggeredColorTransition({
    Key? key,
    required this.child,
    required this.color,
    this.duration = const Duration(milliseconds: 600),
    this.delay = Duration.zero,
    this.curve = Curves.easeInOutCubic,
  }) : super(key: key);

  final Widget child;
  final Color color;
  final Duration duration;
  final Duration delay;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: color),
      duration: duration,
      curve: curve,
      builder: (context, animatedColor, child) {
        return AnimatedContainer(
          duration: delay,
          child: this.child,
        );
      },
    ).animate(
      delay: delay,
      effects: [
        FadeEffect(duration: duration, curve: curve),
        ScaleEffect(
          duration: duration,
          curve: curve,
          begin: const Offset(0.95, 0.95),
          end: const Offset(1.0, 1.0),
        ),
      ],
    );
  }
}

/// Container that animates its colors based on drink theme
class AnimatedThemeContainer extends StatelessWidget {
  const AnimatedThemeContainer({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.useGradient = false,
    this.borderRadius,
    this.padding,
    this.margin,
    this.constraints,
    this.alignment,
  }) : super(key: key);

  final Widget child;
  final Duration duration;
  final bool useGradient;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxConstraints? constraints;
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) {
    final theme = DrinkThemeProvider.of(context);
    
    return AnimatedContainer(
      duration: duration,
      padding: padding,
      margin: margin,
      constraints: constraints,
      alignment: alignment,
      decoration: BoxDecoration(
        color: useGradient ? null : theme.primary,
        gradient: useGradient ? LinearGradient(
          colors: theme.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ) : null,
        borderRadius: borderRadius,
        boxShadow: theme.shadowColor != null ? [
          BoxShadow(
            color: theme.shadowColor!.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: child,
    );
  }
}

/// Text widget that animates its color based on drink theme
class AnimatedThemeText extends StatelessWidget {
  const AnimatedThemeText(
    this.text, {
    Key? key,
    this.style,
    this.useAccentColor = false,
    this.duration = const Duration(milliseconds: 600),
    this.textAlign,
    this.overflow,
    this.maxLines,
  }) : super(key: key);

  final String text;
  final TextStyle? style;
  final bool useAccentColor;
  final Duration duration;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final theme = DrinkThemeProvider.of(context);
    final color = useAccentColor ? theme.accent : theme.primary;
    
    return AnimatedDefaultTextStyle(
      duration: duration,
      style: (style ?? const TextStyle()).copyWith(color: color),
      child: Text(
        text,
        textAlign: textAlign,
        overflow: overflow,
        maxLines: maxLines,
      ),
    );
  }
}

/// Icon that animates its color based on drink theme
class AnimatedThemeIcon extends StatelessWidget {
  const AnimatedThemeIcon(
    this.icon, {
    Key? key,
    this.size,
    this.useAccentColor = false,
    this.duration = const Duration(milliseconds: 600),
  }) : super(key: key);

  final IconData icon;
  final double? size;
  final bool useAccentColor;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final theme = DrinkThemeProvider.of(context);
    final color = useAccentColor ? theme.accent : theme.primary;
    
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: color),
      duration: duration,
      builder: (context, animatedColor, child) {
        return Icon(
          icon,
          color: animatedColor,
          size: size,
        );
      },
    );
  }
}

/// Orchestrates complex theme transition sequences
class ThemeTransitionOrchestrator {
  static void performDrinkThemeTransition({
    required String newDrinkName,
    required VoidCallback onComplete,
    bool enableHaptics = true,
    Duration totalDuration = const Duration(milliseconds: 1200),
  }) {
    if (enableHaptics) {
      // Light haptic feedback at the start
      HapticFeedback.lightImpact();
    }
    
    // Medium haptic at 50% completion
    Future.delayed(totalDuration * 0.5, () {
      if (enableHaptics) {
        HapticFeedback.mediumImpact();
      }
    });
    
    // Light haptic at completion
    Future.delayed(totalDuration, () {
      if (enableHaptics) {
        HapticFeedback.lightImpact();
      }
      onComplete();
    });
  }
}

/// Mixin for widgets that need custom theme transition animations
mixin ThemeTransitionMixin<T extends StatefulWidget> on State<T>, TickerProviderStateMixin {
  
  late AnimationController themeTransitionController;
  late Animation<double> themeTransitionAnimation;
  
  @override
  void initState() {
    super.initState();
    themeTransitionController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    themeTransitionAnimation = CurvedAnimation(
      parent: themeTransitionController,
      curve: Curves.easeInOutCubic,
    );
  }
  
  @override
  void dispose() {
    themeTransitionController.dispose();
    super.dispose();
  }
  
  /// Starts the theme transition animation
  void startThemeTransition() {
    themeTransitionController.forward(from: 0.0);
  }
  
  /// Reverses the theme transition animation
  void reverseThemeTransition() {
    themeTransitionController.reverse();
  }
}

/// Widget that creates a ripple effect when theme changes
class ThemeChangeRipple extends StatefulWidget {
  const ThemeChangeRipple({
    Key? key,
    required this.child,
    this.rippleColor,
    this.duration = const Duration(milliseconds: 1000),
  }) : super(key: key);

  final Widget child;
  final Color? rippleColor;
  final Duration duration;

  @override
  State<ThemeChangeRipple> createState() => _ThemeChangeRippleState();
}

class _ThemeChangeRippleState extends State<ThemeChangeRipple>
    with SingleTickerProviderStateMixin, DrinkThemeAware {
  
  late AnimationController _rippleController;
  late Animation<double> _rippleAnimation;
  
  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOutQuart,
    ));
  }
  
  @override
  void onDrinkThemeChanged(DrinkThemeData? oldTheme, DrinkThemeData newTheme) {
    super.onDrinkThemeChanged(oldTheme, newTheme);
    if (oldTheme != null) {
      _rippleController.forward(from: 0.0);
    }
  }
  
  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = DrinkThemeProvider.of(context);
    
    return AnimatedBuilder(
      animation: _rippleAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: _RipplePainter(
            progress: _rippleAnimation.value,
            color: widget.rippleColor ?? theme.accent.withOpacity(0.3),
          ),
          child: widget.child,
        );
      },
    );
  }
}

class _RipplePainter extends CustomPainter {
  final double progress;
  final Color color;
  
  _RipplePainter({required this.progress, required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;
    
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = (size.width + size.height) / 2;
    final radius = maxRadius * progress;
    
    final paint = Paint()
      ..color = color.withOpacity((1.0 - progress) * color.opacity)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius, paint);
  }
  
  @override
  bool shouldRepaint(_RipplePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}