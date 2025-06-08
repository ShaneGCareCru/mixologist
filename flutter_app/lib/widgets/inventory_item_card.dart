import 'package:flutter/material.dart';
import '../models/inventory_models.dart';
import '../services/inventory_service.dart';

class InventoryItemCard extends StatefulWidget {
  final InventoryItem item;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;

  const InventoryItemCard({
    Key? key,
    required this.item,
    required this.onUpdate,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<InventoryItemCard> createState() => _InventoryItemCardState();
}

class _InventoryItemCardState extends State<InventoryItemCard> {
  bool _isUpdating = false;

  Color get _quantityColor {
    // Use fullness value for more accurate color representation
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
            ...QuantityDescription.all.map((quantity) {
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: _quantityColor.withOpacity(0.2),
              child: Icon(
                _categoryIcon,
                color: _quantityColor,
              ),
            ),
            if (widget.item.expiresSoon)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning,
                    size: 8,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          widget.item.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(IngredientCategory.getDisplayName(widget.item.category)),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _quantityColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    QuantityDescription.getDisplayName(widget.item.quantity),
                    style: TextStyle(
                      color: _quantityColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (widget.item.brand != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    widget.item.brand!,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
            if (widget.item.notes != null && widget.item.notes!.isNotEmpty)
              Text(
                widget.item.notes!,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: _isUpdating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'update':
                      _showQuickUpdateDialog();
                      break;
                    case 'delete':
                      _deleteItem();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'update',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Update Quantity'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
        onTap: _showQuickUpdateDialog,
      ),
    );
  }
}