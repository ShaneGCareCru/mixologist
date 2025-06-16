import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:http/http.dart' as http;
import 'package:mixologist_flutter/features/home/screens/home_screen.dart';
import 'package:mixologist_flutter/main.dart' as main_screens;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('HomeScreen Backend Integration Tests', () {
    
    // First verify backend connectivity with a simple test
    testWidgets('backend connectivity check', (tester) async {
      // Test direct HTTP call (this should work in integration tests)
      try {
        final response = await http.post(
          Uri.parse('http://127.0.0.1:8081/create'),
          body: {'drink_query': 'Martini'},
        ).timeout(Duration(seconds: 5));
        
        expect(response.statusCode, 200, 
               reason: 'Backend should be running at port 8081');
        
        final data = jsonDecode(response.body);
        expect(data, isA<Map<String, dynamic>>(), 
               reason: 'Backend should return JSON response');
        
        print('✅ Backend connectivity verified');
        print('Sample response keys: ${data.keys.take(5).toList()}');
      } catch (e) {
        fail('❌ Backend at port 8081 is not accessible: $e\n'
             'Please start the backend server before running these tests.');
      }
    });

    testWidgets('should search for known cocktail and display recipe', (tester) async {
      // Build the app with HomeScreen
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Wait for any initial animations
      await tester.pumpAndSettle();

      // Verify we're on the home screen
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(CupertinoTextField), findsOneWidget);

      // Enter a known cocktail name
      await tester.enterText(find.byType(CupertinoTextField), 'Margarita');
      await tester.pumpAndSettle();

      // Verify the text was entered
      expect(find.text('Margarita'), findsOneWidget);

      // Submit the search using the text field's onSubmitted
      await tester.testTextInput.receiveAction(TextInputAction.done);
      
      // Wait a moment for the action to trigger
      await tester.pump(Duration(milliseconds: 100));
      
      // Should show loading screen
      expect(find.text('Generating your recipe...'), findsOneWidget);
      
      // Wait for the API call to complete (with generous timeout)
      await tester.pumpAndSettle(Duration(seconds: 15));
      
      // Should now be on the recipe screen
      expect(find.byType(main_screens.RecipeScreen), findsOneWidget);
      
      // Should display recipe content mentioning Margarita
      expect(find.textContaining('Margarita'), findsAtLeastNWidgets(1));
      
      print('✅ Margarita search test passed');
    });

    testWidgets('should search using search button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Enter text
      await tester.enterText(find.byType(CupertinoTextField), 'Old Fashioned');
      await tester.pumpAndSettle();

      // Find and tap the search button
      final searchButton = find.byIcon(CupertinoIcons.search);
      expect(searchButton, findsOneWidget);
      
      await tester.tap(searchButton);
      await tester.pump(Duration(milliseconds: 100));

      // Should show loading
      expect(find.text('Generating your recipe...'), findsOneWidget);
      
      // Wait for API response
      await tester.pumpAndSettle(Duration(seconds: 15));
      
      // Should navigate to recipe screen
      expect(find.byType(main_screens.RecipeScreen), findsOneWidget);
      expect(find.textContaining('Old Fashioned'), findsAtLeastNWidgets(1));
      
      print('✅ Search button test passed');
    });

    testWidgets('should handle description-based search', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Enter a description instead of cocktail name
      await tester.enterText(
        find.byType(CupertinoTextField), 
        'something citrusy and refreshing'
      );
      await tester.pumpAndSettle();

      // Submit search
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump(Duration(milliseconds: 100));

      // Wait for loading and API call (description calls may take longer)
      expect(find.text('Generating your recipe...'), findsOneWidget);
      await tester.pumpAndSettle(Duration(seconds: 20));
      
      // Should navigate to recipe screen
      expect(find.byType(main_screens.RecipeScreen), findsOneWidget);
      
      // Should have some recipe content
      final recipeContent = tester.widget<main_screens.RecipeScreen>(
        find.byType(main_screens.RecipeScreen)
      );
      expect(recipeContent.recipeData, isNotNull);
      
      print('✅ Description search test passed');
    });

    testWidgets('should handle empty search gracefully', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Try to submit empty search
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Should remain on HomeScreen (no API call made)
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(main_screens.RecipeScreen), findsNothing);
      expect(find.text('Generating your recipe...'), findsNothing);
      
      print('✅ Empty search test passed');
    });
  });
}