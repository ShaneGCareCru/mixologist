import 'dart:io';
import 'package:flutter/material.dart';
import '../models/inventory_models.dart';
import '../services/inventory_service.dart';

class AddItemDialog extends StatefulWidget {
  final String? initialName;
  final String? initialCategory;
  final String? initialBrand;
  final String? initialQuantity;
  final File? sourceImage;
  final VoidCallback onItemAdded;

  const AddItemDialog({
    Key? key,
    this.initialName,
    this.initialCategory,
    this.initialBrand,
    this.initialQuantity,
    this.sourceImage,
    required this.onItemAdded,
  }) : super(key: key);

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCategory = IngredientCategory.spirits;
  String _selectedQuantity = QuantityDescription.fullBottle;
  bool _isLoading = false;
  bool _generateStylizedImage = false;

  @override
  void initState() {
    super.initState();
    
    // Set initial values if provided
    _nameController.text = widget.initialName ?? '';
    _brandController.text = widget.initialBrand ?? '';
    
    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory!;
    }
    
    if (widget.initialQuantity != null) {
      _selectedQuantity = widget.initialQuantity!;
    }

    // Enable stylized image generation if source image provided
    _generateStylizedImage = widget.sourceImage != null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _addItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await InventoryService.addInventoryItem(
        name: _nameController.text.trim(),
        category: _selectedCategory,
        quantity: _selectedQuantity,
        sourceImage: _generateStylizedImage ? widget.sourceImage : null,
        brand: _brandController.text.trim().isNotEmpty 
            ? _brandController.text.trim() 
            : null,
        notes: _notesController.text.trim().isNotEmpty 
            ? _notesController.text.trim() 
            : null,
      );

      widget.onItemAdded();
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_generateStylizedImage 
              ? 'Item added with stylized image!' 
              : 'Item added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding item: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Inventory Item'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Source Image Preview (if available)
                if (widget.sourceImage != null) ...[
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        widget.sourceImage!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Stylized Image Generation Option
                  SwitchListTile(
                    title: const Text('Generate Stylized Image'),
                    subtitle: const Text('Create cartoon-style bottle image (~\$0.25)'),
                    value: _generateStylizedImage,
                    onChanged: (value) {
                      setState(() {
                        _generateStylizedImage = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Item Name *',
                    hintText: 'e.g., Vodka, Simple Syrup, Lime',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an item name';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.words,
                ),

                const SizedBox(height: 16),

                // Category Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category *',
                    border: OutlineInputBorder(),
                  ),
                  items: IngredientCategory.all.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(IngredientCategory.getDisplayName(category)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Quantity Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedQuantity,
                  decoration: const InputDecoration(
                    labelText: 'Quantity *',
                    border: OutlineInputBorder(),
                  ),
                  items: QuantityDescription.all.map((quantity) {
                    return DropdownMenuItem(
                      value: quantity,
                      child: Text(QuantityDescription.getDisplayName(quantity)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedQuantity = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a quantity';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Brand Field
                TextFormField(
                  controller: _brandController,
                  decoration: const InputDecoration(
                    labelText: 'Brand (Optional)',
                    hintText: 'e.g., Grey Goose, Monin',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),

                const SizedBox(height: 16),

                // Notes Field
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    hintText: 'Any additional information',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                ),

                if (widget.sourceImage == null) ...[
                  const SizedBox(height: 24),
                  
                  // Quick Add Suggestions
                  const Text(
                    'Quick Add Common Items:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _QuickAddChip(
                        label: 'Vodka',
                        onTap: () => _fillQuickAdd('Vodka', IngredientCategory.spirits),
                      ),
                      _QuickAddChip(
                        label: 'Gin',
                        onTap: () => _fillQuickAdd('Gin', IngredientCategory.spirits),
                      ),
                      _QuickAddChip(
                        label: 'Simple Syrup',
                        onTap: () => _fillQuickAdd('Simple Syrup', IngredientCategory.syrups),
                      ),
                      _QuickAddChip(
                        label: 'Lime Juice',
                        onTap: () => _fillQuickAdd('Lime Juice', IngredientCategory.juices),
                      ),
                      _QuickAddChip(
                        label: 'Tonic Water',
                        onTap: () => _fillQuickAdd('Tonic Water', IngredientCategory.mixers),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _addItem,
          child: _isLoading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add Item'),
        ),
      ],
    );
  }

  void _fillQuickAdd(String name, String category) {
    setState(() {
      _nameController.text = name;
      _selectedCategory = category;
    });
  }
}

class _QuickAddChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickAddChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        label: Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
        backgroundColor: Colors.blue.shade50,
        side: BorderSide(color: Colors.blue.shade200),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}