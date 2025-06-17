import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'drink_theme_engine.dart';

/// InheritedWidget that provides drink theme data to the widget tree
class DrinkThemeProvider extends InheritedWidget {
  const DrinkThemeProvider({
    Key? key,
    required this.theme,
    required this.child,
    this.animationDuration = const Duration(milliseconds: 800),
  }) : super(key: key, child: child);

  final DrinkThemeData theme;
  final Duration animationDuration;

  @override
  final Widget child;

  /// Retrieves the current drink theme from the widget tree
  static DrinkThemeData of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<DrinkThemeProvider>();
    return provider?.theme ?? DrinkThemeEngine.getThemeForDrink('default');
  }

  /// Retrieves the current drink theme without creating a dependency
  static DrinkThemeData? maybeOf(BuildContext context) {
    final provider = context.getInheritedWidgetOfExactType<DrinkThemeProvider>();
    return provider?.theme;
  }

  @override
  bool updateShouldNotify(DrinkThemeProvider oldWidget) {
    return theme != oldWidget.theme;
  }
}

/// Animated wrapper for smooth theme transitions
class AnimatedDrinkTheme extends StatefulWidget {
  const AnimatedDrinkTheme({
    Key? key,
    required this.theme,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.curve = Curves.easeInOutCubic,
  }) : super(key: key);

  final DrinkThemeData theme;
  final Widget child;
  final Duration duration;
  final Curve curve;

  @override
  State<AnimatedDrinkTheme> createState() => _AnimatedDrinkThemeState();
}

class _AnimatedDrinkThemeState extends State<AnimatedDrinkTheme>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  DrinkThemeData? _previousTheme;
  DrinkThemeData? _currentTheme;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
    _currentTheme = widget.theme;
  }

  @override
  void didUpdateWidget(AnimatedDrinkTheme oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.theme != oldWidget.theme) {
      _previousTheme = _currentTheme;
      _currentTheme = widget.theme;
      
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final theme = _previousTheme != null
            ? DrinkThemeData.lerp(_previousTheme!, _currentTheme!, _animation.value)
            : _currentTheme!;

        return DrinkThemeProvider(
          theme: theme,
          child: widget.child,
        );
      },
    );
  }
}

/// Reactive drink theme provider that responds to drink name changes
class ReactiveDrinkThemeProvider extends StatefulWidget {
  const ReactiveDrinkThemeProvider({
    Key? key,
    required this.drinkName,
    required this.child,
    this.animationDuration = const Duration(milliseconds: 800),
    this.fallbackTheme,
  }) : super(key: key);

  final String drinkName;
  final Widget child;
  final Duration animationDuration;
  final DrinkThemeData? fallbackTheme;

  @override
  State<ReactiveDrinkThemeProvider> createState() => _ReactiveDrinkThemeProviderState();
}

class _ReactiveDrinkThemeProviderState extends State<ReactiveDrinkThemeProvider> {
  late DrinkThemeData _currentTheme;

  @override
  void initState() {
    super.initState();
    _updateTheme();
  }

  @override
  void didUpdateWidget(ReactiveDrinkThemeProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.drinkName != oldWidget.drinkName) {
      _updateTheme();
    }
  }

  void _updateTheme() {
    final newTheme = DrinkThemeEngine.getThemeForDrink(widget.drinkName);
    if (mounted) {
      setState(() {
        _currentTheme = newTheme;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedDrinkTheme(
      theme: _currentTheme,
      duration: widget.animationDuration,
      child: widget.child,
    );
  }
}

/// Extension to easily access drink theme colors in widgets
extension DrinkThemeExtension on BuildContext {
  /// Gets the current drink theme
  DrinkThemeData get drinkTheme => DrinkThemeProvider.of(this);
  
  /// Gets the primary color from the current drink theme
  Color get drinkPrimary => drinkTheme.primary;
  
  /// Gets the accent color from the current drink theme
  Color get drinkAccent => drinkTheme.accent;
  
  /// Gets the gradient colors from the current drink theme
  List<Color> get drinkGradient => drinkTheme.gradientColors;
  
  /// Gets the color temperature from the current drink theme
  ColorTemperature get drinkTemperature => drinkTheme.temperature;
  
  /// Creates a linear gradient from the current drink theme
  LinearGradient createDrinkGradient({
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return DrinkThemeEngine.createGradient(drinkTheme, begin: begin, end: end);
  }
  
  /// Creates a radial gradient from the current drink theme
  RadialGradient createDrinkRadialGradient({
    AlignmentGeometry center = Alignment.center,
    double radius = 0.8,
  }) {
    return DrinkThemeEngine.createRadialGradient(drinkTheme, center: center, radius: radius);
  }
}

/// Mixin for widgets that need to respond to drink theme changes
mixin DrinkThemeAware<T extends StatefulWidget> on State<T> {
  DrinkThemeData? _lastTheme;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final currentTheme = DrinkThemeProvider.of(context);
    if (_lastTheme != currentTheme) {
      onDrinkThemeChanged(_lastTheme, currentTheme);
      _lastTheme = currentTheme;
    }
  }
  
  /// Override this method to respond to drink theme changes
  void onDrinkThemeChanged(DrinkThemeData? oldTheme, DrinkThemeData newTheme) {}
}

/// Widget that interpolates between themes based on scroll position
class ScrollDrinkThemeProvider extends StatefulWidget {
  const ScrollDrinkThemeProvider({
    Key? key,
    required this.child,
    required this.themes,
    required this.scrollController,
    this.scrollExtent = 1000.0,
  }) : super(key: key);

  final Widget child;
  final List<DrinkThemeData> themes;
  final ScrollController scrollController;
  final double scrollExtent;

  @override
  State<ScrollDrinkThemeProvider> createState() => _ScrollDrinkThemeProviderState();
}

class _ScrollDrinkThemeProviderState extends State<ScrollDrinkThemeProvider> {
  late DrinkThemeData _currentTheme;

  @override
  void initState() {
    super.initState();
    _currentTheme = widget.themes.isNotEmpty ? widget.themes.first : DrinkThemeEngine.getThemeForDrink('default');
    widget.scrollController.addListener(_updateThemeFromScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_updateThemeFromScroll);
    super.dispose();
  }

  void _updateThemeFromScroll() {
    if (widget.themes.isEmpty) return;

    final scrollProgress = (widget.scrollController.offset / widget.scrollExtent).clamp(0.0, 1.0);
    final themeIndex = (scrollProgress * (widget.themes.length - 1)).floor();
    final themeProgress = (scrollProgress * (widget.themes.length - 1)) - themeIndex;

    final currentThemeIndex = themeIndex.clamp(0, widget.themes.length - 1);
    final nextThemeIndex = (themeIndex + 1).clamp(0, widget.themes.length - 1);

    final interpolatedTheme = DrinkThemeData.lerp(
      widget.themes[currentThemeIndex],
      widget.themes[nextThemeIndex],
      themeProgress,
    );

    if (mounted) {
      setState(() {
        _currentTheme = interpolatedTheme;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DrinkThemeProvider(
      theme: _currentTheme,
      child: widget.child,
    );
  }
}