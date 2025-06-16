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
  final http.Client _httpClient = http.Client(); // HTTP client for streaming request
  
  // Epic 2: Interactive Recipe Components
  int _servingSize = 1;
  bool _isMetric = false; // false = oz, true = ml
  final Map<String, bool> _ingredientChecklist = {};
  
  // Epic 3: Visual Recipe Steps
  final Map<int, bool> _stepCompletion = {};
  
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
    final totalSteps = _stepCompletion.length;
    final completedSteps = _stepCompletion.values.where((completed) => completed).length;
    
    if (completedSteps == 0) return DrinkProgress.emptyGlass;
    if (completedSteps < totalSteps * 0.4) return DrinkProgress.ingredientsAdded;
    if (completedSteps < totalSteps * 0.8) return DrinkProgress.mixed;
    if (completedSteps < totalSteps) return DrinkProgress.garnished;
    return DrinkProgress.complete;
  }
  
  String _getProgressText() {
    switch (_currentDrinkProgress) {
      case DrinkProgress.emptyGlass:
        return 'Ready to start mixing';
      case DrinkProgress.ingredientsAdded:
        return 'Adding ingredients...';
      case DrinkProgress.mixed:
        return 'Mixing and blending...';
      case DrinkProgress.garnished:
        return 'Almost finished!';
      case DrinkProgress.complete:
        return 'Cocktail complete! 🍹';
    }
  }

  void _toggleStepCompleted(int stepIndex, bool completed) {
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
    
    if (stepLower.contains('shake') || stepLower.contains('shaking') ||
        stepLower.contains('stir') || stepLower.contains('stirring') ||
        stepLower.contains('muddle')) {
      return TipCategory.technique;
    } else if (stepLower.contains('strain')) {
      return TipCategory.equipment;
    } else if (stepLower.contains('garnish') || stepLower.contains('serve')) {
      return TipCategory.presentation;
    } else if (stepLower.contains('chill') || stepLower.contains('temperature')) {
      return TipCategory.timing;
    } else if (stepLower.contains('fresh') || stepLower.contains('quality')) {
      return TipCategory.ingredient;
    }
    
    return null;
  }

  IconData _getIngredientIcon(String ingredientName) {
    final nameLower = ingredientName.toLowerCase();
    
    if (nameLower.contains('whiskey') || nameLower.contains('bourbon') || nameLower.contains('scotch')) {
      return Icons.local_bar;
    } else if (nameLower.contains('vodka') || nameLower.contains('gin') || nameLower.contains('rum')) {
      return Icons.local_bar;
    } else if (nameLower.contains('lemon') || nameLower.contains('lime') || nameLower.contains('orange')) {
      return Icons.circle;
    } else if (nameLower.contains('syrup') || nameLower.contains('honey') || nameLower.contains('sugar')) {
      return Icons.water_drop;
    } else if (nameLower.contains('bitters') || nameLower.contains('vermouth')) {
      return Icons.opacity;
    } else if (nameLower.contains('ice') || nameLower.contains('water')) {
      return Icons.ac_unit;
    } else if (nameLower.contains('mint') || nameLower.contains('herb') || nameLower.contains('basil')) {
      return Icons.eco;
    } else if (nameLower.contains('cherry') || nameLower.contains('olive') || nameLower.contains('garnish')) {
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreExpandedFromHash());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Call _connectToImageStream here where MediaQuery is available
    if (!_isImageStreamComplete && _currentImageBytes == null && _imageStreamError == null) {
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
          _generateSpecializedImage(imageKey, ingredientName, context: 'ingredient');
        }
      }
    }
  }

  bool _ingredientActive(String name) {
    if (_hoveredStep == null) return false;
    return _stepIngredientMap[_hoveredStep!]?.contains(name.toLowerCase()) ?? false;
  }

  bool _equipmentActive(String name) {
    if (_hoveredStep == null) return false;
    return _stepEquipmentMap[_hoveredStep!]?.contains(name.toLowerCase()) ?? false;
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
    if (widget.recipeData['ingredients'] is List) {
      for (var ingredient in widget.recipeData['ingredients']) {
        final ingredientName = ingredient['name'];
        _specializedImages['ingredient_$ingredientName'] = null;
        _imageGenerationProgress['ingredient_$ingredientName'] = false;
      }
    }
    
    // Initialize equipment images - handle both new and old data format
    final equipmentList = widget.recipeData['equipment_needed'] ?? widget.recipeData['equipment'] ?? [];
    if (equipmentList is List) {
      for (var equipment in equipmentList) {
        final equipmentName = equipment is Map ? (equipment['item'] ?? equipment['name'] ?? equipment.toString()) : equipment.toString();
        _specializedImages['equipment_$equipmentName'] = null;
        _imageGenerationProgress['equipment_$equipmentName'] = false;
      }
    }
    
    // Initialize method/step images - handle both 'steps' and 'method' keys
    final stepsList = widget.recipeData['steps'] ?? widget.recipeData['method'] ?? [];
    if (stepsList is List) {
      for (int i = 0; i < stepsList.length; i++) {
        _specializedImages['method_step_$i'] = null;
        _imageGenerationProgress['method_step_$i'] = false;
      }
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
    final equipmentList = widget.recipeData['equipment_needed'] ?? widget.recipeData['equipment'] ?? [];
    if (equipmentList is List) {
      for (var item in equipmentList) {
        final equipmentName = item is Map ? (item['item'] ?? item['name'] ?? item.toString()) : item.toString();
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
      
      final request = http.Request('POST', Uri.parse('http://127.0.0.1:8081/$endpoint'));
      request.headers.addAll({"Accept": "text/event-stream", "Cache-Control": "no-cache"});
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
                if (jsonData['type'] == 'partial_image' && jsonData['b64_data'] != null) {
                  if (mounted) {
                    setState(() {
                      _specializedImages[imageType] = base64Decode(jsonData['b64_data']);
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
    
    // Epic 3: Initialize step completion tracking
    final stepsList = widget.recipeData['steps'] ?? widget.recipeData['method'] ?? [];
    if (stepsList is List) {
      for (int i = 0; i < stepsList.length; i++) {
        _stepCompletion[i] = false;
      }
    }
    
    // Load saved progress
    _loadProgress();
  }

  String _getRecipeKey() {
    // Generate a unique key for this recipe based on its content
    final recipeName = widget.recipeData['name'] ?? widget.recipeData['drink_name'] ?? 'unknown';
    final ingredientCount = (widget.recipeData['ingredients'] as List?)?.length ?? 0;
    final stepCount = ((widget.recipeData['steps'] ?? widget.recipeData['method']) as List?)?.length ?? 0;
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
        await prefs.setBool('${recipeKey}_step_$step', 
            _stepCompletion[step] ?? false);
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
    final ingredients = (widget.recipeData['ingredients'] as List?)
            ?.map((e) => e['name'].toString().toLowerCase())
            .toList() ??
        [];
    final equipmentList = widget.recipeData['equipment_needed'] ?? widget.recipeData['equipment'] ?? [];
    final equipment = (equipmentList as List?)
            ?.map((e) => (e is Map ? (e['item'] ?? e['name'] ?? e.toString()) : e.toString()).toLowerCase())
            .toList() ??
        [];
    final stepsList = widget.recipeData['steps'] ?? widget.recipeData['method'] ?? [];
    final steps = (stepsList as List?)?.map((e) => e.toString()) ?? [];
    
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
  Future<void> _generateSpecializedImage(String imageType, String subject, {String context = ""}) async {
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
        'drink_context': widget.recipeData['drink_name'] ?? widget.recipeData['name'] ?? '',
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
        'drink_context': widget.recipeData['drink_name'] ?? widget.recipeData['name'] ?? '',
      };
    } else if (imageType.startsWith('method_') || imageType.startsWith('step_')) {
      endpoint = 'generate_method_image';
      bodyFields = {
        'step_text': subject,
        'step_index': context.isNotEmpty ? context : '0',
      };
    } else if (imageType.startsWith('equipment_')) {
      endpoint = 'generate_equipment_image';
      bodyFields = {
        'equipment_name': subject,
        'drink_context': widget.recipeData['drink_name'] ?? widget.recipeData['name'] ?? '',
      };
    } else {
      return; // Unknown image type
    }
    
    final request = http.Request('POST', Uri.parse('http://127.0.0.1:8081/$endpoint'));
    request.headers.addAll({"Accept": "text/event-stream", "Cache-Control": "no-cache"});
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
                if (jsonData['type'] == 'partial_image' && jsonData['b64_data'] != null) {
                  if (mounted) {
                    setState(() {
                      _specializedImages[imageType] = base64Decode(jsonData['b64_data']);
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

    final imageDescription = widget.recipeData['drink_image_description'] ?? 'A delicious cocktail.';
    final drinkName = widget.recipeData['drink_name'] ?? widget.recipeData['name'] ?? 'Cocktail';
    final servingGlass = widget.recipeData['serving_glass'] ?? '';
    final ingredients = widget.recipeData['ingredients'];

    // Get device screen information for optimal image sizing
    final screenSize = MediaQuery.of(context).size;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    
    // Always use phone portrait size regardless of device orientation
    String preferredImageSize = '1024x1536'; // Phone portrait only

    _imageStreamSubscription?.cancel(); // Cancel previous subscription

    final request = http.Request('POST', Uri.parse('http://127.0.0.1:8081/generate_image')); // Changed port to 8081
    request.headers.addAll({"Accept": "text/event-stream", "Cache-Control": "no-cache"});
    request.bodyFields = { // Use bodyFields for form data
        'image_description': imageDescription,
        'drink_query': drinkName,
        'serving_glass': servingGlass,
        'ingredients': jsonEncode(ingredients),
        'steps': jsonEncode(widget.recipeData['steps'] ?? widget.recipeData['method'] ?? []),
        'garnish': jsonEncode(widget.recipeData['garnish'] ?? []),
        'equipment_needed': jsonEncode(widget.recipeData['equipment_needed'] ?? widget.recipeData['equipment'] ?? []),
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
                if (jsonData['type'] == 'partial_image' && jsonData['b64_data'] != null) {
                  if (mounted) {
                    setState(() {
                      _currentImageBytes = base64Decode(jsonData['b64_data']);
                      _imageStreamError = null;
                    });
                  }
                } else if (jsonData['type'] == 'stream_complete') {
                  if (mounted) {
                    setState(() { _isImageStreamComplete = true; });
                  }
                  debugPrint("Image stream complete from server.");
                  _imageStreamSubscription?.cancel(); 
                } else if (jsonData['type'] == 'error') {
                  if (mounted) {
                    setState(() {
                      _imageStreamError = jsonData['message'] ?? 'Unknown stream error';
                      _currentImageBytes = null;
                    });
                  }
                  debugPrint("Error from image stream: ${jsonData['message']}");
                  _imageStreamSubscription?.cancel();
                }
              } catch (e) {
                debugPrint("Error parsing SSE JSON data: $e. Data: ${eventDataString.length > 50 ? '${eventDataString.substring(0, 50)}...' : eventDataString}");
                if (mounted) { setState(() { _imageStreamError = "Error parsing stream data."; });}
              }
            }
          },
          onError: (error) {
            debugPrint('SSE Stream Listen Error: $error');
            if (mounted) { setState(() { _imageStreamError = 'SSE stream error: $error'; _currentImageBytes = null; });}
          },
          onDone: () {
            debugPrint('SSE Stream Listen Done.');
            if (mounted && !_isImageStreamComplete && _imageStreamError == null) {
                 // setState(() { _imageStreamError = 'Image stream closed prematurely.'; });
            }
          },
          cancelOnError: true,
        );
      } else {
        debugPrint('SSE initial request failed: ${response.statusCode} ${response.reasonPhrase}');
        if (mounted) { setState(() { _imageStreamError = 'Failed to connect to image stream: ${response.statusCode}';});}
      }
    } catch (e) {
      debugPrint('Error sending SSE request: $e');
      if (mounted) { setState(() { _imageStreamError = 'Error connecting to image stream: $e';});}
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
        middle: Text(widget.recipeData['name'] ?? widget.recipeData['drink_name'] ?? 'Recipe'),
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
                    _buildProgressSection(),
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
    return Container(
      padding: iOSTheme.cardPadding,
      decoration: iOSTheme.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.recipeData['name'] ?? widget.recipeData['drink_name'] ?? 'Recipe',
                      style: iOSTheme.largeTitle,
                    ),
                    const SizedBox(height: iOSTheme.smallPadding),
                    if (widget.recipeData['description'] != null)
                      Text(
                        widget.recipeData['description'] as String,
                        style: iOSTheme.body.copyWith(
                          color: CupertinoColors.secondaryLabel,
                        ),
                      ),
                  ],
                ),
              ),
              if (_currentImageBytes != null)
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(iOSTheme.mediumRadius),
                    image: DecorationImage(
                      image: MemoryImage(_currentImageBytes!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Container(
      padding: iOSTheme.cardPadding,
      decoration: iOSTheme.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress',
            style: iOSTheme.title2,
          ),
          const SizedBox(height: iOSTheme.mediumPadding),
          Row(
            children: [
              DrinkProgressGlass(progress: _currentDrinkProgress),
              const SizedBox(width: iOSTheme.mediumPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getProgressText(),
                      style: iOSTheme.headline,
                    ),
                    const SizedBox(height: iOSTheme.smallPadding),
                    LinearProgressIndicator(
                      value: _stepCompletion.isNotEmpty 
                          ? _stepCompletion.values.where((v) => v).length / _stepCompletion.length
                          : 0,
                      backgroundColor: CupertinoColors.systemGrey5,
                      color: iOSTheme.whiskey,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionPreviews() {
    return Column(
      children: [
        SectionPreview(
          title: 'Method',
          icon: Icons.format_list_numbered,
          previewContent: _buildMethodPreviewWidget(),
          expandedContent: _buildMethodSection(),
          totalItems: ((widget.recipeData['steps'] ?? widget.recipeData['method']) as List?)?.length ?? 0,
          completedItems: _stepCompletion.values.where((e) => e).length,
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
          totalItems: (widget.recipeData['ingredients'] as List?)?.length ?? 0,
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
          totalItems: ((widget.recipeData['equipment_needed'] ?? widget.recipeData['equipment']) as List?)?.length ?? 0,
          expanded: _expandedSection == 'equipment',
          onOpen: () => _toggleExpandedSection('equipment'),
          onClose: () => _toggleExpandedSection('equipment'),
        ),
      ],
    );
  }

  Widget _buildMethodPreviewWidget() {
    final steps = (widget.recipeData['steps'] ?? widget.recipeData['method']) as List? ?? [];
    if (steps.isEmpty) return const SizedBox.shrink();
    return Text(
      steps.first.toString(),
      style: iOSTheme.body,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildIngredientsPreviewWidget() {
    final ingredients = (widget.recipeData['ingredients'] as List?)?.take(4).toList() ?? [];
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
                                child: CircularProgressIndicator(strokeWidth: 2),
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
    final equipmentList = widget.recipeData['equipment_needed'] ?? widget.recipeData['equipment'] ?? [];
    final equipment = (equipmentList as List?)?.take(3).toList() ?? [];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: equipment.map((e) {
        final name = e is Map ? (e['item'] ?? e['name'] ?? e.toString()) : e.toString();
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
        return Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: child);
      }).toList(),
    );
  }

  Widget _buildIngredientsSection() {
    final ingredients = widget.recipeData['ingredients'] as List<dynamic>? ?? [];
    
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
                        _ingredientChecklist[name] = !(_ingredientChecklist[name] ?? false);
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
    final method = (widget.recipeData['steps'] ?? widget.recipeData['method']) as List<dynamic>? ?? [];
    
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
                onCheckboxChanged: (completed) => _toggleStepCompleted(index, completed),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEquipmentSection() {
    final equipmentList = widget.recipeData['equipment_needed'] ?? widget.recipeData['equipment'] ?? [];
    final equipment = equipmentList as List<dynamic>? ?? [];
    
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
            final name = item is Map ? (item['item'] ?? item['name'] ?? item.toString()) : item.toString();
            
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