import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../../../theme/ios_theme.dart';
import '../../../shared/widgets/section_preview.dart';
import '../../../shared/widgets/method_card.dart';

class RecipeScreen extends StatefulWidget {
  final Map<String, dynamic> recipeData;
  
  const RecipeScreen({super.key, required this.recipeData});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> with TickerProviderStateMixin {
  String? _expandedSection;
  final Map<int, bool> _stepCompletion = {};
  final Map<String, bool> _ingredientChecklist = {};
  final Map<String, bool> _equipmentChecklist = {};
  String? _activeStep;
  
  // Image generation state
  final Map<String, String> _methodImages = {};
  final Map<String, bool> _imageLoading = {};
  bool _generatingVisuals = false;
  
  // Animation controllers
  late AnimationController _heroAnimationController;
  late AnimationController _sectionAnimationController;
  
  @override
  void initState() {
    super.initState();
    _heroAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _sectionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Initialize checklists
    _initializeChecklists();
    
    // Parse URL hash for deep linking
    _parseInitialState();
  }
  
  @override
  void dispose() {
    _heroAnimationController.dispose();
    _sectionAnimationController.dispose();
    super.dispose();
  }
  
  void _initializeChecklists() {
    // Initialize step completion
    final steps = widget.recipeData['enhanced_steps'] ?? widget.recipeData['steps'] ?? [];
    if (steps is List) {
      for (int i = 0; i < steps.length; i++) {
        _stepCompletion[i] = false;
      }
    }
    
    // Initialize ingredient checklist
    final ingredients = widget.recipeData['ingredients'] ?? [];
    if (ingredients is List) {
      for (var ingredient in ingredients) {
        if (ingredient is Map && ingredient['name'] != null) {
          _ingredientChecklist[ingredient['name']] = false;
        }
      }
    }
    
    // Initialize equipment checklist
    final equipment = widget.recipeData['equipment_needed'] ?? [];
    if (equipment is List) {
      for (var item in equipment) {
        if (item is Map && item['item'] != null) {
          _equipmentChecklist[item['item']] = false;
        }
      }
    }
  }
  
  void _parseInitialState() {
    // In a real app, you'd parse the URL hash here
    // For now, we'll just set initial state
  }
  
  Future<void> _generateMethodImages() async {
    setState(() {
      _generatingVisuals = true;
    });
    
    try {
      final steps = widget.recipeData['enhanced_steps'] ?? widget.recipeData['steps'] ?? [];
      
      if (steps is List) {
        for (int i = 0; i < steps.length; i++) {
          final step = steps[i];
          final stepText = step is Map ? step['action'] ?? step.toString() : step.toString();
          
          setState(() {
            _imageLoading['step_$i'] = true;
          });
          
          try {
            final response = await http.post(
              Uri.parse('http://127.0.0.1:8081/generate_method_image'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'step_text': stepText,
                'drink_name': widget.recipeData['drink_name'] ?? 'Cocktail',
                'ingredients': widget.recipeData['ingredients'] ?? [],
              }),
            );
            
            if (response.statusCode == 200) {
              final data = jsonDecode(response.body);
              setState(() {
                _methodImages['step_$i'] = data['image_url'] ?? '';
                _imageLoading['step_$i'] = false;
              });
            } else {
              setState(() {
                _imageLoading['step_$i'] = false;
              });
            }
          } catch (e) {
            setState(() {
              _imageLoading['step_$i'] = false;
            });
            debugPrint('Error generating image for step $i: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Error generating method images: $e');
    } finally {
      setState(() {
        _generatingVisuals = false;
      });
    }
  }
  
  void _toggleSection(String section) {
    setState(() {
      if (_expandedSection == section) {
        _expandedSection = null;
      } else {
        _expandedSection = section;
      }
    });
  }
  
  void _toggleStepCompletion(int stepIndex) {
    setState(() {
      _stepCompletion[stepIndex] = !(_stepCompletion[stepIndex] ?? false);
    });
  }
  
  void _toggleIngredientCheck(String ingredient) {
    setState(() {
      _ingredientChecklist[ingredient] = !(_ingredientChecklist[ingredient] ?? false);
    });
  }
  
  void _toggleEquipmentCheck(String equipment) {
    setState(() {
      _equipmentChecklist[equipment] = !(_equipmentChecklist[equipment] ?? false);
    });
  }
  
  double get _overallProgress {
    if (_stepCompletion.isEmpty) return 0.0;
    final completed = _stepCompletion.values.where((v) => v).length;
    return completed / _stepCompletion.length;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          widget.recipeData['drink_name'] ?? 'Recipe',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1C1C1E),
        border: const Border(),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: const Icon(CupertinoIcons.back, color: Colors.white),
        ),
      ),
      backgroundColor: const Color(0xFF1C1C1E),
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Hero Section
            SliverToBoxAdapter(
              child: _buildHeroSection(),
            ),
            
            // Progress Indicator
            SliverToBoxAdapter(
              child: _buildProgressSection(),
            ),
            
            // Section Previews (they handle their own expansion)
            SliverToBoxAdapter(
              child: _buildSectionPreviews(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeroSection() {
    return Container(
      height: 400,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2C2C2E),
            Color(0xFF1C1C1E),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Hero Image
          if (widget.recipeData['drink_image_url'] != null)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.recipeData['drink_image_url'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFF2C2C2E),
                      child: const Icon(
                        CupertinoIcons.photo,
                        size: 64,
                        color: Color(0xFF8E8E93),
                      ),
                    );
                  },
                ),
              ),
            ),
          
          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),
          
          // Content
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.recipeData['drink_name'] ?? 'Cocktail',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatBadge(
                      '${widget.recipeData['preparation_time_minutes'] ?? 0} min',
                      CupertinoIcons.clock,
                    ),
                    const SizedBox(width: 12),
                    _buildStatBadge(
                      '${((widget.recipeData['alcohol_content'] ?? 0.0) * 100).toInt()}% ABV',
                      CupertinoIcons.drop,
                    ),
                    const SizedBox(width: 12),
                    _buildStatBadge(
                      'Level ${widget.recipeData['difficulty_rating'] ?? 1}',
                      CupertinoIcons.star,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CupertinoButton(
                  onPressed: _generatingVisuals ? null : _generateMethodImages,
                  color: iOSTheme.whiskey,
                  borderRadius: BorderRadius.circular(8),
                  child: _generatingVisuals
                      ? const CupertinoActivityIndicator(color: Colors.white)
                      : const Text('Generate Visuals'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatBadge(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProgressSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: _overallProgress,
            backgroundColor: const Color(0xFF3A3A3C),
            valueColor: AlwaysStoppedAnimation<Color>(iOSTheme.whiskey),
          ),
          const SizedBox(height: 8),
          Text(
            '${(_overallProgress * 100).toInt()}% Complete',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF8E8E93),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionPreviews() {
    return Column(
      children: [
        _buildSectionPreview(
          'ingredients',
          'Ingredients',
          CupertinoIcons.cube_box,
          _buildIngredientsPreview(),
          (widget.recipeData['ingredients'] as List?)?.length ?? 0,
          _ingredientChecklist.values.where((v) => v).length,
        ),
        _buildSectionPreview(
          'method',
          'Method',
          CupertinoIcons.list_bullet,
          _buildMethodPreview(),
          _stepCompletion.length,
          _stepCompletion.values.where((v) => v).length,
        ),
        _buildSectionPreview(
          'equipment',
          'Equipment',
          CupertinoIcons.wrench,
          _buildEquipmentPreview(),
          (widget.recipeData['equipment_needed'] as List?)?.length ?? 0,
          _equipmentChecklist.values.where((v) => v).length,
        ),
        _buildSectionPreview(
          'variations',
          'Variations',
          CupertinoIcons.shuffle,
          _buildVariationsPreview(),
          (widget.recipeData['suggested_variations'] as List?)?.length ?? 0,
          0,
        ),
      ],
    );
  }
  
  Widget _buildSectionPreview(
    String sectionKey,
    String title,
    IconData icon,
    Widget previewContent,
    int totalItems,
    int completedItems,
  ) {
    final isExpanded = _expandedSection == sectionKey;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: SectionPreview(
        title: title,
        icon: icon,
        previewContent: previewContent,
        expandedContent: _buildSectionContent(sectionKey),
        totalItems: totalItems,
        completedItems: completedItems,
        expanded: isExpanded,
        onOpen: () => _toggleSection(sectionKey),
        onClose: () => _toggleSection(sectionKey),
      ),
    );
  }
  
  Widget _buildIngredientsPreview() {
    final ingredients = widget.recipeData['ingredients'] as List? ?? [];
    final displayIngredients = ingredients.take(4).toList();
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: displayIngredients.map((ingredient) {
        if (ingredient is Map) {
          final name = ingredient['name'] ?? '';
          final isChecked = _ingredientChecklist[name] ?? false;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isChecked ? iOSTheme.whiskey.withOpacity(0.2) : const Color(0xFF3A3A3C),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              name,
              style: TextStyle(
                fontSize: 12,
                color: isChecked ? iOSTheme.whiskey : const Color(0xFF8E8E93),
                fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      }).toList(),
    );
  }
  
  Widget _buildMethodPreview() {
    final steps = widget.recipeData['enhanced_steps'] ?? widget.recipeData['steps'] ?? [];
    if (steps is List && steps.isNotEmpty) {
      final firstStep = steps[0];
      final stepText = firstStep is Map ? firstStep['action'] ?? firstStep.toString() : firstStep.toString();
      
      return Text(
        stepText,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF8E8E93),
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }
    return const Text(
      'No method steps available',
      style: TextStyle(
        fontSize: 14,
        color: Color(0xFF8E8E93),
      ),
    );
  }
  
  Widget _buildEquipmentPreview() {
    final equipment = widget.recipeData['equipment_needed'] as List? ?? [];
    final displayEquipment = equipment.take(3).toList();
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: displayEquipment.map((item) {
        if (item is Map) {
          final name = item['item'] ?? '';
          final isChecked = _equipmentChecklist[name] ?? false;
          final isEssential = item['essential'] ?? false;
          
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isChecked ? iOSTheme.whiskey.withOpacity(0.2) : const Color(0xFF3A3A3C),
              borderRadius: BorderRadius.circular(6),
              border: isEssential ? Border.all(color: iOSTheme.whiskey.withOpacity(0.5), width: 1) : null,
            ),
            child: Text(
              name,
              style: TextStyle(
                fontSize: 12,
                color: isChecked ? iOSTheme.whiskey : const Color(0xFF8E8E93),
                fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      }).toList(),
    );
  }
  
  Widget _buildVariationsPreview() {
    final variations = widget.recipeData['suggested_variations'] as List? ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: variations.take(2).map((variation) {
        if (variation is Map) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.arrow_right,
                  size: 12,
                  color: Color(0xFF8E8E93),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    variation['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      }).toList(),
    );
  }
  
  
  Widget _buildSectionContent([String? sectionKey]) {
    final section = sectionKey ?? _expandedSection;
    switch (section) {
      case 'ingredients':
        return _buildIngredientsSection();
      case 'method':
        return _buildMethodSection();
      case 'equipment':
        return _buildEquipmentSection();
      case 'variations':
        return _buildVariationsSection();
      default:
        return const SizedBox.shrink();
    }
  }
  
  Widget _buildIngredientsSection() {
    final ingredients = widget.recipeData['ingredients'] as List? ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...ingredients.map((ingredient) {
          if (ingredient is Map) {
            final name = ingredient['name'] ?? '';
            final quantity = ingredient['quantity'] ?? '';
            final isChecked = _ingredientChecklist[name] ?? false;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: CupertinoButton(
                padding: const EdgeInsets.all(12),
                color: const Color(0xFF3A3A3C),
                borderRadius: BorderRadius.circular(8),
                onPressed: () => _toggleIngredientCheck(name),
                child: Row(
                  children: [
                    Icon(
                      isChecked ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.circle,
                      color: isChecked ? iOSTheme.whiskey : const Color(0xFF8E8E93),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isChecked ? iOSTheme.whiskey : Colors.white,
                              decoration: isChecked ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          Text(
                            quantity,
                            style: TextStyle(
                              fontSize: 14,
                              color: isChecked ? iOSTheme.whiskey.withOpacity(0.7) : const Color(0xFF8E8E93),
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
          return const SizedBox.shrink();
        }).toList(),
      ],
    );
  }
  
  Widget _buildMethodSection() {
    final steps = widget.recipeData['enhanced_steps'] ?? widget.recipeData['steps'] ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (steps is List)
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final stepText = step is Map ? step['action'] ?? step.toString() : step.toString();
            final isCompleted = _stepCompletion[index] ?? false;
            final isLoading = _imageLoading['step_$index'] ?? false;
            final imageUrl = _methodImages['step_$index'];
            
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: MethodCard(
                data: MethodCardData(
                  stepNumber: index + 1,
                  title: 'Step ${index + 1}',
                  description: stepText,
                  imageUrl: imageUrl,
                  imageAlt: 'Step ${index + 1} illustration',
                  isCompleted: isCompleted,
                  duration: step is Map ? (step['timing_guidance'] ?? '2-3 minutes') : '2-3 minutes',
                  difficulty: 'Medium',
                  proTip: step is Map ? step['technique_detail'] : null,
                ),
                state: isLoading ? MethodCardState.loading : 
                       isCompleted ? MethodCardState.completed : 
                       _activeStep == 'step_$index' ? MethodCardState.active : 
                       MethodCardState.defaultState,
                onCompleted: () => _toggleStepCompletion(index),
                onCheckboxChanged: (completed) => _toggleStepCompletion(index),
              ),
            );
          }).toList(),
      ],
    );
  }
  
  Widget _buildEquipmentSection() {
    final equipment = widget.recipeData['equipment_needed'] as List? ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...equipment.map((item) {
          if (item is Map) {
            final name = item['item'] ?? '';
            final isEssential = item['essential'] ?? false;
            final isChecked = _equipmentChecklist[name] ?? false;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: CupertinoButton(
                padding: const EdgeInsets.all(12),
                color: const Color(0xFF3A3A3C),
                borderRadius: BorderRadius.circular(8),
                onPressed: () => _toggleEquipmentCheck(name),
                child: Row(
                  children: [
                    Icon(
                      isChecked ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.circle,
                      color: isChecked ? iOSTheme.whiskey : const Color(0xFF8E8E93),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isChecked ? iOSTheme.whiskey : Colors.white,
                          decoration: isChecked ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                    if (isEssential)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: iOSTheme.whiskey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'ESSENTIAL',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: iOSTheme.whiskey,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }).toList(),
      ],
    );
  }
  
  Widget _buildVariationsSection() {
    final variations = widget.recipeData['suggested_variations'] as List? ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...variations.map((variation) {
          if (variation is Map) {
            final name = variation['name'] ?? '';
            final description = variation['description'] ?? '';
            final changes = variation['changes'] as List? ?? [];
            
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A3C),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                  if (changes.isNotEmpty) ..[
                    const SizedBox(height: 12),
                    const Text(
                      'Changes:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...changes.map((change) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '•',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF8E8E93),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                change.toString(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF8E8E93),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }).toList(),
      ],
    );
  }
}