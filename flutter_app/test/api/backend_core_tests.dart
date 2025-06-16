import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('Backend Core API Tests', () {
    const String baseUrl = 'http://127.0.0.1:8081';
    
    test('✅ Backend connectivity', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/create'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'drink_query=Test',
      ).timeout(Duration(seconds: 10));
      
      expect(response.statusCode, 200);
      print('Backend connected - Status: ${response.statusCode}');
    });

    test('✅ Known cocktail recipe (Martini)', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/create'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'drink_query=Martini',
      ).timeout(Duration(seconds: 15));
      
      expect(response.statusCode, 200);
      
      final data = jsonDecode(response.body);
      expect(data['drink_name'], isNotNull);
      expect(data['ingredients'], isA<List>());
      expect(data['steps'], isA<List>());
      expect((data['ingredients'] as List).length, greaterThan(0));
      expect((data['steps'] as List).length, greaterThan(0));
      
      print('Martini recipe: ${data['drink_name']} - ${(data['ingredients'] as List).length} ingredients');
    });

    test('✅ Description-based recipe', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/create_from_description'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'drink_description=something citrusy and refreshing',
      ).timeout(Duration(seconds: 20));
      
      expect(response.statusCode, 200);
      
      final data = jsonDecode(response.body);
      expect(data['drink_name'], isNotNull);
      expect(data['ingredients'], isA<List>());
      expect(data['steps'], isA<List>());
      
      print('Generated recipe: ${data['drink_name']}');
    });

    test('✅ Recipe data structure validation', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/create'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'drink_query=Mojito',
      ).timeout(Duration(seconds: 15));
      
      expect(response.statusCode, 200);
      
      final data = jsonDecode(response.body);
      
      // Essential fields for app functionality
      final requiredFields = [
        'drink_name',
        'ingredients', 
        'steps',
        'enhanced_steps',
        'difficulty_rating',
        'preparation_time_minutes',
        'serving_glass',
      ];
      
      for (final field in requiredFields) {
        expect(data.containsKey(field), isTrue, 
               reason: 'Recipe must contain $field for app functionality');
      }
      
      // Validate ingredient structure (needed for RecipeScreen)
      final ingredients = data['ingredients'] as List;
      for (final ingredient in ingredients) {
        expect(ingredient['name'], isNotNull);
        expect(ingredient['quantity'], isNotNull);
      }
      
      // Validate enhanced steps (needed for MethodCard widgets)
      final enhancedSteps = data['enhanced_steps'] as List;
      expect(enhancedSteps.length, greaterThan(0));
      
      for (final step in enhancedSteps) {
        expect(step['action'], isNotNull);
        expect(step['step_number'], isA<num>());
      }
      
      print('Recipe structure validated for: ${data['drink_name']}');
      print('- ${ingredients.length} ingredients with name/quantity');
      print('- ${enhancedSteps.length} enhanced steps with actions');
    });
  });
}