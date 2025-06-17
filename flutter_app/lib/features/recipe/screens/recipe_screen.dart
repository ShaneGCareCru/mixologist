import 'dart:async'; // For StreamSubscription
import 'dart:convert'; // For jsonDecode, base64Decode, utf8, LineSplitter
import 'dart:typed_data'; // For Uint8List
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http; // HTTP package
import 'package:shared_preferences/shared_preferences.dart';

// Local imports
import '../../../shared/widgets/drink_progress_glass.dart';
import '../../../shared/widgets/method_card.dart';
import '../../../shared/widgets/section_preview.dart';
import '../../../theme/ios_theme.dart';

class RecipeScreen extends StatefulWidget {
  final Map<String, dynamic> recipeData;
  const RecipeScreen({super.key, required this.recipeData});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  Uint8List? _currentImageBytes;
  String? _imageStreamError;
  bool _isImageStreamComplete = false;
  StreamSubscription<String>? _imageStreamSubscription; // Changed type
  final http.Client _httpClient =
      http.Client(); // HTTP client for streaming request

  // Epic 2: Interactive Recipe Components
  int _servingSize = 1;
  bool _isMetric = false; // false = oz, true = ml
  final Map<String, bool> _ingredientChecklist = {};

  // Epic 3: Visual Recipe Steps
  final Map<int, bool?> _stepCompletion = {};

  // Dynamic Visual Generation System
  final Map<String, Uint8List?> _specializedImages = {};
  Map<String, bool> _imageGenerationProgress = {};
  String _selectedSection = 'overview'; // Navigation state
  String? _expandedSection;
  final Map<int, List<String>> _stepIngredientMap = {};
  final Map<int, List<String>> _stepEquipmentMap = {};
  final Map<String, GlobalKey> _ingredientIconKeys = {};
  final Map<String, GlobalKey> _equipmentIconKeys = {};
  final List<GlobalKey> _stepCardKeys = [];
  int? _hoveredStep;
  bool _isGeneratingVisuals = false;
  bool _isLoadingRelatedCocktail = false;

  DrinkProgress get _currentDrinkProgress {
    // Check if Mise En Place is complete
    if (_stepCompletion[-1] != true) {
      return DrinkProgress.emptyGlass;
    }

    final stepsRaw =
        widget.recipeData['steps'] ?? widget.recipeData['method'] ?? [];
    final steps = stepsRaw is List ? stepsRaw : [];
    int completedRecipeSteps = 0;
    for (int i = 0; i < steps.length; i++) {
      if (_stepCompletion[i] == true) {
        completedRecipeSteps++;
      }
    }
    final totalRecipeSteps = steps.length;

    if (completedRecipeSteps == 0) return DrinkProgress.ingredientsAdded;
    if (completedRecipeSteps < totalRecipeSteps * 0.4)
      return DrinkProgress.ingredientsAdded;
    if (completedRecipeSteps < totalRecipeSteps * 0.8)
      return DrinkProgress.mixed;
    if (completedRecipeSteps < totalRecipeSteps) return DrinkProgress.garnished;
    return DrinkProgress.complete;
  }

  String _getProgressText() {
    // Check if Mise En Place is complete
    if (_stepCompletion[-1] != true) {
      return _getMiseEnPlaceDescription();
    }

    final stepsRaw =
        widget.recipeData['steps'] ?? widget.recipeData['method'] ?? [];
    final steps = stepsRaw is List ? stepsRaw : [];
    if (steps.isEmpty) return 'No steps available';

    // Find the next incomplete step
    int nextStepIndex = -1;
    for (int i = 0; i < steps.length; i++) {
      if (_stepCompletion[i] != true) {
        nextStepIndex = i;
        break;
      }
    }

    if (nextStepIndex == -1) {
      // All recipe steps complete - show flavor profile
      return _getFlavorProfileDescription();
    } else {
      return 'Step ${nextStepIndex + 1}: ${steps[nextStepIndex]}';
    }
  }

  int _getCurrentStepIndex() {
    // Check if Mise En Place is complete
    if (_stepCompletion[-1] != true) {
      return -1; // Mise En Place
    }

    final stepsRaw =
        widget.recipeData['steps'] ?? widget.recipeData['method'] ?? [];
    final steps = stepsRaw is List ? stepsRaw : [];
    if (steps.isEmpty) return -2; // No steps available

    // Find the next incomplete step
    for (int i = 0; i < steps.length; i++) {
      if (_stepCompletion[i] != true) {
        return i;
      }
    }
    return -2; // All steps complete - show flavor profile
  }

  String _getMiseEnPlaceDescription() {
    final ingredientsRaw = widget.recipeData['ingredients'];
    final ingredients = ingredientsRaw is List ? ingredientsRaw : [];
    final glassware = widget.recipeData['serving_glass'] ?? '';
    final equipmentRaw = widget.recipeData['equipment_needed'] ?? [];
    final equipment = equipmentRaw is List ? equipmentRaw : [];

    List<String> allItems = [];

    // Add ingredient names only (no quantities)
    for (var ingredient in ingredients) {
      final name = ingredient['name']?.toString() ?? '';
      if (name.isNotEmpty) {
        allItems.add(name);
      }
    }

    // Add glassware
    if (glassware.isNotEmpty) {
      allItems.add(glassware);
    }

    // Add equipment
    for (var eq in equipment) {
      final equipmentName = eq is Map
          ? (eq['item'] ?? eq['name'] ?? eq.toString())
          : eq.toString();
      if (equipmentName.isNotEmpty) {
        allItems.add(equipmentName);
      }
    }

    if (allItems.isEmpty) {
      return 'Mise En Place - Ready to start!';
    }

    return 'Gather the following: ${allItems.join(', ')}.';
  }

