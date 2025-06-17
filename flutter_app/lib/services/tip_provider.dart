import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/progress/smart_progress_bar.dart';
import 'dart:math';

/// Data model for cocktail ingredients
class Ingredient {
  final String name;
  final String category;
  final double amount;
  final String unit;
  final bool isOptional;
  final String? brand;
  final String? preparation;
  
  const Ingredient({
    required this.name,
    required this.category,
    required this.amount,
    required this.unit,
    this.isOptional = false,
    this.brand,
    this.preparation,
  });
}

/// Categories for tip types
enum TipCategory {
  technique,
  ingredient,
  equipment,
  timing,
  temperature,
  garnish,
  serving,
  safety,
  substitution,
  troubleshooting,
}

/// Individual tip data model
class CocktailTip {
  final String id;
  final String content;
  final TipCategory category;
  final List<String> keywords;
  final int priority;
  final String? imageUrl;
  final Duration? relevantTiming;
  final bool isDismissible;
  
  const CocktailTip({
    required this.id,
    required this.content,
    required this.category,
    required this.keywords,
    this.priority = 1,
    this.imageUrl,
    this.relevantTiming,
    this.isDismissible = true,
  });
}

/// Contextual tip engine that provides smart, relevant tips based on
/// current step, ingredients, and user preferences
class TipProvider {
  static TipProvider? _instance;
  static TipProvider get instance => _instance ??= TipProvider._();
  
  TipProvider._();
  
  final Map<String, bool> _dismissedTips = {};
  final List<CocktailTip> _tipDatabase = [];
  bool _isInitialized = false;
  
