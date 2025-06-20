import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import '../models/inventory_models.dart';
import '../services/inventory_service.dart';
import '../widgets/inventory_item_card.dart';
import '../widgets/bottle_card.dart';
import '../widgets/add_item_dialog.dart';
import '../widgets/inventory_shelf.dart';
import '../../../theme/ios_theme.dart';
import '../../../shared/widgets/ios_card.dart';
import '../../../shared/widgets/shimmer_components.dart';

class UnifiedInventoryPage extends StatefulWidget {
  const UnifiedInventoryPage({super.key});

  @override
  State<UnifiedInventoryPage> createState() => _UnifiedInventoryPageState();
}

class _UnifiedInventoryPageState extends State<UnifiedInventoryPage> {
  List<InventoryItem> _items = [];
  InventoryStats? _stats;
  bool _isLoading = true;
  bool _isAnalyzing = false;
  String? _error;
  String _searchQuery = '';
  String _selectedCategory = 'all';
  bool _isBackBarView = true; // Toggle between shelf view and list view

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final items = await InventoryService.getInventory();
      final stats = await InventoryService.getInventoryStats();

      setState(() {
        _items = items;
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (photo != null) {
        await _analyzeImage(photo);
      }
    } catch (e) {
      _showError('Error taking photo: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        await _analyzeImage(image);
      }
    } catch (e) {
      _showError('Error picking image: $e');
    }
  }

  Future<void> _analyzeImage(XFile imageFile) async {
    try {
      setState(() {
        _isAnalyzing = true;
      });

      final response = await InventoryService.analyzeImage(imageFile);

      setState(() {
        _isAnalyzing = false;
      });

      if (response.recognizedIngredients.isNotEmpty) {
        await _showRecognitionResults(response, imageFile);
      } else {
        _showError('No ingredients recognized in the image. Try taking a clearer photo with better lighting.');
      }
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      _showError('Error analyzing image: $e');
    }
  }

