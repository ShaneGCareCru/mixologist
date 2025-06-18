import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../widgets/layout/tiered_layout_builder.dart';
import '../../../widgets/progress/smart_progress_bar.dart';
import '../../../services/focus_mode_controller.dart';
import '../../../widgets/glass/glass_visualization.dart';
import '../../../widgets/collapsible/collapsible_section.dart';
import '../../../services/tip_provider.dart';
import '../../../widgets/ingredient_intelligence/ingredient_card.dart';
import '../../../models/ingredient.dart' as Models;

/// Enhanced Recipe Screen implementing the professional 60/25/15 layout hierarchy
/// Features: Tiered layout, adaptive glass visualization, smart progress tracking
class EnhancedRecipeScreen extends StatefulWidget {
  final Map<String, dynamic> recipeData;
  
  const EnhancedRecipeScreen({
    super.key,
    required this.recipeData,
  });

  @override
  State<EnhancedRecipeScreen> createState() => _EnhancedRecipeScreenState();
}

class _EnhancedRecipeScreenState extends State<EnhancedRecipeScreen> {
  late FocusModeController _focusModeController;
  final Map<String, bool> _ingredientChecklist = {};
  final Map<int, bool> _stepCompletion = {};
  int _currentStep = 0;
  
  @override
  void initState() {
    super.initState();
    _focusModeController = FocusModeController();
    _initializeIngredientChecklist();
  }

  void _initializeIngredientChecklist() {
    final ingredients = widget.recipeData['ingredients'] as List? ?? [];
    for (final ingredient in ingredients) {
      final name = ingredient['name'] ?? ingredient.toString();
      _ingredientChecklist[name] = false;
    }
  }