  String _getFlavorProfileDescription() {
    final flavorProfile = widget.recipeData['flavor_profile'] as Map? ?? {};
    if (flavorProfile.isEmpty) {
      return 'Cocktail complete! Enjoy your drink! 🍹';
    }

    String description = 'Tasting Notes - What to expect:\n\n';

    // Primary flavors
    if (flavorProfile['primary_flavors'] is List) {
      final primaryFlavors =
          (flavorProfile['primary_flavors'] as List).join(', ');
      description += 'Primary Flavors: $primaryFlavors\n\n';
    }

    // Secondary notes
    if (flavorProfile['secondary_notes'] is List) {
      final secondaryNotes =
          (flavorProfile['secondary_notes'] as List).join(', ');
      description += 'Secondary Notes: $secondaryNotes\n\n';
    }

    // Mouthfeel
    if (flavorProfile['mouthfeel'] != null) {
      description += 'Mouthfeel: ${flavorProfile['mouthfeel']}\n\n';
    }

    // Finish
    if (flavorProfile['finish'] != null) {
      description += 'Finish: ${flavorProfile['finish']}\n\n';
    }

    // Balance
    if (flavorProfile['balance'] != null) {
      description += 'Balance: ${flavorProfile['balance']}';
    }

    return description.trim();
  }

  void _toggleStepCompleted(int stepIndex, bool? completed) {
    setState(() {
      _stepCompletion[stepIndex] = completed;
    });
    _saveProgress();
  }

  String? _getProTipForStep(String stepText) {
    // Simple pro tip generation based on step content
    final stepLower = stepText.toLowerCase();

    if (stepLower.contains('shake') || stepLower.contains('shaking')) {
      return 'Shake vigorously for 10-15 seconds to properly chill and dilute the drink.';
    } else if (stepLower.contains('stir') || stepLower.contains('stirring')) {
      return 'Stir gently for 20-30 seconds to avoid over-dilution while chilling.';
    } else if (stepLower.contains('strain')) {
      return 'Double strain through a fine mesh strainer for the smoothest texture.';
    } else if (stepLower.contains('garnish')) {
      return 'Express citrus oils over the drink by gently twisting the peel.';
    } else if (stepLower.contains('muddle')) {
      return 'Muddle gently to release oils without creating bitter flavors from over-crushing.';
    }

    return null; // No pro tip for this step
  }

  TipCategory? _getTipCategoryForStep(String stepText) {
    final stepLower = stepText.toLowerCase();

    if (stepLower.contains('shake') ||
        stepLower.contains('shaking') ||
        stepLower.contains('stir') ||
        stepLower.contains('stirring') ||
        stepLower.contains('muddle')) {
      return TipCategory.technique;
    } else if (stepLower.contains('strain')) {
      return TipCategory.equipment;
    } else if (stepLower.contains('garnish') || stepLower.contains('serve')) {
      return TipCategory.presentation;
    } else if (stepLower.contains('chill') ||
        stepLower.contains('temperature')) {
      return TipCategory.timing;
    } else if (stepLower.contains('fresh') || stepLower.contains('quality')) {
      return TipCategory.ingredient;
    }

    return null;
  }

  IconData _getIngredientIcon(String ingredientName) {
    final nameLower = ingredientName.toLowerCase();

    if (nameLower.contains('whiskey') ||
        nameLower.contains('bourbon') ||
        nameLower.contains('scotch')) {
      return Icons.local_bar;
    } else if (nameLower.contains('vodka') ||
        nameLower.contains('gin') ||
        nameLower.contains('rum')) {
      return Icons.local_bar;
    } else if (nameLower.contains('lemon') ||
        nameLower.contains('lime') ||
        nameLower.contains('orange')) {
      return Icons.circle;
    } else if (nameLower.contains('syrup') ||
        nameLower.contains('honey') ||
        nameLower.contains('sugar')) {
      return Icons.water_drop;
    } else if (nameLower.contains('bitters') ||
        nameLower.contains('vermouth')) {
      return Icons.opacity;
    } else if (nameLower.contains('ice') || nameLower.contains('water')) {
      return Icons.ac_unit;
    } else if (nameLower.contains('mint') ||
        nameLower.contains('herb') ||
        nameLower.contains('basil')) {
      return Icons.eco;
    } else if (nameLower.contains('cherry') ||
        nameLower.contains('olive') ||
        nameLower.contains('garnish')) {
      return Icons.circle_outlined;
    } else {
      return Icons.local_grocery_store;
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeIngredientChecklist();
    _initializeSpecializedImages();
    _initializeStepConnections();
    _loadCachedImages(); // Check for existing cached images
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _restoreExpandedFromHash());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Call _connectToImageStream here where MediaQuery is available
    if (!_isImageStreamComplete &&
        _currentImageBytes == null &&
        _imageStreamError == null) {
      _connectToImageStream();
    }
  }

  void _restoreExpandedFromHash() {
    // Placeholder for hash restoration - removed URL dependency for mobile
    // This would be used for deep linking to specific recipe sections
  }

  void _toggleExpandedSection(String id) {
    setState(() {
      if (_expandedSection == id) {
        _expandedSection = null;
      } else {
        _expandedSection = id;

        // Auto-generate ingredient images when ingredients section is expanded
        if (id == 'ingredients') {
          _autoGenerateIngredientImages();
        }
      }
    });
  }

  void _autoGenerateIngredientImages() {
    if (widget.recipeData['ingredients'] is List) {
      for (var ingredient in widget.recipeData['ingredients']) {
        final ingredientName = ingredient['name'];
        final imageKey = 'ingredient_$ingredientName';

        // Only generate if we don't already have the image and aren't currently generating
        if (_specializedImages[imageKey] == null &&
            _imageGenerationProgress[imageKey] != true) {
          _generateSpecializedImage(imageKey, ingredientName,
              context: 'ingredient');
        }
      }
    }
  }

  bool _ingredientActive(String name) {
    if (_hoveredStep == null) return false;
    return _stepIngredientMap[_hoveredStep!]?.contains(name.toLowerCase()) ??
        false;
  }

  bool _equipmentActive(String name) {
    if (_hoveredStep == null) return false;
    return _stepEquipmentMap[_hoveredStep!]?.contains(name.toLowerCase()) ??
        false;
  }

