import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../theme/ios_theme.dart';

/// Custom painter for martini glass shape
class MartiniGlassPainter extends CustomPainter {
  final Color color;
  
  MartiniGlassPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final double centerX = size.width / 2;
    final double rimWidth = size.width * 0.85;
    final double bowlHeight = size.height * 0.55;
    
    // Draw the martini glass bowl with curved sides for more realistic look
    final path = Path();
    
    // Start from left rim
    path.moveTo(centerX - rimWidth / 2, 0);
    // Top rim line
    path.lineTo(centerX + rimWidth / 2, 0);
    // Curved right side to bottom point
    path.quadraticBezierTo(
      centerX + rimWidth / 4, bowlHeight * 0.3,
      centerX, bowlHeight
    );
    // Curved left side back to start
    path.quadraticBezierTo(
      centerX - rimWidth / 4, bowlHeight * 0.3,
      centerX - rimWidth / 2, 0
    );
    
    canvas.drawPath(path, paint);
    
    // Elegant thin stem
    final stemWidth = size.width * 0.04;
    final stemHeight = size.height * 0.3;
    final stemTop = bowlHeight;
    
    canvas.drawRect(
      Rect.fromLTWH(
        centerX - stemWidth / 2, 
        stemTop, 
        stemWidth, 
        stemHeight
      ),
      paint,
    );
    
    // Round base with proper proportions
    final baseHeight = size.height * 0.12;
    final baseWidth = size.width * 0.45;
    final baseTop = stemTop + stemHeight;
    
    canvas.drawOval(
      Rect.fromLTWH(
        centerX - baseWidth / 2,
        baseTop,
        baseWidth,
        baseHeight,
      ),
      paint,
    );
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// Custom painter for cocktail shaker
class ShakerPainter extends CustomPainter {
  final Color color;
  
  ShakerPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final centerX = size.width / 2;
    
    // Shaker strainer/cap (more realistic proportions)
    final capRect = Rect.fromLTWH(
      centerX - size.width * 0.25,
      0,
      size.width * 0.5,
      size.height * 0.12,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(capRect, const Radius.circular(6)),
      paint,
    );
    
    // Shaker body with smooth curves (Boston shaker style)
    final bodyPath = Path();
    final topWidth = size.width * 0.65;
    final midWidth = size.width * 0.75;
    final bottomWidth = size.width * 0.7;
    final bodyTop = size.height * 0.12;
    final bodyHeight = size.height * 0.88;
    final midPoint = bodyTop + bodyHeight * 0.3;
    
    // Create curved shaker body
    bodyPath.moveTo(centerX - topWidth / 2, bodyTop);
    bodyPath.lineTo(centerX + topWidth / 2, bodyTop);
    
    // Curve out to mid section
    bodyPath.quadraticBezierTo(
      centerX + midWidth / 2, midPoint,
      centerX + bottomWidth / 2, bodyTop + bodyHeight
    );
    
    // Bottom curve
    bodyPath.quadraticBezierTo(
      centerX, bodyTop + bodyHeight + 5,
      centerX - bottomWidth / 2, bodyTop + bodyHeight
    );
    
    // Curve back up left side
    bodyPath.quadraticBezierTo(
      centerX - midWidth / 2, midPoint,
      centerX - topWidth / 2, bodyTop
    );
    
    canvas.drawPath(bodyPath, paint);
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// Base shimmer widget that provides consistent styling
class MixologistShimmer extends StatelessWidget {
  final Widget child;
  final bool enabled;
  
