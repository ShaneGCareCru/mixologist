import 'dart:io';
import 'package:flutter/material.dart';
import '../models/inventory_models.dart';
import '../services/inventory_service.dart';
import '../../../shared/widgets/spring_button.dart';

class BottleCard extends StatefulWidget {
  final InventoryItem item;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;

  const BottleCard({
    super.key,
    required this.item,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<BottleCard> createState() => _BottleCardState();
}

class _BottleCardState extends State<BottleCard> {
  bool _isUpdating = false;

  Color get _fullnessColor {
    if (widget.item.fullness <= 0.1) return Colors.red;
    if (widget.item.fullness <= 0.25) return Colors.orange;
    if (widget.item.fullness <= 0.5) return Colors.yellow.shade700;
    return Colors.green;
  }

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
      await InventoryService.updateInventoryItem(
        itemId: widget.item.id,
        quantity: newQuantity,
      );
      
      widget.onUpdate();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quantity updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating quantity: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  Future<void> _deleteItem() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${widget.item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await InventoryService.deleteInventoryItem(
          widget.item.id,
          imagePath: widget.item.imagePath,
        );
        widget.onDelete();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting item: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDetailsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.item.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.item.brand != null) ...[
              Text('Brand: ${widget.item.brand}'),
              const SizedBox(height: 8),
            ],
            Text('Category: ${IngredientCategory.getDisplayName(widget.item.category)}'),
            const SizedBox(height: 8),
            Text('Quantity: ${QuantityDescription.getDisplayName(widget.item.quantity)}'),
            const SizedBox(height: 8),
            Text('Fullness: ${(widget.item.fullness * 100).toStringAsFixed(0)}%'),
            const SizedBox(height: 8),
            if (widget.item.notes != null && widget.item.notes!.isNotEmpty) ...[
              Text('Notes: ${widget.item.notes}'),
              const SizedBox(height: 8),
            ],
            Text('Added: ${widget.item.addedDate.day}/${widget.item.addedDate.month}/${widget.item.addedDate.year}'),
            if (widget.item.expiresSoon)
              const Text(
                'Expires Soon!',
                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showQuickUpdateDialog();
            },
            child: const Text('Update'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteItem();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
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
    if (widget.item.imagePath != null) {
      final file = File(widget.item.imagePath!);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            file,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildDefaultBottleIcon(),
          ),
        );
      }
    }
    return _buildDefaultBottleIcon();
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
    return BottleSpringCard(
      onTap: _showDetailsDialog,
      onLongPress: _showQuickUpdateDialog,
      enabled: !_isUpdating,
      child: Card(
        elevation: 3,
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
    );
  }
}