  void _initializeSpecializedImages() {
    _specializedImages.clear();
    _specializedImages.addAll({
      'glassware': null,
      'garnish': null,
    });
    _imageGenerationProgress = {
      'glassware': false,
      'garnish': false,
    };

    // Initialize ingredient images
    final ingredientsRaw = widget.recipeData['ingredients'];
    final ingredientsList = ingredientsRaw is List ? ingredientsRaw : [];
    for (var ingredient in ingredientsList) {
      final ingredientName = ingredient['name'];
      _specializedImages['ingredient_$ingredientName'] = null;
      _imageGenerationProgress['ingredient_$ingredientName'] = false;
    }

    // Initialize equipment images - handle both new and old data format
    final equipmentRaw = widget.recipeData['equipment_needed'] ??
        widget.recipeData['equipment'] ??
        [];
    final equipmentList = equipmentRaw is List ? equipmentRaw : [];
    for (var equipment in equipmentList) {
      final equipmentName = equipment is Map
          ? (equipment['item'] ?? equipment['name'] ?? equipment.toString())
          : equipment.toString();
      _specializedImages['equipment_$equipmentName'] = null;
      _imageGenerationProgress['equipment_$equipmentName'] = false;
    }

    // Initialize method/step images - handle both 'steps' and 'method' keys
    final stepsRaw =
        widget.recipeData['steps'] ?? widget.recipeData['method'] ?? [];
    final stepsList = stepsRaw is List ? stepsRaw : [];
    for (int i = 0; i < stepsList.length; i++) {
      _specializedImages['method_step_$i'] = null;
      _imageGenerationProgress['method_step_$i'] = false;
    }
  }

  // Load cached images by checking endpoints without generating new ones
  Future<void> _loadCachedImages() async {
    // Try to load glassware
    final glassType = widget.recipeData['serving_glass'];
    if (glassType != null && glassType.isNotEmpty) {
      await _checkCachedImage('glassware', glassType);
    }

    // Try to load garnish
    final garnishes = widget.recipeData['garnish'];
    if (garnishes is List && garnishes.isNotEmpty) {
      await _checkCachedImage('garnish', garnishes.first);
    }

    // Try to load ALL ingredient images
    if (widget.recipeData['ingredients'] is List) {
      final ingredients = widget.recipeData['ingredients'] as List;
      for (var ingredient in ingredients) {
        final ingredientName = ingredient['name'];
        await _checkCachedImage('ingredient_$ingredientName', ingredientName);
        // Small delay to not overwhelm the server
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }

    // Try to load equipment images
    final equipmentList = widget.recipeData['equipment_needed'] ??
        widget.recipeData['equipment'] ??
        [];
    if (equipmentList is List) {
      for (var item in equipmentList) {
        final equipmentName = item is Map
            ? (item['item'] ?? item['name'] ?? item.toString())
            : item.toString();
        await _checkCachedImage('equipment_$equipmentName', equipmentName);
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  // Check if an image is cached on the server and load it if available
  Future<void> _checkCachedImage(String imageType, String subject) async {
    try {
      String endpoint;
      Map<String, String> bodyFields;

      // Determine endpoint based on image type
      if (imageType == 'glassware') {
        endpoint = 'generate_glassware_image';
        bodyFields = {'glass_type': subject};
      } else if (imageType == 'garnish') {
        endpoint = 'generate_garnish_image';
        bodyFields = {'garnish_description': subject};
      } else if (imageType.startsWith('ingredient_')) {
        endpoint = 'generate_ingredient_image';
        bodyFields = {'ingredient_name': subject};
      } else if (imageType.startsWith('equipment_')) {
        endpoint = 'generate_equipment_image';
        bodyFields = {'equipment_name': subject};
      } else {
        return;
      }

      final request =
          http.Request('POST', Uri.parse('http://127.0.0.1:8081/$endpoint'));
      request.headers
          .addAll({"Accept": "text/event-stream", "Cache-Control": "no-cache"});
      request.bodyFields = bodyFields;

      final http.StreamedResponse response = await _httpClient.send(request);
      if (response.statusCode == 200) {
        response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .listen(
          (line) {
            if (line.startsWith('data: ')) {
              final eventDataString = line.substring('data: '.length);
              try {
                final jsonData = jsonDecode(eventDataString);
                if (jsonData['type'] == 'partial_image' &&
                    jsonData['b64_data'] != null) {
                  if (mounted) {
                    setState(() {
                      _specializedImages[imageType] =
                          base64Decode(jsonData['b64_data']);
                    });
                  }
                }
              } catch (e) {
                // Ignore parsing errors for cache check
              }
            }
          },
          onDone: () {
            // If we didn't find a cached image, we don't set any error state
            // The user can still manually generate or use "Generate Visuals"
          },
          cancelOnError: true,
        );
      }
    } catch (e) {
      // Silently fail for cache checks - images can be generated later
      debugPrint('Cache check failed for $imageType: $e');
    }
  }

  void _initializeIngredientChecklist() {
    if (widget.recipeData['ingredients'] is List) {
      for (var ingredient in widget.recipeData['ingredients']) {
        _ingredientChecklist[ingredient['name']] = false;
      }
    }

    // Initialize Mise En Place step (step -1)
    _stepCompletion[-1] = false;

    // Epic 3: Initialize step completion tracking
    final stepsRaw =
        widget.recipeData['steps'] ?? widget.recipeData['method'] ?? [];
    final stepsList = stepsRaw is List ? stepsRaw : [];
    for (int i = 0; i < stepsList.length; i++) {
      _stepCompletion[i] = false;
    }

    // Load saved progress
    _loadProgress();
  }

  String _getRecipeKey() {
    // Generate a unique key for this recipe based on its content
    final recipeName = widget.recipeData['name'] ??
        widget.recipeData['drink_name'] ??
        'unknown';
    final ingredientCount =
        (widget.recipeData['ingredients'] as List?)?.length ?? 0;
    final stepCount =
        ((widget.recipeData['steps'] ?? widget.recipeData['method']) as List?)
                ?.length ??
            0;
    return '${recipeName}_${ingredientCount}_$stepCount';
  }

  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recipeKey = _getRecipeKey();

      // Save ingredient checklist
      for (String ingredient in _ingredientChecklist.keys) {
        await prefs.setBool('${recipeKey}_ingredient_$ingredient',
            _ingredientChecklist[ingredient] ?? false);
      }

      // Save step completion
      for (int step in _stepCompletion.keys) {
        await prefs.setBool(
            '${recipeKey}_step_$step', _stepCompletion[step] ?? false);
      }
    } catch (e) {
      debugPrint('Error saving progress: $e');
    }
  }

  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recipeKey = _getRecipeKey();

      // Load ingredient checklist
      final ingredientKeys = _ingredientChecklist.keys.toList();
      for (String ingredient in ingredientKeys) {
        final saved = prefs.getBool('${recipeKey}_ingredient_$ingredient');
        if (saved != null) {
          _ingredientChecklist[ingredient] = saved;
        }
      }

      // Load step completion
      final stepKeys = _stepCompletion.keys.toList();
      for (int step in stepKeys) {
        final saved = prefs.getBool('${recipeKey}_step_$step');
        if (saved != null) {
          _stepCompletion[step] = saved;
        }
      }

      // Update UI if any progress was loaded
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error loading progress from localStorage: $e');
    }
  }

