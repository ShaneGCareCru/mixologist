import 'package:flutter/material.dart';
import 'dart:math';

/// Responsive layout manager that creates a three-tier visual hierarchy
/// optimizing screen real estate and user focus for different screen sizes
class TieredLayoutBuilder extends StatefulWidget {
  final Widget heroZone;
  final Widget actionZone;
  final Widget discoveryZone;
  final double heroRatio;
  final double actionRatio;
  final double detailRatio;
  final bool enableFocusMode;
  final VoidCallback? onFocusModeChanged;
  final EdgeInsets padding;
  final Duration transitionDuration;
  
  const TieredLayoutBuilder({
    super.key,
    required this.heroZone,
    required this.actionZone,
    required this.discoveryZone,
    this.heroRatio = 0.6,
    this.actionRatio = 0.25,
    this.detailRatio = 0.15,
    this.enableFocusMode = true,
    this.onFocusModeChanged,
    this.padding = const EdgeInsets.all(16),
    this.transitionDuration = const Duration(milliseconds: 300),
  });

  @override
  State<TieredLayoutBuilder> createState() => _TieredLayoutBuilderState();
}

class _TieredLayoutBuilderState extends State<TieredLayoutBuilder>
    with TickerProviderStateMixin {
  late AnimationController _transitionController;
  late Animation<double> _heroScaleAnimation;
  late Animation<double> _actionScaleAnimation;
  late Animation<double> _discoveryOpacityAnimation;
  
  bool _isFocusMode = false;
  late TieredLayoutConfiguration _config;
  
  @override
  void initState() {
    super.initState();
    
    _transitionController = AnimationController(
      duration: widget.transitionDuration,
      vsync: this,
    );
    
    _heroScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2, // Expand hero zone in focus mode
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeInOut,
    ));
    
    _actionScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1, // Slightly expand action zone
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeInOut,
    ));
    
    _discoveryOpacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0, // Hide discovery zone in focus mode
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeOut,
    ));
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateConfiguration();
  }
  
  void _updateConfiguration() {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final isTablet = size.shortestSide >= 600;
    
    _config = TieredLayoutConfiguration.fromContext(
      context,
      heroRatio: widget.heroRatio,
      actionRatio: widget.actionRatio,
      detailRatio: widget.detailRatio,
      isTablet: isTablet,
      orientation: orientation,
    );
  }
  
  void toggleFocusMode() {
    if (!widget.enableFocusMode) return;
    
    setState(() {
      _isFocusMode = !_isFocusMode;
    });
    
    if (_isFocusMode) {
      _transitionController.forward();
    } else {
      _transitionController.reverse();
    }
    
    widget.onFocusModeChanged?.call();
  }
  
  @override
  void dispose() {
    _transitionController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _updateConfiguration();
        
        if (_config.orientation == Orientation.landscape && !_config.isTablet) {
          return _buildLandscapeLayout(constraints);
        } else {
          return _buildPortraitLayout(constraints);
        }
      },
    );
  }
  
  Widget _buildPortraitLayout(BoxConstraints constraints) {
    final availableHeight = constraints.maxHeight - widget.padding.vertical;
    
    return Padding(
      padding: widget.padding,
      child: AnimatedBuilder(
        animation: _transitionController,
        builder: (context, child) {
          final heroHeight = _isFocusMode 
              ? availableHeight * (_config.heroRatio + _config.detailRatio * 0.5)
              : availableHeight * _config.heroRatio;
          
          final actionHeight = _isFocusMode
              ? availableHeight * (_config.actionRatio + _config.detailRatio * 0.5)
              : availableHeight * _config.actionRatio;
          
          final discoveryHeight = _isFocusMode 
              ? 0.0 
              : availableHeight * _config.detailRatio;
          
          return Column(
            children: [
              // Tier 1: Hero Zone (60% screen)
              AnimatedContainer(
                duration: widget.transitionDuration,
                height: heroHeight,
                curve: Curves.easeInOut,
                child: Transform.scale(
                  scale: _heroScaleAnimation.value,
                  child: _TierWrapper(
                    tier: TierType.hero,
                    child: widget.heroZone,
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Tier 2: Action Zone (25% screen)
              AnimatedContainer(
                duration: widget.transitionDuration,
                height: actionHeight,
                curve: Curves.easeInOut,
                child: Transform.scale(
                  scale: _actionScaleAnimation.value,
                  child: _TierWrapper(
                    tier: TierType.action,
                    child: widget.actionZone,
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Tier 3: Discovery Zone (15% screen)
              AnimatedContainer(
                duration: widget.transitionDuration,
                height: discoveryHeight,
                curve: Curves.easeInOut,
                child: Opacity(
                  opacity: _discoveryOpacityAnimation.value,
                  child: _TierWrapper(
                    tier: TierType.discovery,
                    child: widget.discoveryZone,
                  ),
                ),
              ),
              
              // Focus mode toggle
              if (widget.enableFocusMode) ...[
                const SizedBox(height: 16),
                _buildFocusToggle(),
              ],
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildLandscapeLayout(BoxConstraints constraints) {
    return Padding(
      padding: widget.padding,
      child: AnimatedBuilder(
        animation: _transitionController,
        builder: (context, child) {
          return Row(
            children: [
              // Hero and Action zones side by side
              Expanded(
                flex: 7,
                child: Column(
                  children: [
                    // Hero Zone
                    Expanded(
                      flex: _isFocusMode ? 8 : 6,
                      child: Transform.scale(
                        scale: _heroScaleAnimation.value,
                        child: _TierWrapper(
                          tier: TierType.hero,
                          child: widget.heroZone,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Action Zone
                    Expanded(
                      flex: _isFocusMode ? 4 : 3,
                      child: Transform.scale(
                        scale: _actionScaleAnimation.value,
                        child: _TierWrapper(
                          tier: TierType.action,
                          child: widget.actionZone,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Discovery Zone (sidebar)
              if (!_isFocusMode)
                Expanded(
                  flex: 3,
                  child: Opacity(
                    opacity: _discoveryOpacityAnimation.value,
                    child: _TierWrapper(
                      tier: TierType.discovery,
                      child: widget.discoveryZone,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildFocusToggle() {
    return GestureDetector(
      onTap: toggleFocusMode,
      child: AnimatedContainer(
        duration: widget.transitionDuration,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _isFocusMode 
              ? const Color(0xFFB8860B) // Amber
              : const Color(0xFF87A96B), // Sage
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isFocusMode ? Icons.visibility_off : Icons.center_focus_strong,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              _isFocusMode ? 'Exit Focus' : 'Focus Mode',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Configuration class for layout calculations
class TieredLayoutConfiguration {
  final double heroRatio;
  final double actionRatio;
  final double detailRatio;
  final bool isTablet;
  final Orientation orientation;
  final Size screenSize;
  
  const TieredLayoutConfiguration({
    required this.heroRatio,
    required this.actionRatio,
    required this.detailRatio,
    required this.isTablet,
    required this.orientation,
    required this.screenSize,
  });
  
  factory TieredLayoutConfiguration.fromContext(
    BuildContext context, {
    required double heroRatio,
    required double actionRatio,
    required double detailRatio,
    required bool isTablet,
    required Orientation orientation,
  }) {
    final size = MediaQuery.of(context).size;
    
    // Adjust ratios based on device type and orientation
    double adjustedHero = heroRatio;
    double adjustedAction = actionRatio;
    double adjustedDetail = detailRatio;
    
    if (isTablet) {
      // Tablets can show more content in discovery zone
      adjustedHero = 0.55;
      adjustedAction = 0.25;
      adjustedDetail = 0.20;
    }
    
    if (orientation == Orientation.landscape && !isTablet) {
      // Landscape phones need different ratios
      adjustedHero = 0.65;
      adjustedAction = 0.25;
      adjustedDetail = 0.10;
    }
    
    return TieredLayoutConfiguration(
      heroRatio: adjustedHero,
      actionRatio: adjustedAction,
      detailRatio: adjustedDetail,
      isTablet: isTablet,
      orientation: orientation,
      screenSize: size,
    );
  }
}

/// Wrapper widget for individual tiers with consistent styling
class _TierWrapper extends StatelessWidget {
  final TierType tier;
  final Widget child;
  
  const _TierWrapper({
    required this.tier,
    required this.child,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_getBorderRadius()),
        color: _getBackgroundColor().withOpacity(0.02),
        border: Border.all(
          color: _getBackgroundColor().withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_getBorderRadius()),
        child: child,
      ),
    );
  }
  
  double _getBorderRadius() {
    switch (tier) {
      case TierType.hero:
        return 16;
      case TierType.action:
        return 12;
      case TierType.discovery:
        return 8;
    }
  }
  
  Color _getBackgroundColor() {
    switch (tier) {
      case TierType.hero:
        return const Color(0xFFB8860B); // Amber
      case TierType.action:
        return const Color(0xFF87A96B); // Sage
      case TierType.discovery:
        return const Color(0xFF36454F); // Charcoal
    }
  }
}

/// Enum for tier types
enum TierType {
  hero,
  action,
  discovery,
}

/// Extension methods for easy layout building
extension TieredLayoutExtensions on Widget {
  /// Wrap widget in a tiered layout
  Widget withTieredLayout({
    required Widget actionZone,
    required Widget discoveryZone,
    double heroRatio = 0.6,
    double actionRatio = 0.25,
    double detailRatio = 0.15,
    bool enableFocusMode = true,
    VoidCallback? onFocusModeChanged,
  }) {
    return TieredLayoutBuilder(
      heroZone: this,
      actionZone: actionZone,
      discoveryZone: discoveryZone,
      heroRatio: heroRatio,
      actionRatio: actionRatio,
      detailRatio: detailRatio,
      enableFocusMode: enableFocusMode,
      onFocusModeChanged: onFocusModeChanged,
    );
  }
}

/// Responsive breakpoints utility
class ResponsiveBreakpoints {
  static const double mobile = 0;
  static const double tablet = 600;
  static const double desktop = 1200;
  
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < tablet;
  }
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tablet && width < desktop;
  }
  
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktop;
  }
  
  static T responsive<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) return desktop;
    if (isTablet(context) && tablet != null) return tablet;
    return mobile;
  }
}