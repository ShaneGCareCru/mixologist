import 'package:flutter/material.dart';
import '../widgets/safe_recipe_renderer.dart';
import '../widgets/improved_method_card.dart';
import '../widgets/mixologist_image.dart';

/// Improved Recipe Screen implementing our design philosophy
/// Features: Safe data handling, consistent image sizing, unified visual language
class ImprovedRecipeScreen extends StatefulWidget {
  final Map<String, dynamic> recipeData;

  const ImprovedRecipeScreen({
    super.key,
    required this.recipeData,
  });

  @override
  State<ImprovedRecipeScreen> createState() => _ImprovedRecipeScreenState();
}

class _ImprovedRecipeScreenState extends State<ImprovedRecipeScreen> {
  final Map<int, bool> _stepCompletion = {};
  final Map<String, bool> _ingredientChecklist = {};
  int _servingSize = 1;
  bool _isMetric = false;

  @override
  Widget build(BuildContext context) {
    return SafeRecipeRenderer(
      recipeData: widget.recipeData,
      builder: (context, safeData) => Scaffold(
        appBar: AppBar(
          title: Text(safeData.name),
          backgroundColor:
              const Color(0xFFB8860B), // Amber from design philosophy
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRecipeHero(safeData),
              const SizedBox(height: 24),
              _buildIngredientsAndEquipmentSection(safeData),
              const SizedBox(height: 24),
              _buildMethodSection(safeData),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeHero(SafeRecipeData safeData) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero image with consistent 16:9 aspect ratio
          MixologistImage.recipeHero(
            altText: '${safeData.name} cocktail presentation',
            onGenerateRequest: () => _generateRecipeImage(),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  safeData.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFB8860B), // Amber
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  safeData.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.4,
                      ),
                ),
                const SizedBox(height: 12),
                _buildRecipeMetadata(safeData),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeMetadata(SafeRecipeData safeData) {
    return Row(
      children: [
        _buildMetadataChip(Icons.local_bar, safeData.glassType),
        const SizedBox(width: 8),
        _buildMetadataChip(Icons.palette, safeData.garnish),
        const Spacer(),
        _buildServingControls(),
      ],
    );
  }

  Widget _buildMetadataChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF87A96B).withOpacity(0.2), // Sage
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF87A96B).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF87A96B)),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF87A96B),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildServingControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed:
                _servingSize > 1 ? () => setState(() => _servingSize--) : null,
            icon: const Icon(Icons.remove_circle_outline, size: 20),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          Text(
            '$_servingSize',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          IconButton(
            onPressed:
                _servingSize < 12 ? () => setState(() => _servingSize++) : null,
            icon: const Icon(Icons.add_circle_outline, size: 20),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsAndEquipmentSection(SafeRecipeData safeData) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.scatter_plot,
                  color: const Color(0xFFB8860B), // Amber
                ),
                const SizedBox(width: 8),
                Text(
                  'Ingredients & Equipment',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFB8860B),
                      ),
                ),
                const Spacer(),
                Switch(
                  value: _isMetric,
                  onChanged: (value) => setState(() => _isMetric = value),
                  activeColor: const Color(0xFF87A96B), // Sage
                ),
                Text(
                  _isMetric ? 'ml' : 'oz',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Combined ingredients and equipment grid with 1:1 aspect ratio
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio:
                    1.0, // Consistent 1:1 ratio from design philosophy
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount:
                  safeData.ingredients.length + safeData.equipment.length,
              itemBuilder: (context, index) {
                if (index < safeData.ingredients.length) {
                  // Render ingredient card
                  return _buildIngredientCard(safeData, index);
                } else {
                  // Render equipment card
                  final equipmentIndex = index - safeData.ingredients.length;
                  return _buildEquipmentCard(safeData, equipmentIndex);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientCard(SafeRecipeData safeData, int index) {
    final ingredientName = safeData.getIngredientName(index);
    final quantity = safeData.getIngredientQuantity(index);
    final scaledQuantity = _scaleQuantity(quantity, _servingSize);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Consistent ingredient image with 1:1 aspect ratio
            Expanded(
              flex: 3,
              child: MixologistImage.ingredient(
                altText: ingredientName,
                onGenerateRequest: () =>
                    _generateIngredientImage(ingredientName),
              ),
            ),
            const SizedBox(height: 8),
            // Ingredient details
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Text(
                    ingredientName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    scaledQuantity,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF87A96B), // Sage
                          fontWeight: FontWeight.w500,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  Transform.scale(
                    scale: 0.8,
                    child: Checkbox(
                      value: _ingredientChecklist[ingredientName] ?? false,
                      onChanged: (value) {
                        setState(() {
                          _ingredientChecklist[ingredientName] = value ?? false;
                        });
                      },
                      activeColor: const Color(0xFF87A96B), // Sage
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
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

  Widget _buildEquipmentCard(SafeRecipeData safeData, int index) {
    final equipmentName = safeData.getEquipment(index) ?? 'Unknown equipment';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Consistent equipment image with 1:1 aspect ratio
            Expanded(
              flex: 3,
              child: MixologistImage.equipment(
                altText: equipmentName,
                onGenerateRequest: () => _generateEquipmentImage(equipmentName),
              ),
            ),
            const SizedBox(height: 8),
            // Equipment details
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Text(
                    equipmentName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Equipment',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFFB8860B), // Amber for equipment
                          fontWeight: FontWeight.w500,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  Transform.scale(
                    scale: 0.8,
                    child: Checkbox(
                      value: _ingredientChecklist[equipmentName] ?? false,
                      onChanged: (value) {
                        setState(() {
                          _ingredientChecklist[equipmentName] = value ?? false;
                        });
                      },
                      activeColor:
                          const Color(0xFFB8860B), // Amber for equipment
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
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

  Widget _buildMethodSection(SafeRecipeData safeData) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.format_list_numbered,
                  color: const Color(0xFFB8860B), // Amber
                ),
                const SizedBox(width: 8),
                Text(
                  'Method',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFB8860B),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress indicator
            _buildProgressIndicator(safeData),
            const SizedBox(height: 16),
            // Method steps using improved cards
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 1200
                    ? 3
                    : MediaQuery.of(context).size.width > 800
                        ? 2
                        : 1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8, // Optimized for method cards
              ),
              itemCount: safeData.steps.length,
              itemBuilder: (context, index) {
                final stepText =
                    safeData.getStep(index) ?? 'Step information missing';
                final data = SafeMethodCardData.fromString(stepText, index + 1);

                return ImprovedMethodCard(
                  data: data,
                  state: (_stepCompletion[index] ?? false)
                      ? MethodCardState.completed
                      : MethodCardState.defaultState,
                  onCompleted: () => _toggleStepCompleted(index, true),
                  onPrevious: () => _toggleStepCompleted(index, false),
                  onGenerateImage: () => _generateMethodImage(index),
                  onCheckboxChanged: (value) =>
                      _toggleStepCompleted(index, value ?? false),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(SafeRecipeData safeData) {
    final totalSteps = safeData.steps.length;
    final completedSteps =
        _stepCompletion.values.where((completed) => completed).length;
    final progress = totalSteps > 0 ? completedSteps / totalSteps : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFB8860B).withOpacity(0.1), // Amber
            const Color(0xFF87A96B).withOpacity(0.1), // Sage
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFB8860B).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                '$completedSteps/$totalSteps steps',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF87A96B),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              const Color(0xFF87A96B), // Sage
            ),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text(
            _getProgressText(progress),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
      ),
    );
  }

  void _toggleStepCompleted(int index, bool completed) {
    setState(() {
      _stepCompletion[index] = completed;
    });
  }

  String _scaleQuantity(String quantity, int servingSize) {
    // Simple quantity scaling - could be enhanced with proper parsing
    if (servingSize == 1) return quantity;

    // Extract numbers and scale them
    final regex = RegExp(r'(\d+\.?\d*)');
    return quantity.replaceAllMapped(regex, (match) {
      final number = double.tryParse(match.group(0)!) ?? 1.0;
      final scaled = number * servingSize;
      return scaled % 1 == 0
          ? scaled.toInt().toString()
          : scaled.toStringAsFixed(1);
    });
  }

  String _getProgressText(double progress) {
    if (progress == 0) return 'Ready to start mixing';
    if (progress < 0.4) return 'Adding ingredients...';
    if (progress < 0.8) return 'Mixing and blending...';
    if (progress < 1.0) return 'Almost finished!';
    return 'Cocktail complete! 🍹';
  }

  void _generateRecipeImage() {
    // Implement recipe image generation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating recipe image...')),
    );
  }

  void _generateIngredientImage(String ingredientName) {
    // Implement ingredient image generation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Generating image for $ingredientName...')),
    );
  }

  void _generateMethodImage(int stepIndex) {
    // Implement method step image generation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Generating image for step ${stepIndex + 1}...')),
    );
  }

  void _generateEquipmentImage(String equipmentName) {
    // Implement equipment image generation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Generating image for $equipmentName...')),
    );
  }
}
