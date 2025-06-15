import 'package:flutter/material.dart';
import '../models/inventory_models.dart';
import '../services/inventory_service.dart';

class AddInventoryItemPage extends StatefulWidget {
  final String? initialName;
  final String? initialCategory;
  final String? initialBrand;
  final String? initialQuantity;
  final VoidCallback onItemAdded;

  const AddInventoryItemPage({
    super.key,
    this.initialName,
    this.initialCategory,
    this.initialBrand,
    this.initialQuantity,
    required this.onItemAdded,
  });

  @override
  State<AddInventoryItemPage> createState() => _AddInventoryItemPageState();
}

class _AddInventoryItemPageState extends State<AddInventoryItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCategory = IngredientCategory.spirits;
  String _selectedQuantity = QuantityDescription.fullBottle;
  bool _isLoading = false;

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
        const SnackBar(
          content: Text('Item added successfully!'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Inventory Item'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _addItem,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Name Field
            Material(
              color: Colors.transparent,
              child: TextFormField(
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
            ),

            const SizedBox(height: 16),

            // Category Dropdown
            Material(
              color: Colors.transparent,
              child: DropdownButtonFormField<String>(
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
            ),

            const SizedBox(height: 16),

            // Quantity Dropdown
            Material(
              color: Colors.transparent,
              child: DropdownButtonFormField<String>(
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
            ),

            const SizedBox(height: 16),

            // Brand Field
            Material(
              color: Colors.transparent,
              child: TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(
                  labelText: 'Brand (Optional)',
                  hintText: 'e.g., Grey Goose, Monin',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
            ),

            const SizedBox(height: 16),

            // Notes Field
            Material(
              color: Colors.transparent,
              child: TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Any additional information',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),

            const SizedBox(height: 32),

            // Quick Add Suggestions
            const Text(
              'Quick Add Common Items:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
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
                  label: 'Whiskey',
                  onTap: () => _fillQuickAdd('Whiskey', IngredientCategory.spirits),
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
                  label: 'Angostura Bitters',
                  onTap: () => _fillQuickAdd('Angostura Bitters', IngredientCategory.bitters),
                ),
                _QuickAddChip(
                  label: 'Tonic Water',
                  onTap: () => _fillQuickAdd('Tonic Water', IngredientCategory.mixers),
                ),
                _QuickAddChip(
                  label: 'Fresh Lime',
                  onTap: () => _fillQuickAdd('Fresh Lime', IngredientCategory.freshIngredients),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Add Button
            ElevatedButton(
              onPressed: _isLoading ? null : _addItem,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Add to Inventory',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
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
        label: Text(label),
        backgroundColor: Colors.blue.shade50,
        side: BorderSide(color: Colors.blue.shade200),
      ),
    );
  }
}