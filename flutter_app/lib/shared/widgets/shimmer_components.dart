import 'package:flutter/cupertino.dart';
import 'package:shimmer/shimmer.dart';
import '../../theme/ios_theme.dart';

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
      height: 220,
      padding: const EdgeInsets.all(24),
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
          // Elegant martini glass
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Glass rim (wider, more elegant)
              MixologistShimmer(
                child: Container(
                  width: 70,
                  height: 6,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey4,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              // Glass bowl (V-shape for martini)
              MixologistShimmer(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Left side of V
                    Transform.rotate(
                      angle: 0.4,
                      child: Container(
                        width: 35,
                        height: 6,
                        color: CupertinoColors.systemGrey4,
                      ),
                    ),
                    // Right side of V
                    Transform.rotate(
                      angle: -0.4,
                      child: Container(
                        width: 35,
                        height: 6,
                        color: CupertinoColors.systemGrey4,
                      ),
                    ),
                    // Bowl fill area
                    Positioned(
                      top: 15,
                      child: Container(
                        width: 50,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: CupertinoColors.systemGrey4,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(25),
                            bottomRight: Radius.circular(25),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              // Thin elegant stem
              MixologistShimmer(
                child: Container(
                  width: 2,
                  height: 50,
                  color: CupertinoColors.systemGrey4,
                ),
              ),
              const SizedBox(height: 2),
              // Round base
              MixologistShimmer(
                child: Container(
                  width: 28,
                  height: 6,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey4,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
          
          // Professional cocktail shaker
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Shaker cap/strainer
              MixologistShimmer(
                child: Container(
                  width: 35,
                  height: 15,
                  decoration: const BoxDecoration(
                    color: CupertinoColors.systemGrey4,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(17),
                      topRight: Radius.circular(17),
                    ),
                  ),
                ),
              ),
              // Shaker top (slightly tapered)
              MixologistShimmer(
                child: Container(
                  width: 42,
                  height: 25,
                  decoration: const BoxDecoration(
                    color: CupertinoColors.systemGrey4,
                  ),
                ),
              ),
              // Shaker body (traditional Boston shaker shape)
              MixologistShimmer(
                child: Container(
                  width: 45,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: CupertinoColors.systemGrey4,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Spirit bottles with realistic shapes
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Tall spirit bottle (whiskey/vodka style)
              Column(
                children: [
                  // Bottle cap
                  MixologistShimmer(
                    child: Container(
                      width: 14,
                      height: 8,
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey4,
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                  ),
                  // Bottle neck
                  MixologistShimmer(
                    child: Container(
                      width: 12,
                      height: 25,
                      color: CupertinoColors.systemGrey4,
                    ),
                  ),
                  // Bottle shoulder
                  MixologistShimmer(
                    child: Container(
                      width: 22,
                      height: 8,
                      color: CupertinoColors.systemGrey4,
                    ),
                  ),
                  // Bottle body
                  MixologistShimmer(
                    child: Container(
                      width: 20,
                      height: 70,
                      decoration: const BoxDecoration(
                        color: CupertinoColors.systemGrey4,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(4),
                          bottomRight: Radius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Liqueur bottle (shorter, rounder)
              Column(
                children: [
                  // Cork/cap
                  MixologistShimmer(
                    child: Container(
                      width: 12,
                      height: 6,
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey4,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  // Short neck
                  MixologistShimmer(
                    child: Container(
                      width: 10,
                      height: 15,
                      color: CupertinoColors.systemGrey4,
                    ),
                  ),
                  // Round body (liqueur style)
                  MixologistShimmer(
                    child: Container(
                      width: 18,
                      height: 45,
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey4,
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Bar tools
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Jigger (measuring tool)
              MixologistShimmer(
                child: Container(
                  width: 16,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: CupertinoColors.systemGrey4,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                      bottomLeft: Radius.circular(6),
                      bottomRight: Radius.circular(6),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Bar spoon (long thin)
              MixologistShimmer(
                child: Container(
                  width: 2,
                  height: 80,
                  color: CupertinoColors.systemGrey4,
                ),
              ),
              const SizedBox(height: 4),
              // Spoon bowl
              MixologistShimmer(
                child: Container(
                  width: 8,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: CupertinoColors.systemGrey4,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                ),
              ),
            ],
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