  Future<void> _showRecognitionResults(ImageRecognitionResponse response, XFile sourceImage) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recognized Ingredients'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            children: [
              if (response.suggestions.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Suggestions:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ...response.suggestions.map((suggestion) => Text('• $suggestion')),
                    ],
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  itemCount: response.recognizedIngredients.length,
                  itemBuilder: (context, index) {
                    final ingredient = response.recognizedIngredients[index];
                    return Card(
                      child: ListTile(
                        title: Text(ingredient.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Category: ${IngredientCategory.getDisplayName(ingredient.category)}'),
                            Text('Confidence: ${(ingredient.confidence * 100).toStringAsFixed(1)}%'),
                            if (ingredient.brand != null) Text('Brand: ${ingredient.brand}'),
                            if (ingredient.quantityEstimate != null)
                              Text('Quantity: ${QuantityDescription.getDisplayName(ingredient.quantityEstimate!)}'),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _addRecognizedItem(ingredient, sourceImage);
                          },
                          child: const Text('Add'),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _addRecognizedItem(RecognizedIngredient ingredient, XFile sourceImage) {
    _showAddItemDialog(
      initialName: ingredient.name,
      initialCategory: ingredient.category,
      initialBrand: ingredient.brand,
      initialQuantity: ingredient.quantityEstimate,
      sourceImage: sourceImage,
    );
  }

  void _showAddItemDialog({
    String? initialName,
    String? initialCategory,
    String? initialBrand,
    String? initialQuantity,
    XFile? sourceImage,
  }) {
    showDialog(
      context: context,
      builder: (context) => AddItemDialog(
        initialName: initialName,
        initialCategory: initialCategory,
        initialBrand: initialBrand,
        initialQuantity: initialQuantity,
        sourceImage: sourceImage,
        onItemAdded: _loadInventory,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  List<InventoryItem> get _filteredItems {
    return _items.where((item) {
      final matchesSearch = _searchQuery.isEmpty ||
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (item.brand?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

      final matchesCategory = _selectedCategory == 'all' || item.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  Map<String, List<InventoryItem>> get _itemsByCategory {
    final itemsByCategory = <String, List<InventoryItem>>{};
    
    for (final item in _filteredItems) {
      if (!itemsByCategory.containsKey(item.category)) {
        itemsByCategory[item.category] = [];
      }
      itemsByCategory[item.category]!.add(item);
    }

    // Sort categories by priority: spirits first, then by item count
    final sortedCategories = itemsByCategory.keys.toList()..sort((a, b) {
      // Prioritize spirits and liqueurs
      if (a == IngredientCategory.spirits && b != IngredientCategory.spirits) return -1;
      if (b == IngredientCategory.spirits && a != IngredientCategory.spirits) return 1;
      if (a == IngredientCategory.liqueurs && b != IngredientCategory.liqueurs) return -1;
      if (b == IngredientCategory.liqueurs && a != IngredientCategory.liqueurs) return 1;
      
      // Then sort by item count (descending)
      return itemsByCategory[b]!.length.compareTo(itemsByCategory[a]!.length);
    });

    // Return ordered map
    final orderedMap = <String, List<InventoryItem>>{};
    for (final category in sortedCategories) {
      orderedMap[category] = itemsByCategory[category]!;
    }

    return orderedMap;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Bar Inventory'),
        backgroundColor: CupertinoColors.systemBackground,
        border: const Border(),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(
                _isBackBarView ? CupertinoIcons.list_bullet : CupertinoIcons.square_grid_2x2,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _isBackBarView = !_isBackBarView;
                });
              }, minimumSize: Size(iOSTheme.minimumTouchTarget, iOSTheme.minimumTouchTarget),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _loadInventory, minimumSize: Size(iOSTheme.minimumTouchTarget, iOSTheme.minimumTouchTarget),
              child: const Icon(CupertinoIcons.refresh, size: 20),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.add, size: 20),
              onPressed: () => _showAddItemDialog(), minimumSize: Size(iOSTheme.minimumTouchTarget, iOSTheme.minimumTouchTarget),
            ),
          ],
        ),
      ),
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: Column(
        children: [
          // Stats Card
          if (_stats != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(label: 'Total', value: _stats!.totalItems.toString()),
                  _StatItem(label: 'Categories', value: _stats!.byCategory.length.toString()),
                  _StatItem(label: 'Expiring', value: _stats!.expiringSoon.toString()),
                ],
              ),
            ),

          // Search and Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search inventory...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Material(
                  color: Colors.transparent,
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    items: [
                      const DropdownMenuItem(value: 'all', child: Text('All Categories')),
                      ...IngredientCategory.all.map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(IngredientCategory.getDisplayName(category)),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value ?? 'all';
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Camera Actions
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isAnalyzing ? null : _takePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Scan with Camera'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isAnalyzing ? null : _pickFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Pick from Gallery'),
                  ),
                ),
              ],
            ),
          ),

          if (_isAnalyzing)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: iOSTheme.adaptiveColor(
                    context,
                    CupertinoColors.systemGrey6,
                    iOSTheme.darkSecondaryBackground,
                  ),
                  borderRadius: BorderRadius.circular(iOSTheme.smallRadius),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CupertinoActivityIndicator(),
                    SizedBox(width: 16),
                    Text('Analyzing image with AI...'),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Items Display
          Expanded(
            child: _isLoading
                ? _buildLoadingShimmer()
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Error: $_error'),
                            ElevatedButton(
                              onPressed: _loadInventory,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _filteredItems.isEmpty
                        ? const Center(
                            child: Text(
                              'No items found.\nTap + to add items or use camera to scan ingredients.',
                              textAlign: TextAlign.center,
                            ),
                          )
                        : _isBackBarView
                            ? _buildShelfView()
                            : _buildListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      itemCount: 8,
      itemBuilder: (context, index) {
        return const InventoryItemShimmer();
      },
    );
  }

  Widget _buildShelfView() {
    final itemsByCategory = _itemsByCategory;
    
    if (itemsByCategory.isEmpty) {
      return const Center(
        child: Text(
          'No items found.\nTap + to add items or use camera to scan ingredients.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        // Build a shelf for each category
        ...itemsByCategory.entries.map(
          (entry) => InventoryShelf(
            title: IngredientCategory.getDisplayName(entry.key),
            items: entry.value,
            onUpdate: _loadInventory,
            onDelete: _loadInventory,
            onSeeAll: entry.value.length > 4 ? () {
              // Navigate to category-specific view
              _showCategoryView(entry.key, entry.value);
            } : null,
          ),
        ),
        // Add some bottom padding
        const SliverPadding(
          padding: EdgeInsets.only(bottom: 80),
        ),
      ],
    );
  }

  void _showCategoryView(String category, List<InventoryItem> items) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(IngredientCategory.getDisplayName(category)),
          ),
          body: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return BottleCard(
                item: item,
                onUpdate: () {
                  _loadInventory();
                  Navigator.of(context).pop(); // Close category view
                },
                onDelete: () {
                  _loadInventory();
                  Navigator.of(context).pop(); // Close category view
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        return InventoryItemCard(
          item: item,
          onUpdate: _loadInventory,
          onDelete: _loadInventory,
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}