  const MixologistShimmer({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    
    return Shimmer.fromColors(
      baseColor: iOSTheme.adaptiveColor(
        context,
        const Color(0xFFE0E0E0),
        const Color(0xFF2C2C2E),
      ),
      highlightColor: iOSTheme.adaptiveColor(
        context,
        const Color(0xFFF5F5F5),
        const Color(0xFF3C3C3E),
      ),
      period: const Duration(milliseconds: 1500),
      child: child,
    );
  }
}

/// Shimmer placeholder for recipe cards
class RecipeCardShimmer extends StatelessWidget {
  const RecipeCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return MixologistShimmer(
      child: Container(
        height: 280,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey5,
          borderRadius: BorderRadius.circular(iOSTheme.largeRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey4,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(iOSTheme.largeRadius),
                  topRight: Radius.circular(iOSTheme.largeRadius),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title placeholder
                  Container(
                    height: 24,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey4,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Description placeholder
                  Container(
                    height: 16,
                    width: 200,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey4,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 16,
                    width: 150,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey4,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer placeholder for inventory items that looks like bottles
class InventoryItemShimmer extends StatelessWidget {
  const InventoryItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return MixologistShimmer(
      child: Container(
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey5,
          borderRadius: BorderRadius.circular(iOSTheme.smallRadius),
        ),
        child: Row(
          children: [
            // Bottle shape placeholder
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Bottle neck
                Container(
                  width: 12,
                  height: 20,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey4,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                // Bottle body
                Container(
                  width: 40,
                  height: 50,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey4,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Brand name
                  Container(
                    height: 20,
                    width: 120,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey4,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Product name
                  Container(
                    height: 16,
                    width: 100,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey4,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Category/volume
                  Container(
                    height: 14,
                    width: 80,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey4,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            // Quantity indicator
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: CupertinoColors.systemGrey4,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 20,
                  height: 12,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey4,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer placeholder for text lines
class TextLineShimmer extends StatelessWidget {
  final double width;
  final double height;
  
  const TextLineShimmer({
    super.key,
    this.width = double.infinity,
    this.height = 16,
  });

  @override
  Widget build(BuildContext context) {
    return MixologistShimmer(
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey4,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

/// Shimmer placeholder for circular avatars/images
class CircleShimmer extends StatelessWidget {
  final double size;
  
  const CircleShimmer({
    super.key,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    return MixologistShimmer(
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: CupertinoColors.systemGrey4,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Full-screen shimmer loading for recipe generation that looks like bartender making drinks
class RecipeGenerationShimmer extends StatelessWidget {
  const RecipeGenerationShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: iOSTheme.adaptiveColor(
        context,
        CupertinoColors.systemBackground,
        iOSTheme.darkBackground,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Bartender workspace title
              const Text(
                'Crafting your perfect drink...',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                  color: CupertinoColors.label,
                ),
              ),
              const SizedBox(height: 40),
              
              // Cocktail mixing scene
              _buildMixingStation(context),
              
              const SizedBox(height: 40),
              
              // Ingredients being prepared
              _buildIngredientsPrep(context),
              
              const Spacer(),
              
              // Bartender tip card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: iOSTheme.adaptiveColor(
                    context,
                    CupertinoColors.systemGrey6,
                    iOSTheme.darkSecondaryBackground,
                  ),
                  borderRadius: BorderRadius.circular(iOSTheme.largeRadius),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        MixologistShimmer(
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: CupertinoColors.systemGrey4,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: TextLineShimmer(height: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const TextLineShimmer(height: 16),
                    const SizedBox(height: 8),
                    const TextLineShimmer(width: 250, height: 16),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMixingStation(BuildContext context) {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: iOSTheme.adaptiveColor(
          context,
          CupertinoColors.systemGrey6,
          iOSTheme.darkSecondaryBackground,
        ),
        borderRadius: BorderRadius.circular(iOSTheme.largeRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Elegant martini glass using CustomPainter
          Expanded(
            flex: 2,
            child: MixologistShimmer(
              child: CustomPaint(
                size: const Size(60, 140),
                painter: MartiniGlassPainter(color: CupertinoColors.systemGrey4),
              ),
            ),
          ),
          
          // Professional cocktail shaker using CustomPainter
          Expanded(
            flex: 2,
            child: MixologistShimmer(
              child: CustomPaint(
                size: const Size(50, 130),
                painter: ShakerPainter(color: CupertinoColors.systemGrey4),
              ),
            ),
          ),
          
          // Spirit bottles (simplified to fit)
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Tall spirit bottle (whiskey/gin style)
                MixologistShimmer(
                  child: Column(
                    children: [
                      // Bottle cap/cork
                      Container(
                        width: 10,
                        height: 5,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey4,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      // Bottle neck (tapered)
                      Container(
                        width: 8,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: CupertinoColors.systemGrey4,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(2),
                            topRight: Radius.circular(2),
                          ),
                        ),
                      ),
                      // Bottle shoulder (wider transition)
                      Container(
                        width: 16,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: CupertinoColors.systemGrey4,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                      ),
                      // Bottle body (classic spirit bottle shape)
                      Container(
                        width: 16,
                        height: 42,
                        decoration: const BoxDecoration(
                          color: CupertinoColors.systemGrey4,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(3),
                            bottomRight: Radius.circular(3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                
                // Liqueur bottle (rounder, shorter)
                MixologistShimmer(
                  child: Column(
                    children: [
                      // Cork/cap (smaller)
                      Container(
                        width: 8,
                        height: 4,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey4,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      // Short neck
                      Container(
                        width: 6,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: CupertinoColors.systemGrey4,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(1),
                            topRight: Radius.circular(1),
                          ),
                        ),
                      ),
                      // Round body (liqueur style - wider and rounder)
                      Container(
                        width: 14,
                        height: 22,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey4,
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Bar tools (simplified)
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Jigger
                MixologistShimmer(
                  child: Container(
                    width: 14,
                    height: 25,
                    decoration: const BoxDecoration(
                      color: CupertinoColors.systemGrey4,
                      borderRadius: BorderRadius.all(Radius.circular(7)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Bar spoon
                MixologistShimmer(
                  child: Container(
                    width: 2,
                    height: 60,
                    color: CupertinoColors.systemGrey4,
                  ),
                ),
                const SizedBox(height: 4),
                // Spoon bowl
                MixologistShimmer(
                  child: Container(
                    width: 6,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: CupertinoColors.systemGrey4,
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsPrep(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: iOSTheme.adaptiveColor(
          context,
          CupertinoColors.systemGrey6,
          iOSTheme.darkSecondaryBackground,
        ),
        borderRadius: BorderRadius.circular(iOSTheme.largeRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ingredients title
          const TextLineShimmer(width: 120, height: 18),
          const SizedBox(height: 12),
          
          // Ingredient items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Lime wedge
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MixologistShimmer(
                      child: Container(
                        width: 24,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: CupertinoColors.systemGrey4,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const TextLineShimmer(width: 30, height: 10),
                  ],
                ),
              ),
              
              // Ice cubes
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MixologistShimmer(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemGrey4,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        MixologistShimmer(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemGrey4,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const TextLineShimmer(width: 28, height: 10),
                  ],
                ),
              ),
              
              // Garnish
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MixologistShimmer(
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: CupertinoColors.systemGrey4,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const TextLineShimmer(width: 32, height: 10),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}