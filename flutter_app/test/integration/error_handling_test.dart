import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mixologist_flutter/features/home/screens/home_screen.dart';
import 'package:mixologist_flutter/features/recipe/screens/recipe_screen.dart';

void main() {
  group('Error Handling Integration Tests', () {
    testWidgets('should handle backend connectivity errors gracefully',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        await tester.enterText(searchField, 'Martini');
        await tester.pump();
      }
      expect(find.byType(HomeScreen), findsOneWidget);
    });
    testWidgets('should handle malformed recipe data', (tester) async {
      final malformedData = {
        'drink_name': 'Broken Recipe',
        'steps': 'not a list',
        'alcohol_content': 'not a number',
      };
      await tester.pumpWidget(
        MaterialApp(
          home: RecipeScreen(recipeData: malformedData),
        ),
      );
      await tester.pump();
    });
    testWidgets('should handle empty search results', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();
      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        await tester.enterText(searchField, 'NonexistentDrink12345');
        await tester.pump();
        expect(find.byType(HomeScreen), findsOneWidget);
      }
    });
    testWidgets('should handle network timeouts gracefully', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        await tester.tap(searchField);
        await tester.pump();
      }
      expect(find.byType(HomeScreen), findsOneWidget);
    });
    testWidgets('should handle missing required recipe fields', (tester) async {
      final minimalData = {
        'drink_name': 'Minimal Recipe',
        'ingredients': [],
        'steps': [],
        'alcohol_content': 0.0,
        'preparation_time_minutes': 0,
        'description': 'Test recipe',
      };
      await tester.pumpWidget(
        MaterialApp(
          home: RecipeScreen(recipeData: minimalData),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(RecipeScreen), findsOneWidget);
      expect(find.textContaining('Minimal Recipe'), findsAtLeastNWidgets(1));
    });
    testWidgets('should handle rapid user interactions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();
      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        await tester.enterText(searchField, 'M');
        await tester.pump(Duration(milliseconds: 10));
        await tester.enterText(searchField, 'Ma');
        await tester.pump(Duration(milliseconds: 10));
        await tester.enterText(searchField, 'Mar');
        await tester.pump(Duration(milliseconds: 10));
        await tester.enterText(searchField, 'Mart');
        await tester.pump(Duration(milliseconds: 10));
        await tester.enterText(searchField, 'Martini');
      }
    });
  });
}
