import 'dart:async'; // For StreamSubscription
import 'dart:convert'; // For jsonDecode, base64Decode, utf8, LineSplitter
import 'dart:typed_data'; // For Uint8List
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http; // HTTP package
// No longer importing flutter_client_sse
import 'firebase_options.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:web/web.dart' as html;
import 'widgets/section_preview.dart';
import 'widgets/connection_line.dart';
import 'widgets/drink_progress_glass.dart';
import 'widgets/method_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MixologistApp());
}

class MixologistApp extends StatelessWidget {
  const MixologistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: _SmoothScrollBehavior(),
      child: MaterialApp(
        title: 'Mixologist',
        theme: _buildLightTheme(),
        darkTheme: _buildDarkTheme(),
        themeMode: ThemeMode.system,
        home: const LoginScreen(),
      ),
    );
  }

  ThemeData _buildLightTheme() {
    const whiskey = Color(0xFF8B4513);
    const amber = Color(0xFFFFBF00);
    const ice = Color(0xFFE3F2FD);
    const bitters = Color(0xFF8B0000);
    const orangePeel = Color(0xFFFF8C00);

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: whiskey,
        brightness: Brightness.light,
        primary: whiskey,
        secondary: amber,
        surface: ice,
        error: bitters,
        tertiary: orangePeel,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.25),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.25),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
      ),
      cardTheme: CardThemeData(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  ThemeData _buildDarkTheme() {
    const whiskey = Color(0xFF8B4513);
    const amber = Color(0xFFFFBF00);
    const darkIce = Color(0xFF1A1A1A);
    const bitters = Color(0xFF8B0000);
    const orangePeel = Color(0xFFFF8C00);

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: whiskey,
        brightness: Brightness.dark,
        primary: amber,
        secondary: orangePeel,
        surface: darkIce,
        error: bitters,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.5, color: Colors.white),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.5, color: Colors.white),
        headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.25, color: Colors.white),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.25, color: Colors.white),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white70),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white70),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white60),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
        labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.white),
      ),
      cardTheme: CardThemeData(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        color: const Color(0xFF2A2A2A),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}

