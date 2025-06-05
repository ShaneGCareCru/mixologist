import 'dart:async'; // For StreamSubscription
import 'dart:convert'; // For jsonDecode, base64Decode, utf8, LineSplitter
import 'dart:typed_data'; // For Uint8List
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http; // HTTP package
// No longer importing flutter_client_sse
import 'firebase_options.dart';

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
    return MaterialApp(
      title: 'Mixologist',
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,
      home: const LoginScreen(),
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
              print("Signed in anonymously");
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              }
            } catch (e) {
              print("Error signing in anonymously: $e");
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
        print('Error fetching recipe: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      setState(() { _isLoadingRecipe = false; _recipeError = 'Failed to connect: $e'; });
      print('Exception fetching recipe: $e');
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
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
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
                      : 'Signed in as: ${user.displayName ?? user.email ?? user.uid.substring(0,6)+"..."}',
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
  Map<String, bool> _ingredientChecklist = {};
  
  // Epic 3: Visual Recipe Steps
  Map<int, bool> _stepCompletion = {};

  @override
  void initState() {
    super.initState();
    _connectToImageStream();
    _initializeIngredientChecklist();
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
              print("SSE Data: $eventDataString");
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
                  print("Image stream complete from server.");
                  _imageStreamSubscription?.cancel(); 
                } else if (jsonData['type'] == 'error') {
                  if (mounted) {
                    setState(() {
                      _imageStreamError = jsonData['message'] ?? 'Unknown stream error';
                      _currentImageBytes = null;
                    });
                  }
                  print("Error from image stream: ${jsonData['message']}");
                  _imageStreamSubscription?.cancel();
                }
              } catch (e) {
                print("Error parsing SSE JSON data: $e. Data: $eventDataString");
                if (mounted) { setState(() { _imageStreamError = "Error parsing stream data."; });}
              }
            }
          },
          onError: (error) {
            print('SSE Stream Listen Error: $error');
            if (mounted) { setState(() { _imageStreamError = 'SSE stream error: $error'; _currentImageBytes = null; });}
          },
          onDone: () {
            print('SSE Stream Listen Done.');
            if (mounted && !_isImageStreamComplete && _imageStreamError == null) {
                 // setState(() { _imageStreamError = 'Image stream closed prematurely.'; });
            }
          },
          cancelOnError: true,
        );
      } else {
        print('SSE initial request failed: ${response.statusCode} ${response.reasonPhrase}');
        if (mounted) { setState(() { _imageStreamError = 'Failed to connect to image stream: ${response.statusCode}';});}
      }
    } catch (e) {
      print('Error sending SSE request: $e');
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipeData['drink_name'] ?? 'Recipe'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Card(
              elevation: 8,
              margin: const EdgeInsets.only(bottom: 8),
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: 300,
                  maxHeight: 400,
                ),
                width: double.infinity,
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
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 500),
                        opacity: 1.0,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.memory(
                            _currentImageBytes!,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ),
                    if (_imageStreamError != null)
                      Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red[600],
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Image Generation Failed',
                              style: TextStyle(
                                color: Colors.red[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _imageStreamError!,
                              style: TextStyle(color: Colors.red[600]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    if (_currentImageBytes == null && _imageStreamError == null)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                            ),
                            child: const CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Creating your cocktail image...',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (_currentImageBytes != null && !_isImageStreamComplete)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Enhancing...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (_isImageStreamComplete && _currentImageBytes != null)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Complete',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '${widget.recipeData['drink_name']}',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.local_bar, color: Theme.of(context).colorScheme.secondary, size: 20),
                        const SizedBox(width: 8),
                        Text('${(widget.recipeData['alcohol_content'] * 100).toStringAsFixed(1)}% ABV', 
                             style: Theme.of(context).textTheme.bodyLarge),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.wine_bar, color: Theme.of(context).colorScheme.secondary, size: 20),
                        const SizedBox(width: 8),
                        Text('${widget.recipeData['serving_glass']}', 
                             style: Theme.of(context).textTheme.bodyLarge),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.grain, color: Theme.of(context).colorScheme.secondary, size: 20),
                        const SizedBox(width: 8),
                        Text('${widget.recipeData['rim']}', 
                             style: Theme.of(context).textTheme.bodyLarge),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Epic 2: Task 2.1 - Serving Size Calculator Component
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Ingredients', style: Theme.of(context).textTheme.titleLarge),
                        Row(
                          children: [
                            // Epic 2: Task 2.2 - Unit Conversion Toggle
                            Text('oz', style: Theme.of(context).textTheme.bodySmall),
                            Switch(
                              value: _isMetric,
                              onChanged: (value) {
                                setState(() {
                                  _isMetric = value;
                                });
                              },
                              activeColor: Theme.of(context).colorScheme.secondary,
                            ),
                            Text('ml', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Serving Size Calculator
                    Row(
                      children: [
                        Text('Servings:', style: Theme.of(context).textTheme.bodyLarge),
                        const SizedBox(width: 16),
                        IconButton(
                          onPressed: _servingSize > 1 ? () {
                            setState(() {
                              _servingSize--;
                            });
                          } : null,
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
                          onPressed: _servingSize < 12 ? () {
                            setState(() {
                              _servingSize++;
                            });
                          } : null,
                          icon: const Icon(Icons.add_circle_outline),
                          iconSize: 32,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Epic 2: Task 2.3 - Ingredient Checklist
                    if (widget.recipeData['ingredients'] is List) ...[
                      Text(
                        'Progress: ${_ingredientChecklist.values.where((checked) => checked).length}/${_ingredientChecklist.length} ingredients ready',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      for (var ingredient in widget.recipeData['ingredients'])
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Checkbox(
                                value: _ingredientChecklist[ingredient['name']] ?? false,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _ingredientChecklist[ingredient['name']] = value ?? false;
                                  });
                                },
                                activeColor: Theme.of(context).colorScheme.secondary,
                              ),
                              Expanded(
                                child: Text(
                                  '${ingredient['name']}: ${_scaleIngredientAmount(ingredient['quantity'], _servingSize)}',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    decoration: _ingredientChecklist[ingredient['name']] == true 
                                        ? TextDecoration.lineThrough 
                                        : null,
                                    color: _ingredientChecklist[ingredient['name']] == true 
                                        ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 12),
                      if (_ingredientChecklist.values.any((checked) => checked))
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _ingredientChecklist.updateAll((key, value) => false);
                            });
                          },
                          child: const Text('Reset Checklist'),
                        ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Epic 3: Visual Recipe Steps with Progress Tracking
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Instructions', style: Theme.of(context).textTheme.titleLarge),
                        if (widget.recipeData['steps'] is List)
                          Text(
                            '${_stepCompletion.values.where((completed) => completed).length}/${widget.recipeData['steps'].length} completed',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Epic 3: Task 3.3 - Progress Bar
                    if (widget.recipeData['steps'] is List)
                      LinearProgressIndicator(
                        value: _stepCompletion.values.where((completed) => completed).length / 
                               widget.recipeData['steps'].length,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
                      ),
                    const SizedBox(height: 16),
                    // Epic 3: Task 3.1 - Step Card Components
                    if (widget.recipeData['steps'] is List)
                      for (var i = 0; i < widget.recipeData['steps'].length; i++)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Card(
                            elevation: _stepCompletion[i] == true ? 2 : 4,
                            color: _stepCompletion[i] == true 
                                ? Theme.of(context).colorScheme.secondaryContainer
                                : Theme.of(context).colorScheme.surface,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Step number badge
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: _stepCompletion[i] == true 
                                          ? Theme.of(context).colorScheme.secondary
                                          : Theme.of(context).colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: _stepCompletion[i] == true
                                          ? Icon(
                                              Icons.check,
                                              color: Theme.of(context).colorScheme.onSecondary,
                                              size: 18,
                                            )
                                          : Text(
                                              '${i + 1}',
                                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                                color: Theme.of(context).colorScheme.onPrimary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Step content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.recipeData['steps'][i],
                                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                            decoration: _stepCompletion[i] == true 
                                                ? TextDecoration.lineThrough 
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Complete checkbox
                                        Row(
                                          children: [
                                            Checkbox(
                                              value: _stepCompletion[i] ?? false,
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  _stepCompletion[i] = value ?? false;
                                                });
                                              },
                                              activeColor: Theme.of(context).colorScheme.secondary,
                                            ),
                                            Text(
                                              'Complete',
                                              style: Theme.of(context).textTheme.bodyMedium,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ),
            // Enhanced sections with better styling
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.local_florist, color: Theme.of(context).colorScheme.secondary),
                        const SizedBox(width: 8),
                        Text('Garnish', style: Theme.of(context).textTheme.titleLarge),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (widget.recipeData['garnish'] is List && (widget.recipeData['garnish'] as List).isNotEmpty)
                      for (var garn in widget.recipeData['garnish']) 
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            children: [
                              Icon(Icons.fiber_manual_record, size: 8, color: Theme.of(context).colorScheme.secondary),
                              const SizedBox(width: 8),
                              Text(garn, style: Theme.of(context).textTheme.bodyLarge),
                            ],
                          ),
                        )
                    else
                      Text("None specified", style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.history_edu, color: Theme.of(context).colorScheme.secondary),
                        const SizedBox(width: 8),
                        Text('History', style: Theme.of(context).textTheme.titleLarge),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.recipeData['drink_history'] ?? 'No history available',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            
            // Epic 4: Task 4.2 - Related Cocktails Carousel
            const SizedBox(height: 16),
            if (widget.recipeData['related_cocktails'] is List && 
                (widget.recipeData['related_cocktails'] as List).isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.local_bar_outlined, color: Theme.of(context).colorScheme.secondary),
                          const SizedBox(width: 8),
                          Text('Related Cocktails', style: Theme.of(context).textTheme.titleLarge),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 120,
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
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.local_bar,
                                        size: 32,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        cocktail,
                                        style: Theme.of(context).textTheme.bodyMedium,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Enhanced recipe metadata from backend
            const SizedBox(height: 16),
            if (widget.recipeData['difficulty_rating'] != null || 
                widget.recipeData['preparation_time_minutes'] != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Theme.of(context).colorScheme.secondary),
                          const SizedBox(width: 8),
                          Text('Recipe Details', style: Theme.of(context).textTheme.titleLarge),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (widget.recipeData['difficulty_rating'] != null)
                        Row(
                          children: [
                            Text('Difficulty: ', style: Theme.of(context).textTheme.bodyMedium),
                            ...List.generate(5, (index) => Icon(
                              index < (widget.recipeData['difficulty_rating'] ?? 0)
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 16,
                              color: Theme.of(context).colorScheme.secondary,
                            )),
                            const SizedBox(width: 8),
                            Text('${widget.recipeData['difficulty_rating']}/5', 
                                 style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      if (widget.recipeData['preparation_time_minutes'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              Icon(Icons.timer, size: 16, color: Theme.of(context).colorScheme.secondary),
                              const SizedBox(width: 8),
                              Text('Prep time: ${widget.recipeData['preparation_time_minutes']} minutes',
                                   style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ),
                      if (widget.recipeData['skill_level_recommendation'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              Icon(Icons.school, size: 16, color: Theme.of(context).colorScheme.secondary),
                              const SizedBox(width: 8),
                              Text('Skill level: ${widget.recipeData['skill_level_recommendation']}',
                                   style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            
            // Equipment section
            const SizedBox(height: 16),
            if (widget.recipeData['equipment_needed'] is List && 
                (widget.recipeData['equipment_needed'] as List).isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.build, color: Theme.of(context).colorScheme.secondary),
                          const SizedBox(width: 8),
                          Text('Equipment Needed', style: Theme.of(context).textTheme.titleLarge),
                        ],
                      ),
                      const SizedBox(height: 12),
                      for (var equipment in widget.recipeData['equipment_needed'])
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            children: [
                              Icon(Icons.fiber_manual_record, size: 8, color: Theme.of(context).colorScheme.secondary),
                              const SizedBox(width: 8),
                              Text(equipment['item'] ?? equipment, style: Theme.of(context).textTheme.bodyLarge),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            
            // Food pairings section
            const SizedBox(height: 16),
            if (widget.recipeData['food_pairings'] is List && 
                (widget.recipeData['food_pairings'] as List).isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.restaurant, color: Theme.of(context).colorScheme.secondary),
                          const SizedBox(width: 8),
                          Text('Food Pairings', style: Theme.of(context).textTheme.titleLarge),
                        ],
                      ),
                      const SizedBox(height: 12),
                      for (var pairing in widget.recipeData['food_pairings'])
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            children: [
                              Icon(Icons.fiber_manual_record, size: 8, color: Theme.of(context).colorScheme.secondary),
                              const SizedBox(width: 8),
                              Text(pairing, style: Theme.of(context).textTheme.bodyLarge),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
