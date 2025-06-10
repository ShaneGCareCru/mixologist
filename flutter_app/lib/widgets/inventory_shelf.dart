/// Netflix-style inventory shelf implementing the "rows-of-carousels" pattern
/// for smooth 60fps scrolling performance. Follows the implementation checklist:
///
/// 1. Uses Slivers with SliverToBoxAdapter wrapping horizontal ListView
/// 2. Fixed item sizes (140px width) for optimal scroll physics
/// 3. ListView.builder with cacheExtent for smooth pre-building
/// 4. Image optimization with CachedNetworkImage and FadeInImage
/// 5. Platform-specific physics (iOS: BouncingScrollPhysics)
/// 6. PageStorageKey for scroll position preservation
/// 7. Optional snap-to-start functionality
/// 8. Enhanced features: liquid levels, low-stock glow, hover effects

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/inventory_models.dart';
import 'bottle_card.dart';

class InventoryShelf extends StatefulWidget {
  final String title;
  final List<InventoryItem> items;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;
  final VoidCallback? onSeeAll;
  final bool enableSnapToStart;

  const InventoryShelf({
    Key? key,
    required this.title,
    required this.items,
    required this.onUpdate,
    required this.onDelete,
    this.onSeeAll,
    this.enableSnapToStart = false,
  }) : super(key: key);

  @override
  State<InventoryShelf> createState() => _InventoryShelfState();
}

class _InventoryShelfState extends State<InventoryShelf> {
  late ScrollController _scrollController;
  