  void _initializeStepConnections() {
    final ingredientsRaw = widget.recipeData['ingredients'];
    final ingredients = (ingredientsRaw is List)
        ? ingredientsRaw.map((e) => e['name'].toString().toLowerCase()).toList()
        : <String>[];
    final equipmentRaw = widget.recipeData['equipment_needed'] ??
        widget.recipeData['equipment'] ??
        [];
    final equipmentList = equipmentRaw is List ? equipmentRaw : [];
    final equipment = equipmentList
        .map((e) =>
            (e is Map ? (e['item'] ?? e['name'] ?? e.toString()) : e.toString())
                .toLowerCase())
        .toList();
    final stepsRaw =
        widget.recipeData['steps'] ?? widget.recipeData['method'] ?? [];
    final stepsList = stepsRaw is List ? stepsRaw : [];
    final steps = stepsList.map((e) => e.toString());

    // Initialize step card keys
    _stepCardKeys.clear();
    for (int i = 0; i < steps.length; i++) {
      _stepCardKeys.add(GlobalKey());
    }

    int idx = 0;
    for (final step in steps) {
      final stepLower = step.toLowerCase();
      _stepIngredientMap[idx] = [
        for (final ing in ingredients)
          if (stepLower.contains(ing)) ing
      ];
      _stepEquipmentMap[idx] = [
        for (final eq in equipment)
          if (stepLower.contains(eq)) eq
      ];
      idx++;
    }
  }

  // Epic 2: Task 2.1 - Serving Size Calculator Logic
  String _scaleIngredientAmount(String originalAmount, int servings) {
    // Extract number from amount string (e.g., "2 oz" -> 2.0)
    final RegExp numberRegex = RegExp(r'(\d+(?:\.\d+)?)');
    final match = numberRegex.firstMatch(originalAmount);

    if (match != null) {
      final double baseAmount = double.parse(match.group(1)!);
      final double scaledAmount = baseAmount * servings;
      final String unit = originalAmount.replaceAll(numberRegex, '').trim();

      // Epic 2: Task 2.2 - Unit conversion
      if (_isMetric && unit.toLowerCase().contains('oz')) {
        final double mlAmount = scaledAmount * 29.5735;
        return '${mlAmount.toStringAsFixed(1)} ml';
      } else if (!_isMetric && unit.toLowerCase().contains('ml')) {
        final double ozAmount = scaledAmount / 29.5735;
        return '${ozAmount.toStringAsFixed(1)} oz';
      }

      return '${scaledAmount % 1 == 0 ? scaledAmount.toInt() : scaledAmount.toStringAsFixed(1)} $unit';
    }

    return originalAmount; // Return original if no number found
  }

  // Specialized Image Generation Functions
  Future<void> _generateSpecializedImage(String imageType, String subject,
      {String context = ""}) async {
    if (_imageGenerationProgress[imageType] == true) return;

    setState(() {
      _imageGenerationProgress[imageType] = true;
    });

    String endpoint;
    Map<String, String> bodyFields;

    // Determine endpoint and parameters based on image type
    if (imageType == 'glassware') {
      endpoint = 'generate_glassware_image';
      bodyFields = {
        'glass_type': subject,
        'drink_context':
            widget.recipeData['drink_name'] ?? widget.recipeData['name'] ?? '',
      };
    } else if (imageType == 'garnish') {
      endpoint = 'generate_garnish_image';
      bodyFields = {
        'garnish_description': subject,
        'preparation_method': '',
      };
    } else if (imageType.startsWith('ingredient_')) {
      endpoint = 'generate_ingredient_image';
      bodyFields = {
        'ingredient_name': subject,
        'drink_context':
            widget.recipeData['drink_name'] ?? widget.recipeData['name'] ?? '',
      };
    } else if (imageType.startsWith('method_') ||
        imageType.startsWith('step_')) {
      endpoint = 'generate_method_image';
      bodyFields = {
        'step_text': subject,
        'step_index': context.isNotEmpty ? context : '0',
      };
    } else if (imageType.startsWith('equipment_')) {
      endpoint = 'generate_equipment_image';
      bodyFields = {
        'equipment_name': subject,
        'drink_context':
            widget.recipeData['drink_name'] ?? widget.recipeData['name'] ?? '',
      };
    } else {
      return; // Unknown image type
    }

    final request =
        http.Request('POST', Uri.parse('http://127.0.0.1:8081/$endpoint'));
    request.headers
        .addAll({"Accept": "text/event-stream", "Cache-Control": "no-cache"});
    request.bodyFields = bodyFields;

    try {
      final http.StreamedResponse response = await _httpClient.send(request);

      if (response.statusCode == 200) {
        response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .listen(
          (line) {
            if (line.startsWith('data: ')) {
              final eventDataString = line.substring('data: '.length);
              try {
                final jsonData = jsonDecode(eventDataString);
                if (jsonData['type'] == 'partial_image' &&
                    jsonData['b64_data'] != null) {
                  if (mounted) {
                    setState(() {
                      _specializedImages[imageType] =
                          base64Decode(jsonData['b64_data']);
                    });
                  }
                } else if (jsonData['type'] == 'stream_complete') {
                  if (mounted) {
                    setState(() {
                      _imageGenerationProgress[imageType] = false;
                    });
                  }
                } else if (jsonData['type'] == 'error') {
                  if (mounted) {
                    setState(() {
                      _imageGenerationProgress[imageType] = false;
                    });
                  }
                }
              } catch (e) {
                debugPrint("Error parsing specialized image SSE data: $e");
              }
            }
          },
          onError: (error) {
            debugPrint('Specialized image stream error: $error');
            if (mounted) {
              setState(() {
                _imageGenerationProgress[imageType] = false;
              });
            }
          },
          onDone: () {
            if (mounted) {
              setState(() {
                _imageGenerationProgress[imageType] = false;
              });
            }
          },
        );
      }
    } catch (e) {
      debugPrint('Error generating specialized image: $e');
      if (mounted) {
        setState(() {
          _imageGenerationProgress[imageType] = false;
        });
      }
    }
  }

