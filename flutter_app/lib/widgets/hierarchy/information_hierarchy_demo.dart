import 'package:flutter/material.dart';
import '../layout/tiered_layout_builder.dart';
import '../progress/smart_progress_bar.dart';
import '../collapsible/collapsible_section.dart';
import '../scroll/scroll_aware_visibility.dart';
import '../../services/focus_mode_controller.dart';
import '../../services/tip_provider.dart';

/// Demonstration of the complete Information Hierarchy Redesign system
/// showcasing the three-tier layout with all integrated components
class InformationHierarchyDemo extends StatefulWidget {
  const InformationHierarchyDemo({super.key});

  @override
  State<InformationHierarchyDemo> createState() => _InformationHierarchyDemoState();
}

class _InformationHierarchyDemoState extends State<InformationHierarchyDemo> {
  int _currentStep = 2;
  late List<RecipeStep> _recipeSteps;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize services
    FocusModeController.instance.initialize();
    TipProvider.instance.initialize();
    
    // Create sample recipe steps
    _recipeSteps = [
      const RecipeStep(
        stepNumber: 1,
        title: 'Prepare Glass',
        description: 'Chill a coupe glass in the freezer for 10 minutes',
        estimatedTime: Duration(seconds: 30),
        type: RecipeStepType.preparation,
        tip: 'A chilled glass keeps your cocktail colder longer',
      ),
      const RecipeStep(
        stepNumber: 2,
        title: 'Add Ingredients',
        description: 'Add gin, lemon juice, and simple syrup to shaker',
        estimatedTime: Duration(seconds: 45),
        type: RecipeStepType.preparation,
        tip: 'Measure ingredients precisely for consistent results',
      ),
      const RecipeStep(
        stepNumber: 3,
        title: 'Add Ice',
        description: 'Fill shaker with fresh ice cubes',
        estimatedTime: Duration(seconds: 15),
        type: RecipeStepType.preparation,
        tip: 'Use large, clear ice cubes for slower dilution',
      ),
      const RecipeStep(
        stepNumber: 4,
        title: 'Shake',
        description: 'Shake vigorously for 10-15 seconds',
        estimatedTime: Duration(seconds: 15),
        type: RecipeStepType.shaking,
        tip: 'Shake until the shaker is frosty cold to the touch',
      ),
      const RecipeStep(
        stepNumber: 5,
        title: 'Strain',
        description: 'Double strain into the chilled glass',
        estimatedTime: Duration(seconds: 20),
        type: RecipeStepType.straining,
        tip: 'Double straining removes ice chips for a silky texture',
      ),
      const RecipeStep(
        stepNumber: 6,
        title: 'Garnish',
        description: 'Express lemon peel oils and drop into glass',
        estimatedTime: Duration(seconds: 30),
        type: RecipeStepType.garnishing,
        tip: 'Give the peel a firm squeeze to express the oils',
      ),
    ];
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Information Hierarchy'),
        backgroundColor: const Color(0xFFB8860B),
        foregroundColor: Colors.white,
        actions: [
          FocusModeToggle(
            style: FocusToggleStyle.icon,
            showLabel: false,
          ),
        ],
      ),
      body: FocusModeGestureDetector(
        child: TieredLayoutBuilder(
          heroZone: _buildHeroZone(),
          actionZone: _buildActionZone(),
          discoveryZone: _buildDiscoveryZone(),
          onFocusModeChanged: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  FocusModeController.instance.isFocusMode 
                      ? 'Focus mode enabled - distractions hidden'
                      : 'Focus mode disabled - all content visible',
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
      ),
      floatingActionButton: _buildFloatingButtons(),
    );
  }
  
  Widget _buildHeroZone() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFB8860B).withOpacity(0.1),
            const Color(0xFF87A96B).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Hero content with scroll-aware animations
          Expanded(
            flex: 3,
            child: ScrollAwareContainer(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated cocktail illustration
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB8860B).withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFB8860B),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.local_bar,
                        size: 60,
                        color: Color(0xFFB8860B),
                      ),
                    ).animateOnScroll(
                      animationType: AnimationType.scaleIn,
                      scaleFrom: 0.5,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Recipe title
                    Text(
                      'Classic Gin Sour',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFB8860B),
                      ),
                      textAlign: TextAlign.center,
                    ).animateOnScroll(
                      animationType: AnimationType.slideAndFade,
                      slideOffset: const Offset(0, 30),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Recipe description
                    Text(
                      'A refreshing balance of botanicals, citrus, and sweetness',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ).animateOnScroll(
                      animationType: AnimationType.fadeIn,
                      triggerOffset: 150,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Ingredient flow animation area
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildIngredientFlow(),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildIngredientFlow() {
    final ingredients = [
      {'name': 'Gin', 'amount': '2 oz', 'color': const Color(0xFF4CAF50)},
      {'name': 'Lemon', 'amount': '0.75 oz', 'color': const Color(0xFFFFEB3B)},
      {'name': 'Syrup', 'amount': '0.5 oz', 'color': const Color(0xFFFF9800)},
    ];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: ingredients.asMap().entries.map((entry) {
        final index = entry.key;
        final ingredient = entry.value;
        
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (ingredient['color'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (ingredient['color'] as Color).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: ingredient['color'] as Color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.scatter_plot,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                ingredient['name'] as String,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                ingredient['amount'] as String,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ).animateOnScroll(
          animationType: AnimationType.slideAndFade,
          slideOffset: Offset(0, 20 + (index * 10)),
          triggerOffset: 200,
        );
      }).toList(),
    );
  }
  
  Widget _buildActionZone() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Smart progress bar
          Expanded(
            flex: 3,
            child: SmartProgressBar(
              steps: _recipeSteps,
              currentStep: _currentStep,
              showTips: true,
              showTiming: true,
              onStepTapped: (step) {
                setState(() {
                  _currentStep = step;
                });
              },
              onComplete: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🍹 Cocktail complete! Enjoy responsibly.'),
                    backgroundColor: Color(0xFF87A96B),
                  ),
                );
              },
            ).scrollAware(visibilityThreshold: 0.3),
          ),
          
          const SizedBox(height: 16),
          
          // Action buttons
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _currentStep > 0 ? () {
                      setState(() {
                        _currentStep--;
                      });
                    } : null,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Previous'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF87A96B),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _currentStep < _recipeSteps.length ? () {
                      setState(() {
                        _currentStep++;
                      });
                    } : null,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Next'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB8860B),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDiscoveryZone() {
    return FocusModeAware(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Recipe details section
            RecipeDetailSection(
              title: 'Recipe Details',
              icon: Icons.info_outline,
              initiallyExpanded: false,
              items: [
                const DetailItem(
                  label: 'Difficulty',
                  value: 'Beginner',
                  icon: Icons.star,
                  color: Color(0xFF4CAF50),
                ),
                const DetailItem(
                  label: 'Time',
                  value: '3 minutes',
                  icon: Icons.timer,
                ),
                const DetailItem(
                  label: 'Glass',
                  value: 'Coupe',
                  icon: Icons.wine_bar,
                ),
                const DetailItem(
                  label: 'Method',
                  value: 'Shake & Strain',
                  icon: Icons.sports_bar,
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Variations section
            CollapsibleSection(
              title: 'Variations',
              preferenceKey: 'recipe_variations',
              leading: const Icon(
                Icons.auto_awesome,
                color: Color(0xFFB8860B),
                size: 20,
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildVariationCard(
                    'Whiskey Sour',
                    'Replace gin with bourbon whiskey',
                    Icons.local_bar,
                  ),
                  const SizedBox(height: 8),
                  _buildVariationCard(
                    'Vodka Sour',
                    'Replace gin with premium vodka',
                    Icons.local_drink,
                  ),
                  const SizedBox(height: 8),
                  _buildVariationCard(
                    'Amaretto Sour',
                    'Replace gin with amaretto liqueur',
                    Icons.wine_bar,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Tips & techniques section
            CollapsibleSection(
              title: 'Pro Tips',
              preferenceKey: 'recipe_tips',
              leading: const Icon(
                Icons.lightbulb_outline,
                color: Color(0xFFB8860B),
                size: 20,
              ),
              content: Column(
                children: [
                  TipDisplay(
                    tip: TipProvider.instance.getTipForStep(_recipeSteps[_currentStep.clamp(0, _recipeSteps.length - 1)]),
                    category: TipCategory.technique,
                    showDismissButton: false,
                  ),
                  const SizedBox(height: 12),
                  TipDisplay(
                    tip: 'Always use fresh citrus juice for the best flavor',
                    category: TipCategory.ingredient,
                    showDismissButton: false,
                  ),
                  const SizedBox(height: 12),
                  TipDisplay(
                    tip: 'Chill your glass beforehand for optimal temperature',
                    category: TipCategory.serving,
                    showDismissButton: false,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Troubleshooting section
            CollapsibleSection(
              title: 'Troubleshooting',
              preferenceKey: 'recipe_troubleshooting',
              leading: const Icon(
                Icons.build,
                color: Color(0xFFB8860B),
                size: 20,
              ),
              content: Column(
                children: [
                  _buildTroubleshootingItem(
                    'Too sour?',
                    'Add a small amount of simple syrup',
                  ),
                  _buildTroubleshootingItem(
                    'Too sweet?',
                    'Add a few drops of fresh lemon juice',
                  ),
                  _buildTroubleshootingItem(
                    'Too weak?',
                    'Use less ice or shake for less time',
                  ),
                  _buildTroubleshootingItem(
                    'Cloudy appearance?',
                    'Double strain through a fine mesh',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildVariationCard(String title, String description, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF87A96B).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF87A96B).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF87A96B),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF87A96B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTroubleshootingItem(String problem, String solution) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              color: Color(0xFFFF5722),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodySmall,
                children: [
                  TextSpan(
                    text: problem,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: solution,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFloatingButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Focus mode FAB
        FloatingActionButton(
          heroTag: 'focus',
          onPressed: () {
            FocusModeController.instance.toggleFocusMode();
          },
          backgroundColor: const Color(0xFFB8860B),
          child: AnimatedBuilder(
            animation: FocusModeController.instance,
            builder: (context, child) {
              return Icon(
                FocusModeController.instance.isFocusMode 
                    ? Icons.visibility_off 
                    : Icons.center_focus_strong,
                color: Colors.white,
              );
            },
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Tutorial FAB
        AnimatedBuilder(
          animation: FocusModeController.instance,
          builder: (context, child) {
            if (!FocusModeController.instance.showTutorial) {
              return FloatingActionButton(
                heroTag: 'tutorial',
                onPressed: () {
                  FocusModeController.instance.resetTutorial();
                  _showTutorial();
                },
                backgroundColor: const Color(0xFF87A96B),
                child: const Icon(
                  Icons.help_outline,
                  color: Colors.white,
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
  
  void _showTutorial() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => FocusModeTutorial(
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }
}

/// Extension for easy hierarchy demo navigation
extension InformationHierarchyDemoExtensions on BuildContext {
  /// Show the information hierarchy demo
  void showInformationHierarchyDemo() {
    Navigator.of(this).push(
      MaterialPageRoute(
        builder: (context) => const InformationHierarchyDemo(),
      ),
    );
  }
}