  @override
  void dispose() {
    _focusModeController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipeData['name'] ?? 'Recipe'),
        backgroundColor: const Color(0xFFB8860B),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.viewfinder),
            onPressed: () => _focusModeController.toggleFocusMode(),
          ),
        ],
      ),
      body: TieredLayoutBuilder(
        heroZone: _buildHeroSection(),      // Glass + visual elements (60%)
        actionZone: _buildActionSection(),  // Smart progress + tips (25%)
        discoveryZone: _buildDetailSection(), // Collapsible details (15%)
        heroRatio: 0.6,
        actionRatio: 0.25,
        detailRatio: 0.15,
        enableFocusMode: true,
        onFocusModeChanged: () => _focusModeController.toggleFocusMode(),
      ),
    );
  }
  
  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          // Adaptive glass visualization
          Center(
            child: RecipeGlassWidget(
              recipeName: widget.recipeData['name'] ?? 'Cocktail',
              ingredients: _getIngredientNames(),
              size: const Size(200, 280),
              fillLevel: _calculateFillLevel(),
              showGarnish: true,
              enableInteraction: true,
              onTap: () => _showGlassDetails(),
            ),
          ),
          
          // Recipe title overlay
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.recipeData['name'] ?? 'Recipe',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFB8860B),
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
                if (widget.recipeData['description'] != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.recipeData['description'],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Smart progress bar
          Expanded(
            flex: 2,
            child: SmartProgressBar(
              steps: _getRecipeSteps(),
              currentStepIndex: _currentStep,
              showTechnique: true,
              showTiming: true,
              onStepTap: _jumpToStep,
              completedSteps: _stepCompletion,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Contextual tip card
          Expanded(
            flex: 1,
            child: _buildContextualTipCard(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          CollapsibleSection(
            title: 'Ingredients',
            leading: const Icon(Icons.scatter_plot, color: Color(0xFFB8860B)),
            initiallyExpanded: false,
            content: _buildSmartIngredientsGrid(),
          ),
          
          const SizedBox(height: 8),
          
          CollapsibleSection(
            title: 'Equipment',
            leading: const Icon(Icons.build_circle_outlined, color: Color(0xFFB8860B)),
            initiallyExpanded: false,
            content: _buildEquipmentSection(),
          ),
          
          const SizedBox(height: 8),
          
          CollapsibleSection(
            title: 'Variations',
            leading: const Icon(Icons.auto_awesome, color: Color(0xFF87A96B)),
            initiallyExpanded: false,
            content: _buildVariationsSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildContextualTipCard() {
    final currentStep = _getCurrentStep();
    if (currentStep == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Ready to start mixing!'),
        ),
      );
    }

    final tipProvider = TipProvider();
    final tip = tipProvider.getTipForStep(RecipeStep(
      stepNumber: _currentStep + 1,
      title: 'Current Step',
      description: currentStep,
      estimatedTime: const Duration(minutes: 2),
    ));
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: const Color(0xFFB8860B),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Pro Tip',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFB8860B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                tip,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartIngredientsGrid() {
    final ingredients = widget.recipeData['ingredients'] as List? ?? [];
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: ingredients.length,
      itemBuilder: (context, index) {
        final ingredientData = ingredients[index];
        final name = ingredientData['name'] ?? ingredientData.toString();
        final amount = ingredientData['amount'] ?? '';
        
        return IngredientCard(
          ingredient: _createIngredientFromData(ingredientData),
          amount: _parseAmount(amount),
          unit: _parseUnit(amount),
          onTap: () => _showSubstitutions(ingredientData),
          onLongPress: () => _showBrandRecommendations(ingredientData),
          showCost: true,
          showTastingNotes: true,
        );
      },
    );
  }

  Widget _buildEquipmentSection() {
    final equipment = widget.recipeData['equipment'] as List? ?? [];
    if (equipment.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No special equipment required'),
      );
    }

    return Column(
      children: equipment.map((item) {
        final name = item['name'] ?? item.toString();
        return ListTile(
          leading: Icon(
            Icons.build_circle_outlined,
            color: const Color(0xFFB8860B),
          ),
          title: Text(name),
          trailing: Checkbox(
            value: _ingredientChecklist[name] ?? false,
            onChanged: (value) {
              setState(() {
                _ingredientChecklist[name] = value ?? false;
              });
            },
            activeColor: const Color(0xFFB8860B),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildVariationsSection() {
    final variations = widget.recipeData['variations'] as List? ?? [];
    if (variations.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No variations available'),
      );
    }

    return Column(
      children: variations.map((variation) {
        final name = variation['name'] ?? 'Variation';
        final description = variation['description'] ?? '';
        return ListTile(
          leading: Icon(
            Icons.auto_awesome,
            color: const Color(0xFF87A96B),
          ),
          title: Text(name),
          subtitle: description.isNotEmpty ? Text(description) : null,
          onTap: () => _showVariationDetails(variation),
        );
      }).toList(),
    );
  }

  // Helper methods
  List<String> _getIngredientNames() {
    final ingredients = widget.recipeData['ingredients'] as List? ?? [];
    return ingredients.map((i) => i['name']?.toString() ?? '').toList();
  }

  double _calculateFillLevel() {
    final checked = _ingredientChecklist.values.where((v) => v).length;
    final total = _ingredientChecklist.length;
    return total > 0 ? checked / total : 0.0;
  }

  List<RecipeStep> _getRecipeSteps() {
    final stepsRaw = widget.recipeData['steps'] ?? widget.recipeData['method'] ?? [];
    final steps = stepsRaw is List ? stepsRaw : [];
    
    return steps.asMap().entries.map((entry) {
      final index = entry.key;
      final step = entry.value;
      final stepText = step['description'] ?? step.toString();
      
      return RecipeStep(
        stepNumber: index + 1,
        title: 'Step ${index + 1}',
        description: stepText,
        estimatedTime: const Duration(minutes: 2),
        isCompleted: _stepCompletion[index] ?? false,
        isActive: index == _currentStep,
      );
    }).toList();
  }

  String? _getCurrentStep() {
    final steps = _getRecipeSteps();
    if (_currentStep < steps.length) {
      return steps[_currentStep].description;
    }
    return null;
  }

  void _jumpToStep(int stepIndex) {
    setState(() {
      _currentStep = stepIndex;
    });
  }

  void _onIngredientChecked(String ingredient) {
    setState(() {
      _ingredientChecklist[ingredient] = !(_ingredientChecklist[ingredient] ?? false);
    });
  }

  void _showGlassDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Glass Details'),
        content: Text('Fill Level: ${(_calculateFillLevel() * 100).toInt()}%'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSubstitutions(Map<String, dynamic> ingredientData) {
    // Implementation for substitutions
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Substitutions for ${ingredientData['name']}')),
    );
  }

  void _showBrandRecommendations(Map<String, dynamic> ingredientData) {
    // Implementation for brand recommendations
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Brand recommendations for ${ingredientData['name']}')),
    );
  }

  void _showVariationDetails(Map<String, dynamic> variation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(variation['name'] ?? 'Variation'),
        content: Text(variation['description'] ?? 'No description available'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Models.Ingredient _createIngredientFromData(Map<String, dynamic> data) {
    final name = data['name'] ?? '';
    return Models.Ingredient(
      id: 'recipe_${name.hashCode}',
      name: name,
      category: _inferCategory(name),
      tier: Models.QualityTier.standard,
      fillLevel: _ingredientChecklist[name] == true ? 1.0 : 0.0,
      pricePerOz: 2.0,
      substitutes: [],
      metadata: data,
    );
  }

  String _inferCategory(String name) {
    final nameLower = name.toLowerCase();
    if (nameLower.contains('whiskey') || nameLower.contains('bourbon')) return 'Whiskey';
    if (nameLower.contains('gin')) return 'Gin';
    if (nameLower.contains('vodka')) return 'Vodka';
    if (nameLower.contains('rum')) return 'Rum';
    if (nameLower.contains('tequila')) return 'Tequila';
    return 'Other';
  }

  double _parseAmount(String amount) {
    final regex = RegExp(r'(\d+\.?\d*)');
    final match = regex.firstMatch(amount);
    return match != null ? double.tryParse(match.group(1)!) ?? 1.0 : 1.0;
  }

  Models.Unit _parseUnit(String amount) {
    final amountLower = amount.toLowerCase();
    if (amountLower.contains('oz')) return Models.Unit.oz;
    if (amountLower.contains('ml')) return Models.Unit.ml;
    if (amountLower.contains('cl')) return Models.Unit.cl;
    return Models.Unit.shots;
  }
}