  void _connectToImageStream() async {
    setState(() {
      _currentImageBytes = null;
      _imageStreamError = null;
      _isImageStreamComplete = false;
    });

    final imageDescription =
        widget.recipeData['drink_image_description'] ?? 'A delicious cocktail.';
    final drinkName = widget.recipeData['drink_name'] ??
        widget.recipeData['name'] ??
        'Cocktail';
    final servingGlass = widget.recipeData['serving_glass'] ?? '';
    final ingredients = widget.recipeData['ingredients'];

    // Get device screen information for optimal image sizing
    final screenSize = MediaQuery.of(context).size;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;

    // Always use phone portrait size regardless of device orientation
    String preferredImageSize = '1024x1536'; // Phone portrait only

    _imageStreamSubscription?.cancel(); // Cancel previous subscription

    final request = http.Request(
        'POST',
        Uri.parse(
            'http://127.0.0.1:8081/generate_image')); // Changed port to 8081
    request.headers
        .addAll({"Accept": "text/event-stream", "Cache-Control": "no-cache"});
    request.bodyFields = {
      // Use bodyFields for form data
      'image_description': imageDescription,
      'drink_query': drinkName,
      'serving_glass': servingGlass,
      'ingredients': jsonEncode(ingredients),
      'steps': jsonEncode(
          widget.recipeData['steps'] ?? widget.recipeData['method'] ?? []),
      'garnish': jsonEncode(widget.recipeData['garnish'] ?? []),
      'equipment_needed': jsonEncode(widget.recipeData['equipment_needed'] ??
          widget.recipeData['equipment'] ??
          []),
      // Device-aware image sizing for better iOS screen utilization
      'image_size': preferredImageSize,
      'screen_width': screenSize.width.toString(),
      'screen_height': screenSize.height.toString(),
      'pixel_ratio': pixelRatio.toString(),
      'platform': 'ios', // Specify platform for backend optimizations
    };

    try {
      final http.StreamedResponse response = await _httpClient.send(request);

      if (response.statusCode == 200) {
        _imageStreamSubscription = response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter()) // Process line by line
            .listen(
          (line) {
            if (line.startsWith('data: ')) {
              final eventDataString = line.substring('data: '.length);
              try {
                final jsonData = jsonDecode(eventDataString);
                // Only log event type for cleaner logs
                if (jsonData['type'] != null) {
                  debugPrint("SSE Event: ${jsonData['type']}");
                }
                if (jsonData['type'] == 'partial_image' &&
                    jsonData['b64_data'] != null) {
                  if (mounted) {
                    setState(() {
                      _currentImageBytes = base64Decode(jsonData['b64_data']);
                      _imageStreamError = null;
                    });
                  }
                } else if (jsonData['type'] == 'stream_complete') {
                  if (mounted) {
                    setState(() {
                      _isImageStreamComplete = true;
                    });
                  }
                  debugPrint("Image stream complete from server.");
                  _imageStreamSubscription?.cancel();
                } else if (jsonData['type'] == 'error') {
                  if (mounted) {
                    setState(() {
                      _imageStreamError =
                          jsonData['message'] ?? 'Unknown stream error';
                      _currentImageBytes = null;
                    });
                  }
                  debugPrint("Error from image stream: ${jsonData['message']}");
                  _imageStreamSubscription?.cancel();
                }
              } catch (e) {
                debugPrint(
                    "Error parsing SSE JSON data: $e. Data: ${eventDataString.length > 50 ? '${eventDataString.substring(0, 50)}...' : eventDataString}");
                if (mounted) {
                  setState(() {
                    _imageStreamError = "Error parsing stream data.";
                  });
                }
              }
            }
          },
          onError: (error) {
            debugPrint('SSE Stream Listen Error: $error');
            if (mounted) {
              setState(() {
                _imageStreamError = 'SSE stream error: $error';
                _currentImageBytes = null;
              });
            }
          },
          onDone: () {
            debugPrint('SSE Stream Listen Done.');
            if (mounted &&
                !_isImageStreamComplete &&
                _imageStreamError == null) {
              // setState(() { _imageStreamError = 'Image stream closed prematurely.'; });
            }
          },
          cancelOnError: true,
        );
      } else {
        debugPrint(
            'SSE initial request failed: ${response.statusCode} ${response.reasonPhrase}');
        if (mounted) {
          setState(() {
            _imageStreamError =
                'Failed to connect to image stream: ${response.statusCode}';
          });
        }
      }
    } catch (e) {
      debugPrint('Error sending SSE request: $e');
      if (mounted) {
        setState(() {
          _imageStreamError = 'Error connecting to image stream: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _imageStreamSubscription?.cancel();
    _httpClient.close(); // Close the client when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.recipeData['name'] ??
            widget.recipeData['drink_name'] ??
            'Recipe'),
        backgroundColor: CupertinoColors.systemBackground,
        border: const Border(),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: iOSTheme.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroSection(),
                    const SizedBox(height: iOSTheme.largePadding),
                    _buildSectionPreviews(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    // Calculate image dimensions based on 2:3 aspect ratio (width:height)
    final screenWidth = MediaQuery.of(context).size.width;
    final imageWidth = (screenWidth -
            iOSTheme.screenPadding.horizontal -
            iOSTheme.mediumPadding) *
        2 /
        3;
    final imageHeight =
        imageWidth * 3 / 2; // 2:3 ratio means height = width * 1.5

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side - 2/3 width for image with proper 2:3 aspect ratio
        if (_currentImageBytes != null)
          Container(
            width: imageWidth,
            height: imageHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(iOSTheme.mediumRadius),
              image: DecorationImage(
                image: MemoryImage(_currentImageBytes!),
                fit: BoxFit
                    .contain, // Use contain to show full image without cropping
              ),
            ),
          ),
        const SizedBox(width: iOSTheme.mediumPadding),
        // Right side - 1/3 width for comprehensive info (in a card)
        Expanded(
          child: Container(
            height: imageHeight, // Match the image height
            padding: iOSTheme.cardPadding,
            decoration: iOSTheme.cardDecoration(context),
            child: _buildComprehensiveInfoPanel(),
          ),
        ),
      ],
    );
  }

