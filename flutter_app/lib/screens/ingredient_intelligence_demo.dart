import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/ingredient.dart';
import '../widgets/ingredient_intelligence/ingredient_intelligence.dart';
import '../theme/app_colors.dart';

/// Demo screen showcasing all ingredient intelligence features
class IngredientIntelligenceDemo extends StatefulWidget {
  const IngredientIntelligenceDemo({super.key});

  @override
  State<IngredientIntelligenceDemo> createState() => _IngredientIntelligenceDemoState();
}

class _IngredientIntelligenceDemoState extends State<IngredientIntelligenceDemo> {
  double _amount = 2.0;
  Unit _unit = Unit.oz;
  
  // Sample ingredients for demo
  final List<Ingredient> _sampleIngredients = [
    Ingredient(
      id: '1',
      name: 'Premium Tequila',
      category: 'spirits',
      tier: QualityTier.premium,
      fillLevel: 0.75,
      brand: 'Casamigos',
      pricePerOz: 3.25,
      tastingNote: 'Earthy agave with citrus hints',
    ),
    Ingredient(
      id: '2',
      name: 'Triple Sec',
      category: 'liqueurs',
      tier: QualityTier.standard,
      fillLevel: 0.5,
      brand: 'Cointreau',
      pricePerOz: 1.60,
      tastingNote: 'Bright orange citrus essence',
    ),
    Ingredient(
      id: '3',
      name: 'Lime Juice',
      category: 'mixers',
      tier: QualityTier.standard,
      fillLevel: 0.9,
      pricePerOz: 0.35,
      tastingNote: 'Bright acidity with citrus zing',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.charcoalSurface,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: AppColors.smokyGlass,
        middle: Text(
          'Ingredient Intelligence',
          style: TextStyle(
            color: AppColors.champagneGold,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildSectionHeader(
                'Smart Ingredient Cards',
                'Tap for substitutions, long press for brand recommendations',
              ),
              
              const SizedBox(height: 16),
              
              // Ingredient cards
              SizedBox(
                height: 200,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _sampleIngredients.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final ingredient = _sampleIngredients[index];
                    return IngredientCard(
                      ingredient: ingredient,
                      amount: _amount,
                      unit: _unit,
                      onTap: () => _showSubstitutions(ingredient.name),
                      onLongPress: () => _showBrandRecommendations(ingredient.name),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Measurement converter
              _buildSectionHeader(
                'Measurement Converter',
                'Swipe to change units with haptic feedback',
              ),
              
              const SizedBox(height: 16),
              
              MeasurementSelector(
                amount: _amount,
                currentUnit: _unit,
                onChanged: (amount, unit) {
                  setState(() {
                    _amount = amount;
                    _unit = unit;
                  });
                },
              ),
              
              const SizedBox(height: 32),
              
              // Cost estimation demo
              _buildSectionHeader(
                'Cost Estimation',
                'Real-time cost calculation for cocktail ingredients',
              ),
              
              const SizedBox(height: 16),
              
              _buildCostEstimationDemo(),
              
              const SizedBox(height: 32),
              
              // Action buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: AppColors.champagneGold,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: AppColors.champagneGold.withOpacity(0.7),
            fontSize: 14,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildCostEstimationDemo() {
    final calculator = CostCalculator();
    double totalCost = 0.0;
    
    for (final ingredient in _sampleIngredients) {
      totalCost += calculator.calculatePourCost(
        ingredient.name,
        _amount,
        _unit,
        tier: ingredient.tier,
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.smokyGlass.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.champagneGold.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Cocktail Cost Estimate:',
                style: TextStyle(
                  color: AppColors.champagneGold,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '\$${totalCost.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppColors.warmCopper,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...(_sampleIngredients.map((ingredient) {
            final cost = calculator.calculatePourCost(
              ingredient.name,
              _amount,
              _unit,
              tier: ingredient.tier,
            );
            
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${ingredient.name} (${_amount.toStringAsFixed(1)} ${_unit.displayName})',
                    style: TextStyle(
                      color: AppColors.champagneGold.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '\$${cost.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: AppColors.citrusGlow.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          })),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: CupertinoButton(
            color: AppColors.deepBitters.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
            onPressed: () => _showSubstitutions('tequila'),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.arrow_2_squarepath, size: 20),
                SizedBox(width: 8),
                Text(
                  'Show Substitution Options',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        SizedBox(
          width: double.infinity,
          child: CupertinoButton(
            color: AppColors.richWhiskey.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
            onPressed: () => _showBrandRecommendations('tequila'),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.star_circle, size: 20),
                SizedBox(width: 8),
                Text(
                  'Show Brand Recommendations',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showSubstitutions(String ingredientName) {
    SubstitutionSheet.show(
      context,
      ingredientName,
      onSubstitutionSelected: (substitution) {
        Navigator.of(context).pop();
        _showSuccessMessage('Selected: ${substitution.ingredient.name}');
      },
    );
  }

  void _showBrandRecommendations(String ingredientName) {
    BrandRecommendations.show(
      context,
      ingredientName,
      budget: BudgetLevel.mid,
      onBrandSelected: (brand) {
        Navigator.of(context).pop();
        _showSuccessMessage('Selected: ${brand.name}');
      },
    );
  }

  void _showSuccessMessage(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Selection Made'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}