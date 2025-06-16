import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mixologist_flutter/widgets/safe_recipe_renderer.dart';
import 'package:mixologist_flutter/widgets/improved_method_card.dart';
import 'package:mixologist_flutter/widgets/mixologist_image.dart';

void main() {
  group('SafeRecipeData', () {
    test('handles missing recipe data gracefully', () {
      // Test empty/null data
      final emptyData = SafeRecipeData({});
      expect(emptyData.name, 'Unnamed Cocktail');
      expect(emptyData.description, 'A delicious cocktail worth trying.');
      expect(emptyData.ingredients, isEmpty);
      expect(emptyData.steps, isNotEmpty); // Should have fallback message
      expect(emptyData.isComplete, false);
    });

    test('safely accesses ingredient data', () {
      final data = SafeRecipeData({
        'drink_name': 'Old Fashioned',
        'ingredients': [
          {'name': 'Whiskey', 'quantity': '2 oz'},
          {'name': 'Simple Syrup'}, // Missing quantity
          'Bitters', // String instead of map
          null, // Null ingredient
        ],
      });

      expect(data.name, 'Old Fashioned');
      expect(data.ingredients.length, 4);
      expect(data.getIngredientName(0), 'Whiskey');
      expect(data.getIngredientQuantity(0), '2 oz');
      expect(data.getIngredientName(1), 'Simple Syrup');
      expect(data.getIngredientQuantity(1), 'To taste'); // Fallback
      expect(data.getIngredientName(2), 'Bitters');
      expect(data.getIngredientName(3), 'Unknown ingredient'); // Null handling
      expect(data.getIngredientName(99), 'Unknown ingredient'); // Out of bounds
    });

    test('safely accesses step data', () {
      final data = SafeRecipeData({
        'steps': [
          'Add whiskey to glass',
          null, // Null step
          '', // Empty step
        ],
      });

      expect(data.steps.length, 3);
      expect(data.getStep(0), 'Add whiskey to glass');
      expect(data.getStep(1), 'Step information missing'); // Null handling
      expect(data.getStep(2), 'Step information missing'); // Empty handling
      expect(data.getStep(99), isNull); // Out of bounds
    });

    test('handles different data field names', () {
      // Test alternative field names
      final data = SafeRecipeData({
        'name': 'Martini', // Instead of 'drink_name'
        'method': ['Stir', 'Strain'], // Instead of 'steps'
        'equipment': ['Shaker', 'Strainer'], // Instead of 'equipment_needed'
      });

      expect(data.name, 'Martini');
      expect(data.steps.length, 2);
      expect(data.equipment.length, 2);
    });
  });

  group('SafeMethodCardData', () {
    test('creates from string with intelligent defaults', () {
      final data = SafeMethodCardData.fromString('Shake vigorously for 15 seconds', 1);
      
      expect(data.stepNumber, 1);
      expect(data.description, 'Shake vigorously for 15 seconds');
      expect(data.duration, '15 seconds'); // Intelligent parsing
      expect(data.difficulty, 'Intermediate'); // Based on content
      expect(data.proTip, contains('Shake vigorously')); // Relevant tip
      expect(data.tipCategory, TipCategory.technique);
    });

    test('estimates duration and difficulty correctly', () {
      final shakeData = SafeMethodCardData.fromString('Shake with ice', 1);
      expect(shakeData.duration, '15 seconds');
      expect(shakeData.difficulty, 'Intermediate');

      final stirData = SafeMethodCardData.fromString('Stir gently', 2);
      expect(stirData.duration, '30 seconds');
      expect(stirData.difficulty, 'Basic');

      final muddleData = SafeMethodCardData.fromString('Muddle herbs carefully', 3);
      expect(muddleData.difficulty, 'Advanced');
    });

    test('handles missing or invalid map data', () {
      final data = SafeMethodCardData.fromMap(null, 1);
      expect(data.stepNumber, 1);
      expect(data.description, 'Step information will be available soon.');
      
      final emptyData = SafeMethodCardData.fromMap({}, 2);
      expect(emptyData.stepNumber, 2);
      expect(emptyData.description, 'Step information will be available soon.');
    });
  });

  group('MixologistImage Widget Tests', () {
    testWidgets('displays placeholder when no image provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MixologistImage.ingredient(
              altText: 'Test Ingredient',
            ),
          ),
        ),
      );

      expect(find.text('Test Ingredient'), findsOneWidget);
      expect(find.byIcon(Icons.scatter_plot), findsOneWidget);
    });

    testWidgets('shows correct aspect ratio for different image types', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                MixologistImage.recipeHero(altText: 'Hero'),
                MixologistImage.ingredient(altText: 'Ingredient'),
                MixologistImage.methodStep(altText: 'Method'),
                MixologistImage.equipment(altText: 'Equipment'),
              ],
            ),
          ),
        ),
      );

      final aspectRatios = tester.widgetList<AspectRatio>(find.byType(AspectRatio));
      expect(aspectRatios.length, 4);
      
      // Check aspect ratios match design philosophy
      expect(aspectRatios.elementAt(0).aspectRatio, 16 / 9); // Hero
      expect(aspectRatios.elementAt(1).aspectRatio, 1.0); // Ingredient
      expect(aspectRatios.elementAt(2).aspectRatio, 4 / 3); // Method
      expect(aspectRatios.elementAt(3).aspectRatio, 1.0); // Equipment
    });

    testWidgets('displays generating state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MixologistImage.ingredient(
              altText: 'Test',
              isGenerating: true,
            ),
          ),
        ),
      );

      expect(find.text('Crafting visual...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('SafeRecipeRenderer Widget Tests', () {
    testWidgets('renders builder when recipe data is complete', (WidgetTester tester) async {
      final recipeData = {
        'drink_name': 'Test Cocktail',
        'ingredients': [{'name': 'Ingredient 1', 'quantity': '1 oz'}],
        'steps': ['Step 1'],
      };

      await tester.pumpWidget(
        MaterialApp(
          home: SafeRecipeRenderer(
            recipeData: recipeData,
            builder: (context, safeData) => Text(safeData.name),
          ),
        ),
      );

      expect(find.text('Test Cocktail'), findsOneWidget);
    });

    testWidgets('shows empty state for incomplete recipe', (WidgetTester tester) async {
      final incompleteData = {'drink_name': 'Incomplete'}; // Missing ingredients and steps

      await tester.pumpWidget(
        MaterialApp(
          home: SafeRecipeRenderer(
            recipeData: incompleteData,
            builder: (context, safeData) => Text(safeData.name),
          ),
        ),
      );

      expect(find.text('Recipe Information Incomplete'), findsOneWidget);
      expect(find.text('Request Complete Recipe'), findsOneWidget);
    });

    testWidgets('shows custom empty widget when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SafeRecipeRenderer(
            recipeData: {},
            builder: (context, safeData) => Text(safeData.name),
            emptyWidget: const Text('Custom Empty State'),
          ),
        ),
      );

      expect(find.text('Custom Empty State'), findsOneWidget);
    });
  });

  group('ImprovedMethodCard Widget Tests', () {
    testWidgets('displays method card with safe data', (WidgetTester tester) async {
      final data = SafeMethodCardData.fromString('Shake with ice', 1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImprovedMethodCard(data: data),
          ),
        ),
      );

      expect(find.text('Step 1'), findsOneWidget);
      expect(find.text('Shake with ice'), findsOneWidget);
      expect(find.text('15 seconds'), findsOneWidget);
      expect(find.text('Intermediate'), findsOneWidget);
    });

    testWidgets('shows pro tip when expanded', (WidgetTester tester) async {
      final data = SafeMethodCardData.fromString('Shake vigorously', 1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImprovedMethodCard(data: data),
          ),
        ),
      );

      // Initially collapsed
      expect(find.text('Shake vigorously for 10-15 seconds'), findsNothing);
      
      // Tap to expand
      await tester.tap(find.byIcon(Icons.lightbulb_outline));
      await tester.pumpAndSettle();
      
      // Pro tip should now be visible
      expect(find.text('Shake vigorously for 10-15 seconds'), findsOneWidget);
    });

    testWidgets('handles checkbox interaction', (WidgetTester tester) async {
      bool completed = false;
      final data = SafeMethodCardData.fromString('Test step', 1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImprovedMethodCard(
              data: data,
              onCheckboxChanged: (value) => completed = value ?? false,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Checkbox));
      expect(completed, true);
    });
  });
}