class _SmoothScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mixologist Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              await FirebaseAuth.instance.signInAnonymously();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              }
            } catch (e) {
              if (context.mounted) { // Check mounted before showing SnackBar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error signing in: $e')),
                );
              }
            }
          },
          child: const Text('Sign In Anonymously'),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _drinkQueryController = TextEditingController();
  bool _isLoadingRecipe = false;
  String? _recipeError;

  Future<void> _getRecipe() async {
    if (_drinkQueryController.text.isEmpty) {
      setState(() { _recipeError = 'Please enter a drink name.'; });
      return;
    }
    setState(() { _isLoadingRecipe = true; _recipeError = null; });
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8081/create'), // Changed port to 8081
        body: {'drink_query': _drinkQueryController.text},
      );
      setState(() { _isLoadingRecipe = false; });
      if (response.statusCode == 200) {
        final recipeData = jsonDecode(response.body);
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RecipeScreen(recipeData: recipeData)),
          );
        }
      } else {
        setState(() { _recipeError = 'Error fetching recipe: ${response.statusCode}'; });
      }
    } catch (e) {
      setState(() { _isLoadingRecipe = false; _recipeError = 'Failed to connect: $e'; });
    }
  }

  @override
  void dispose() {
    _drinkQueryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Mixologist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              final nav = Navigator.of(context);
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                nav.pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (user != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  user.isAnonymous
                      ? 'Signed in as: Anonymous (${user.uid.substring(0,6)}...)'
                      : 'Signed in as: ${user.displayName ?? user.email ?? '${user.uid.substring(0,6)}...'}',
                  textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            TextField(
              controller: _drinkQueryController,
              decoration: InputDecoration(
                labelText: 'Enter Drink Name',
                hintText: 'e.g., Margarita, Old Fashioned',
                border: const OutlineInputBorder(),
                errorText: _recipeError,
              ),
              onSubmitted: (_) => _getRecipe(),
            ),
            const SizedBox(height: 20),
            _isLoadingRecipe
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                    onPressed: _getRecipe,
                    child: const Text('Get Recipe', style: TextStyle(fontSize: 16)),
                  ),
          ],
        ),
      ),
    );
  }
}

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
  Map<String, Uint8List?> _specializedImages = {};
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

  void _completeStep(int stepIndex) {
    setState(() {
      _stepCompletion[stepIndex] = true;
    });
    _saveProgress(); // Save progress when step is completed
  }

  void _goToPreviousStep(int currentStepIndex) {
    if (currentStepIndex > 0) {
      setState(() {
        _stepCompletion[currentStepIndex - 1] = false;
      });
      _saveProgress(); // Save progress when step is unchecked
    }
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
    _connectToImageStream();
    _initializeIngredientChecklist();
    _initializeSpecializedImages();
    _initializeStepConnections();
    _loadCachedImages(); // Check for existing cached images
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreExpandedFromHash());
  }

  void _restoreExpandedFromHash() {
    final fragment = Uri.base.fragment;
    const sections = ['ingredients', 'method', 'equipment', 'variations'];
    if (sections.contains(fragment)) {
      setState(() {
        _expandedSection = fragment;
      });
    }
  }

  void _toggleExpandedSection(String id) {
    setState(() {
      if (_expandedSection == id) {
        _expandedSection = null;
        if (kIsWeb) {
          html.window.history.replaceState(null, '', '#');
        }
      } else {
        _expandedSection = id;
        if (kIsWeb) {
          html.window.history.replaceState(null, '', '#$id');
        }
        
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
    _specializedImages = {
      'glassware': null,
      'garnish': null,
    };
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
    
    // Initialize equipment images
    if (widget.recipeData['equipment_needed'] is List) {
      for (var equipment in widget.recipeData['equipment_needed']) {
        final equipmentName = equipment['item'] ?? equipment;
        _specializedImages['equipment_$equipmentName'] = null;
        _imageGenerationProgress['equipment_$equipmentName'] = false;
      }
    }
    
    // Initialize method/step images
    if (widget.recipeData['steps'] is List) {
      for (int i = 0; i < widget.recipeData['steps'].length; i++) {
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
    if (widget.recipeData['equipment_needed'] is List) {
      final equipment = widget.recipeData['equipment_needed'] as List;
      for (var item in equipment) {
        final equipmentName = item['item'] ?? item;
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
    }
  }

  void _initializeIngredientChecklist() {
    if (widget.recipeData['ingredients'] is List) {
      for (var ingredient in widget.recipeData['ingredients']) {
        _ingredientChecklist[ingredient['name']] = false;
      }
    }
    
    // Epic 3: Initialize step completion tracking
    if (widget.recipeData['steps'] is List) {
      for (int i = 0; i < widget.recipeData['steps'].length; i++) {
        _stepCompletion[i] = false;
      }
    }
    
    // Load saved progress
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      if (kIsWeb) {
        await _loadProgressWeb();
        return;
      }
      
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
      // Fallback to web storage if SharedPreferences fails
      if (kIsWeb) {
        await _loadProgressWeb();
      }
    }
  }

  Future<void> _saveProgress() async {
    try {
      if (kIsWeb) {
        await _saveProgressWeb();
        return;
      }
      
      final prefs = await SharedPreferences.getInstance();
      final recipeKey = _getRecipeKey();
      
      // Save ingredient checklist
      for (String ingredient in _ingredientChecklist.keys) {
        await prefs.setBool('${recipeKey}_ingredient_$ingredient', _ingredientChecklist[ingredient]!);
      }
      
      // Save step completion
      for (int step in _stepCompletion.keys) {
        await prefs.setBool('${recipeKey}_step_$step', _stepCompletion[step]!);
      }
    } catch (e) {
      // Fallback to web storage if SharedPreferences fails
      if (kIsWeb) {
        await _saveProgressWeb();
      }
    }
  }

  String _getRecipeKey() {
    // Generate a unique key for this recipe based on its content
    final recipeName = widget.recipeData['name'] ?? 'unknown';
    final ingredientCount = (widget.recipeData['ingredients'] as List?)?.length ?? 0;
    final stepCount = (widget.recipeData['steps'] as List?)?.length ?? 0;
    return '${recipeName}_${ingredientCount}_$stepCount';
  }


  Future<void> _saveProgressWeb() async {
    if (!kIsWeb) return;
    
    try {
      final recipeKey = _getRecipeKey();
      
      // Save ingredient checklist
      for (String ingredient in _ingredientChecklist.keys) {
        html.window.localStorage['${recipeKey}_ingredient_$ingredient'] = 
            _ingredientChecklist[ingredient].toString();
      }
      
      // Save step completion
      for (int step in _stepCompletion.keys) {
        html.window.localStorage['${recipeKey}_step_$step'] = 
            _stepCompletion[step].toString();
      }
    } catch (e) {
      // Silently fail - localStorage may not be available
    }
  }

  Future<void> _loadProgressWeb() async {
    if (!kIsWeb) return;
    
    try {
      final recipeKey = _getRecipeKey();
      
      // Load ingredient checklist
      final ingredientKeys = _ingredientChecklist.keys.toList();
      for (String ingredient in ingredientKeys) {
        final saved = html.window.localStorage['${recipeKey}_ingredient_$ingredient'];
        if (saved != null) {
          _ingredientChecklist[ingredient] = saved.toLowerCase() == 'true';
        }
      }
      
      // Load step completion
      final stepKeys = _stepCompletion.keys.toList();
      for (int step in stepKeys) {
        final saved = html.window.localStorage['${recipeKey}_step_$step'];
        if (saved != null) {
          _stepCompletion[step] = saved.toLowerCase() == 'true';
        }
      }
      
      // Update UI if any progress was loaded
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      // Silently fail - localStorage may not be available
    }
  }

  void _initializeStepConnections() {
    final ingredients = (widget.recipeData['ingredients'] as List?)
            ?.map((e) => e['name'].toString().toLowerCase())
            .toList() ??
        [];
    final equipment = (widget.recipeData['equipment_needed'] as List?)
            ?.map((e) => (e['item'] ?? e).toString().toLowerCase())
            .toList() ??
        [];
    final steps = (widget.recipeData['steps'] as List?)?.map((e) => e.toString()) ?? [];
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
  
  // Navigate to a new cocktail recipe
  Future<void> _loadRelatedCocktail(String cocktailName) async {
    setState(() {
      _isLoadingRelatedCocktail = true;
    });
    
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8081/create'),
        body: {'drink_query': cocktailName},
      );
      
      if (response.statusCode == 200) {
        final newRecipeData = jsonDecode(response.body);
        if (mounted) {
          // Navigate to the new recipe page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeScreen(recipeData: newRecipeData),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading $cocktailName: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load $cocktailName: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRelatedCocktail = false;
        });
      }
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
        'drink_context': widget.recipeData['drink_name'] ?? '',
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
        'drink_context': widget.recipeData['drink_name'] ?? '',
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
        'drink_context': widget.recipeData['drink_name'] ?? '',
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
                // Ignore parsing errors
              }
            }
          },
          onError: (error) {
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
      if (mounted) {
        setState(() {
          _imageGenerationProgress[imageType] = false;
        });
      }
    }
  }
  
  // Generate all visual assets for the recipe
  Future<void> _generateRecipeVisuals() async {
    setState(() {
      _isGeneratingVisuals = true;
    });
    
    // Generate glassware image (if not already cached)
    final glassType = widget.recipeData['serving_glass'];
    if (glassType != null && glassType.isNotEmpty && _specializedImages['glassware'] == null) {
      await _generateSpecializedImage('glassware', glassType);
    }
    
    // Generate garnish image (if not already cached)
    final garnishes = widget.recipeData['garnish'];
    if (garnishes is List && garnishes.isNotEmpty && _specializedImages['garnish'] == null) {
      await _generateSpecializedImage('garnish', garnishes.first);
    }
    
    // Generate ALL ingredient images (not just first 3)
    if (widget.recipeData['ingredients'] is List) {
      final ingredients = widget.recipeData['ingredients'] as List;
      for (var ingredient in ingredients) {
        final ingredientName = ingredient['name'];
        final imageKey = 'ingredient_$ingredientName';
        
        // Only generate if not already cached or being generated
        if (_specializedImages[imageKey] == null && _imageGenerationProgress[imageKey] != true) {
          await _generateSpecializedImage(imageKey, ingredientName);
          // Add delay between requests to prevent overload
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }
    }
    
    // Generate equipment images
    if (widget.recipeData['equipment_needed'] is List) {
      final equipment = widget.recipeData['equipment_needed'] as List;
      for (var item in equipment) {
        final equipmentName = item['item'] ?? item;
        final imageKey = 'equipment_$equipmentName';
        
        // Only generate if not already cached or being generated
        if (_specializedImages[imageKey] == null && _imageGenerationProgress[imageKey] != true) {
          await _generateSpecializedImage(imageKey, equipmentName);
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }
    }
    
    // Generate method/step images
    if (widget.recipeData['steps'] is List) {
      final steps = widget.recipeData['steps'] as List;
      for (int i = 0; i < steps.length; i++) {
        final stepDescription = steps[i];
        final imageKey = 'method_step_$i';
        
        // Only generate if not already cached or being generated
        if (_specializedImages[imageKey] == null && _imageGenerationProgress[imageKey] != true) {
          await _generateSpecializedImage(imageKey, stepDescription, context: i.toString());
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }
    }
    
    setState(() {
      _isGeneratingVisuals = false;
    });
  }

  void _connectToImageStream() async {
    setState(() {
      _currentImageBytes = null;
      _imageStreamError = null;
      _isImageStreamComplete = false;
    });

    final imageDescription = widget.recipeData['drink_image_description'] ?? 'A delicious cocktail.';
    final drinkName = widget.recipeData['drink_name'] ?? 'Cocktail';
    final servingGlass = widget.recipeData['serving_glass'] ?? '';
    final ingredients = widget.recipeData['ingredients'];

    _imageStreamSubscription?.cancel(); // Cancel previous subscription

    final request = http.Request('POST', Uri.parse('http://127.0.0.1:8081/generate_image')); // Changed port to 8081
    request.headers.addAll({"Accept": "text/event-stream", "Cache-Control": "no-cache"});
    request.bodyFields = { // Use bodyFields for form data
        'image_description': imageDescription,
        'drink_query': drinkName,
        'serving_glass': servingGlass,
        'ingredients': jsonEncode(ingredients),
        'steps': jsonEncode(widget.recipeData['steps'] ?? []),
        'garnish': jsonEncode(widget.recipeData['garnish'] ?? []),
        'equipment_needed': jsonEncode(widget.recipeData['equipment_needed'] ?? []),
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
                  _imageStreamSubscription?.cancel(); 
                } else if (jsonData['type'] == 'error') {
                  if (mounted) {
                    setState(() {
                      _imageStreamError = jsonData['message'] ?? 'Unknown stream error';
                      _currentImageBytes = null;
                    });
                  }
                  _imageStreamSubscription?.cancel();
                }
              } catch (e) {
                if (mounted) { setState(() { _imageStreamError = "Error parsing stream data."; });}
              }
            }
          },
          onError: (error) {
            if (mounted) { setState(() { _imageStreamError = 'SSE stream error: $error'; _currentImageBytes = null; });}
          },
          onDone: () {
            if (mounted && !_isImageStreamComplete && _imageStreamError == null) {
                 // setState(() { _imageStreamError = 'Image stream closed prematurely.'; });
            }
          },
          cancelOnError: true,
        );
      } else {
        if (mounted) { setState(() { _imageStreamError = 'Failed to connect to image stream: ${response.statusCode}';});}
      }
    } catch (e) {
      if (mounted) { setState(() { _imageStreamError = 'Error connecting to image stream: $e';});}
    }
  }

  @override
  void dispose() {
    _imageStreamSubscription?.cancel();
    _httpClient.close(); // Close the client when the widget is disposed
    super.dispose();
  }
  
  // Visual Navigation System
  Widget _buildNavigationBar() {
    final sections = [
      {'id': 'overview', 'icon': Icons.home, 'label': 'Overview'},
      {'id': 'ingredients', 'icon': Icons.local_grocery_store, 'label': 'Ingredients'},
      {'id': 'method', 'icon': Icons.format_list_numbered, 'label': 'Method'},
      {'id': 'equipment', 'icon': Icons.build, 'label': 'Equipment'},
      {'id': 'variations', 'icon': Icons.auto_awesome, 'label': 'Variations'},
    ];
    
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: sections.length,
        itemBuilder: (context, index) {
          final section = sections[index];
          final isSelected = _selectedSection == section['id'];
          
          return Container(
            width: 80,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedSection = section['id'] as String;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        section['icon'] as IconData,
                        color: isSelected 
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        section['label'] as String,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isSelected 
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  // Section Content Builders
  Widget _buildOverviewSection() {
    return Column(
      children: [
        // Main layout: Image left, Details right
        SizedBox(
          height: 500,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Hero Image
              Expanded(
                flex: 7,
                child: Card(
                  elevation: 8,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.grey[100]!,
                          Colors.grey[200]!,
                        ],
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_currentImageBytes != null)
                          Image.memory(
                            _currentImageBytes!,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                        if (_currentImageBytes == null && _imageStreamError == null)
                          const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Creating your cocktail image...'),
                            ],
                          ),
                        // Time Overlay - Top Right
                        if (_currentImageBytes != null)
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${widget.recipeData['preparation_time_minutes'] ?? 5} min',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        // Alcohol Overlay - Bottom Right  
                        if (_currentImageBytes != null)
                          Positioned(
                            bottom: 80, // Above the generate button
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${(widget.recipeData['alcohol_content'] * 100).toStringAsFixed(1)}% ABV',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        // Generate Visuals Button
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: FloatingActionButton.extended(
                            onPressed: _isGeneratingVisuals ? null : _generateRecipeVisuals,
                            icon: _isGeneratingVisuals 
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.auto_awesome),
                            label: Text(_isGeneratingVisuals ? 'Generating All Images...' : 'Generate All Visuals'),
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            foregroundColor: Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Right: Details Sidebar
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      // Quick Stats Cards
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    Icon(Icons.local_bar, color: Theme.of(context).colorScheme.secondary),
                                    const SizedBox(height: 4),
                                    Text('${(widget.recipeData['alcohol_content'] * 100).toStringAsFixed(1)}% ABV'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    Icon(Icons.timer, color: Theme.of(context).colorScheme.secondary),
                                    const SizedBox(height: 4),
                                    Text('${widget.recipeData['preparation_time_minutes'] ?? 5} min'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Comprehensive Variations Section
                      if (widget.recipeData['suggested_variations'] is List && 
                          (widget.recipeData['suggested_variations'] as List).isNotEmpty) ...[
                        Text('Variations', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Column(
                          children: [
                            for (var variation in widget.recipeData['suggested_variations'])
                              Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      variation['name'] ?? 'Variation',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (variation['description'] != null && variation['description'].toString().isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        variation['description'],
                                        style: Theme.of(context).textTheme.bodySmall,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                    if (variation['changes'] is List && (variation['changes'] as List).isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Wrap(
                                        spacing: 4,
                                        children: (variation['changes'] as List).take(3)
                                            .map((change) => Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    change,
                                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                      color: Theme.of(context).colorScheme.secondary,
                                                    ),
                                                  ),
                                                ))
                                            .toList(),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Related Cocktails Section
                      if (widget.recipeData['related_cocktails'] is List && 
                          (widget.recipeData['related_cocktails'] as List).isNotEmpty) ...[
                        Text('Related Cocktails', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 80,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.recipeData['related_cocktails'].length,
                            itemBuilder: (context, index) {
                              final cocktail = widget.recipeData['related_cocktails'][index];
                              return Container(
                                width: 120,
                                margin: const EdgeInsets.only(right: 8),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _isLoadingRelatedCocktail 
                                        ? null 
                                        : () => _loadRelatedCocktail(cocktail),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.local_bar,
                                            size: 20,
                                            color: Theme.of(context).colorScheme.secondary,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            cocktail,
                                            style: Theme.of(context).textTheme.labelSmall,
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Food Pairings Section
                      if (widget.recipeData['food_pairings'] is List && 
                          (widget.recipeData['food_pairings'] as List).isNotEmpty) ...[
                        Text('Food Pairings', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: (widget.recipeData['food_pairings'] as List)
                              .map((pairing) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.tertiaryContainer.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.restaurant, 
                                          size: 12, 
                                          color: Theme.of(context).colorScheme.tertiary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          pairing,
                                          style: Theme.of(context).textTheme.labelSmall,
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // History Section
                      if (widget.recipeData['drink_history'] != null && 
                          widget.recipeData['drink_history'].toString().isNotEmpty) ...[
                        Text('History', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              widget.recipeData['drink_history'].toString(),
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Debug: Print trivia data
                      Builder(
                        builder: (context) {
                          print('=== TRIVIA DEBUG ===');
                          print('Recipe data keys: ${widget.recipeData.keys.toList()}');
                          print('drink_trivia exists: ${widget.recipeData.containsKey('drink_trivia')}');
                          print('drink_trivia value: ${widget.recipeData['drink_trivia']}');
                          print('drink_trivia type: ${widget.recipeData['drink_trivia'].runtimeType}');
                          if (widget.recipeData['drink_trivia'] is List) {
                            print('drink_trivia length: ${(widget.recipeData['drink_trivia'] as List).length}');
                          }
                          print('===================');
                          return const SizedBox.shrink();
                        },
                      ),
                      
                      // Trivia Section
                      if (widget.recipeData['drink_trivia'] is List && 
                          (widget.recipeData['drink_trivia'] as List).isNotEmpty) ...[
                        Text('Trivia', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        ...((widget.recipeData['drink_trivia'] as List).take(3).map((trivia) {
                          final fact = trivia['fact'] ?? trivia.toString();
                          final category = trivia['category'] ?? '';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (category.isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        margin: const EdgeInsets.only(bottom: 6),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.primaryContainer,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          category.toUpperCase(),
                                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    Text(
                                      fact,
                                      style: Theme.of(context).textTheme.bodySmall,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        })),
                      ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildSectionPreviews(),
      ],
    );
  }

  Widget _buildSectionPreviews() {
    return Stack(
      children: [
        Column(
          children: [
            SectionPreview(
              title: 'Method',
              icon: Icons.format_list_numbered,
              previewContent: _buildMethodPreviewWidget(),
              expandedContent: _buildMethodSection(),
              totalItems: (widget.recipeData['steps'] as List?)?.length ?? 0,
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
              totalItems: (widget.recipeData['equipment_needed'] as List?)?.length ?? 0,
              expanded: _expandedSection == 'equipment',
              onOpen: () => _toggleExpandedSection('equipment'),
              onClose: () => _toggleExpandedSection('equipment'),
            ),
            const SizedBox(height: 12),
            SectionPreview(
              title: 'Variations',
              icon: Icons.auto_awesome,
              previewContent: _buildVariationsPreviewWidget(),
              expandedContent: _buildVariationsSection(),
              totalItems: (widget.recipeData['suggested_variations'] as List?)?.length ?? 0,
              expanded: _expandedSection == 'variations',
              onOpen: () => _toggleExpandedSection('variations'),
              onClose: () => _toggleExpandedSection('variations'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIngredientsPreviewWidget() {
    final ingredients =
        (widget.recipeData['ingredients'] as List?)?.take(4).toList() ?? [];
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
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

  Widget _buildMethodPreviewWidget() {
    final steps = (widget.recipeData['steps'] as List?) ?? [];
    if (steps.isEmpty) return const SizedBox.shrink();
    return Text(
      steps.first.toString(),
      style: Theme.of(context).textTheme.bodyMedium,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildEquipmentPreviewWidget() {
    final equipment =
        (widget.recipeData['equipment_needed'] as List?)?.take(3).toList() ?? [];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: equipment.map((e) {
        final name = e['item'] ?? e.toString();
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
              color: Theme.of(context).colorScheme.secondary,
            ),
          );
        }
        return Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: child);
      }).toList(),
    );
  }

  Widget _buildVariationsPreviewWidget() {
    final variations =
        (widget.recipeData['suggested_variations'] as List?)?.take(3).toList() ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: variations.map((v) {
        final name = v['name'] ?? '';
        return Row(
          children: [
            Icon(
              Icons.arrow_right,
              size: 14,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                name,
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildIngredientIcons() {
    final ingredients = (widget.recipeData['ingredients'] as List?) ?? [];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ingredients.map((ingredient) {
          final name = ingredient['name'];
          final key = _ingredientIconKeys.putIfAbsent(name, () => GlobalKey());
          final active = _ingredientActive(name);
          return Container(
            key: key,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(
                  color: active
                      ? Theme.of(context).colorScheme.secondary
                      : Colors.transparent,
                  width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(name,
                style: Theme.of(context).textTheme.labelSmall),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEquipmentIcons() {
    final equipment = (widget.recipeData['equipment_needed'] as List?) ?? [];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: equipment.map((e) {
          final name = e['item'] ?? e.toString();
          final key = _equipmentIconKeys.putIfAbsent(name, () => GlobalKey());
          final active = _equipmentActive(name);
          return Container(
            key: key,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withValues(alpha: 0.6),
                        blurRadius: 6,
                      )
                    ]
                  : [],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.build,
                size: 16,
                color: active
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.primary),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildIngredientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Serving Size Controls
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Serving Size', style: Theme.of(context).textTheme.titleMedium),
                    Row(
                      children: [
                        Text('oz', style: Theme.of(context).textTheme.bodySmall),
                        Switch(
                          value: _isMetric,
                          onChanged: (value) => setState(() => _isMetric = value),
                          activeColor: Theme.of(context).colorScheme.secondary,
                        ),
                        Text('ml', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _servingSize > 1 ? () => setState(() => _servingSize--) : null,
                      icon: const Icon(Icons.remove_circle_outline),
                      iconSize: 32,
                    ),
                    Container(
                      constraints: const BoxConstraints(minWidth: 40),
                      child: Text(
                        '$_servingSize',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      onPressed: _servingSize < 12 ? () => setState(() => _servingSize++) : null,
                      icon: const Icon(Icons.add_circle_outline),
                      iconSize: 32,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Visual Ingredients Grid
        if (widget.recipeData['ingredients'] is List)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: (widget.recipeData['ingredients'] as List).length,
            itemBuilder: (context, index) {
              final ingredient = widget.recipeData['ingredients'][index];
              final ingredientName = ingredient['name'];
              final imageKey = 'ingredient_$ingredientName';
              final hasImage = _specializedImages[imageKey] != null;
              final isGenerating = _imageGenerationProgress[imageKey] == true;
              
              return Card(
                elevation: 4,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      // Ingredient Image or Placeholder
                      Expanded(
                        flex: 3,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: hasImage
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    _specializedImages[imageKey]!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : isGenerating
                                  ? const Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          CircularProgressIndicator(strokeWidth: 2),
                                          SizedBox(height: 8),
                                          Text('Generating...', style: TextStyle(fontSize: 10)),
                                        ],
                                      ),
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.grey[300]!, width: 1),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            _getIngredientIcon(ingredientName),
                                            size: 32,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            ingredientName,
                                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Tap "Generate Visuals"',
                                            style: TextStyle(
                                              fontSize: 8,
                                              color: Colors.grey[600],
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Ingredient Details
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            Text(
                              ingredientName,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _scaleIngredientAmount(ingredient['quantity'], _servingSize),
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Checkbox(
                              value: _ingredientChecklist[ingredientName] ?? false,
                              onChanged: (value) {
                                setState(() {
                                  _ingredientChecklist[ingredientName] = value ?? false;
                                });
                                _saveProgress(); // Save progress when ingredient is checked/unchecked
                              },
                              activeColor: Theme.of(context).colorScheme.secondary,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
  
  Widget _buildMethodSection() {
    return Stack(
      children: [
        Column(
          children: [
            if (widget.recipeData['ingredients'] is List)
              _buildIngredientIcons(),
            if (widget.recipeData['ingredients'] is List)
              const SizedBox(height: 8),
            if (widget.recipeData['equipment_needed'] is List)
              _buildEquipmentIcons(),
            const SizedBox(height: 16),
        // Progress indicator with animated glass
        if (widget.recipeData['steps'] is List)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Progress', style: Theme.of(context).textTheme.titleMedium),
                      Text(
                        '${_stepCompletion.values.where((completed) => completed).length}/${widget.recipeData['steps'].length}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Animated glass visualization
                      DrinkProgressGlass(
                        progress: _currentDrinkProgress,
                        liquidColors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Traditional progress bar
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LinearProgressIndicator(
                              value: _stepCompletion.values.where((completed) => completed).length / 
                                     widget.recipeData['steps'].length,
                              backgroundColor: Theme.of(context).colorScheme.surface,
                              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getProgressText(),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        // Step Cards with MethodCard widgets in a grid
        if (widget.recipeData['steps'] is List)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 3 : 
                             MediaQuery.of(context).size.width > 800 ? 2 : 1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2, // Slightly taller to accommodate content
            ),
            itemCount: widget.recipeData['steps'].length,
            itemBuilder: (context, i) {
              final key = _stepCardKeys.length > i ? _stepCardKeys[i] : GlobalKey();
              if (_stepCardKeys.length <= i) _stepCardKeys.add(key);
              final step = widget.recipeData['steps'][i];
              final stepImageKey = 'method_step_$i';
              final stepImageBytes = _specializedImages[stepImageKey];
              final isGeneratingStepImage = _imageGenerationProgress[stepImageKey] == true;
              
              return Container(
                key: key,
                child: MouseRegion(
                  onEnter: (_) => setState(() => _hoveredStep = i),
                  onExit: (_) => setState(() => _hoveredStep = null),
                  child: GestureDetector(
                    onTap: () => _completeStep(i),
                    child: MethodCard(
                      data: MethodCardData(
                        stepNumber: i + 1,
                        title: '',
                        description: step,
                        imageBytes: stepImageBytes,
                        isGenerating: isGeneratingStepImage,
                        imageAlt: 'Step ${i + 1} illustration',
                        isCompleted: _stepCompletion[i] ?? false,
                        duration: '30 sec',
                        difficulty: 'Easy',
                        proTip: _getProTipForStep(step),
                        tipCategory: _getTipCategoryForStep(step),
                      ),
                      state: _stepCompletion[i] == true 
                          ? MethodCardState.completed 
                          : _hoveredStep == i 
                              ? MethodCardState.active 
                              : MethodCardState.defaultState,
                      onCompleted: () => _completeStep(i),
                      onPrevious: () => _goToPreviousStep(i),
                      enableSwipeGestures: true,
                      enableKeyboardNavigation: true,
                      enableAutoAdvance: true,
                      autoAdvanceDuration: const Duration(seconds: 15),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    ),
        if (_hoveredStep != null)
          ConnectionLine(
            from: _stepCardKeys[_hoveredStep!],
            to: [
              ...?_stepIngredientMap[_hoveredStep!]
                  ?.map((n) => _ingredientIconKeys[n])
                  .whereType<GlobalKey>(),
              ...?_stepEquipmentMap[_hoveredStep!]
                  ?.map((n) => _equipmentIconKeys[n])
                  .whereType<GlobalKey>(),
            ],
            active: true,
          ),
      ],
    );
  }
  
  Widget _buildEquipmentSection() {
    if (widget.recipeData['equipment_needed'] is! List || 
        (widget.recipeData['equipment_needed'] as List).isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No specific equipment required'),
        ),
      );
    }
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: (widget.recipeData['equipment_needed'] as List).length,
      itemBuilder: (context, index) {
        final equipment = widget.recipeData['equipment_needed'][index];
        final equipmentName = equipment['item'] ?? equipment;
        final imageKey = 'equipment_$equipmentName';
        final hasImage = _specializedImages[imageKey] != null;
        final isGenerating = _imageGenerationProgress[imageKey] == true;
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Equipment Image or Placeholder
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: hasImage
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              _specializedImages[imageKey]!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : isGenerating
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(strokeWidth: 2),
                                    SizedBox(height: 8),
                                    Text('Generating...', style: TextStyle(fontSize: 10)),
                                  ],
                                ),
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.build, 
                                         color: Theme.of(context).colorScheme.secondary),
                                    const SizedBox(height: 4),
                                    Text('Use Generate Visuals', 
                                         style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                                         textAlign: TextAlign.center),
                                  ],
                                ),
                              ),
                  ),
                ),
                const SizedBox(height: 8),
                // Equipment Details
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Text(
                        equipmentName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (equipment is Map && equipment['essential'] == true)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Essential',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSecondary,
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
      },
    );
  }
  
  Widget _buildVariationsSection() {
    return Column(
      children: [
        // Related Cocktails
        if (widget.recipeData['related_cocktails'] is List && 
            (widget.recipeData['related_cocktails'] as List).isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Related Cocktails', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.recipeData['related_cocktails'].length,
                  itemBuilder: (context, index) {
                    final cocktail = widget.recipeData['related_cocktails'][index];
                    return Container(
                      width: 160,
                      margin: const EdgeInsets.only(right: 12),
                      child: Card(
                        elevation: 4,
                        child: InkWell(
                          onTap: _isLoadingRelatedCocktail 
                              ? null 
                              : () => _loadRelatedCocktail(cocktail),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _isLoadingRelatedCocktail
                                    ? const SizedBox(
                                        width: 32,
                                        height: 32,
                                        child: CircularProgressIndicator(strokeWidth: 3),
                                      )
                                    : Icon(
                                        Icons.local_bar,
                                        size: 32,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                const SizedBox(height: 8),
                                Text(
                                  cocktail,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: _isLoadingRelatedCocktail 
                                        ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)
                                        : null,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (!_isLoadingRelatedCocktail)
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Tap to try',
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: Theme.of(context).colorScheme.secondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        // Suggested Variations
        if (widget.recipeData['suggested_variations'] is List && 
            (widget.recipeData['suggested_variations'] as List).isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Variations', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              for (var variation in widget.recipeData['suggested_variations'])
                Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          variation['name'] ?? 'Variation',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          variation['description'] ?? '',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (variation['changes'] is List)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Wrap(
                              spacing: 8,
                              children: (variation['changes'] as List)
                                  .map((change) => Chip(
                                        label: Text(change),
                                        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                                      ))
                                  .toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        // Food Pairings
        if (widget.recipeData['food_pairings'] is List && 
            (widget.recipeData['food_pairings'] as List).isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text('Food Pairings', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (widget.recipeData['food_pairings'] as List)
                    .map((pairing) => Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.restaurant, 
                                     size: 16, 
                                     color: Theme.of(context).colorScheme.secondary),
                                const SizedBox(width: 4),
                                Text(pairing),
                              ],
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
      ],
    );
  }
  
  Widget _getCurrentSectionContent() {
    switch (_selectedSection) {
      case 'ingredients':
        return _buildIngredientsSection();
      case 'method':
        return _buildMethodSection();
      case 'equipment':
        return _buildEquipmentSection();
      case 'variations':
        return _buildVariationsSection();
      case 'overview':
      default:
        return _buildOverviewSection();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipeData['drink_name'] ?? 'Recipe'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      body: Column(
        children: [
          // Visual Navigation Bar
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
            child: _buildNavigationBar(),
          ),
          // Section Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: _getCurrentSectionContent(),
            ),
          ),
        ],
      ),
    );
  }
}