  /// Initialize the tip provider with database and user preferences
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _loadTipDatabase();
    await _loadUserPreferences();
    _isInitialized = true;
  }
  
  /// Get the most relevant tip for the current recipe step
  String getTipForStep(RecipeStep step) {
    final relevantTips = _getTipsForStep(step);
    if (relevantTips.isEmpty) return _getGenericTipForStepType(step.type);
    
    // Filter out dismissed tips
    final availableTips = relevantTips
        .where((tip) => !_dismissedTips.containsKey(tip.id))
        .toList();
    
    if (availableTips.isEmpty) return _getGenericTipForStepType(step.type);
    
    // Sort by priority and select the best one
    availableTips.sort((a, b) => b.priority.compareTo(a.priority));
    return availableTips.first.content;
  }
  
  /// Get tips specific to an ingredient
  List<String> getIngredientTips(Ingredient ingredient) {
    final tips = _tipDatabase
        .where((tip) => 
            tip.category == TipCategory.ingredient &&
            tip.keywords.any((keyword) => 
                ingredient.name.toLowerCase().contains(keyword.toLowerCase()) ||
                ingredient.category.toLowerCase().contains(keyword.toLowerCase())))
        .where((tip) => !_dismissedTips.containsKey(tip.id))
        .map((tip) => tip.content)
        .toList();
    
    if (tips.isEmpty) {
      return _getGenericIngredientTips(ingredient);
    }
    
    return tips;
  }
  
  /// Get equipment-specific tips
  List<String> getEquipmentTips(String equipment) {
    final tips = _tipDatabase
        .where((tip) => 
            tip.category == TipCategory.equipment &&
            tip.keywords.any((keyword) => 
                equipment.toLowerCase().contains(keyword.toLowerCase())))
        .where((tip) => !_dismissedTips.containsKey(tip.id))
        .map((tip) => tip.content)
        .toList();
    
    return tips.isNotEmpty ? tips : _getGenericEquipmentTips(equipment);
  }
  
  /// Get technique-specific tips
  List<String> getTechniqueTips(String technique) {
    final tips = _tipDatabase
        .where((tip) => 
            tip.category == TipCategory.technique &&
            tip.keywords.any((keyword) => 
                technique.toLowerCase().contains(keyword.toLowerCase())))
        .where((tip) => !_dismissedTips.containsKey(tip.id))
        .map((tip) => tip.content)
        .toList();
    
    return tips.isNotEmpty ? tips : _getGenericTechniqueTips(technique);
  }
  
  /// Get tips for troubleshooting common issues
  List<String> getTroubleshootingTips(String issue) {
    final tips = _tipDatabase
        .where((tip) => 
            tip.category == TipCategory.troubleshooting &&
            tip.keywords.any((keyword) => 
                issue.toLowerCase().contains(keyword.toLowerCase())))
        .where((tip) => !_dismissedTips.containsKey(tip.id))
        .map((tip) => tip.content)
        .toList();
    
    return tips.isNotEmpty ? tips : _getGenericTroubleshootingTips(issue);
  }
  
  /// Get tips by category
  List<CocktailTip> getTipsByCategory(TipCategory category) {
    return _tipDatabase
        .where((tip) => tip.category == category)
        .where((tip) => !_dismissedTips.containsKey(tip.id))
        .toList();
  }
  
  /// Get a random tip from available tips
  String getRandomTip([TipCategory? category]) {
    var availableTips = _tipDatabase
        .where((tip) => !_dismissedTips.containsKey(tip.id))
        .toList();
    
    if (category != null) {
      availableTips = availableTips
          .where((tip) => tip.category == category)
          .toList();
    }
    
    if (availableTips.isEmpty) return _getGenericRandomTip();
    
    final random = Random();
    return availableTips[random.nextInt(availableTips.length)].content;
  }
  
  /// Dismiss a tip so it won't show again
  Future<void> dismissTip(String tipId) async {
    _dismissedTips[tipId] = true;
    await _saveUserPreferences();
  }
  
  /// Reset all dismissed tips
  Future<void> resetDismissedTips() async {
    _dismissedTips.clear();
    await _saveUserPreferences();
  }
  
  /// Check if a tip has been dismissed
  bool isTipDismissed(String tipId) {
    return _dismissedTips.containsKey(tipId);
  }
  
  // Private helper methods
  
  List<CocktailTip> _getTipsForStep(RecipeStep step) {
    return _tipDatabase.where((tip) {
      // Match by step type
      if (tip.category == TipCategory.technique) {
        return tip.keywords.any((keyword) => 
            _getStepTypeKeywords(step.type).contains(keyword.toLowerCase()));
      }
      
      // Match by timing
      if (tip.relevantTiming != null) {
        final timeDiff = (step.estimatedTime.inSeconds - tip.relevantTiming!.inSeconds).abs();
        return timeDiff <= 30; // Within 30 seconds
      }
      
      // Match by keywords in description
      return tip.keywords.any((keyword) => 
          step.description.toLowerCase().contains(keyword.toLowerCase()));
    }).toList();
  }
  
  List<String> _getStepTypeKeywords(RecipeStepType type) {
    switch (type) {
      case RecipeStepType.preparation:
        return ['prep', 'prepare', 'setup', 'measure'];
      case RecipeStepType.mixing:
        return ['mix', 'combine', 'blend'];
      case RecipeStepType.shaking:
        return ['shake', 'shaker', 'ice'];
      case RecipeStepType.stirring:
        return ['stir', 'bar spoon', 'gentle'];
      case RecipeStepType.straining:
        return ['strain', 'strainer', 'fine', 'double'];
      case RecipeStepType.garnishing:
        return ['garnish', 'twist', 'peel', 'cherry'];
      case RecipeStepType.serving:
        return ['serve', 'glass', 'present', 'temperature'];
    }
  }
  
  String _getGenericTipForStepType(RecipeStepType type) {
    switch (type) {
      case RecipeStepType.preparation:
        return 'Measure ingredients precisely for consistent results.';
      case RecipeStepType.mixing:
        return 'Combine ingredients gently to preserve carbonation.';
      case RecipeStepType.shaking:
        return 'Shake vigorously for 10-15 seconds to properly chill and dilute.';
      case RecipeStepType.stirring:
        return 'Stir smoothly in one direction to avoid creating air bubbles.';
      case RecipeStepType.straining:
        return 'Use a fine strainer to remove ice chips and fruit pulp.';
      case RecipeStepType.garnishing:
        return 'Express citrus oils over the drink before adding the garnish.';
      case RecipeStepType.serving:
        return 'Serve immediately while the drink is perfectly chilled.';
    }
  }
  
  List<String> _getGenericIngredientTips(Ingredient ingredient) {
    final tips = <String>[];
    
    // Category-based tips
    switch (ingredient.category.toLowerCase()) {
      case 'spirits':
      case 'whiskey':
      case 'bourbon':
      case 'scotch':
        tips.add('Store spirits at room temperature away from direct light.');
        break;
      case 'citrus':
      case 'lemon':
      case 'lime':
        tips.add('Roll citrus on the counter before juicing for maximum yield.');
        break;
      case 'syrup':
      case 'simple syrup':
        tips.add('Simple syrup can be stored in the refrigerator for up to one month.');
        break;
      case 'bitters':
        tips.add('A few dashes of bitters can transform the entire flavor profile.');
        break;
      default:
        tips.add('Use fresh, high-quality ingredients for the best results.');
    }
    
    // Amount-based tips
    if (ingredient.amount > 2) {
      tips.add('This is a primary ingredient - measure carefully for balance.');
    } else if (ingredient.amount < 0.5) {
      tips.add('A little goes a long way - start with less and adjust to taste.');
    }
    
    // Optional ingredient tip
    if (ingredient.isOptional) {
      tips.add('This ingredient is optional but adds complexity to the flavor.');
    }
    
    return tips;
  }
  
  List<String> _getGenericEquipmentTips(String equipment) {
    switch (equipment.toLowerCase()) {
      case 'shaker':
      case 'cocktail shaker':
        return ['Chill your shaker before use for better temperature control.'];
      case 'jigger':
      case 'measuring cup':
        return ['Use a jigger for precise measurements - eyeballing leads to inconsistency.'];
      case 'bar spoon':
        return ['A bar spoon holds about 1/8 oz - useful for small measurements.'];
      case 'strainer':
        return ['Double strain through a fine mesh for silky smooth cocktails.'];
      case 'muddler':
        return ['Press and twist gently - over-muddling releases bitter compounds.'];
      default:
        return ['Keep your bar tools clean and properly maintained.'];
    }
  }
  
  List<String> _getGenericTechniqueTips(String technique) {
    switch (technique.toLowerCase()) {
      case 'shake':
      case 'shaking':
        return ['Shake with confidence - weak shaking leads to weak drinks.'];
      case 'stir':
      case 'stirring':
        return ['Stir spirit-forward cocktails to maintain clarity and texture.'];
      case 'muddle':
      case 'muddling':
        return ['Muddle in the bottom of the shaker to avoid splashing.'];
      case 'strain':
      case 'straining':
        return ['Strain quickly to prevent over-dilution from melting ice.'];
      case 'float':
      case 'floating':
        return ['Pour slowly over the back of a bar spoon for clean layers.'];
      default:
        return ['Practice your technique - consistency comes with repetition.'];
    }
  }
  
  List<String> _getGenericTroubleshootingTips(String issue) {
    switch (issue.toLowerCase()) {
      case 'too sweet':
        return ['Add a splash of citrus or bitters to balance sweetness.'];
      case 'too sour':
        return ['Add a small amount of simple syrup to round out acidity.'];
      case 'too weak':
        return ['Use less ice or shake/stir for a shorter time.'];
      case 'too strong':
        return ['Add a splash of water or extend the shaking time.'];
      case 'cloudy':
        return ['Double strain through a fine mesh to remove particles.'];
      case 'separated':
        return ['Shake more vigorously to properly emulsify ingredients.'];
      default:
        return ['Taste and adjust - great cocktails require fine-tuning.'];
    }
  }
  
  String _getGenericRandomTip() {
    final tips = [
      'Always taste as you go - your palate is your best tool.',
      'Fresh ice makes a noticeable difference in cocktail quality.',
      'Chill your glassware for 10 minutes before serving.',
      'Keep your workspace organized for efficient cocktail making.',
      'Practice your pours - muscle memory leads to consistency.',
      'Quality ingredients are worth the investment.',
      'Clean your tools between different spirits to avoid flavor contamination.',
      'Temperature is just as important as flavor in cocktails.',
    ];
    
    final random = Random();
    return tips[random.nextInt(tips.length)];
  }
  
  void _loadTipDatabase() {
    _tipDatabase.addAll([
      // Technique tips
      const CocktailTip(
        id: 'shake_technique_1',
        content: 'Shake vigorously for 10-15 seconds until the shaker is frosty cold.',
        category: TipCategory.technique,
        keywords: ['shake', 'shaker', 'vigorous'],
        priority: 3,
      ),
      
      const CocktailTip(
        id: 'stir_technique_1',
        content: 'Stir spirit-forward cocktails gently in one direction for 30 seconds.',
        category: TipCategory.technique,
        keywords: ['stir', 'spirit', 'gentle'],
        priority: 3,
      ),
      
      const CocktailTip(
        id: 'muddle_technique_1',
        content: 'Press and twist when muddling - don\'t pulverize or bitter compounds will release.',
        category: TipCategory.technique,
        keywords: ['muddle', 'herbs', 'fruit'],
        priority: 2,
      ),
      
      // Ingredient tips
      const CocktailTip(
        id: 'citrus_freshness_1',
        content: 'Always use fresh citrus juice - bottled juice lacks the bright acidity.',
        category: TipCategory.ingredient,
        keywords: ['lemon', 'lime', 'citrus', 'fresh'],
        priority: 3,
      ),
      
      const CocktailTip(
        id: 'ice_quality_1',
        content: 'Use large, clear ice cubes for slower dilution and better presentation.',
        category: TipCategory.ingredient,
        keywords: ['ice', 'dilution', 'clear'],
        priority: 2,
      ),
      
      const CocktailTip(
        id: 'simple_syrup_1',
        content: 'Make simple syrup with a 1:1 ratio of sugar to water for perfect sweetness.',
        category: TipCategory.ingredient,
        keywords: ['simple syrup', 'sugar', 'sweet'],
        priority: 2,
      ),
      
      // Equipment tips
      const CocktailTip(
        id: 'jigger_precision_1',
        content: 'Use a jigger for all measurements - consistency is key to great cocktails.',
        category: TipCategory.equipment,
        keywords: ['jigger', 'measure', 'precise'],
        priority: 3,
      ),
      
      const CocktailTip(
        id: 'shaker_chill_1',
        content: 'Chill your shaker in the freezer for 10 minutes before making cocktails.',
        category: TipCategory.equipment,
        keywords: ['shaker', 'chill', 'cold'],
        priority: 1,
      ),
      
      // Timing tips
      const CocktailTip(
        id: 'serve_immediately_1',
        content: 'Serve cocktails immediately after preparation for optimal temperature and dilution.',
        category: TipCategory.timing,
        keywords: ['serve', 'immediate', 'temperature'],
        priority: 2,
      ),
      
      // Garnish tips
      const CocktailTip(
        id: 'citrus_express_1',
        content: 'Express citrus peel oils over the drink by giving it a firm squeeze.',
        category: TipCategory.garnish,
        keywords: ['citrus', 'peel', 'express', 'oils'],
        priority: 2,
      ),
      
      // Troubleshooting tips
      const CocktailTip(
        id: 'balance_sweet_1',
        content: 'If too sweet, add a few drops of lemon juice or a dash of bitters.',
        category: TipCategory.troubleshooting,
        keywords: ['sweet', 'balance', 'lemon', 'bitters'],
        priority: 2,
      ),
      
      const CocktailTip(
        id: 'balance_sour_1',
        content: 'If too sour, add a small amount of simple syrup to balance acidity.',
        category: TipCategory.troubleshooting,
        keywords: ['sour', 'balance', 'syrup', 'acid'],
        priority: 2,
      ),
    ]);
  }
  
  Future<void> _loadUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dismissedList = prefs.getStringList('dismissed_tips') ?? [];
      
      _dismissedTips.clear();
      for (final tipId in dismissedList) {
        _dismissedTips[tipId] = true;
      }
    } catch (e) {
      debugPrint('TipProvider: Failed to load user preferences: $e');
    }
  }
  
  Future<void> _saveUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dismissedList = _dismissedTips.keys.toList();
      await prefs.setStringList('dismissed_tips', dismissedList);
    } catch (e) {
      debugPrint('TipProvider: Failed to save user preferences: $e');
    }
  }
}

