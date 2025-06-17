import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Image types with standardized aspect ratios following our design philosophy
enum MixologistImageType {
  /// 16:9 aspect ratio for appetizing, professional recipe presentation
  recipeHero(16 / 9, 400, 225),
  
  /// 1:1 aspect ratio for consistent ingredient thumbnails
  ingredient(1.0, 128, 128),
  
  /// 4:3 aspect ratio optimized for technique demonstration
  methodStep(4 / 3, 400, 300),
  
  /// 1:1 aspect ratio for clean equipment integration
  equipment(1.0, 128, 128),
  
  /// 3:2 aspect ratio for general purpose images
  general(3 / 2, 300, 200);
  
  const MixologistImageType(this.aspectRatio, this.cacheWidth, this.cacheHeight);
  
  final double aspectRatio;
  final int cacheWidth;
  final int cacheHeight;
}

/// Unified image component implementing our design philosophy's image standards
/// Provides consistent caching, sizing, and placeholder handling
class MixologistImage extends StatelessWidget {
  final String? imageUrl;
  final Uint8List? imageBytes;
  final MixologistImageType type;
  final String altText;
  final bool isGenerating;
  final VoidCallback? onTap;
  final VoidCallback? onGenerateRequest;
  final BoxFit fit;
  final bool showPlaceholderInstructions;
  
  const MixologistImage({
    super.key,
    this.imageUrl,
    this.imageBytes,
    required this.type,
    required this.altText,
    this.isGenerating = false,
    this.onTap,
    this.onGenerateRequest,
    this.fit = BoxFit.cover,
    this.showPlaceholderInstructions = true,
  });
  
  /// Factory for recipe hero images
  factory MixologistImage.recipeHero({
    Key? key,
    String? imageUrl,
    Uint8List? imageBytes,
    required String altText,
    bool isGenerating = false,
    VoidCallback? onTap,
    VoidCallback? onGenerateRequest,
  }) => MixologistImage(
    key: key,
    imageUrl: imageUrl,
    imageBytes: imageBytes,
    type: MixologistImageType.recipeHero,
    altText: altText,
    isGenerating: isGenerating,
    onTap: onTap,
    onGenerateRequest: onGenerateRequest,
  );
  
  /// Factory for ingredient thumbnails
  factory MixologistImage.ingredient({
    Key? key,
    String? imageUrl,
    Uint8List? imageBytes,
    required String altText,
    bool isGenerating = false,
    VoidCallback? onTap,
    VoidCallback? onGenerateRequest,
  }) => MixologistImage(
    key: key,
    imageUrl: imageUrl,
    imageBytes: imageBytes,
    type: MixologistImageType.ingredient,
    altText: altText,
    isGenerating: isGenerating,
    onTap: onTap,
    onGenerateRequest: onGenerateRequest,
  );
  
  /// Factory for method step images
  factory MixologistImage.methodStep({
    Key? key,
    String? imageUrl,
    Uint8List? imageBytes,
    required String altText,
    bool isGenerating = false,
    VoidCallback? onTap,
    VoidCallback? onGenerateRequest,
  }) => MixologistImage(
    key: key,
    imageUrl: imageUrl,
    imageBytes: imageBytes,
    type: MixologistImageType.methodStep,
    altText: altText,
    isGenerating: isGenerating,
    onTap: onTap,
    onGenerateRequest: onGenerateRequest,
  );
  
  /// Factory for equipment images
  factory MixologistImage.equipment({
    Key? key,
    String? imageUrl,
    Uint8List? imageBytes,
    required String altText,
    bool isGenerating = false,
    VoidCallback? onTap,
    VoidCallback? onGenerateRequest,
  }) => MixologistImage(
    key: key,
    imageUrl: imageUrl,
    imageBytes: imageBytes,
    type: MixologistImageType.equipment,
    altText: altText,
    isGenerating: isGenerating,
    onTap: onTap,
    onGenerateRequest: onGenerateRequest,
  );
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AspectRatio(
      aspectRatio: type.aspectRatio,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildImageContent(context, theme),
          ),
        ),
      ),
    );
  }
  
  Widget _buildImageContent(BuildContext context, ThemeData theme) {
    // Show loading state
    if (isGenerating) {
      return _buildGeneratingState(theme);
    }
    
    // Show generated image from bytes
    if (imageBytes != null) {
      return _buildImageFromBytes(theme);
    }
    
    // Show cached network image from URL
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return _buildNetworkImage(theme);
    }
    
    // Show elegant placeholder
    return _buildPlaceholder(theme);
  }
  
  Widget _buildGeneratingState(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer.withOpacity(0.3),
            theme.colorScheme.secondaryContainer.withOpacity(0.3),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Crafting visual...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'This will just take a moment',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildImageFromBytes(ThemeData theme) {
    return Image.memory(
      imageBytes!,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) => _buildErrorState(theme),
    );
  }
  
  Widget _buildNetworkImage(ThemeData theme) {
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      fit: fit,
      memCacheWidth: type.cacheWidth,
      memCacheHeight: type.cacheHeight,
      placeholder: (context, url) => _buildLoadingState(theme),
      errorWidget: (context, url, error) => _buildErrorState(theme),
    );
  }
  
  Widget _buildLoadingState(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary.withOpacity(0.7),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildErrorState(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.3),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 32,
              color: theme.colorScheme.error.withOpacity(0.7),
            ),
            const SizedBox(height: 8),
            Text(
              'Image unavailable',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            // Craft-inspired colors from our design philosophy
            const Color(0xFFB8860B).withOpacity(0.1), // Amber
            const Color(0xFF87A96B).withOpacity(0.1), // Sage
          ],
        ),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getPlaceholderIcon(),
              size: _getIconSize(),
              color: theme.colorScheme.primary.withOpacity(0.6),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                altText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (showPlaceholderInstructions && onGenerateRequest != null) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onGenerateRequest,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Generate Image',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  IconData _getPlaceholderIcon() {
    switch (type) {
      case MixologistImageType.recipeHero:
        return Icons.local_bar;
      case MixologistImageType.ingredient:
        return Icons.scatter_plot;
      case MixologistImageType.methodStep:
        return Icons.gesture;
      case MixologistImageType.equipment:
        return Icons.kitchen;
      case MixologistImageType.general:
        return Icons.image_outlined;
    }
  }
  
  double _getIconSize() {
    switch (type) {
      case MixologistImageType.recipeHero:
        return 48;
      case MixologistImageType.ingredient:
      case MixologistImageType.equipment:
        return 32;
      case MixologistImageType.methodStep:
        return 40;
      case MixologistImageType.general:
        return 36;
    }
  }
}