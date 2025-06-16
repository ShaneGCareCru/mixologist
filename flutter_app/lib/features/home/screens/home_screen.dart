import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:fuzzy/fuzzy.dart';
import '../../../theme/ios_theme.dart';
import '../../../shared/widgets/loading_screen.dart';
import '../../ai_assistant/ai_assistant_page.dart';
import '../../inventory/unified_inventory_page.dart';
import '../../auth/login_screen.dart';
import '../../recipe/screens/recipe_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _unifiedSearchController = TextEditingController();
  String? _searchError;
  
  // Known cocktail names for fuzzy matching
  static const List<String> _knownCocktails = [
    'Margarita', 'Old Fashioned', 'Mojito', 'Manhattan', 'Martini', 'Cosmopolitan',
    'Daiquiri', 'Whiskey Sour', 'Piña Colada', 'Mai Tai', 'Negroni', 'Aperol Spritz',
    'Bloody Mary', 'Moscow Mule', 'Tom Collins', 'Gin and Tonic', 'Dark and Stormy',
    'Caipirinha', 'Mint Julep', 'Sazerac', 'Ramos Gin Fizz', 'Aviation', 'Sidecar',
    'Bee\'s Knees', 'Bramble', 'Corpse Reviver', 'Last Word', 'Paper Plane', 'Penicillin',
    'Vieux Carré', 'Boulevardier', 'Rusty Nail', 'Godfather', 'Amaretto Sour', 'Paloma',
    'Cuban Libre', 'Tequila Sunrise', 'Blue Hawaiian', 'Long Island Iced Tea', 'Mudslide',
    'White Russian', 'Black Russian', 'Screwdriver', 'Cape Codder', 'Greyhound'
  ];
  
  late final Fuzzy<String> _fuzzyMatcher;
  
  @override
  void initState() {
    super.initState();
    _fuzzyMatcher = Fuzzy<String>(_knownCocktails);
  }

  Future<void> _performUnifiedSearch() async {
    final query = _unifiedSearchController.text.trim();
    
    if (query.isEmpty) {
      setState(() { _searchError = 'Please enter something to search for.'; });
      return;
    }
    
    setState(() { _searchError = null; });
    
    // Navigate to loading screen
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const LoadingScreen()),
    );
    
    try {
      // Try fuzzy matching against known cocktails first
      final fuzzyResults = _fuzzyMatcher.search(query);
      final bestMatch = fuzzyResults.isNotEmpty && fuzzyResults.first.score > 0.3 
          ? fuzzyResults.first : null;
      
      http.Response response;
      
      if (bestMatch != null) {
        // Fuzzy match found - treat as cocktail name
        response = await http.post(
          Uri.parse('http://127.0.0.1:8081/create'),
          body: {'drink_query': bestMatch.item},
        );
      } else {
        // No fuzzy match - treat as description
        response = await http.post(
          Uri.parse('http://127.0.0.1:8081/create_from_description'),
          body: {'drink_description': query},
        );
      }
      
      // Pop loading screen
      Navigator.of(context).pop();
      
      if (response.statusCode == 200) {
        final recipeData = jsonDecode(response.body);
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RecipeScreen(recipeData: recipeData)),
          );
        }
      } else {
        setState(() { _searchError = 'Error creating drink: ${response.statusCode}'; });
        debugPrint('Error creating drink: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      // Pop loading screen on error
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      setState(() { _searchError = 'Failed to connect: $e'; });
      debugPrint('Exception creating drink: $e');
    }
  }

  @override
  void dispose() {
    _unifiedSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('AI Mixologist', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1C1C1E),
        border: const Border(),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: Size(iOSTheme.minimumTouchTarget, iOSTheme.minimumTouchTarget),
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => const AIAssistantPage(),
                  ),
                );
              },
              child: const Icon(CupertinoIcons.chat_bubble_text, size: 20, color: Colors.white),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: Size(iOSTheme.minimumTouchTarget, iOSTheme.minimumTouchTarget),
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => const UnifiedInventoryPage(),
                  ),
                );
              },
              child: const Icon(CupertinoIcons.cube_box, size: 20, color: Colors.white),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: Size(iOSTheme.minimumTouchTarget, iOSTheme.minimumTouchTarget),
              onPressed: () async {
                final navigator = Navigator.of(context);
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  navigator.pushReplacement(
                    CupertinoPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                }
              },
              child: const Icon(CupertinoIcons.square_arrow_right, size: 20, color: Colors.white),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFF1C1C1E),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              
              // Main heading
              const Text(
                'Let curiosity\nguide you.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                  height: 1.1,
                  letterSpacing: -0.5,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Subtitle
              const Text(
                'Your first sip begins with a word.\nJust type what you crave—a flavor, a\nfeeling, a moment—and we\'ll handle the\nrest.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF8E8E93),
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Search input
              Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2E),
                  borderRadius: BorderRadius.circular(27),
                  border: Border.all(
                    color: const Color(0xFF3A3A3C),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoTextField(
                        controller: _unifiedSearchController,
                        placeholder: 'aperol spritz',
                        placeholderStyle: const TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 16,
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        decoration: const BoxDecoration(),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        onSubmitted: (_) => _performUnifiedSearch(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: CupertinoButton(
                        padding: const EdgeInsets.all(8),
                        onPressed: _performUnifiedSearch,
                        child: const Icon(
                          CupertinoIcons.search,
                          color: Color(0xFF8E8E93),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Error message
              if (_searchError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    _searchError!,
                    style: const TextStyle(
                      color: Color(0xFFFF3B30),
                      fontSize: 14,
                    ),
                  ),
                ),
              
              const SizedBox(height: 48),
              
              // Suggestion chips
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildSuggestionChip('Margarita'),
                  _buildSuggestionChip('something fruity'),
                  _buildSuggestionChip('Mojito'),
                  _buildSuggestionChip('warm and spicy'),
                ],
              ),
              
              const Spacer(flex: 2),
              
              // Bottom inspiration text
              const Text(
                'The future of mixology starts\nwith your imagination.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF8E8E93),
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSuggestionChip(String text) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: const Color(0xFF2C2C2E),
      borderRadius: BorderRadius.circular(20),
      onPressed: () {
        _unifiedSearchController.text = text;
        _performUnifiedSearch();
      },
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}