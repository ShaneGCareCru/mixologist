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

/// Shimmer placeholder for inventory items
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
            // Image placeholder
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey4,
                borderRadius: BorderRadius.circular(iOSTheme.smallRadius),
              ),
            ),
            const SizedBox(width: 12),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 20,
                    width: 150,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey4,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 16,
                    width: 100,
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

/// Full-screen shimmer loading for recipe generation
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
              const SizedBox(height: 60),
              // Large cocktail glass placeholder
              const CircleShimmer(size: 120),
              const SizedBox(height: 40),
              // Title placeholder
              const TextLineShimmer(width: 200, height: 28),
              const SizedBox(height: 16),
              // Subtitle placeholders
              const TextLineShimmer(width: 250, height: 18),
              const SizedBox(height: 8),
              const TextLineShimmer(width: 180, height: 18),
              const SizedBox(height: 40),
              // Progress indicator
              MixologistShimmer(
                child: Container(
                  height: 4,
                  width: 200,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Spacer(),
              // Fun fact placeholder
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: iOSTheme.adaptiveColor(
                    context,
                    CupertinoColors.systemGrey6,
                    iOSTheme.darkSecondaryBackground,
                  ),
                  borderRadius: BorderRadius.circular(iOSTheme.smallRadius),
                ),
                child: Column(
                  children: const [
                    TextLineShimmer(width: double.infinity, height: 16),
                    SizedBox(height: 8),
                    TextLineShimmer(width: double.infinity, height: 16),
                    SizedBox(height: 8),
                    TextLineShimmer(width: 200, height: 16),
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
}