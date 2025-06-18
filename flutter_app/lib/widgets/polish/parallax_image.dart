import 'package:flutter/material.dart';
import 'dart:math';

/// Image widget with parallax scrolling effect for depth and polish
/// Creates the illusion of depth by moving images at different rates
class ParallaxImage extends StatefulWidget {
  final String? imagePath;
  final ImageProvider? imageProvider;
  final double parallaxFactor; // 0.0 = no parallax, 1.0 = full parallax
  final ScrollController? scrollController;
  final double height;
  final double width;
  final BoxFit fit;
  final bool enableBoundaryClamp;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool enableCache;
  final AlignmentGeometry alignment;
  final ColorFilter? colorFilter;
  final BlendMode? blendMode;
  final bool enablePerformanceMode;
  
  const ParallaxImage({
    super.key,
    this.imagePath,
    this.imageProvider,
    this.parallaxFactor = 0.5,
    this.scrollController,
    this.height = 200.0,
    this.width = double.infinity,
    this.fit = BoxFit.cover,
    this.enableBoundaryClamp = true,
    this.placeholder,
    this.errorWidget,
    this.enableCache = true,
    this.alignment = Alignment.center,
    this.colorFilter,
    this.blendMode,
    this.enablePerformanceMode = false,
  }) : assert(imagePath != null || imageProvider != null,
              'Either imagePath or imageProvider must be provided');

  @override
  State<ParallaxImage> createState() => _ParallaxImageState();
}

class _ParallaxImageState extends State<ParallaxImage> {
  ScrollController? _scrollController;
  double _parallaxOffset = 0.0;
  bool _isDisposed = false;
  
  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupScrollListener();
    });
  }
  
  void _setupScrollListener() {
    _scrollController = widget.scrollController ?? 
                      PrimaryScrollController.maybeOf(context);
    
    if (_scrollController != null) {
      _scrollController!.addListener(_updateParallax);
      _updateParallax();
    }
  }
  
  @override
  void didUpdateWidget(ParallaxImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.scrollController != widget.scrollController) {
      _scrollController?.removeListener(_updateParallax);
      _setupScrollListener();
    }
  }
  
  @override
  void dispose() {
    _isDisposed = true;
    _scrollController?.removeListener(_updateParallax);
    super.dispose();
  }
  
  void _updateParallax() {
    if (_isDisposed || !mounted) return;
    
    final renderObject = context.findRenderObject();
    if (renderObject == null || !renderObject.attached) return;
    
    final renderBox = renderObject as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    
    final screenHeight = MediaQuery.of(context).size.height;
    final elementTop = position.dy;
    final elementBottom = position.dy + size.height;
    
    // Calculate visibility and position relative to screen
    final screenTop = 0.0;
    final screenBottom = screenHeight;
    
    // Only calculate parallax if element is visible
    if (elementBottom > screenTop && elementTop < screenBottom) {
      // Calculate how much the element has moved through the viewport
      final elementCenter = elementTop + size.height / 2;
      final screenCenter = screenHeight / 2;
      
      // Distance from screen center (-1.0 to 1.0)
      final relativePosition = (elementCenter - screenCenter) / (screenHeight / 2);
      
      // Calculate parallax offset
      double newOffset = relativePosition * widget.parallaxFactor * 50;
      
      // Apply boundary clamping
      if (widget.enableBoundaryClamp) {
        final maxOffset = size.height * 0.3; // Limit offset to 30% of image height
        newOffset = newOffset.clamp(-maxOffset, maxOffset);
      }
      
      if ((newOffset - _parallaxOffset).abs() > 0.5) {
        setState(() {
          _parallaxOffset = newOffset;
        });
      }
    }
  }
  
  ImageProvider _getImageProvider() {
    if (widget.imageProvider != null) {
      return widget.imageProvider!;
    }
    
    if (widget.imagePath!.startsWith('http')) {
      return NetworkImage(widget.imagePath!);
    } else {
      return AssetImage(widget.imagePath!);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ClipRect(
        child: OverflowBox(
          minHeight: widget.height + 100, // Extra height for parallax movement
          maxHeight: widget.height + 100,
          child: Transform.translate(
            offset: Offset(0, _parallaxOffset),
            child: widget.enablePerformanceMode
                ? _buildPerformanceImage()
                : _buildStandardImage(),
          ),
        ),
      ),
    );
  }
  
  Widget _buildStandardImage() {
    return Image(
      image: _getImageProvider(),
      fit: widget.fit,
      alignment: widget.alignment,
      colorFilter: widget.colorFilter,
      width: widget.width,
      height: widget.height + 100,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          child: child,
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        
        return widget.placeholder ??
            Container(
              color: Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFB8860B),
                ),
              ),
            );
      },
      errorBuilder: (context, error, stackTrace) {
        return widget.errorWidget ??
            Container(
              color: Colors.grey[300],
              child: const Center(
                child: Icon(
                  Icons.error_outline,
                  color: Colors.grey,
                  size: 32,
                ),
              ),
            );
      },
    );
  }
  
  Widget _buildPerformanceImage() {
    // Simplified version for better performance
    return Container(
      width: widget.width,
      height: widget.height + 100,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: _getImageProvider(),
          fit: widget.fit,
          alignment: widget.alignment,
          colorFilter: widget.colorFilter,
        ),
      ),
    );
  }
}