  Widget _buildComprehensiveInfoPanel() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and description
          Text(
            widget.recipeData['name'] ??
                widget.recipeData['drink_name'] ??
                'Recipe',
            style: iOSTheme.title2.copyWith(fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: iOSTheme.smallPadding),
          if (widget.recipeData['description'] != null)
            Text(
              widget.recipeData['description'] as String,
              style: iOSTheme.caption1.copyWith(
                color: CupertinoColors.secondaryLabel,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: iOSTheme.mediumPadding),

          // Progress Section (moved from below)
          _buildCompactProgress(),
          const SizedBox(height: iOSTheme.mediumPadding),

          // Quick Facts
          _buildCondensedFacts(),
          const SizedBox(height: iOSTheme.mediumPadding),

          // History sections
          _buildHistorySection(),
          const SizedBox(height: iOSTheme.mediumPadding),

          // Trivia sections
          _buildTriviaSection(),
          const SizedBox(height: iOSTheme.mediumPadding),

          // Variations and Similar Drinks
          _buildVariationsSection(),
        ],
      ),
    );
  }

  Widget _buildCompactProgress() {
    final currentStepIndex = _getCurrentStepIndex();
    final isMiseEnPlace = currentStepIndex == -1;
    final isFlavorProfile = currentStepIndex == -2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: iOSTheme.headline.copyWith(fontWeight: FontWeight.w600),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _resetProgress,
              child: Icon(
                CupertinoIcons.refresh,
                size: 18,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: iOSTheme.smallPadding),

        // Glass at top, centered
        Center(
          child: DrinkProgressGlass(
              progress: _currentDrinkProgress, width: 40, height: 60),
        ),
        const SizedBox(height: iOSTheme.smallPadding),

        // Progress bar
        LinearProgressIndicator(
          value: _getOverallProgress(),
          backgroundColor: CupertinoColors.systemGrey5,
          color: iOSTheme.whiskey,
          minHeight: 4,
        ),
        const SizedBox(height: iOSTheme.mediumPadding),

        // Step text below glass
        Text(
          _getProgressText(),
          style: iOSTheme.caption1.copyWith(fontWeight: FontWeight.w500),
          maxLines: 8,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: iOSTheme.mediumPadding),

        // Action button at bottom
        if (isMiseEnPlace)
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: iOSTheme.whiskey,
              borderRadius: BorderRadius.circular(8),
              onPressed: () {
                _toggleStepCompleted(-1, true);
              },
              child: Text(
                'Ready to Start Mixing',
                style: iOSTheme.caption1.copyWith(
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        if (!isMiseEnPlace && !isFlavorProfile)
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: iOSTheme.whiskey,
              borderRadius: BorderRadius.circular(8),
              onPressed: () {
                _toggleStepCompleted(currentStepIndex, true);
              },
              child: Text(
                'Mark Step ${currentStepIndex + 1} Done',
                style: iOSTheme.caption1.copyWith(
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        if (isFlavorProfile)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '🍹 Enjoy Your Cocktail!',
              textAlign: TextAlign.center,
              style: iOSTheme.caption1.copyWith(
                color: CupertinoColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  double _getOverallProgress() {
    final stepsRaw =
        widget.recipeData['steps'] ?? widget.recipeData['method'] ?? [];
    final steps = stepsRaw is List ? stepsRaw : [];
    final totalSteps = steps.length + 1; // +1 for Mise En Place

    int completedSteps = 0;

    // Check Mise En Place
    if (_stepCompletion[-1] == true) {
      completedSteps++;
    }

    // Check recipe steps
    for (int i = 0; i < steps.length; i++) {
      if (_stepCompletion[i] == true) {
        completedSteps++;
      }
    }

    return totalSteps > 0 ? completedSteps / totalSteps : 0;
  }

  void _resetProgress() {
    setState(() {
      // Reset Mise En Place
      _stepCompletion[-1] = false;

      // Reset all recipe steps
      final stepsRaw =
          widget.recipeData['steps'] ?? widget.recipeData['method'] ?? [];
      final steps = stepsRaw is List ? stepsRaw : [];
      for (int i = 0; i < steps.length; i++) {
        _stepCompletion[i] = false;
      }

      // Reset ingredient checklist
      for (String ingredient in _ingredientChecklist.keys) {
        _ingredientChecklist[ingredient] = false;
      }
    });
    _saveProgress();
  }

  Widget _buildCondensedFacts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Facts',
          style: iOSTheme.headline.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: iOSTheme.smallPadding),

        // Glass type
        if (widget.recipeData['serving_glass'] != null)
          _buildFactRow(
            'Glass',
            widget.recipeData['serving_glass'].toString(),
            CupertinoIcons.circle,
          ),

        // Alcohol content or spirit base
        if (widget.recipeData['ingredients'] is List)
          _buildFactRow(
            'Base',
            _getPrimarySpirit(),
            CupertinoIcons.drop,
          ),

        // Preparation method
        _buildFactRow(
          'Method',
          _getPreparationMethod(),
          CupertinoIcons.gear,
        ),

        // Difficulty or category
        if (widget.recipeData['category'] != null)
          _buildFactRow(
            'Style',
            widget.recipeData['category'].toString(),
            CupertinoIcons.tag,
          ),
      ],
    );
  }

  Widget _buildHistorySection() {
    final drinkHistory = widget.recipeData['drink_history'];
    if (drinkHistory == null || drinkHistory.toString().trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'History',
          style: iOSTheme.headline.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: iOSTheme.smallPadding),
        Text(
          drinkHistory.toString(),
          style: iOSTheme.caption2.copyWith(
            color: CupertinoColors.secondaryLabel,
          ),
          maxLines: 6,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildTriviaSection() {
    final drinkTrivia = widget.recipeData['drink_trivia'];
    if (drinkTrivia == null || (drinkTrivia is List && drinkTrivia.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trivia',
          style: iOSTheme.headline.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: iOSTheme.smallPadding),

        // Display trivia facts from the array
        if (drinkTrivia is List)
          ...drinkTrivia.map<Widget>((triviaItem) {
            if (triviaItem is Map) {
              final fact = triviaItem['fact']?.toString() ?? '';
              final category = triviaItem['category']?.toString() ?? '';

              if (fact.isNotEmpty) {
                return _buildTriviaItem(fact, category);
              }
            }
            return const SizedBox.shrink();
          }),
      ],
    );
  }

  Widget _buildTriviaItem(String fact, String category) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (category.isNotEmpty)
            Text(
              category,
              style: iOSTheme.caption1.copyWith(
                fontWeight: FontWeight.w600,
                color: iOSTheme.whiskey,
              ),
            ),
          const SizedBox(height: 2),
          Text(
            fact,
            style: iOSTheme.caption2.copyWith(
              color: CupertinoColors.secondaryLabel,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildVariationsSection() {
    final relatedCocktails = widget.recipeData['related_cocktails'];
    final suggestedVariations = widget.recipeData['suggested_variations'];

    if ((relatedCocktails == null ||
            (relatedCocktails is List && relatedCocktails.isEmpty)) &&
        (suggestedVariations == null ||
            (suggestedVariations is List && suggestedVariations.isEmpty))) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Related Drinks',
          style: iOSTheme.headline.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: iOSTheme.smallPadding),

        // Related Cocktails
        if (relatedCocktails is List && relatedCocktails.isNotEmpty)
          _buildRelatedCocktailsList(relatedCocktails),

        // Suggested Variations
        if (suggestedVariations is List && suggestedVariations.isNotEmpty) ...[
          const SizedBox(height: iOSTheme.smallPadding),
          _buildVariationsList(suggestedVariations),
        ],
      ],
    );
  }

  Widget _buildRelatedCocktailsList(List relatedCocktails) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Similar Cocktails',
          style: iOSTheme.caption1.copyWith(
            fontWeight: FontWeight.w600,
            color: iOSTheme.whiskey,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: relatedCocktails.take(6).map<Widget>((cocktail) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                cocktail.toString(),
                style: iOSTheme.caption2.copyWith(
                  color: CupertinoColors.label,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildVariationsList(List variations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Variations',
          style: iOSTheme.caption1.copyWith(
            fontWeight: FontWeight.w600,
            color: iOSTheme.whiskey,
          ),
        ),
        const SizedBox(height: 4),
        ...variations.take(3).map<Widget>((variation) {
          if (variation is Map) {
            final name = variation['name']?.toString() ?? '';
            final description = variation['description']?.toString() ?? '';

            if (name.isNotEmpty) {
              return _buildVariationItem(name, description);
            }
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildVariationItem(String name, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: iOSTheme.caption2.copyWith(
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              description,
              style: iOSTheme.caption2.copyWith(
                color: CupertinoColors.secondaryLabel,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFactRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: CupertinoColors.systemGrey,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: iOSTheme.caption1.copyWith(
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.label,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: iOSTheme.caption1.copyWith(
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _getPrimarySpirit() {
    final ingredients = widget.recipeData['ingredients'] as List? ?? [];
    for (var ingredient in ingredients) {
      final name = ingredient['name']?.toString().toLowerCase() ?? '';
      if (name.contains('whiskey') ||
          name.contains('bourbon') ||
          name.contains('scotch')) {
        return 'Whiskey';
      } else if (name.contains('vodka')) {
        return 'Vodka';
      } else if (name.contains('gin')) {
        return 'Gin';
      } else if (name.contains('rum')) {
        return 'Rum';
      } else if (name.contains('tequila')) {
        return 'Tequila';
      }
    }
    return 'Mixed';
  }

  String _getPreparationMethod() {
    final methodRaw =
        widget.recipeData['steps'] ?? widget.recipeData['method'] ?? [];
    final method = methodRaw is List ? methodRaw : [];
    if (method.isNotEmpty) {
      final firstStep = method.first.toString().toLowerCase();
      if (firstStep.contains('shake')) {
        return 'Shaken';
      } else if (firstStep.contains('stir')) {
        return 'Stirred';
      } else if (firstStep.contains('build')) {
        return 'Built';
      } else if (firstStep.contains('muddle')) {
        return 'Muddled';
      }
    }
    return 'Mixed';
  }

  Widget _buildSectionPreviews() {
    return Column(
      children: [
        SectionPreview(
          title: 'Method',
          icon: Icons.format_list_numbered,
          previewContent: _buildMethodPreviewWidget(),
          expandedContent: _buildMethodSection(),
          totalItems: (() {
            final stepsRaw =
                widget.recipeData['steps'] ?? widget.recipeData['method'] ?? [];
            final steps = stepsRaw is List ? stepsRaw : [];
            return steps.length;
          })(),
          completedItems: _stepCompletion.values.where((e) => e == true).length,
          expanded: _expandedSection == 'method',
          onOpen: () => _toggleExpandedSection('method'),
          onClose: () => _toggleExpandedSection('method'),
        ),
        const SizedBox(height: 12),
        SectionPreview(
          title: 'Ingredients',
          icon: Icons.local_grocery_store,
          previewContent: _buildIngredientsPreviewWidget(),
          expandedContent: _buildIngredientsSection(),
          totalItems: (() {
            final ingredientsRaw = widget.recipeData['ingredients'];
            final ingredients = ingredientsRaw is List ? ingredientsRaw : [];
            return ingredients.length;
          })(),
          completedItems: _ingredientChecklist.values.where((e) => e).length,
          expanded: _expandedSection == 'ingredients',
          onOpen: () => _toggleExpandedSection('ingredients'),
          onClose: () => _toggleExpandedSection('ingredients'),
        ),
        const SizedBox(height: 12),
        SectionPreview(
          title: 'Equipment',
          icon: Icons.build,
          previewContent: _buildEquipmentPreviewWidget(),
          expandedContent: _buildEquipmentSection(),
          totalItems: (() {
            final equipmentRaw = widget.recipeData['equipment_needed'] ??
                widget.recipeData['equipment'] ??
                [];
            final equipment = equipmentRaw is List ? equipmentRaw : [];
            return equipment.length;
          })(),
          expanded: _expandedSection == 'equipment',
          onOpen: () => _toggleExpandedSection('equipment'),
          onClose: () => _toggleExpandedSection('equipment'),
        ),
      ],
    );
  }

  Widget _buildMethodPreviewWidget() {
    final stepsRaw =
        widget.recipeData['steps'] ?? widget.recipeData['method'] ?? [];
    final steps = stepsRaw is List ? stepsRaw : [];
    if (steps.isEmpty) return const SizedBox.shrink();
    return Text(
      steps.first.toString(),
      style: iOSTheme.body,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildIngredientsPreviewWidget() {
    final ingredientsRaw = widget.recipeData['ingredients'];
    final ingredients = ingredientsRaw is List ? ingredientsRaw : [];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: ingredients.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        final ingredient = ingredients[index];
        final name = ingredient['name'] ?? ingredient.toString();
        final imageKey = 'ingredient_$name';
        return Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: SizedBox(
                  width: double.infinity,
                  child: _specializedImages[imageKey] != null
                      ? Image.memory(
                          _specializedImages[imageKey]!,
                          fit: BoxFit.cover,
                        )
                      : _imageGenerationProgress[imageKey] == true
                          ? Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : Container(
                              color: Colors.grey[100],
                              child: const Center(
                                child: Icon(Icons.image_not_supported,
                                    color: Colors.grey, size: 32),
                              ),
                            ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    name,
                    style: iOSTheme.body.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEquipmentPreviewWidget() {
    final equipmentRaw = widget.recipeData['equipment_needed'] ??
        widget.recipeData['equipment'] ??
        [];
    final equipment = equipmentRaw is List ? equipmentRaw : [];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: equipment.map((e) {
        final name =
            e is Map ? (e['item'] ?? e['name'] ?? e.toString()) : e.toString();
        final imageKey = 'equipment_$name';
        Widget child;
        if (_specializedImages[imageKey] != null) {
          child = ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.memory(
              _specializedImages[imageKey]!,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          );
        } else {
          child = Container(
            width: 40,
            height: 40,
            color: Colors.grey[200],
            child: Icon(
              Icons.build,
              size: 20,
              color: iOSTheme.whiskey,
            ),
          );
        }
        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4), child: child);
      }).toList(),
    );
  }

  Widget _buildIngredientsSection() {
    final ingredientsRaw = widget.recipeData['ingredients'];
    final ingredients = ingredientsRaw is List ? ingredientsRaw : [];

    return Container(
      padding: iOSTheme.cardPadding,
      decoration: iOSTheme.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ingredients',
            style: iOSTheme.title2,
          ),
          const SizedBox(height: iOSTheme.mediumPadding),
          ...ingredients.map((ingredient) {
            final name = ingredient['name'] as String? ?? '';
            final amount = ingredient['amount'] as String? ?? '';
            final unit = ingredient['unit'] as String? ?? '';

            return Padding(
              padding: const EdgeInsets.only(bottom: iOSTheme.smallPadding),
              child: Row(
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Icon(
                      _ingredientChecklist[name] == true
                          ? CupertinoIcons.checkmark_circle_fill
                          : CupertinoIcons.circle,
                      color: _ingredientChecklist[name] == true
                          ? CupertinoColors.systemGreen
                          : CupertinoColors.systemGrey,
                    ),
                    onPressed: () {
                      setState(() {
                        _ingredientChecklist[name] =
                            !(_ingredientChecklist[name] ?? false);
                      });
                      _saveProgress();
                    },
                  ),
                  const SizedBox(width: iOSTheme.mediumPadding),
                  Icon(
                    _getIngredientIcon(name),
                    size: 20,
                    color: CupertinoColors.systemGrey,
                  ),
                  const SizedBox(width: iOSTheme.mediumPadding),
                  Expanded(
                    child: Text(
                      '$amount $unit $name',
                      style: iOSTheme.body.copyWith(
                        decoration: _ingredientChecklist[name] == true
                            ? TextDecoration.lineThrough
                            : null,
                        color: _ingredientChecklist[name] == true
                            ? CupertinoColors.systemGrey
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMethodSection() {
    final methodRaw =
        widget.recipeData['steps'] ?? widget.recipeData['method'] ?? [];
    final method = methodRaw is List ? methodRaw : [];

    return Container(
      padding: iOSTheme.cardPadding,
      decoration: iOSTheme.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Method',
            style: iOSTheme.title2,
          ),
          const SizedBox(height: iOSTheme.mediumPadding),
          ...method.asMap().entries.map<Widget>((entry) {
            final index = entry.key;
            final step = entry.value as String? ?? '';
            final isCompleted = _stepCompletion[index] ?? false;

            return Padding(
              padding: const EdgeInsets.only(bottom: iOSTheme.mediumPadding),
              child: MethodCard(
                key: _stepCardKeys.length > index ? _stepCardKeys[index] : null,
                data: MethodCardData(
                  stepNumber: index + 1,
                  title: 'Step ${index + 1}',
                  description: step,
                  imageAlt: 'Step ${index + 1} illustration',
                  isCompleted: isCompleted,
                  duration: '~2 min',
                  difficulty: 'Easy',
                  proTip: _getProTipForStep(step),
                  tipCategory: _getTipCategoryForStep(step),
                ),
                onCheckboxChanged: (completed) =>
                    _toggleStepCompleted(index, completed),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEquipmentSection() {
    final equipmentRaw = widget.recipeData['equipment_needed'] ??
        widget.recipeData['equipment'] ??
        [];
    final equipment = equipmentRaw is List ? equipmentRaw : [];

    if (equipment.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: iOSTheme.cardPadding,
      decoration: iOSTheme.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Equipment',
            style: iOSTheme.title2,
          ),
          const SizedBox(height: iOSTheme.mediumPadding),
          ...equipment.map((item) {
            final name = item is Map
                ? (item['item'] ?? item['name'] ?? item.toString())
                : item.toString();

            return Padding(
              padding: const EdgeInsets.only(bottom: iOSTheme.smallPadding),
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.wrench,
                    size: 20,
                    color: CupertinoColors.systemGrey,
                  ),
                  const SizedBox(width: iOSTheme.mediumPadding),
                  Text(
                    name,
                    style: iOSTheme.body,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
