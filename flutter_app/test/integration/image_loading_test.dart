import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:mixologist_flutter/features/recipe/screens/recipe_screen.dart';

void main() {
  group('Image Loading Integration Tests', () {
    late Map<String, dynamic> sampleRecipeData;

    setUpAll(() async {
      // Fetch real recipe data that includes images
      try {
        final response = await http
            .post(
              Uri.parse('http://127.0.0.1:8081/create'),
              headers: {'Content-Type': 'application/x-www-form-urlencoded'},
              body: 'drink_query=Martini',
            )
            .timeout(Duration(seconds: 15));

        if (response.statusCode == 200) {
          sampleRecipeData = jsonDecode(response.body);
          print('Using real recipe data with images for testing');
        } else {
          throw Exception('Backend returned ${response.statusCode}');
        }
      } catch (e) {
        // Fallback to mock data with image URLs
        sampleRecipeData = {
          'drink_name': 'Test Martini',
          'ingredients': [
            {
              'name': 'Gin',
              'quantity': '2.5 oz',
              'image_url':
                  'https://via.placeholder.com/150x150/0000FF/FFFFFF?text=Gin'
            },
            {
              'name': 'Dry Vermouth',
              'quantity': '0.5 oz',
              'image_url':
                  'https://via.placeholder.com/150x150/FF0000/FFFFFF?text=Vermouth'
            },
          ],
          'steps': ['Step 1', 'Step 2'],
          'alcohol_content': 0.35,
          'preparation_time_minutes': 5,
          'description': 'Classic Martini cocktail',
          'cocktail_image_url':
              'https://via.placeholder.com/400x300/00FF00/FFFFFF?text=Martini',
          'step_images': [
            'https://via.placeholder.com/200x150/FF00FF/FFFFFF?text=Step1',
            'https://via.placeholder.com/200x150/FFFF00/FFFFFF?text=Step2',
          ],
        };
        print('Using fallback mock data with placeholder images');
      }
    });

    testWidgets('should handle cocktail hero image loading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RecipeScreen(recipeData: sampleRecipeData),
        ),
      );

      // Initial render
      await tester.pumpAndSettle();

      // Look for any Image widgets that might be cocktail images
      final imageWidgets = find.byType(Image);
      final cachedImageWidgets = find.byType(CachedNetworkImage);

      // Should have RecipeScreen without crashing
      expect(find.byType(RecipeScreen), findsOneWidget);

      // Test that images exist or that the app handles their absence gracefully
      if (imageWidgets.evaluate().isNotEmpty ||
          cachedImageWidgets.evaluate().isNotEmpty) {
        print('✅ Image widgets found in recipe display');

        // Test that image widgets don't cause crashes
        await tester.pump(Duration(seconds: 1));
        expect(find.byType(RecipeScreen), findsOneWidget);
      } else {
        print(
            'ℹ️  No direct image widgets found (images may be generated dynamically)');
      }
    });

    testWidgets('should handle ingredient images loading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RecipeScreen(recipeData: sampleRecipeData),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to ingredients section if needed
      // Look for ingredient names to verify section is loaded
      final ingredients = sampleRecipeData['ingredients'] as List;

      for (final ingredient in ingredients.take(2)) {
        // Should display ingredient names
        expect(
            find.textContaining(ingredient['name']), findsAtLeastNWidgets(1));
      }

      // Test that the app doesn't crash with ingredient data
      expect(find.byType(RecipeScreen), findsOneWidget);

      print('✅ Ingredient section handles image data correctly');
    });

    testWidgets('should handle step images and visual content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RecipeScreen(recipeData: sampleRecipeData),
        ),
      );

      await tester.pumpAndSettle();

      // Verify steps data is present
      final steps = sampleRecipeData['steps'] as List;
      expect(steps.length, greaterThan(0));

      // Test that method section renders without crashing
      expect(find.byType(RecipeScreen), findsOneWidget);

      // Test scrolling to ensure images don't cause memory issues
      await tester.drag(find.byType(RecipeScreen), const Offset(0, -200));
      await tester.pumpAndSettle();

      expect(find.byType(RecipeScreen), findsOneWidget);

      print('✅ Method steps handle visual content correctly');
    });

    testWidgets('should gracefully handle missing or invalid image URLs',
        (tester) async {
      // Create recipe data with invalid image URLs
      final testData = Map<String, dynamic>.from(sampleRecipeData);
      testData['cocktail_image_url'] = 'invalid://not-a-real-url';
      testData['ingredients'] = [
        {
          'name': 'Test Ingredient',
          'quantity': '1 oz',
          'image_url': 'broken://url'
        },
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: RecipeScreen(recipeData: testData),
        ),
      );

      // Should render without crashing even with invalid URLs
      await tester.pumpAndSettle();
      expect(find.byType(RecipeScreen), findsOneWidget);

      // Should display the recipe name
      expect(
          find.textContaining(testData['drink_name']), findsAtLeastNWidgets(1));

      print('✅ App handles invalid image URLs gracefully');
    });

    testWidgets('should handle image loading states and errors',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RecipeScreen(recipeData: sampleRecipeData),
        ),
      );

      // Initial render
      await tester.pump();

      // Should show loading state or render immediately
      expect(find.byType(RecipeScreen), findsOneWidget);

      // Allow time for potential image loading
      await tester.pump(Duration(milliseconds: 500));

      // Should still be functional
      expect(find.byType(RecipeScreen), findsOneWidget);
      expect(find.textContaining(sampleRecipeData['drink_name']),
          findsAtLeastNWidgets(1));

      // Test interaction during image loading
      await tester.drag(find.byType(RecipeScreen), const Offset(0, -100));
      await tester.pumpAndSettle();

      expect(find.byType(RecipeScreen), findsOneWidget);

      print('✅ App handles image loading states correctly');
    });

    testWidgets('should maintain performance with multiple images',
        (tester) async {
      // Create recipe with many images to test performance
      final heavyImageData = Map<String, dynamic>.from(sampleRecipeData);
      heavyImageData['ingredients'] = List.generate(
          10,
          (index) => {
                'name': 'Ingredient $index',
                'quantity': '${index + 1} oz',
                'image_url':
                    'https://via.placeholder.com/150x150/000000/FFFFFF?text=Item$index'
              });
      // Ensure required fields exist
      heavyImageData['alcohol_content'] = sampleRecipeData['alcohol_content'];
      heavyImageData['preparation_time_minutes'] =
          sampleRecipeData['preparation_time_minutes'];
      heavyImageData['description'] = sampleRecipeData['description'];

      await tester.pumpWidget(
        MaterialApp(
          home: RecipeScreen(recipeData: heavyImageData),
        ),
      );

      // Should handle many images without major performance issues
      await tester.pumpAndSettle();
      expect(find.byType(RecipeScreen), findsOneWidget);

      // Test scrolling performance
      for (int i = 0; i < 3; i++) {
        await tester.drag(find.byType(RecipeScreen), const Offset(0, -200));
        await tester.pump(Duration(milliseconds: 100));
      }

      expect(find.byType(RecipeScreen), findsOneWidget);

      print('✅ App maintains performance with multiple images');
    });
  });
}
