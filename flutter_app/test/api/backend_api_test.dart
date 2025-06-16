import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('Backend API Integration Tests', () {
    const String baseUrl = 'http://127.0.0.1:8081';
    
    test('should connect to backend server', () async {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/create'),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: 'drink_query=Test Connection',
        ).timeout(Duration(seconds: 10));
        
        // Should receive some response (even if it's an error response)
        expect(response.statusCode, lessThan(500), 
               reason: 'Backend should be reachable and not have server errors');
        
        print('✅ Backend connectivity test passed - Status: ${response.statusCode}');
      } catch (e) {
        fail('❌ Cannot connect to backend at $baseUrl: $e\n'
             'Please ensure the backend server is running.');
      }
    });

    test('should fetch recipe for known cocktail (Martini)', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/create'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'drink_query=Martini',
      ).timeout(Duration(seconds: 15));
      
      expect(response.statusCode, 200);
      
      final data = jsonDecode(response.body);
      expect(data, isA<Map<String, dynamic>>());
      
      // Verify essential recipe fields are present
      expect(data['drink_name'], isNotNull);
      expect(data['ingredients'], isNotNull);
      expect(data['steps'], isNotNull);
      
      // Verify drink name contains "Martini"
      expect(data['drink_name'].toString().toLowerCase(), contains('martini'));
      
      // Verify ingredients is a list with content
      expect(data['ingredients'], isA<List>());
      expect((data['ingredients'] as List).length, greaterThan(0));
      
      // Verify steps is a list with content
      expect(data['steps'], isA<List>());
      expect((data['steps'] as List).length, greaterThan(0));
      
      print('✅ Martini recipe test passed');
      print('   Recipe: ${data['drink_name']}');
      print('   Ingredients: ${(data['ingredients'] as List).length}');
      print('   Steps: ${(data['steps'] as List).length}');
    });

    test('should fetch recipe for another known cocktail (Old Fashioned)', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/create'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'drink_query=Old Fashioned',
      ).timeout(Duration(seconds: 15));
      
      expect(response.statusCode, 200);
      
      final data = jsonDecode(response.body);
      expect(data, isA<Map<String, dynamic>>());
      
      // Verify recipe structure
      expect(data['drink_name'], isNotNull);
      expect(data['ingredients'], isA<List>());
      expect(data['steps'], isA<List>());
      expect((data['ingredients'] as List).length, greaterThan(0));
      expect((data['steps'] as List).length, greaterThan(0));
      
      print('✅ Old Fashioned recipe test passed');
      print('   Recipe: ${data['drink_name']}');
    });

    test('should handle description-based requests', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/create_from_description'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'drink_description=something citrusy and refreshing',
      ).timeout(Duration(seconds: 20));
      
      expect(response.statusCode, 200);
      
      final data = jsonDecode(response.body);
      expect(data, isA<Map<String, dynamic>>());
      
      // Should return a valid recipe structure
      expect(data['drink_name'], isNotNull);
      expect(data['ingredients'], isA<List>());
      expect(data['steps'], isA<List>());
      
      print('✅ Description-based recipe test passed');
      print('   Generated: ${data['drink_name']}');
    });

    test('should return comprehensive recipe data structure', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/create'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'drink_query=Mojito',
      ).timeout(Duration(seconds: 15));
      
      expect(response.statusCode, 200);
      
      final data = jsonDecode(response.body);
      
      // Test for rich recipe data structure (based on curl response)
      final expectedFields = [
        'drink_name',
        'ingredients', 
        'steps',
        'enhanced_steps',
        'flavor_profile',
        'equipment_needed',
        'difficulty_rating',
        'preparation_time_minutes',
        'alcohol_content',
        'serving_glass',
        'garnish',
        'drink_history',
        'food_pairings',
      ];
      
      for (final field in expectedFields) {
        expect(data.containsKey(field), isTrue, 
               reason: 'Recipe should contain $field field');
      }
      
      // Test specific data types
      expect(data['ingredients'], isA<List>());
      expect(data['steps'], isA<List>());
      expect(data['enhanced_steps'], isA<List>());
      expect(data['flavor_profile'], isA<Map>());
      expect(data['equipment_needed'], isA<List>());
      expect(data['difficulty_rating'], isA<num>());
      expect(data['preparation_time_minutes'], isA<num>());
      expect(data['alcohol_content'], isA<num>());
      
      print('✅ Comprehensive recipe structure test passed');
      print('   All expected fields present for: ${data['drink_name']}');
    });

    test('should handle ingredients with proper structure', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/create'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'drink_query=Negroni',
      ).timeout(Duration(seconds: 15));
      
      expect(response.statusCode, 200);
      
      final data = jsonDecode(response.body);
      final ingredients = data['ingredients'] as List;
      
      // Each ingredient should have name and quantity
      for (final ingredient in ingredients) {
        expect(ingredient, isA<Map>());
        expect(ingredient['name'], isNotNull);
        expect(ingredient['quantity'], isNotNull);
      }
      
      print('✅ Ingredient structure test passed');
      print('   Ingredients for ${data['drink_name']}: ${ingredients.length}');
    });

    test('should provide equipment and difficulty information', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/create'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'drink_query=Whiskey Sour',
      ).timeout(Duration(seconds: 15));
      
      expect(response.statusCode, 200);
      
      final data = jsonDecode(response.body);
      
      // Verify equipment list
      final equipment = data['equipment_needed'] as List;
      expect(equipment.length, greaterThan(0));
      
      for (final item in equipment) {
        expect(item, isA<Map>());
        expect(item['item'], isNotNull);
        expect(item['essential'], isA<bool>());
      }
      
      // Verify difficulty rating
      final difficulty = data['difficulty_rating'];
      expect(difficulty, isA<num>());
      expect(difficulty, greaterThan(0));
      expect(difficulty, lessThanOrEqualTo(5));
      
      print('✅ Equipment and difficulty test passed');
      print('   Equipment items: ${equipment.length}');
      print('   Difficulty: $difficulty/5');
    });
  });
}