  // Performance constants
  static const double _itemWidth = 140.0;
  static const double _cacheExtentMultiplier = 3.0;
  static const double _shelfHeight = 200.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    
    // Add snap-to-start listener if enabled
    if (widget.enableSnapToStart) {
      _scrollController.addListener(_snapListener);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _snapListener() {
    // Simple snap-to-start implementation
    if (!_scrollController.position.isScrollingNotifier.value) {
      final double offset = _scrollController.offset;
      final double itemPosition = offset / _itemWidth;
      final double snapPosition = itemPosition.round() * _itemWidth;
      
      if ((offset - snapPosition).abs() > 10) {
        _scrollController.animateTo(
          snapPosition,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.items.length > 4 && widget.onSeeAll != null)
                  InkWell(
                    onTap: widget.onSeeAll,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        'See All ▸',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            height: _shelfHeight,
            child: ListView.builder(
              key: PageStorageKey(widget.title),
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: Theme.of(context).platform == TargetPlatform.iOS
                  ? const BouncingScrollPhysics()
                  : const ClampingScrollPhysics(),
              cacheExtent: _cacheExtentMultiplier * _itemWidth,
              itemCount: widget.items.length,
              itemExtent: _itemWidth,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                return Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 16 : 8,
                    right: index == widget.items.length - 1 ? 16 : 8,
                  ),
                  child: EnhancedBottleCard(
                    item: item,
                    onUpdate: widget.onUpdate,
                    onDelete: widget.onDelete,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class EnhancedBottleCard extends StatefulWidget {
  final InventoryItem item;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;

  const EnhancedBottleCard({
    Key? key,
    required this.item,
    required this.onUpdate,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<EnhancedBottleCard> createState() => _EnhancedBottleCardState();
}

class _EnhancedBottleCardState extends State<EnhancedBottleCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isUpdating = false;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  Color get _fullnessColor {
    if (widget.item.fullness <= 0.1) return Colors.red;
    if (widget.item.fullness <= 0.25) return Colors.orange;
    if (widget.item.fullness <= 0.5) return Colors.yellow.shade700;
    return Colors.green;
  }

  bool get _isLowStock => widget.item.fullness < 0.15;

  IconData get _categoryIcon {
    switch (widget.item.category) {
      case IngredientCategory.spirits:
        return Icons.local_bar;
      case IngredientCategory.liqueurs:
        return Icons.wine_bar;
      case IngredientCategory.bitters:
        return Icons.opacity;
      case IngredientCategory.syrups:
        return Icons.water_drop;
      case IngredientCategory.juices:
        return Icons.emoji_food_beverage;
      case IngredientCategory.freshIngredients:
        return Icons.eco;
      case IngredientCategory.garnishes:
        return Icons.local_florist;
      case IngredientCategory.mixers:
        return Icons.bubble_chart;
      case IngredientCategory.equipment:
        return Icons.kitchen;
      default:
        return Icons.inventory;
    }
  }

  Future<void> _updateQuantity(String newQuantity) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call
      widget.onUpdate();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quantity updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating quantity: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  void _showDetailsDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow('Brand', widget.item.brand),
                      _buildDetailRow('Category', IngredientCategory.getDisplayName(widget.item.category)),
                      _buildDetailRow('Quantity', QuantityDescription.getDisplayName(widget.item.quantity)),
                      _buildDetailRow('Fullness', '${(widget.item.fullness * 100).toStringAsFixed(0)}%'),
                      if (widget.item.notes != null && widget.item.notes!.isNotEmpty)
                        _buildDetailRow('Notes', widget.item.notes),
                      _buildDetailRow('Added', '${widget.item.addedDate.day}/${widget.item.addedDate.month}/${widget.item.addedDate.year}'),
                      if (widget.item.expiresSoon)
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.warning, color: Colors.orange),
                              SizedBox(width: 8),
                              Text(
                                'Expires Soon!',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _showQuickUpdateDialog();
                              },
                              child: const Text('Update Quantity'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                widget.onDelete();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Delete'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickUpdateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update ${widget.item.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select new quantity:'),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              width: double.maxFinite,
              child: ListView(
                children: QuantityDescription.all.map((quantity) {
                  return ListTile(
                    title: Text(QuantityDescription.getDisplayName(quantity)),
                    leading: Radio<String>(
                      value: quantity,
                      groupValue: widget.item.quantity,
                      onChanged: (value) {
                        Navigator.of(context).pop();
                        if (value != null && value != widget.item.quantity) {
                          _updateQuantity(value);
                        }
                      },
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      if (quantity != widget.item.quantity) {
                        _updateQuantity(quantity);
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottleImage() {
    Widget imageWidget;

    if (widget.item.imagePath != null) {
      // Check if it's a network URL or local file
      final imagePath = widget.item.imagePath!;
      
      if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
        // Network image with caching
        imageWidget = ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: imagePath,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            placeholder: (context, url) => Container(
              decoration: BoxDecoration(
                color: _fullnessColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            errorWidget: (context, url, error) => _buildDefaultBottleIcon(),
            fadeInDuration: const Duration(milliseconds: 300),
            fadeOutDuration: const Duration(milliseconds: 100),
            memCacheWidth: 150, // Thumbnail optimization as suggested
          ),
        );
      } else {
        // Local file
        final file = File(imagePath);
        if (file.existsSync()) {
          imageWidget = ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: FadeInImage(
              placeholder: MemoryImage(_generatePlaceholderBytes()),
              image: FileImage(file),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              fadeInDuration: const Duration(milliseconds: 300),
              fadeOutDuration: const Duration(milliseconds: 100),
              imageErrorBuilder: (context, error, stackTrace) => _buildDefaultBottleIcon(),
            ),
          );
        } else {
          imageWidget = _buildDefaultBottleIcon();
        }
      }
    } else {
      imageWidget = _buildDefaultBottleIcon();
    }

    // Add liquid level overlay using ClipPath
    return Stack(
      children: [
        imageWidget,
        // Liquid level overlay
        Positioned.fill(
          child: ClipPath(
            clipper: _LiquidLevelClipper(fullness: widget.item.fullness),
            child: Container(
              decoration: BoxDecoration(
                color: _fullnessColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Generate a simple placeholder to avoid layout jumps
  static Uint8List _generatePlaceholderBytes() {
    // Simple 1x1 transparent pixel
    return Uint8List.fromList([
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
      0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
      0x0B, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
      0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
      0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82
    ]);
  }

  Widget _buildDefaultBottleIcon() {
    return Container(
      decoration: BoxDecoration(
        color: _fullnessColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _fullnessColor.withOpacity(0.3)),
      ),
      child: Icon(
        _categoryIcon,
        size: 40,
        color: _fullnessColor,
      ),
    );
  }

  Widget _buildFullnessIndicator() {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        widthFactor: widget.item.fullness,
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            color: _fullnessColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: kIsWeb ? (_) {
        setState(() => _isHovered = true);
        _scaleController.forward();
      } : null,
      onExit: kIsWeb ? (_) {
        setState(() => _isHovered = false);
        _scaleController.reverse();
      } : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: kIsWeb ? _scaleAnimation.value : 1.0,
            child: GestureDetector(
              onTap: _showDetailsDialog,
              onLongPress: _showQuickUpdateDialog,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    // Low stock glow effect
                    if (_isLowStock)
                      BoxShadow(
                        color: Colors.redAccent.withOpacity(0.4),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    // Regular shadow
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Card(
                  elevation: 0, // Remove default elevation since we're using custom shadows
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Bottle Image
                        Expanded(
                          flex: 3,
                          child: Stack(
                            children: [
                              Center(child: _buildBottleImage()),
                              if (widget.item.expiresSoon)
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.orange,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.warning,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              if (_isUpdating)
                                const Center(
                                  child: CircularProgressIndicator(),
                                ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Item Name
                        Text(
                          widget.item.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        // Brand (if available)
                        if (widget.item.brand != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.item.brand!,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        
                        const SizedBox(height: 8),
                        
                        // Fullness Indicator
                        _buildFullnessIndicator(),
                        
                        const SizedBox(height: 4),
                        
                        // Fullness Percentage
                        Text(
                          '${(widget.item.fullness * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 10,
                            color: _fullnessColor,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LiquidLevelClipper extends CustomClipper<Path> {
  final double fullness;

  _LiquidLevelClipper({required this.fullness});

  @override
  Path getClip(Size size) {
    final path = Path();
    final liquidHeight = size.height * (1.0 - fullness);
    
    path.addRRect(RRect.fromLTRBR(
      0,
      liquidHeight,
      size.width,
      size.height,
      const Radius.circular(8),
    ));
    
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return oldClipper is _LiquidLevelClipper && oldClipper.fullness != fullness;
  }
}