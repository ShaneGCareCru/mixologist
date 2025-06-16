#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> main() async {
  const baseUrl = 'http://127.0.0.1:8081';
  
  print('🧪 Testing backend API at $baseUrl');
  print('=' * 50);
  
  try {
    // Test 1: Basic connectivity
    print('\n1. Testing basic connectivity...');
    final connectResponse = await http.post(
      Uri.parse('$baseUrl/create'),
      body: {'drink_query': 'Test'},
    ).timeout(Duration(seconds: 10));
    
    print('   ✅ Connected - Status: ${connectResponse.statusCode}');
    
    // Test 2: Martini recipe
    print('\n2. Testing Martini recipe...');
    final martiniResponse = await http.post(
      Uri.parse('$baseUrl/create'),
      body: {'drink_query': 'Martini'},
    ).timeout(Duration(seconds: 15));
    
    if (martiniResponse.statusCode == 200) {
      final data = jsonDecode(martiniResponse.body);
      print('   ✅ Martini recipe received');
      print('   📋 Recipe: ${data['drink_name']}');
      print('   🥃 Ingredients: ${(data['ingredients'] as List).length}');
      print('   📝 Steps: ${(data['steps'] as List).length}');
      
      // Verify structure
      final requiredFields = ['drink_name', 'ingredients', 'steps'];
      for (final field in requiredFields) {
        if (!data.containsKey(field)) {
          print('   ❌ Missing field: $field');
          exit(1);
        }
      }
      print('   ✅ Recipe structure is valid');
    } else {
      print('   ❌ Failed - Status: ${martiniResponse.statusCode}');
      exit(1);
    }
    
    // Test 3: Description-based request
    print('\n3. Testing description-based recipe...');
    final descResponse = await http.post(
      Uri.parse('$baseUrl/create_from_description'),
      body: {'drink_description': 'something citrusy and refreshing'},
    ).timeout(Duration(seconds: 20));
    
    if (descResponse.statusCode == 200) {
      final data = jsonDecode(descResponse.body);
      print('   ✅ Description-based recipe received');
      print('   📋 Generated: ${data['drink_name']}');
    } else {
      print('   ❌ Failed - Status: ${descResponse.statusCode}');
      exit(1);
    }
    
    // Test 4: Different cocktail
    print('\n4. Testing Old Fashioned recipe...');
    final oldFashionedResponse = await http.post(
      Uri.parse('$baseUrl/create'),
      body: {'drink_query': 'Old Fashioned'},
    ).timeout(Duration(seconds: 15));
    
    if (oldFashionedResponse.statusCode == 200) {
      final data = jsonDecode(oldFashionedResponse.body);
      print('   ✅ Old Fashioned recipe received');
      print('   📋 Recipe: ${data['drink_name']}');
    } else {
      print('   ❌ Failed - Status: ${oldFashionedResponse.statusCode}');
      exit(1);
    }
    
    print('\n' + '=' * 50);
    print('🎉 All backend API tests passed!');
    print('   The backend is working correctly and ready for integration');
    print('   with the Flutter app\'s search functionality.');
    
  } catch (e) {
    print('\n❌ Backend API test failed: $e');
    print('\nPlease ensure the backend server is running at $baseUrl');
    exit(1);
  }
}