/// Widget for displaying contextual tips with dismissal functionality
class TipDisplay extends StatefulWidget {
  final String tip;
  final String? tipId;
  final TipCategory category;
  final VoidCallback? onDismiss;
  final EdgeInsets padding;
  final bool showDismissButton;
  
  const TipDisplay({
    super.key,
    required this.tip,
    this.tipId,
    this.category = TipCategory.technique,
    this.onDismiss,
    this.padding = const EdgeInsets.all(12),
    this.showDismissButton = true,
  });

  @override
  State<TipDisplay> createState() => _TipDisplayState();
}

class _TipDisplayState extends State<TipDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _handleDismiss() async {
    if (widget.tipId != null) {
      await TipProvider.instance.dismissTip(widget.tipId!);
    }
    
    await _controller.reverse();
    widget.onDismiss?.call();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              padding: widget.padding,
              decoration: BoxDecoration(
                color: _getCategoryColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getCategoryColor().withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getCategoryIcon(),
                    size: 20,
                    color: _getCategoryColor(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.tip,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _getCategoryColor(),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (widget.showDismissButton) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _handleDismiss,
                      icon: Icon(
                        Icons.close,
                        size: 16,
                        color: _getCategoryColor().withOpacity(0.7),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Color _getCategoryColor() {
    switch (widget.category) {
      case TipCategory.technique:
        return const Color(0xFFB8860B); // Amber
      case TipCategory.ingredient:
        return const Color(0xFF87A96B); // Sage
      case TipCategory.equipment:
        return const Color(0xFF2196F3); // Blue
      case TipCategory.timing:
        return const Color(0xFFFF9800); // Orange
      case TipCategory.temperature:
        return const Color(0xFF00BCD4); // Cyan
      case TipCategory.garnish:
        return const Color(0xFFE91E63); // Pink
      case TipCategory.serving:
        return const Color(0xFF9C27B0); // Purple
      case TipCategory.safety:
        return const Color(0xFFF44336); // Red
      case TipCategory.substitution:
        return const Color(0xFF4CAF50); // Green
      case TipCategory.troubleshooting:
        return const Color(0xFFFF5722); // Deep Orange
    }
  }
  
  IconData _getCategoryIcon() {
    switch (widget.category) {
      case TipCategory.technique:
        return Icons.sports_bar;
      case TipCategory.ingredient:
        return Icons.scatter_plot;
      case TipCategory.equipment:
        return Icons.kitchen;
      case TipCategory.timing:
        return Icons.timer;
      case TipCategory.temperature:
        return Icons.thermostat;
      case TipCategory.garnish:
        return Icons.local_florist;
      case TipCategory.serving:
        return Icons.local_bar;
      case TipCategory.safety:
        return Icons.warning;
      case TipCategory.substitution:
        return Icons.swap_horiz;
      case TipCategory.troubleshooting:
        return Icons.build;
    }
  }
}