import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mixologist_flutter/features/home/screens/home_screen.dart';
import 'package:mixologist_flutter/features/recipe/screens/recipe_screen.dart';

void main() {
  group('HomeScreen Search Integration Tests', () {
    setUpAll(() {
      // Verify backend is available before running tests
      print('Setting up tests - verifying backend connectivity...');
    });

    testWidgets('should fetch recipe when searching for known cocktail',
        (tester) async {
      // Build the HomeScreen
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Verify the search field is present
      expect(find.byType(CupertinoTextField), findsOneWidget);

      // Enter "Margarita" in search field
      await tester.enterText(find.byType(CupertinoTextField), 'Margarita');
      await tester.pump();

      // Verify text was entered
      expect(find.text('Margarita'), findsOneWidget);

      // Submit the search by calling onSubmitted
      await tester.testTextInput.receiveAction(TextInputAction.done);

      // Wait for loading screen and API call
      await tester.pump(); // Trigger loading screen

      // Should find LoadingScreen
      expect(find.text('Generating your recipe...'), findsOneWidget);

      // Wait for API call to complete (generous timeout for real backend)
      await tester.pumpAndSettle(Duration(seconds: 10));

      // Verify navigation to RecipeScreen occurred
      expect(find.byType(RecipeScreen), findsOneWidget);

      // Verify recipe data is displayed (should contain "Margarita" somewhere)
      expect(find.textContaining('Margarita'), findsAtLeastNWidgets(1));
    });

    testWidgets('should fetch recipe from description', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Enter description instead of cocktail name
      await tester.enterText(
          find.byType(CupertinoTextField), 'something citrusy and refreshing');
      await tester.pump();

      // Submit the search
      await tester.testTextInput.receiveAction(TextInputAction.done);

      // Wait for loading screen
      await tester.pump();
      expect(find.text('Generating your recipe...'), findsOneWidget);

      // Wait for API response (description endpoint might be slower)
      await tester.pumpAndSettle(Duration(seconds: 15));

      // Should navigate to recipe screen with generated recipe
      expect(find.byType(RecipeScreen), findsOneWidget);

      // Should display some kind of recipe content (look for any ingredient-related text)
      final hasIngredientsText =
          find.textContaining('ingredient').evaluate().isNotEmpty ||
              find.text('Ingredients').evaluate().isNotEmpty ||
              find.text('ingredients').evaluate().isNotEmpty;
      expect(hasIngredientsText, isTrue);
    });

    testWidgets('should trigger search via search button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Enter text
      await tester.enterText(find.byType(CupertinoTextField), 'Old Fashioned');
      await tester.pump();

      // Find and tap the search button (CupertinoIcons.search)
      final searchButton = find.byIcon(CupertinoIcons.search);
      expect(searchButton, findsOneWidget);

      await tester.tap(searchButton);

      // Wait for loading and API call
      await tester.pump();
      expect(find.text('Generating your recipe...'), findsOneWidget);

      await tester.pumpAndSettle(Duration(seconds: 10));

      // Should navigate to RecipeScreen
      expect(find.byType(RecipeScreen), findsOneWidget);
    });

    testWidgets('should handle empty search input gracefully', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Try to submit empty search
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // Should remain on HomeScreen (no navigation)
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(RecipeScreen), findsNothing);

      // Should not show loading screen
      expect(find.text('Generating your recipe...'), findsNothing);
    });

    testWidgets('should display loading screen during API call',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(),
        ),
      );

      await tester.enterText(find.byType(CupertinoTextField), 'Mojito');
      await tester.pump();

      // Submit search
      await tester.testTextInput.receiveAction(TextInputAction.done);

      // Immediately after submission, should show loading
      await tester.pump();
      expect(find.text('Generating your recipe...'), findsOneWidget);

      // The loading screen should be the current screen
      expect(find.byType(HomeScreen),
          findsNothing); // Should have navigated away from home
    });
  });

  // Helper function to test backend connectivity
  group('Backend Connectivity', () {
    test('should be able to connect to backend at port 8081', () async {
      try {
        final response = await http.post(
          Uri.parse('http://127.0.0.1:8081/create'),
          body: {'drink_query': 'Martini'},
        ).timeout(Duration(seconds: 5));

        expect(response.statusCode, 200);

        final data = jsonDecode(response.body);
        expect(data, isA<Map<String, dynamic>>());

        print('✅ Backend connectivity test passed');
        print('Response keys: ${data.keys.toList()}');
      } catch (e) {
        fail('❌ Backend at port 8081 is not accessible: $e\n'
            'Please ensure the backend is running before running these tests.');
      }
    });
  });
}