/// Multi-layer parallax container for complex depth effects
class LayeredParallaxContainer extends StatefulWidget {
  final List<ParallaxLayer> layers;
  final ScrollController? scrollController;
  final double height;
  final double width;
  final bool enablePerformanceMode;
  
  const LayeredParallaxContainer({
    super.key,
    required this.layers,
    this.scrollController,
    this.height = 300.0,
    this.width = double.infinity,
    this.enablePerformanceMode = false,
  });

  @override
  State<LayeredParallaxContainer> createState() => _LayeredParallaxContainerState();
}

class _LayeredParallaxContainerState extends State<LayeredParallaxContainer> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: widget.layers.map((layer) {
          return Positioned.fill(
            child: ParallaxImage(
              imageProvider: layer.imageProvider,
              imagePath: layer.imagePath,
              parallaxFactor: layer.parallaxFactor,
              scrollController: widget.scrollController,
              height: widget.height,
              width: widget.width,
              fit: layer.fit,
              alignment: layer.alignment,
              colorFilter: layer.colorFilter,
              enablePerformanceMode: widget.enablePerformanceMode,
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Data model for parallax layers
class ParallaxLayer {
  final String? imagePath;
  final ImageProvider? imageProvider;
  final double parallaxFactor;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final ColorFilter? colorFilter;
  final double opacity;
  
  const ParallaxLayer({
    this.imagePath,
    this.imageProvider,
    required this.parallaxFactor,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.colorFilter,
    this.opacity = 1.0,
  }) : assert(imagePath != null || imageProvider != null);
}

/// Parallax container specifically designed for ingredient images
class IngredientParallax extends StatelessWidget {
  final String imagePath;
  final String ingredientName;
  final ScrollController? scrollController;
  final double size;
  final VoidCallback? onTap;
  
  const IngredientParallax({
    super.key,
    required this.imagePath,
    required this.ingredientName,
    this.scrollController,
    this.size = 120.0,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Background with parallax
              ParallaxImage(
                imagePath: imagePath,
                parallaxFactor: 0.3,
                scrollController: scrollController,
                height: size,
                width: size,
                fit: BoxFit.cover,
              ),
              
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.4),
                    ],
                  ),
                ),
              ),
              
              // Ingredient name
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Text(
                  ingredientName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hero parallax banner for recipe headers
class RecipeHeroParallax extends StatelessWidget {
  final String backgroundImage;
  final String title;
  final String? subtitle;
  final ScrollController? scrollController;
  final double height;
  final List<Widget>? actions;
  
  const RecipeHeroParallax({
    super.key,
    required this.backgroundImage,
    required this.title,
    this.subtitle,
    this.scrollController,
    this.height = 250.0,
    this.actions,
  });
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          // Parallax background
          ParallaxImage(
            imagePath: backgroundImage,
            parallaxFactor: 0.7,
            scrollController: scrollController,
            height: height,
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
          
          // Content overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),
          
          // Text content
          Positioned(
            bottom: 32,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      const Shadow(
                        color: Colors.black,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      shadows: [
                        const Shadow(
                          color: Colors.black,
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Actions
          if (actions != null)
            Positioned(
              top: 40,
              right: 16,
              child: Row(
                children: actions!,
              ),
            ),
        ],
      ),
    );
  }
}

/// Utility class for parallax presets
class ParallaxPresets {
  /// Gentle parallax for subtle depth
  static const double gentle = 0.2;
  
  /// Standard parallax for normal depth
  static const double standard = 0.5;
  
  /// Strong parallax for dramatic depth
  static const double strong = 0.8;
  
  /// Extreme parallax for maximum depth
  static const double extreme = 1.0;
  
  /// Create layers for ingredient showcase
  static List<ParallaxLayer> ingredientShowcase({
    required String backgroundImage,
    required String foregroundImage,
  }) {
    return [
      ParallaxLayer(
        imagePath: backgroundImage,
        parallaxFactor: gentle,
        colorFilter: ColorFilter.mode(
          Colors.black.withOpacity(0.2),
          BlendMode.darken,
        ),
      ),
      ParallaxLayer(
        imagePath: foregroundImage,
        parallaxFactor: standard,
        alignment: Alignment.bottomCenter,
      ),
    ];
  }
  
  /// Create layers for cocktail hero section
  static List<ParallaxLayer> cocktailHero({
    required String glassImage,
    String? garnishImage,
  }) {
    final layers = <ParallaxLayer>[
      ParallaxLayer(
        imagePath: glassImage,
        parallaxFactor: standard,
      ),
    ];
    
    if (garnishImage != null) {
      layers.add(
        ParallaxLayer(
          imagePath: garnishImage,
          parallaxFactor: strong,
          alignment: Alignment.topRight,
        ),
      );
    }
    
    return layers;
  }
}

/// Extension methods for easy parallax integration
extension ParallaxExtensions on Widget {
  /// Wrap widget with parallax scrolling
  Widget withParallax({
    ScrollController? scrollController,
    double parallaxFactor = 0.5,
    double height = 200.0,
  }) {
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          ParallaxImage(
            imageProvider: const AssetImage('assets/images/placeholder.jpg'),
            parallaxFactor: parallaxFactor,
            scrollController: scrollController,
            height: height,
          ),
          this,
        ],
      ),
    );
  }
}

/// Performance monitoring for parallax effects
class ParallaxPerformanceMonitor {
  static bool _isPerformanceModeEnabled = false;
  static int _frameDropCount = 0;
  static DateTime? _lastFrameTime;
  
  /// Enable performance monitoring
  static void enable() {
    _isPerformanceModeEnabled = true;
  }
  
  /// Check if performance mode should be activated
  static bool shouldUsePerformanceMode() {
    return _isPerformanceModeEnabled && _frameDropCount > 5;
  }
  
  /// Record frame timing
  static void recordFrame() {
    final now = DateTime.now();
    if (_lastFrameTime != null) {
      final timeDiff = now.difference(_lastFrameTime!).inMilliseconds;
      if (timeDiff > 32) { // More than ~30fps
        _frameDropCount++;
      } else if (_frameDropCount > 0) {
        _frameDropCount--;
      }
    }
    _lastFrameTime = now;
  }
  
  /// Reset performance counters
  static void reset() {
    _frameDropCount = 0;
    _lastFrameTime = null;
  }
}