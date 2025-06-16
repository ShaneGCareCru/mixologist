#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> main() async {
  const baseUrl = 'http://127.0.0.1:8081';
  
  print('🔍 Debugging backend connectivity...');
  
  try {
    // Test with explicit headers like curl
    print('\n1. Testing with form-encoded data (like curl)...');
    final response = await http.post(
      Uri.parse('$baseUrl/create'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'User-Agent': 'Dart/Flutter Test',
      },
      body: 'drink_query=Martini',
    ).timeout(Duration(seconds: 5));
    
    print('✅ Success! Status: ${response.statusCode}');
    print('Response length: ${response.body.length}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Recipe name: ${data['drink_name']}');
    }
    
  } catch (e) {
    print('❌ Form-encoded failed: $e');
    
    // Try with different approach
    try {
      print('\n2. Testing with Map body (Flutter default)...');
      final response2 = await http.post(
        Uri.parse('$baseUrl/create'),
        body: {'drink_query': 'Martini'},
      ).timeout(Duration(seconds: 5));
      
      print('✅ Map body success! Status: ${response2.statusCode}');
    } catch (e2) {
      print('❌ Map body also failed: $e2');
      
      // Test if server is even reachable
      try {
        print('\n3. Testing basic TCP connection...');
        final socket = await Socket.connect('127.0.0.1', 8081)
            .timeout(Duration(seconds: 3));
        print('✅ TCP connection successful');
        await socket.close();
        
        print('\n4. Trying GET request to see if server responds...');
        final getResponse = await http.get(Uri.parse('$baseUrl/'))
            .timeout(Duration(seconds: 3));
        print('GET response status: ${getResponse.statusCode}');
        
      } catch (e3) {
        print('❌ Even basic connection failed: $e3');
      }
    }
  }
}