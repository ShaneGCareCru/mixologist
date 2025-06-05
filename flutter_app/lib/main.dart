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
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginScreen(),
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

  @override
  void initState() {
    super.initState();
    _connectToImageStream();
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
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.grey[200],
              child: _currentImageBytes != null
                  ? Image.memory(_currentImageBytes!, fit: BoxFit.contain)
                  : _imageStreamError != null
                      ? Center(child: Text('Error loading image: $_imageStreamError', style: const TextStyle(color: Colors.red), textAlign: TextAlign.center,))
                      : const Center(child: CircularProgressIndicator()),
            ),
            if (_isImageStreamComplete && _currentImageBytes != null)
              const Padding(padding: EdgeInsets.all(4.0), child: Center(child: Text("Final image loaded.", style: TextStyle(fontSize: 10, color: Colors.green)))),
            
            const SizedBox(height: 20),
            Text('Drink Name: ${widget.recipeData['drink_name']}', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('Alcohol Content: ${(widget.recipeData['alcohol_content'] * 100).toStringAsFixed(1)}%'),
            Text('Serving Glass: ${widget.recipeData['serving_glass']}'),
            Text('Rim: ${widget.recipeData['rim']}'),
            const SizedBox(height: 16),
            Text('Ingredients:', style: Theme.of(context).textTheme.titleLarge),
            if (widget.recipeData['ingredients'] is List)
              for (var ingredient in widget.recipeData['ingredients'])
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                  child: Text('  • ${ingredient['name']}: ${ingredient['quantity']}'),
                ),
            const SizedBox(height: 16),
            Text('Steps:', style: Theme.of(context).textTheme.titleLarge),
            if (widget.recipeData['steps'] is List)
              for (var i = 0; i < widget.recipeData['steps'].length; i++)
                 Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                  child: Text('  ${i + 1}. ${widget.recipeData['steps'][i]}'),
                ),
            const SizedBox(height: 16),
            Text('Garnish:', style: Theme.of(context).textTheme.titleLarge),
             if (widget.recipeData['garnish'] is List && (widget.recipeData['garnish'] as List).isNotEmpty)
              for (var garn in widget.recipeData['garnish']) 
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                  child: Text('  • $garn'),
                )
             else
                const Padding(
                  padding: EdgeInsets.only(left: 8.0, top: 4.0),
                  child: Text("  None specified"),
                ),
            const SizedBox(height: 16),
            Text('History:', style: Theme.of(context).textTheme.titleLarge),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 4.0),
              child: Text(widget.recipeData['drink_history'] ?? 'N/A'),
            ),
            const SizedBox(height: 16),
            Text('Image Description (for AI):', style: Theme.of(context).textTheme.titleSmall),
             Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 4.0),
              child: Text(widget.recipeData['drink_image_description'] ?? 'N/A', style: Theme.of(context).textTheme.bodySmall),
            ),
          ],
        ),
      ),
    );
  }
}
